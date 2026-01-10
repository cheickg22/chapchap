import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/features/home/domain/models/diagnostic_otification_model.dart';
import 'package:restart_tagxi/features/home/domain/models/get_preferences_model.dart';
import 'package:restart_tagxi/features/home/domain/models/online_offline_model.dart';
import 'package:restart_tagxi/features/home/domain/models/price_per_distance_model.dart';
import 'package:restart_tagxi/features/home/domain/models/update_preference_model.dart';
import '../../../../core/network/network.dart';
import '../../../driverprofile/domain/models/vehicle_types_model.dart';
import '../../domain/repositories/home_repo.dart';

class HomeUsecase {
  final HomeRepository _homeRepository;

  const HomeUsecase(this._homeRepository);

  Future<Either<Failure, UserDetailResponseModel>> userDetails(
      {String? requestId}) async {
    return _homeRepository.getUserDetails(requestId: requestId);
  }

  Future<Either<Failure, OnlineOfflineResponseModel>> onlineOffline() async {
    return _homeRepository.onlineOffline();
  }

  Future<Either<Failure, PricePerDistanceModel>> updatePricePerDistance(
      {required String price}) async {
    return _homeRepository.updatePricePerDistance(price: price);
  }

  Future<Either<Failure, VehicleTypeModel>> getSubVehicleTypes(
      {required String serviceLocationId, required String vehicleType}) async {
    return _homeRepository.getSubVehicleTypes(
        serviceLocationId: serviceLocationId, vehicleType: vehicleType);
  }

  Future<Either<Failure, dynamic>> updateVehicleTypesApi(
      {required List subTypes}) async {
    return _homeRepository.updateVehicleTypesApi(subTypes: subTypes);
  }

  Future<Either<Failure, DiagnosticNotification>>
      getDiagnostiNotification() async {
    return _homeRepository.getDiagnostiNotification();
  }

  Future<Either<Failure, GetPreferencesModel>> getPreferencesDetails() async {
    return _homeRepository.getPreferencesDetails();
  }

  Future<Either<Failure, UpdatePreferencesModel>> updatePreferences(
      {required List id}) async {
    return _homeRepository.updatePreferences(id: id);
  }
}
