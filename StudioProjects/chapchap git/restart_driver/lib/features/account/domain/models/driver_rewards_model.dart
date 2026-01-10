import 'dart:convert';

DriverRewardsModel driverRewardsModelFromJson(String str) =>
    DriverRewardsModel.fromJson(json.decode(str));

String driverRewardsModelToJson(DriverRewardsModel data) =>
    json.encode(data.toJson());

class DriverRewardsModel {
  bool success;
  String message;
  List<DriverRewardsData> data;
  Meta meta;

  DriverRewardsModel({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory DriverRewardsModel.fromJson(Map<String, dynamic> json) =>
      DriverRewardsModel(
        success: json["success"],
        message: json["message"],
        data: List<DriverRewardsData>.from(
            json["data"].map((x) => DriverRewardsData.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta.toJson(),
      };
}

class DriverRewardsData {
  String? id;
  String? requestId;
  bool isCredit;
  double? amount;
  int rewardPoints;
  String? remarks;
  String? createdAt;

  DriverRewardsData({
    required this.id,
    required this.requestId,
    required this.isCredit,
    required this.amount,
    required this.rewardPoints,
    required this.remarks,
    required this.createdAt,
  });

  factory DriverRewardsData.fromJson(Map<String, dynamic> json) =>
      DriverRewardsData(
        id: json["id"] ?? "0",
        requestId: json["request_id"] ?? "",
        isCredit: json["is_credit"],
        amount: json["amount"].toDouble() ?? 0.0,
        rewardPoints: json["reward_points"] ?? 0,
        remarks: json["remarks"] ?? "",
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "request_id": requestId ?? "",
        "is_credit": isCredit,
        "amount": amount,
        "reward_points": rewardPoints,
        "remarks": remarks,
        "created_at": createdAt,
      };
}

class Meta {
  RewardsPagination pagination;

  Meta({
    required this.pagination,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        pagination: RewardsPagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination.toJson(),
      };
}

class RewardsPagination {
  int total;
  int count;
  int perPage;
  int currentPage;
  int totalPages;
  dynamic links;

  RewardsPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
    required this.links,
  });

  factory RewardsPagination.fromJson(Map<String, dynamic> json) =>
      RewardsPagination(
        total: json["total"],
        count: json["count"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        totalPages: json["total_pages"],
        links: json["links"] != {} ? Links.fromJson(json["links"]) : {},
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "count": count,
        "per_page": perPage,
        "current_page": currentPage,
        "total_pages": totalPages,
        "links": links.toJson(),
      };
}

class Links {
  String? next;

  Links({
    required this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        next: json["next"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "next": next,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
