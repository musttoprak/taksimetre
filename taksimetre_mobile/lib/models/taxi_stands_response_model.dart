class TaxiStandResponseModel {
  String name;
  double distance;
  double latitude;
  double longitude;

  TaxiStandResponseModel({required this.name, required this.distance, required this.latitude, required this.longitude});

  factory TaxiStandResponseModel.fromJson(Map<String, dynamic> json) {
    return TaxiStandResponseModel(
      name: json['name'],
      distance: json['distance'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}