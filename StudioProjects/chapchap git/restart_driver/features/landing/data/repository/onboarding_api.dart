import 'package:dio/dio.dart';

import '../../../../core/network/network.dart';

class OnBoardingApi {
  Future<dynamic> getOnboardingApi({required String type}) async {
    try {
      Response response = await DioProviderImpl().get((type == "driver")
          ? ApiEndpoints.onBoarding
          : ApiEndpoints.onBoardingOwner);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
