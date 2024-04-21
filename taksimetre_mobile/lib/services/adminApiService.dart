import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:location/location.dart';

import '../models/distance_matrix_response_model.dart';
import '../models/fee_table_response_model.dart';
import '../models/taxi_stands_response_model.dart';
import '../models/user_response_model.dart';
import 'apiUrl.dart';

class AdminApiService {
  static Future<List<UserResponseModel>> getUsers() async {
    Dio dio = Dio();
    print("$baseUrl/users");
    var result = await dio.get("$baseUrl/users");
    final List<dynamic> data = jsonDecode(result.data);
    return data.map((e) => UserResponseModel.fromJson(e)).toList();
  }

  static Future<List<UserResponseModel>> userChangeActive(
      String id, bool isActive) async {
    Dio dio = Dio();
    print("$baseUrl/userChangeActive?id=$id&isActive=$isActive");
    var result =
        await dio.get("$baseUrl/userChangeActive?id=$id&isActive=$isActive");
    final List<dynamic> data = jsonDecode(result.data);
    return data.map((e) => UserResponseModel.fromJson(e)).toList();
  }

  static Future<List<FeeTableResponseModel>> getFeeTableValues() async {
    Dio dio = Dio();
    print("$baseUrl/getFeeTableValues");
    var result = await dio.get("$baseUrl/getFeeTableValues");
    final List<dynamic> data = jsonDecode(result.data);
    return data.map((e) => FeeTableResponseModel.fromJson(e)).toList();
  }

  static Future<List<FeeTableResponseModel>> feeChangeValue(
      String id, double value) async {
    Dio dio = Dio();
    print("$baseUrl/feeChangeValue?id=$id&value=$value");
    var result = await dio.get("$baseUrl/feeChangeValue?id=$id&value=$value");
    final List<dynamic> data = jsonDecode(result.data);
    return data.map((e) => FeeTableResponseModel.fromJson(e)).toList();
  }

  static Future<List<DistanceMatrixResponseModel>> getAllRoutes() async {
    Dio dio = Dio();
    print("$baseUrl/getAllRoutes");
    var result = await dio.get("$baseUrl/getAllRoutes");

    List<dynamic> data = jsonDecode(result.data);
    return data.map((e) => DistanceMatrixResponseModel.fromJson(e)).toList();
  }

  static Future<List<TaxiStandResponseModel>> getAllTaxiStands(LocationData locationData) async {
    Dio dio = Dio();
    print("$baseUrl/getAllTaxiStands?latitude=${locationData.latitude}&longitude=${locationData.longitude}");
    var result = await dio.get("$baseUrl/getAllTaxiStands?latitude=${locationData.latitude}&longitude=${locationData.longitude}");
    final List<dynamic> parsedList = jsonDecode(result.data);
    return parsedList.map((e) => TaxiStandResponseModel.fromJson(e)).toList();
  }
}
