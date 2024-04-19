import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/distance_matrix_response_model.dart';
import '../models/route_response_model.dart';
import '../models/search_text_response_model.dart';
import '../models/taxi_stands_response_model.dart';
import 'apiUrl.dart';

class MapsApiService {
  static Future<DistanceMatrixResponseModel> checkPriceApi(
      LatLng firstPosition, LatLng secondPosition) async {
    Dio dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    var result = await dio.get("$baseUrl/api", queryParameters: {
      'origins': "${firstPosition.latitude},${firstPosition.longitude}",
      'destinations': "${secondPosition.latitude},${secondPosition.longitude}",
      'userId': userId
    });
    print(result.realUri);
    var data = jsonDecode(result.data);
    DistanceMatrixResponseModel responseModel =
        DistanceMatrixResponseModel.fromJson(data);
    return responseModel;
  }

  static Future<SearchTextResponseModel> searchTextLocation(
      String searchText) async {
    Dio dio = Dio();
    print("$baseUrl/text?query=${searchText.replaceAll(" ", "")}");
    var result =
        await dio.get("$baseUrl/text?query=${searchText.replaceAll(" ", "")}");
    var data = jsonDecode(result.data);
    return SearchTextResponseModel.fromJson(data);
  }

  static Future<List<TaxiStandResponseModel>> getCurrentLocationByNearTaxiStand(
      LocationData locationData) async {
    Dio dio = Dio();
    print(
        "$baseUrl/durak?latitude=${locationData.latitude}&longitude=${locationData.longitude}");
    var result = await dio.get(
        "$baseUrl/durak?latitude=${locationData.latitude}&longitude=${locationData.longitude}");
    final List<dynamic> parsedList = jsonDecode(result.data);
    return parsedList.map((e) => TaxiStandResponseModel.fromJson(e)).toList();
  }

  static Future<RouteResponseModel> getTaxiStandsRoute(
      LatLng currentLocation, LatLng standsLocation) async {
    Dio dio = Dio();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');

    print(
        "$baseUrl/route?origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${standsLocation.latitude},${standsLocation.longitude}&userId=$userId");
    var result = await dio.get(
        "$baseUrl/route?origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${standsLocation.latitude},${standsLocation.longitude}&userId=$userId");
    final parsedList = jsonDecode(result.data);
    return RouteResponseModel.fromJson(parsedList);
  }
}
