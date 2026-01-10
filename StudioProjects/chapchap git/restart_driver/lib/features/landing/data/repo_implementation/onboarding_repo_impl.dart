import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network.dart';
import '../../domain/models/onboarding_model.dart';
import '../../domain/repositories/onboarding_repo.dart';
import '../repository/onboarding_api.dart';

class OnBoardingRepositoryImpl implements OnBoardingRepository {
  final OnBoardingApi _onBoardingApi;

  OnBoardingRepositoryImpl(this._onBoardingApi);
  // OnBoardingData
  @override
  Future<Either<Failure, OnBoardingResponseModel>> getOnboarding(
      {required String type}) async {
    try {
      Response response = await _onBoardingApi.getOnboardingApi(type: type);

      // Vérifier le status code d'abord
      if (response.statusCode != 200) {
        return Left(GetDataFailure(
            message: 'Server error: ${response.statusCode}',
            statusCode: response.statusCode ?? 0));
      }

      // Vérifier si response.data est null ou vide
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'No data received from server'));
      }

      // Vérifier si response.data est un Map avant d'accéder aux propriétés
      if (response.data is! Map<String, dynamic>) {
        return Left(GetDataFailure(message: 'Invalid response format'));
      }

      final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      // Vérifier s'il y a une erreur dans la réponse
      if (responseData['error'] != null) {
        return Left(GetDataFailure(message: responseData['error'].toString()));
      }

      // Vérifier le status code dans les données
      if (response.statusCode == 400) {
        return Left(GetDataFailure(
            message: responseData["message"]?.toString() ?? 'Bad request',
            statusCode: response.statusCode!));
      }

      // Parser la réponse seulement si tout est OK
      final onBoardingResponseModel = OnBoardingResponseModel.fromJson(responseData);
      return Right(onBoardingResponseModel);

    } on DioException catch (e) {
      // Gérer spécifiquement les erreurs Dio (404, 500, etc.)
      String errorMessage = 'Network error';
      if (e.response != null) {
        errorMessage = 'Server error: ${e.response!.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout';
      }
      return Left(GetDataFailure(message: errorMessage));
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    } catch (e) {
      // Catch any other unexpected errors
      return Left(GetDataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
