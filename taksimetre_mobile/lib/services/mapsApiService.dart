import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../models/distance_matrix_response_model.dart';
import '../models/search_text_response_model.dart';
import '../models/taxi_stands_response_model.dart';

class MapsApiService {
  static const baseUrl = "http://192.168.195.1:6060";

  static Future<DistanceMatrixResponseModel> checkPriceApi(
      LatLng firstPosition, LatLng secondPosition) async {
    Dio dio = Dio();

    var result = await dio.get("$baseUrl/api", queryParameters: {
      'origins': "${firstPosition.latitude},${firstPosition.longitude}",
      'destinations': "${secondPosition.latitude},${secondPosition.longitude}"
    });

    var data = jsonDecode(result.data);
    DistanceMatrixResponseModel responseModel =
        DistanceMatrixResponseModel.fromJson(data);
    return responseModel;
  }

  static Future<SearchTextResponseModel> searchTextLocation(String searchText) async {
    Dio dio = Dio();
    print("$baseUrl/text?query=${searchText.replaceAll(" ", "")}");
    var result = await dio.get("$baseUrl/text?query=${searchText.replaceAll(" ", "")}");
    var data = jsonDecode(result.data);
    return SearchTextResponseModel.fromJson(data);
  }

  static Future<List<TaxiStandResponseModel>> getCurrentLocationByNearTaxiStand(LocationData locationData) async {
    Dio dio = Dio();
    print("$baseUrl/durak?latitude=${locationData.latitude}&longitude=${locationData.longitude}");
    var result = await dio.get("$baseUrl/durak?latitude=${locationData.latitude}&longitude=${locationData.longitude}");
    final List<dynamic> parsedList = jsonDecode(result.data);
    return parsedList.map((e) => TaxiStandResponseModel.fromJson(e)).toList();
  }
}
