// ignore_for_file: prefer_collection_literals, unnecessary_this

import 'dart:convert';

SubscriptionListModel subscriptionListModelFromJson(String str) =>
    SubscriptionListModel.fromJson(json.decode(str));

class SubscriptionListModel {
  bool? success;
  String? message;
  List<SubscriptionData>? data;

  SubscriptionListModel({this.success, this.message, this.data});

  SubscriptionListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <SubscriptionData>[];
      json['data'].forEach((v) {
        data!.add(SubscriptionData.fromJson(v));
      });
    }
  }
}

class SubscriptionData {
  int? id;
  String? name;
  String? description;
  int? duration;
  double? amount;
  String? vehicleTypeId;
  String? vehicleTypeName;

  SubscriptionData(
      {this.id,
      this.name,
      this.description,
      this.duration,
      this.amount,
      this.vehicleTypeId,
      this.vehicleTypeName});

  SubscriptionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    duration = json['duration'];
    amount = json['amount'].toDouble() ?? 0.0;
    vehicleTypeId = json['vehicle_type_id'];
    vehicleTypeName = json['vehicle_type_name'];
  }
}

SubscriptionSuccessModel subscriptionSuccessModelFromJson(String str) =>
    SubscriptionSuccessModel.fromJson(json.decode(str));

class SubscriptionSuccessModel {
  bool? success;
  String? message;
  SubscriptionSuccessData? data;

  SubscriptionSuccessModel({this.success, this.message, this.data});

  SubscriptionSuccessModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? SubscriptionSuccessData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class SubscriptionSuccessData {
  int? driverId;
  String? isSubscribed;

  SubscriptionSuccessData({this.driverId, this.isSubscribed});

  SubscriptionSuccessData.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'];
    isSubscribed = json['is_subscribed'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['driver_id'] = this.driverId;
    data['is_subscribed'] = this.isSubscribed;
    return data;
  }
}
