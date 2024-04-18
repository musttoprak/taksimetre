import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:taksimetre_mobile/services/mapsApiService.dart';

import '../models/distance_matrix_response_model.dart';
import '../models/search_text_response_model.dart';

class MapScreenCubit extends Cubit<MapScreenState> {
  GoogleMapController? mapController;
  bool isLoading = true;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCBWnZj5N6sGEpN-HzAPO5MZdSHspnDmZc";
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};
  bool isButtonActive = true;
  LocationData? currentLocation;
  bool isStackVisible = false;
  DistanceMatrixResponseModel? response;
  BuildContext context;
  AnimationController animationController;
  TextEditingController myLocationController;
  TextEditingController locationController;
  LatLng? myLocation;
  LatLng? location;
  SearchTextResponseModel? model;

  MapScreenCubit(this.context, this.animationController,this.myLocationController,this.locationController)
      : super(MapScreenInitialState()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.getLocation().then((value) {
      currentLocation = value;
      emit(MapScreenLocationState(currentLocation!));
      changeLoadingView();
    });
  }

  Future<void> changeVisible() async {
    if (isStackVisible) {
      animationController.reverse();
      await Future.delayed(const Duration(milliseconds: 500));
      isStackVisible = false;
    } else {
      isStackVisible = true;
      animationController.forward();
    }
    emit(MapScreenChangeVisibleState(isStackVisible));
  }

  void addMarker(LatLng position) {
    if (markers.length < 2) {
      markers.add(Marker(
        markerId: MarkerId('${position.latitude}-${position.longitude}'),
        position: position,
        onTap: () {
          removeMarker(MarkerId('${position.latitude}-${position.longitude}'));
        },
      ));
      changeButtonText(true);
    } else {
      changeButtonText(false);
    }
  }

  void removeMarker(MarkerId markerId) {
    markers.removeWhere((element) => element.markerId == markerId);
    polylines = {};
    emit(MapScreenRemoveMarkerState(polylines, markers));
  }

  void removeMarkerAll() {
    markers = {};
    polylines = {};
    emit(MapScreenRemoveMarkerState(polylines, markers));
  }

  Future<void> poly(bool isCurrentLocation) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result;
    if (isCurrentLocation) {
      result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(markers.elementAt(0).position.latitude,
            markers.elementAt(0).position.longitude),
        travelMode: TravelMode.driving,
      );
    } else {
      result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(markers.elementAt(0).position.latitude,
            markers.elementAt(0).position.longitude),
        PointLatLng(markers.elementAt(1).position.latitude,
            markers.elementAt(1).position.longitude),
        travelMode: TravelMode.driving,
      );
    }

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      changeButtonText(false);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }


  void _zoomToPolygon(LatLng firstMarkerPosition , LatLng secondMarkerPosition) {
    if (mapController != null) {
      LatLngBounds bounds = _calculateBounds(firstMarkerPosition,secondMarkerPosition);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  LatLngBounds _calculateBounds(LatLng firstMarkerPosition , LatLng secondMarkerPosition) {
    double minLat = min(firstMarkerPosition.latitude, secondMarkerPosition.latitude);
    double maxLat = max(firstMarkerPosition.latitude, secondMarkerPosition.latitude);
    double minLng = min(firstMarkerPosition.longitude, secondMarkerPosition.longitude);
    double maxLng = max(firstMarkerPosition.longitude, secondMarkerPosition.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    return bounds;
  }

  Future<void> onSubmitButtonPressed() async {
    print("tıklandı");
    if(isStackVisible){
      if(myLocation != null || location != null){
        removeMarkerAll();
        addMarker(myLocation!);
        addMarker(location!);
        await poly(false);
        response =  await MapsApiService.checkPriceApi(myLocation!, location!);
        isStackVisible = false;
        _zoomToPolygon(myLocation!,location!);
        emit(MapScreenChangeDataState(response!));
      }else{
        isButtonActive = false;
        emit(MapScreenActiveState(isButtonActive));
      }
    }else{
      if (markers.isNotEmpty) {
        LatLng? firstPosition;
        LatLng? secondPosition;
        if (markers.length == 1) {
          secondPosition = markers.first.position;
          firstPosition =
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
          await poly(true);
        } else {
          firstPosition = markers.first.position;
          secondPosition = markers.last.position;
          await poly(false);
        }

        response =  await MapsApiService.checkPriceApi(firstPosition, secondPosition);
        _zoomToPolygon(firstPosition,secondPosition);
        emit(MapScreenChangeDataState(response!));
      } else {
        changeButtonText(false);
      }
    }
  }

  Future<void> searchText(String text,bool isFirstForm) async {
    model = await MapsApiService.searchTextLocation(text);
    if(model?.formattedAddress == null){
      emit(MapScreenChangeSearchDataState(null));
    }else{
      model!.isFirstForm = isFirstForm;
      emit(MapScreenChangeSearchDataState(model));
    }
  }

  void completeSearch(){
    if(model!.isFirstForm){
      myLocationController.text = model!.formattedAddress!;
      myLocation = LatLng(model!.latitude!, model!.longitude!);
    }else{
      locationController.text = model!.formattedAddress!;
      location = LatLng(model!.latitude!, model!.longitude!);
    }
  }

  void clearSearch(){
    model = null;
    emit(MapScreenChangeSearchDataState(model));
  }

  void changeButtonText(bool isActive) {
    isButtonActive = isActive;
    emit(MapScreenActiveState(isButtonActive));
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    emit(MapScreenLoadingState(isLoading));
  }

  void mapsControllerInitalize(GoogleMapController mapController) {
    this.mapController = mapController;
  }
}

abstract class MapScreenState {}

class MapScreenInitialState extends MapScreenState {}

class MapScreenLoadingState extends MapScreenState {
  final bool isLoading;

  MapScreenLoadingState(this.isLoading);
}

class MapScreenActiveState extends MapScreenState {
  final bool isLoading;

  MapScreenActiveState(this.isLoading);
}

class MapScreenLocationState extends MapScreenState {
  final LocationData value;

  MapScreenLocationState(this.value);
}

class MapScreenChangeVisibleState extends MapScreenState {
  final bool isStackVisible;

  MapScreenChangeVisibleState(this.isStackVisible);
}

class MapScreenChangeDataState extends MapScreenState {
  final DistanceMatrixResponseModel data;

  MapScreenChangeDataState(this.data);
}

class MapScreenRemoveMarkerState extends MapScreenState {
  final Map<PolylineId, Polyline> polylines;
  final Set<Marker> markers;

  MapScreenRemoveMarkerState(this.polylines, this.markers);
}
class MapScreenChangeSearchDataState extends MapScreenState {
  final SearchTextResponseModel? data;

  MapScreenChangeSearchDataState(this.data);
}