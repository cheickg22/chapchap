import 'package:dio/dio.dart';

import '../../../../common/common.dart';
import '../../../../core/network/network.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';

class DriverProfileApi {
  //Get service Location
  Future getServiceLocation() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getServiceLocation,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

//Get Vehicle Type
  Future getVehicleType({required String id, required String type}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getVehicleTypes
            .toString()
            .replaceAll('service', id)
            .replaceAll('vehilceType', type),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

//Get Vehicle Make
  Future getVehicleMake(
      {required String type, required String iconType}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getVehicleMake
            .toString()
            .replaceAll('vehicleType', type)
            .replaceAll('iconFor', iconType),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

//Get Vehicle Model
  Future getVehicleModel({required String id}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getVehicleModel.toString().replaceAll('make', id),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

//Update Vehicle
  Future updateVehicle(
      {required String? serviceLocation,
      required String? customMake,
      required String? customModel,
      required String? carColor,
      required String? carNumber,
      required String? vehicleType,
      required String? vehicleYear,
      required String? transportType,
      required String? companyName,
      required String? companyCity,
      required String? companyAddress,
      required String? companyPostalCode,
      required String? companyTaxNumber,
      required String? from}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        (from == 'owner')
            ? ApiEndpoints.addVehicle
            : ApiEndpoints.updateVehicle,
        body: (userData!.role == 'driver' || from == 'owner')
            ? {
                if (from != 'owner') 'service_location_id': serviceLocation,
                if (from != 'owner') 'is_company_driver': false,
                'vehicle_type': vehicleType,
                'custom_make': customMake,
                'custom_model': customModel,
                'car_color': carColor,
                'car_number': carNumber,
                'vehicle_year': vehicleYear,
                if (from != 'owner') 'transport_type': transportType
              }
            : {
                'service_location_id': serviceLocation,
                "address": companyAddress,
                "postal_code": companyPostalCode,
                "city": companyCity,
                "tax_number": companyTaxNumber,
                "company_name": companyName,
                'transport_type': transportType
              },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

//Get Documents
  Future getDocuments({String? fleetId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (fleetId != null)
            ? ApiEndpoints.fleetDocumentNeeded
                .toString()
                .replaceAll('fleetId', fleetId)
            : ApiEndpoints.neededDocuments,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

//Upload Documents
  Future uploadDocuments(
      {required String id,
      required String? identifyNumber,
      required String? expiryDate,
      required String? fleetId,
      required String document,
      required String? documentBack}) async {
    try {
      final token = await AppSharedPreference.getToken();
      final formData = FormData.fromMap({
        if (identifyNumber != null && identifyNumber != '')
          'identify_number': identifyNumber,
        if (expiryDate != null && expiryDate != '') 'expiry_date': expiryDate,
        'document_id': id,
        if (fleetId != null) 'fleet_id': fleetId.toString()
      });
      formData.files
          .add(MapEntry('document', await MultipartFile.fromFile(document)));
      if (documentBack != null && documentBack.isNotEmpty) {
        formData.files.add(
            MapEntry('back_image', await MultipartFile.fromFile(documentBack)));
      }
      Response response = await DioProviderImpl().post(
        ApiEndpoints.uploadDocument,
        body: formData,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
