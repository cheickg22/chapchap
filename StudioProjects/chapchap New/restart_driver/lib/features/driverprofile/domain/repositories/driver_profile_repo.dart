import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/needed_documents_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/upload_document_model.dart';

import 'package:restart_tagxi/features/driverprofile/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_make_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_model_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_types_model.dart';
import 'package:restart_tagxi/features/driverprofile/domain/models/vehicle_update_model.dart';

import '../../../../core/network/network.dart';

abstract class DriverProfileRepository {
  Future<Either<Failure, ServiceLocationModel>> getServiceLocation();

  Future<Either<Failure, VehicleTypeModel>> getVehicleType(
      {required String id, required String type});

  Future<Either<Failure, VehicleMakeModel>> getVehicleMake(
      {required String type, required String iconType});

  Future<Either<Failure, VehicleModelModel>> getVehicleModel(
      {required String id});

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
  });

  Future<Either<Failure, NeededDocumentsModel>> getDocuments({String? fleetId});

  Future<Either<Failure, UploadDocumentModel>> uploadDocuments(
      {required String id,
      required String? identifyNumber,
      required String? expiryDate,
      required String? fleetId,
      required String document,
      required String documentBack});
}
