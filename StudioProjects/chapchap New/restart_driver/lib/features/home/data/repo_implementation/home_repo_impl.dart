import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/features/home/domain/models/diagnostic_otification_model.dart';
import 'package:restart_tagxi/features/home/domain/models/get_preferences_model.dart';
import 'package:restart_tagxi/features/home/domain/models/online_offline_model.dart';
import 'package:restart_tagxi/features/home/domain/models/price_per_distance_model.dart';
import 'package:restart_tagxi/features/home/domain/models/update_preference_model.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network.dart';
import '../../../driverprofile/domain/models/vehicle_types_model.dart';
import '../../domain/repositories/home_repo.dart';
import '../repository/home_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApi _homeApi;

  HomeRepositoryImpl(this._homeApi);
  // UserDetailData
  @override
  Future<Either<Failure, UserDetailResponseModel>> getUserDetails(
      {String? requestId}) async {
    UserDetailResponseModel userDetailsResponseModel;
    try {
      Response response =
          await _homeApi.getUserDetailsApi(requestId: requestId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(
            message: response.data['error'], statusCode: response.statusCode!));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode));
        } else {
          userDetailsResponseModel =
              UserDetailResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(userDetailsResponseModel);
  }

  @override
  Future<Either<Failure, OnlineOfflineResponseModel>> onlineOffline() async {
    OnlineOfflineResponseModel onlineOfflineData;
    try {
      Response response = await _homeApi.onlineOfflineApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          onlineOfflineData =
              OnlineOfflineResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(onlineOfflineData);
  }

  @override
  Future<Either<Failure, PricePerDistanceModel>> updatePricePerDistance(
      {required String price}) async {
    PricePerDistanceModel pricePerDistanceModel;
    try {
      Response response = await _homeApi.updatePricePerDistance(price: price);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          pricePerDistanceModel = PricePerDistanceModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(pricePerDistanceModel);
  }

  @override
  Future<Either<Failure, VehicleTypeModel>> getSubVehicleTypes(
      {required String serviceLocationId, required String vehicleType}) async {
    VehicleTypeModel vehicleTypesModelResponse;
    try {
      Response response = await _homeApi.getSubVehicleTypesApi(
          serviceLocationId: serviceLocationId, vehicleType: vehicleType);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          vehicleTypesModelResponse = VehicleTypeModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(vehicleTypesModelResponse);
  }

  @override
  Future<Either<Failure, dynamic>> updateVehicleTypesApi(
      {required List subTypes}) async {
    dynamic updateVehicleTypesResponse;
    try {
      Response response =
          await _homeApi.updateVehicleTypesApi(subTypes: subTypes);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          updateVehicleTypesResponse = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(updateVehicleTypesResponse);
  }

  @override
  Future<Either<Failure, DiagnosticNotification>>
      getDiagnostiNotification() async {
    DiagnosticNotification diagnosticNotification;
    try {
      Response response = await _homeApi.getDiagnostiNotification();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          diagnosticNotification =
              DiagnosticNotification.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(diagnosticNotification);
  }

  @override
  Future<Either<Failure, GetPreferencesModel>> getPreferencesDetails() async {
    GetPreferencesModel getPreferencesDetailsResponseModel;
    try {
      Response response = await _homeApi.getPreferencesDetailsApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(
            message: response.data['error'], statusCode: response.statusCode!));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode));
        } else {
          getPreferencesDetailsResponseModel =
              GetPreferencesModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(getPreferencesDetailsResponseModel);
  }

  @override
  Future<Either<Failure, UpdatePreferencesModel>> updatePreferences(
      {required List id}) async {
    UpdatePreferencesModel updatePreferencesResponse;
    try {
      Response response = await _homeApi.updatePreferences(id: id);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          // updatePreferencesResponse = response.data;
          updatePreferencesResponse =
              UpdatePreferencesModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(updatePreferencesResponse);
  }
}
