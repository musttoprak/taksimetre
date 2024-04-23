import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:taksimetre_mobile/models/taxi_stands_response_model.dart';
import 'package:taksimetre_mobile/services/adminApiService.dart';
import 'package:taksimetre_mobile/services/mapsApiService.dart';

import '../constants/app_colors.dart';
import '../models/distance_matrix_response_model.dart';
import '../models/route_response_model.dart';
import '../models/search_text_response_model.dart';
import '../services/routeApiService.dart';

class MapScreenCubit extends Cubit<MapScreenState> {
  GoogleMapController? mapController;
  DistanceMatrixResponseModel? distanceMatrixResponseModel;
  bool isAdmin;
  bool isLoading = true;
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCBWnZj5N6sGEpN-HzAPO5MZdSHspnDmZc";
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> allMarkers = {};
  Set<Marker> markers = {};
  Set<Marker> taxiStandsMarker = {};
  bool isButtonActive = true;
  LocationData? currentLocation;
  bool isStackVisible = false;
  bool isTaxiInfoVisible = false;
  DistanceMatrixResponseModel? response;
  BuildContext context;
  AnimationController animationController;
  TextEditingController myLocationController;
  TextEditingController locationController;
  LatLng? myLocation;
  LatLng? location;
  SearchTextResponseModel? model;
  List<TaxiStandResponseModel> listStands = [];
  RouteResponseModel? routeResponseModel;

  MapScreenCubit(this.context,this.distanceMatrixResponseModel ,this.isAdmin,this.animationController,
      this.myLocationController, this.locationController)
      : super(MapScreenInitialState()) {
    getCurrentLocation();
  }

  void clearResult() {
    response = null;
    routeResponseModel = null;
    removeMarkerAll();
    clearSearch();
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

    location.getLocation().then((value) async {
      currentLocation = value;
      if (currentLocation != null) {
        if(isAdmin){
          listStands = await AdminApiService.getAllTaxiStands(
              currentLocation!);
        }else{
          listStands = await MapsApiService.getCurrentLocationByNearTaxiStand(
              currentLocation!);
        }
        addTaxiStands();
      }
      emit(MapScreenLocationState(currentLocation!));
      changeLoadingView();
      if(distanceMatrixResponseModel != null){
        showRoute();
      }
    });
  }


  Future<void> showRoute() async {
    removeMarkerAll();
    addMarker(distanceMatrixResponseModel!.destinations);
    addMarker(distanceMatrixResponseModel!.origins);
    await poly(false);
    response = distanceMatrixResponseModel;
    isStackVisible = false;
    _zoomToPolygon(distanceMatrixResponseModel!.destinations, distanceMatrixResponseModel!.origins);
    emit(MapScreenChangeDataState(response!));
  }

  Future<BitmapDescriptor> getCustomMarkerIcon(String imagePath) async {
    final ByteData byteData = await rootBundle.load(imagePath);
    final Uint8List imageData = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(imageData);
  }


  void addTaxiStands() async {
    for (var e in listStands) {
      final icon = await getCustomMarkerIcon('assets/taxi_icon.png');

      taxiStandsMarker.add(Marker(
          markerId: MarkerId('${e.latitude}-${e.longitude}'),
          position: LatLng(e.latitude, e.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: e.name,
            snippet:
                "${e.distance.toStringAsFixed(2)} km - Yol tarifi için tıkla",
            onTap: () async {
              await getTaxiStandsRoute(e);
              walkTaxiStandsRoutes();
              await polyWalk(LatLng(e.latitude, e.longitude));
              _zoomToPolygon(LatLng(currentLocation!.latitude!, currentLocation!.longitude!), LatLng(e.latitude, e.longitude));
              mapController!.hideMarkerInfoWindow(
                  MarkerId('${e.latitude}-${e.longitude}'));
              emit(MapScreenAddTaxiPolyState(polylines));
            },
          )));
    }
    allMarkers.addAll(taxiStandsMarker);
    emit(MapScreenAddTaxiStandsState(allMarkers));
  }

  void walkTaxiStandsRoutes() {
    removeMarkerAll();
    isStackVisible = false;
    isTaxiInfoVisible = true;
  }

  Future<RouteResponseModel?> getTaxiStandsRoute(
      TaxiStandResponseModel e) async {
    await MapsApiService.getTaxiStandsRoute(
            LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            LatLng(e.latitude, e.longitude))
        .then((value) {
      routeResponseModel = value;
    });
    return null;
  }

  Future<void> changeVisible() async {
    if (isStackVisible) {
      animationController.reverse();
      await Future.delayed(const Duration(milliseconds: 500));
      isStackVisible = false;
    } else {
      removeMarkerAll();
      isStackVisible = true;
      animationController.forward();
    }
    emit(MapScreenChangeVisibleState(isStackVisible));
  }

  void addMarker(LatLng position) {
    if (markers.length < 2) {
      Marker marker = Marker(
        markerId: MarkerId('${position.latitude}-${position.longitude}'),
        position: position,
        onTap: () {
          removeMarker(MarkerId('${position.latitude}-${position.longitude}'));
        },
      );
      markers.add(marker);
      allMarkers.add(marker);
      changeButtonText(true);
    } else {
      changeButtonText(false);
    }
  }

  void removeMarker(MarkerId markerId) {
    markers.removeWhere((element) => element.markerId == markerId);
    allMarkers.removeWhere((element) => element.markerId == markerId);
    polylines = {};
    emit(MapScreenRemoveMarkerState(polylines, markers));
  }

  void removeMarkerAll() {
    allMarkers.removeAll(markers);
    markers = {};
    polylines = {};
    emit(MapScreenRemoveMarkerState(polylines, markers));
  }

  Future<void> polyWalk(LatLng e) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(e.latitude, e.longitude),
      travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      changeButtonText(false);
    }
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppColors.headerTextColor,
      points: polylineCoordinates,
      jointType: JointType.round,
      patterns: [PatternItem.dot, PatternItem.gap(10)],
      width: 8,
    );
    polylines[id] = polyline;
    return;
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
      color: AppColors.headerTextColor,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }

  //void _zoomToPolygon(LatLng firstMarkerPosition, LatLng secondMarkerPosition) {
  //  if (mapController != null) {
  //    LatLngBounds bounds =
  //        _calculateBounds(firstMarkerPosition, secondMarkerPosition);
  //    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  //  }
  //}      

  void _zoomToPolygon(LatLng firstMarkerPosition, LatLng secondMarkerPosition) {
    if (mapController != null) {
      List<LatLng> points = [];
      polylines.forEach((key, value) {
        points.addAll(value.points);
      });
      LatLngBounds bounds = _calculateBoundsWithPolygon(points);
      // Yeni bir LatLngBounds oluştururken, üst kısmına 400 piksel ekleyelim
      double topPadding = 100.0;
      LatLngBounds paddedBounds = LatLngBounds(
        southwest: LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
        northeast: LatLng(bounds.northeast.latitude + (topPadding / 111000), bounds.northeast.longitude),
      );

      mapController!.animateCamera(CameraUpdate.newLatLngBounds(paddedBounds, 10));
    }
  }

  LatLngBounds _calculateBoundsWithPolygon(List<LatLng> polygonPoints) {
    double minLat = polygonPoints[0].latitude;
    double maxLat = polygonPoints[0].latitude;
    double minLng = polygonPoints[0].longitude;
    double maxLng = polygonPoints[0].longitude;

    for (int i = 1; i < polygonPoints.length; i++) {
      if (polygonPoints[i].latitude > maxLat) {
        maxLat = polygonPoints[i].latitude;
      } else if (polygonPoints[i].latitude < minLat) {
        minLat = polygonPoints[i].latitude;
      }
      if (polygonPoints[i].longitude > maxLng) {
        maxLng = polygonPoints[i].longitude;
      } else if (polygonPoints[i].longitude < minLng) {
        minLng = polygonPoints[i].longitude;
      }
    }

    return LatLngBounds(northeast: LatLng(maxLat, maxLng), southwest: LatLng(minLat, minLng));
  }


  LatLngBounds _calculateBounds(
      LatLng firstMarkerPosition, LatLng secondMarkerPosition) {
    double minLat =
        min(firstMarkerPosition.latitude, secondMarkerPosition.latitude);
    double maxLat =
        max(firstMarkerPosition.latitude, secondMarkerPosition.latitude);
    double minLng =
        min(firstMarkerPosition.longitude, secondMarkerPosition.longitude);
    double maxLng =
        max(firstMarkerPosition.longitude, secondMarkerPosition.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    return bounds;
  }

  Future<void> onSubmitButtonPressed() async {
    if (isStackVisible) {
      if (myLocation != null || location != null) {
        removeMarkerAll();
        addMarker(myLocation!);
        addMarker(location!);
        await poly(false);
        response = await MapsApiService.checkPriceApi(myLocation!, location!);
        isStackVisible = false;
        _zoomToPolygon(myLocation!, location!);
        emit(MapScreenChangeDataState(response!));
      } else {
        isButtonActive = false;
        emit(MapScreenActiveState(isButtonActive));
      }
    } else {
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

        response =
            await MapsApiService.checkPriceApi(firstPosition, secondPosition);
        _zoomToPolygon(firstPosition, secondPosition);
        emit(MapScreenChangeDataState(response!));
      } else {
        changeButtonText(false);
      }
    }
  }

  Future<void> searchText(String text, bool isFirstForm) async {
    model = await MapsApiService.searchTextLocation(text);
    if (model?.formattedAddress == null) {
      emit(MapScreenChangeSearchDataState(null));
    } else {
      model!.isFirstForm = isFirstForm;
      emit(MapScreenChangeSearchDataState(model));
    }
  }

  void completeSearch() {
    if (model!.isFirstForm) {
      myLocationController.text = model!.formattedAddress!;
      myLocation = LatLng(model!.latitude!, model!.longitude!);
    } else {
      locationController.text = model!.formattedAddress!;
      location = LatLng(model!.latitude!, model!.longitude!);
    }
  }

  void clearSearch() {
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

class MapScreenAddTaxiStandsState extends MapScreenState {
  final Set<Marker> allMarkers;

  MapScreenAddTaxiStandsState(this.allMarkers);
}

class MapScreenAddTaxiPolyState extends MapScreenState {
  final Map<PolylineId, Polyline> poly;

  MapScreenAddTaxiPolyState(this.poly);
}
