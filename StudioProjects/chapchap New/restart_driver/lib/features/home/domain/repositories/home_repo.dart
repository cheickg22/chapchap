import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/features/home/domain/models/diagnostic_otification_model.dart';
import 'package:restart_tagxi/features/home/domain/models/get_preferences_model.dart';
import 'package:restart_tagxi/features/home/domain/models/online_offline_model.dart';
import 'package:restart_tagxi/features/home/domain/models/price_per_distance_model.dart';
import 'package:restart_tagxi/features/home/domain/models/update_preference_model.dart';

import '../../../../core/network/network.dart';
import '../../../driverprofile/domain/models/vehicle_types_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, UserDetailResponseModel>> getUserDetails(
      {String? requestId});
  Future<Either<Failure, OnlineOfflineResponseModel>> onlineOffline();
  Future<Either<Failure, PricePerDistanceModel>> updatePricePerDistance(
      {required String price});
  Future<Either<Failure, VehicleTypeModel>> getSubVehicleTypes(
      {required String serviceLocationId, required String vehicleType});
  Future<Either<Failure, dynamic>> updateVehicleTypesApi(
      {required List subTypes});
  Future<Either<Failure, DiagnosticNotification>> getDiagnostiNotification();
  Future<Either<Failure, GetPreferencesModel>> getPreferencesDetails();
  Future<Either<Failure, UpdatePreferencesModel>> updatePreferences(
      {required List id});
}
