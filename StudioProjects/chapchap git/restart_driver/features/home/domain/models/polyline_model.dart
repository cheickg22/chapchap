class PolylineModel {
  bool success;
  String polyString;
  String distance;
  String duration;
  List<dynamic> polyList;

  PolylineModel({
    required this.success,
    required this.polyString,
    required this.distance,
    required this.duration,
    required this.polyList,
  });

  factory PolylineModel.fromJson(Map<String, dynamic> json) {
    return PolylineModel(
      success: json["success"],
      polyString: json["polyString"],
      distance: json['distance'],
      duration: json['duration'],
      polyList: json['polyList'],
    );
  }
}
