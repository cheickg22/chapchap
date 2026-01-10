import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/core/network/network.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/needed_documents_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/upload_document_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_make_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_model_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_types_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_update_model.dart';

import '../../domain/repositories/driver_profile_repo.dart';

class DriverProfileUsecase {
  final DriverProfileRepository _driverProfileRepository;

  const DriverProfileUsecase(this._driverProfileRepository);

  Future<Either<Failure, ServiceLocationModel>> getServiceLocation() async {
    return _driverProfileRepository.getServiceLocation();
  }

  Future<Either<Failure, VehicleTypeModel>> getVehicleType(
      {required String id, required String type}) async {
    return _driverProfileRepository.getVehicleType(id: id, type: type);
  }

  Future<Either<Failure, NeededDocumentsModel>> getDocuments(
      {String? fleetId}) async {
    return _driverProfileRepository.getDocuments(fleetId: fleetId);
  }

  Future<Either<Failure, UploadDocumentModel>> uploadDocuments(
      {required String id,
      required String? identifyNumber,
      required String? expiryDate,
      required String? fleetId,
      required String document,
      required String? documentBack}) async {
    return _driverProfileRepository.uploadDocuments(
        id: id,
        identifyNumber: identifyNumber,
        expiryDate: expiryDate,
        fleetId: fleetId,
        document: document,
        documentBack: documentBack!);
  }

  Future<Either<Failure, VehicleMakeModel>> getVehicleMake(
      {required String type, required String iconType}) async {
    return _driverProfileRepository.getVehicleMake(
        type: type, iconType: iconType);
  }

  Future<Either<Failure, VehicleModelModel>> getVehicleModel({
    required String id,
  }) async {
    return _driverProfileRepository.getVehicleModel(id: id);
  }

  Future<Either<Failure, VehicleUpdateModel>> updateVehicle(
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
    return _driverProfileRepository.updateVehicle(
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
        companyPostalCode: companyPostalCode,
        companyTaxNumber: companyTaxNumber,
        from: from);
  }
}
