import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/needed_documents_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/upload_document_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_make_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_model_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_types_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_update_model.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network.dart';
import '../../domain/repositories/driver_profile_repo.dart';
import '../repository/driver_profile_api.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  final DriverProfileApi _driverProfileApi;

  DriverProfileRepositoryImpl(this._driverProfileApi);

  // UserDetailData
  @override
  Future<Either<Failure, ServiceLocationModel>> getServiceLocation() async {
    ServiceLocationModel serviceLocationModel;
    try {
      Response response = await _driverProfileApi.getServiceLocation();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          serviceLocationModel = ServiceLocationModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(serviceLocationModel);
  }

  @override
  Future<Either<Failure, VehicleTypeModel>> getVehicleType(
      {required String id, required String type}) async {
    VehicleTypeModel vehicleTypeModel;
    try {
      Response response =
          await _driverProfileApi.getVehicleType(id: id, type: type);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          vehicleTypeModel = VehicleTypeModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(vehicleTypeModel);
  }

  @override
  Future<Either<Failure, VehicleMakeModel>> getVehicleMake(
      {required String type, required String iconType}) async {
    VehicleMakeModel vehicleMakeModel;
    try {
      Response response = await _driverProfileApi.getVehicleMake(
          type: type, iconType: iconType);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          vehicleMakeModel = VehicleMakeModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(vehicleMakeModel);
  }

  @override
  Future<Either<Failure, VehicleModelModel>> getVehicleModel({
    required String id,
  }) async {
    VehicleModelModel vehicleModelModel;
    try {
      Response response = await _driverProfileApi.getVehicleModel(
        id: id,
      );
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          vehicleModelModel = VehicleModelModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(vehicleModelModel);
  }

  @override
  Future<Either<Failure, VehicleUpdateModel>> updateVehicle({
    required String? serviceLocation,
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
    required String? from,
  }) async {
    VehicleUpdateModel vehicleUpdateModel;
    try {
      Response response = await _driverProfileApi.updateVehicle(
          serviceLocation: serviceLocation,
          customMake: customMake,
          customModel: customModel,
          carColor: carColor,
          carNumber: carNumber,
          vehicleType: vehicleType,
          transportType: transportType,
          vehicleYear: vehicleYear,
          companyName: companyName,
          companyCity: companyCity,
          companyAddress: companyAddress,
          companyTaxNumber: companyTaxNumber,
          companyPostalCode: companyPostalCode,
          from: from);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          printWrapped(response.data.toString());
          vehicleUpdateModel = VehicleUpdateModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(vehicleUpdateModel);
  }

  @override
  Future<Either<Failure, NeededDocumentsModel>> getDocuments(
      {String? fleetId}) async {
    NeededDocumentsModel neededDocumentsModel;
    try {
      Response response =
          await _driverProfileApi.getDocuments(fleetId: fleetId);
      printWrapped(response.data.toString());
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          neededDocumentsModel = NeededDocumentsModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(neededDocumentsModel);
  }

  @override
  Future<Either<Failure, UploadDocumentModel>> uploadDocuments(
      {required String id,
      required String? identifyNumber,
      required String? expiryDate,
      required String? fleetId,
      required String document,
      required String documentBack}) async {
    UploadDocumentModel uploadDocumentModel;
    try {
      Response response = await _driverProfileApi.uploadDocuments(
          id: id,
          identifyNumber: identifyNumber,
          expiryDate: expiryDate,
          fleetId: fleetId,
          document: document,
          documentBack: documentBack);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          printWrapped(
              "Dcoument Upload Response=============> ${response.data.toString()}");
          uploadDocumentModel = UploadDocumentModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(uploadDocumentModel);
  }
}
