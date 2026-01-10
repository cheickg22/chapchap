class GoodsTypeModel {
  bool success;
  List<GoodsData> goods;
  GoodsTypeModel({required this.success, required this.goods});

  factory GoodsTypeModel.fromJson(Map<String, dynamic> json) {
    List<GoodsData> data = [];
    json['data'].forEach((e) {
      data.add(GoodsData.fromJson(e));
    });
    return GoodsTypeModel(
      success: json["success"],
      goods: data,
    );
  }
}

class GoodsData {
  String id;
  String name;
  GoodsData({required this.id, required this.name});

  factory GoodsData.fromJson(Map<String, dynamic> json) {
    return GoodsData(id: json['id'].toString(), name: json['goods_type_name']);
  }
}
