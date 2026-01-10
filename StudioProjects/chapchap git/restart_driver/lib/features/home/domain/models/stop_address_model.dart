import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressList {
  String address;
  LatLng latlng;
  String id;
  String? type;
  String? name;
  String? number;
  String? instructions;
  bool pickup;

  AddressList({
    required this.id,
    required this.address,
    required this.latlng,
    required this.pickup,
    this.type,
    this.name,
    this.number,
    this.instructions,
  });
}
