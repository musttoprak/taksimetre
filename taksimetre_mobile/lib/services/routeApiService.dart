import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/distance_matrix_response_model.dart';
import 'apiUrl.dart';

class RouteApiService {
  static Future<List<DistanceMatrixResponseModel>?> getRoutes() async {
    Dio dio = Dio();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    print("$baseUrl/getRoutes?userId=$userId");
    var result = await dio
        .get("$baseUrl/getRoutes", queryParameters: {'userId': userId});

    List<dynamic> data = jsonDecode(result.data);
    return data.map((e) => DistanceMatrixResponseModel.fromJson(e)).toList();
  }

  static Future<void> changeRatingRoute(
      int id, int rating) async {
    Dio dio = Dio();
    print("$baseUrl/changeRatingRoute?id=$id&rating=$rating");
    await dio.get("$baseUrl/changeRatingRoute",
        queryParameters: {'id': id, 'rating': rating});
    return;
  }
}
