class DistanceMatrixResponseModel {
  final List<String> destinationAddresses;
  final List<String> originAddresses;
  final List<DistanceRow> rows;
  final String status;

  DistanceMatrixResponseModel({
    required this.destinationAddresses,
    required this.originAddresses,
    required this.rows,
    required this.status,
  });

  factory DistanceMatrixResponseModel.fromJson(Map<String, dynamic> json) {
    return DistanceMatrixResponseModel(
      destinationAddresses: List<String>.from(json['destination_addresses']),
      originAddresses: List<String>.from(json['origin_addresses']),
      rows: List<DistanceRow>.from(json['rows'].map((row) => DistanceRow.fromJson(row))),
      status: json['status'],
    );
  }
}

class DistanceRow {
  final List<DistanceElement> elements;

  DistanceRow({
    required this.elements,
  });

  factory DistanceRow.fromJson(Map<String, dynamic> json) {
    return DistanceRow(
      elements: List<DistanceElement>.from(json['elements'].map((element) => DistanceElement.fromJson(element))),
    );
  }
}

class DistanceElement {
  final DistanceModel distance;
  final DistanceDuration duration;
  final String status;

  DistanceElement({
    required this.distance,
    required this.duration,
    required this.status,
  });

  factory DistanceElement.fromJson(Map<String, dynamic> json) {
    return DistanceElement(
      distance: DistanceModel.fromJson(json['distance']),
      duration: DistanceDuration.fromJson(json['duration']),
      status: json['status'],
    );
  }
}

class DistanceModel {
  final String text;
  final int value;

  DistanceModel({
    required this.text,
    required this.value,
  });

  factory DistanceModel.fromJson(Map<String, dynamic> json) {
    return DistanceModel(
      text: json['text'],
      value: json['value'],
    );
  }
}

class DistanceDuration {
  final String text;
  final int value;

  DistanceDuration({
    required this.text,
    required this.value,
  });

  factory DistanceDuration.fromJson(Map<String, dynamic> json) {
    return DistanceDuration(
      text: json['text'],
      value: json['value'],
    );
  }
}
