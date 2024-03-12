import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../models/distance_matrix_response_model.dart';

class MapScreenCubit extends Cubit<MapScreenState> {
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

  MapScreenCubit(this.context, this.animationController)
      : super(MapScreenInitialState()){
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
    emit(MapScreenRemoveMarkerState(polylines,markers));
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

  Future<void> onSubmitButtonPressed() async {
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

      await checkPriceApi(firstPosition, secondPosition);
      emit(MapScreenChangeDataState(response!));
    } else {
      changeButtonText(false);
    }
  }

  Future<void> checkPriceApi(
      LatLng firstPosition, LatLng secondPosition) async {
    Dio dio = Dio();
    var result = await dio.get("http://10.3.12.202:6060/api", queryParameters: {
      'destinations': "${firstPosition.latitude},${firstPosition.longitude}",
      'origins': "${secondPosition.latitude},${secondPosition.longitude}"
    });
    var data = jsonDecode(result.data);
    DistanceMatrixResponseModel responseModel =
        DistanceMatrixResponseModel.fromJson(data);
    response = responseModel;
  }

  void changeButtonText(bool isActive) {
    isButtonActive = isActive;
    emit(MapScreenActiveState(isButtonActive));
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    print(isLoading);
    emit(MapScreenLoadingState(isLoading));
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

