import 'package:equatable/equatable.dart';

class MoovMoneyAgentModel extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final double distance;
  final String openingHours;
  final bool isOpen;

  const MoovMoneyAgentModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.openingHours,
    required this.isOpen,
  });

  factory MoovMoneyAgentModel.fromJson(Map<String, dynamic> json) {
    return MoovMoneyAgentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      openingHours: json['opening_hours'] as String,
      isOpen: json['is_open'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'opening_hours': openingHours,
      'is_open': isOpen,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        distance,
      ];
}
