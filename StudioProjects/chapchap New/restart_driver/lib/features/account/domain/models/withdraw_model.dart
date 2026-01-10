class WithdrawModel {
  bool success;
  List data;
  Pagination? pagination;
  String walletBalance;

  WithdrawModel(
      {required this.success,
      required this.data,
      required this.pagination,
      required this.walletBalance});

  factory WithdrawModel.fromJson(Map<String, dynamic> json) => WithdrawModel(
      success: json["success"],
      data: json["withdrawal_history"]['data'],
      pagination:
          Pagination.fromJson(json["withdrawal_history"]['meta']['pagination']),
      walletBalance: json['wallet_balance'].toString());
}

class Pagination {
  int total;
  int count;
  int perPage;
  int currentPage;
  int totalPages;
  dynamic links;

  Pagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
    required this.links,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"] ?? 0,
        count: json["count"] ?? 0,
        perPage: json["per_page"] ?? 0,
        currentPage: json["current_page"] ?? 0,
        totalPages: json["total_pages"] ?? 0,
        links: (json["links"] != null) ? Links.fromJson(json["links"]) : null,
      );
}

class Links {
  String next;

  Links({
    required this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        next: json["next"] ?? '',
      );
}
