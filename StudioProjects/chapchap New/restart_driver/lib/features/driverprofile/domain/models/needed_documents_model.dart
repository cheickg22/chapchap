class NeededDocumentsModel {
  bool success;
  List<NeededDocumentsData> data;
  bool enableSubmitButton;
  NeededDocumentsModel(
      {required this.success,
      required this.data,
      required this.enableSubmitButton});

  factory NeededDocumentsModel.fromJson(Map<String, dynamic> json) {
    List<NeededDocumentsData> data = [];
    json['data'].forEach((e) {
      data.add(NeededDocumentsData.fromJson(e));
    });
    return NeededDocumentsModel(
        success: json["success"],
        data: data,
        enableSubmitButton: json['enable_submit_button']);
  }
}

class NeededDocumentsData {
  String id;
  String name;
  String docType;
  bool hasIdNumer;
  bool hasExpiryDate;
  String? idKey;
  bool isUploaded;
  bool isEditable;
  String documentStatus;
  bool isFrontAndBack;
  String? statusString;
  Map? document;
  bool isRequired;
  // Map? fleetDocument;
  // DateTime expiryDate;
  NeededDocumentsData({
    required this.id,
    required this.name,
    required this.docType,
    required this.hasIdNumer,
    required this.hasExpiryDate,
    required this.idKey,
    required this.isUploaded,
    required this.isEditable,
    required this.documentStatus,
    required this.isFrontAndBack,
    required this.statusString,
    required this.document,
    required this.isRequired,
    // required this.fleetDocument,
    // required this.expiryDate,
  });

  factory NeededDocumentsData.fromJson(Map<String, dynamic> json) {
    return NeededDocumentsData(
      id: json['id'].toString(),
      name: json['name'],
      docType: json['doc_type'],
      hasIdNumer: json['has_identify_number'] ?? false,
      hasExpiryDate: json['has_expiry_date'] ?? false,
      idKey: json['identify_number_locale_key'],
      isUploaded: json['is_uploaded'] ?? false,
      isEditable: json['is_editable'] ?? false,
      documentStatus: json['document_status'].toString(),
      isFrontAndBack: json['is_front_and_back'] ?? false,
      statusString: json['document_status_string'],
      document: json['driver_document'],
      isRequired: json['is_required'] ?? false,
      // fleetDocument: json['fleet_document']
    );
    // expiryDate: json['expiry_date']);
  }
}
