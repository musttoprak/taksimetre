import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceMatrixResponseModel {
  final int routeId;
  final int duration;
  final double price;
  final String destinationAddresses;
  final String originAddresses;
  final LatLng destinations;
  final LatLng origins;
  final int starRating;

  DistanceMatrixResponseModel(
      {required this.routeId,
      required this.duration,
      required this.price,
      required this.destinationAddresses,
      required this.originAddresses,
      required this.destinations,
      required this.origins,
      required this.starRating});

  factory DistanceMatrixResponseModel.fromJson(Map<String, dynamic> json) {
    return DistanceMatrixResponseModel(
        routeId: json['routeId'],
        duration: json['duration'],
        price: double.parse(json['price'].toString()),
        destinationAddresses: json['destinationAddresses'],
        originAddresses: json['originAddresses'],
        destinations: LatLng(double.parse(json['destinations'].toString().split(",")[0]),double.parse(json['destinations'].toString().split(",")[1])),
        origins: LatLng(double.parse(json['origins'].toString().split(",")[0]),double.parse(json['origins'].toString().split(",")[1])),
        starRating: json['starRating']);
  }
}
