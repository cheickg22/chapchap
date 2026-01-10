import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import '../../../../common/local_data.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../../../core/network/endpoints.dart';

class AccApi {
  //get history
  Future getHistoryApi(String historyFilter, {String? pageNo}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (pageNo != null && pageNo != 'null' && pageNo.isNotEmpty)
            ? '${ApiEndpoints.history}?$historyFilter&page=$pageNo'
            : '${ApiEndpoints.history}?$historyFilter',
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Outstation
  Future readyToPickup({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.readyToPickup,
        body: {'request_id': requestId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //add driver
  Future addDriverApi({
    required String name,
    required String email,
    required String mobile,
    required String address,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.addDrivers,
        body: {
          'name': name,
          'email': email,
          'mobile': mobile,
          'address': address,
          'transport_type': userData!.transportType
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future getDriverApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getDrivers,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped('text get drivers api ${response.data}');
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future deleteDriverApi({required String driverId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.deleteDriver
            .toString()
            .replaceAll('driverId', driverId.toString()),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getReportSection(
      {required String fromDate, required String toDate}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.reportApi
            .toString()
            .replaceAll('fromDate', fromDate)
            .replaceAll('toDate', toDate),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //get driver
  Future getVehiclesApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getVehicles,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get driver
  Future assignDriverApi(
      {required String fleetId, required String driverId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.assignDriver.toString().replaceAll('fleetId', fleetId),
        body: {'driver_id': driverId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //logout
  Future logoutApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.logout,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //delete account
  Future deleteAccountApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.deleteAccount,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//delete notification
  Future deleteNotification(String id) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.deleteNotification}/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //clearAll notification
  Future clearAllNotification() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.clearAllNotification,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped(response.data.toString());
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // get Earnings
  Future getEarnings() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getEarnings,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //delete notification
  Future getDailyEarnings(final String date) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.getDailyEarnings,
        body: {'date': date},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //make complaint confirm button
  Future makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.makeComplaintButton,
        headers: {'Authorization': token},
        body: (requestId.isEmpty)
            ? jsonEncode({
                'complaint_title_id': complaintTitleId,
                'description': complaintText,
              })
            : jsonEncode({
                'complaint_title_id': complaintTitleId,
                'description': complaintText,
                'request_id': requestId,
              }),
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get notifications
  Future getNotificationsApi({String? pageNo}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (pageNo != null)
            ? '${ApiEndpoints.notification}?page=$pageNo'
            : ApiEndpoints.notification,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Make Complaints
  Future makeComplaintsApi({String? complaintType}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (complaintType == 'general')
            ? '${ApiEndpoints.makeComplaint}?complaint_type=general'
            : '${ApiEndpoints.makeComplaint}?complaint_type=request',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //Faq
  Future getFaqLists() async {
    try {
      final token = await AppSharedPreference.getToken();
      Position? position = await Geolocator.getLastKnownPosition();
      double lat = (position != null) ? position.latitude : 0;
      double long = (position != null) ? position.longitude : 0;
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.faqData}/$lat/$long',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped(response.data.toString());
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Wallet History
  Future getWalletHistoryLists(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.walletHistory}?page=$page',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Subscription
  Future makeSubscriptionPlans(int paymentOpt, int amount, int planId) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response =
          await DioProviderImpl().post(ApiEndpoints.makeSubscription,
              headers: {'Authorization': token},
              body: jsonEncode({
                'payment_opt': paymentOpt,
                'amount': amount,
                'plan_id': planId,
              }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//subscription
  Future getSubscriptionLists() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.subscriptionList,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Incentive
  Future getIncentive({required int type}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (type == 0)
            ? ApiEndpoints.todayIncentive
            : ApiEndpoints.weeklyIncentive,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future moneytransfers({
    required String transferMobile,
    required String role,
    required String transferAmount,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.transferMoney,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: FormData.fromMap({
            'mobile': transferMobile,
            'role': role,
            'amount': transferAmount
          }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      required String profileImage,
      String? mapType,
      bool? updateFcmToken,
      String? mobile,
      String? country}) async {
    try {
      dynamic fcmToken;
      final token = await AppSharedPreference.getToken();
      if (updateFcmToken != null && updateFcmToken) {
        fcmToken = await FirebaseMessaging.instance.getToken();
      }
      final formData = FormData.fromMap({
        if (name.isNotEmpty) "name": name,
        if (email.isNotEmpty) "email": email,
        if (gender.isNotEmpty)
          'gender': (gender == 'Male' || gender == 'male')
              ? 'male'
              : (gender == 'Female' || gender == 'female')
                  ? 'female'
                  : 'others',
        if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
        if (country != null && country.isNotEmpty) 'country': country,
        if (updateFcmToken != null && updateFcmToken) 'fcm_token': fcmToken,
        if (mapType != null && mapType.isNotEmpty) 'map_type': mapType
      });

      if (profileImage.isNotEmpty) {
        formData.files.add(MapEntry(
            'profile_picture', await MultipartFile.fromFile(profileImage)));
      }
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updateUserDetailsButton,
        body: formData,
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future addSosContacts({
    required String name,
    required String number,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.addSosContact,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: FormData.fromMap({
            'name': name,
            'number': number,
          }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //sos delete
  Future deleteSosContacts(String id) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        '${ApiEndpoints.deleteSosContact}/$id',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//admin send message
  Future sendAdminMessage({
    required String newChat,
    required String message,
    required String chatId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.sendAdminMessage,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: (chatId.isEmpty)
              ? FormData.fromMap({'new_conversation': 1, 'content': message})
              : FormData.fromMap({
                  'new_conversation': 0,
                  'content': message,
                  'conversation_id': chatId
                }));
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//admin chat history
  Future getAdminChatHistoryLists() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.adminChatHistory,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//get bank details
  Future getBankDetails() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getBankInfo,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//update bank details
  Future updateBankDetails({required dynamic body}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updateBankInfo,
        body: body,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//rewards points
  Future rewardPointsPost({required String amount}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.rewardsPointsPost,
        body: jsonEncode({
          'amount': amount,
        }),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Withdraw amount
  Future getWithdrawData(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.getWithdrawData}?page=$page',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Request withdraw
  Future requestWithdraw({required String amount}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.requestWithdraw,
        body: {'requested_amount': amount},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//admin message seen api
  Future adminMessageSeen(String chatId) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.adminMessageSeen}?conversation_id=$chatId',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Get driver levelup
  Future getDriverLevels(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        "${ApiEndpoints.driverLevel}?page=$page",
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//get driver rewards
  Future getDriverRewards(int page) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        "${ApiEndpoints.driverRewards}?page=$page",
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get notifications
  Future getOwnerDashboard() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.ownerDashboard,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//fleet driver dashboard
  Future getFleetDashboard({required String fleetId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.fleetDashboard,
        body: {'fleet_id': fleetId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

//Get driver performance
  Future getDriverPerformance({required String driverId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.driverPerformance,
        body: {'driver_id': driverId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //get Leaderboard
  Future getLeaderBoard(
      {required int type, required String lat, required String lng}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (type == 0)
            ? '${ApiEndpoints.leaderBoardEarnings}?current_lat=$lat&current_lng=$lng'
            : '${ApiEndpoints.leaderBoardTrips}?current_lat=$lat&current_lng=$lng',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // stripeIntent
  Future stripeSetupIntent() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.stripCreate,
        headers: {'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped(response.data.toString());
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // stripSaveCard
  Future stripeSaveCardDetails({
    required String paymentMethodId,
    required String last4Number,
    required String cardType,
    required String validThrough,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response =
          await DioProviderImpl().post(ApiEndpoints.stripSavedCardsDetail,
              headers: {'Authorization': token},
              body: FormData.fromMap({
                'payment_method_id': paymentMethodId,
                'last_number': last4Number,
                'card_type': cardType,
                'valid_through': validThrough
              }));
      if (kDebugMode) {
        printWrapped(response.data.toString());
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // cardList
  Future cardList() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.savedCardList,
        headers: {'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped(response.data.toString());
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // delete card
  Future deleteCard({required String cardId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.deleteCardsDetail + cardId,
        headers: {'Authorization': token},
      );
      debugPrint(response.toString());
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future addMoneyToWalletFromCard({
    required String amount,
    required String cardToken,
    String? planId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.stripAddMoneyToWallet,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: FormData.fromMap({
            'amount': amount,
            'card_token': cardToken,
            if (planId != null && planId.isNotEmpty) 'plan_id': planId
          }));
      printWrapped(response.data.toString());
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  //support ticket
  Future supportTicketTitles({required bool isFromRequest}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        isFromRequest
            ? "${ApiEndpoints.ticketTitles}?title_type=request"
            : ApiEndpoints.ticketTitles,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped("ticket titles List ${response.data.toString()}");
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Response> makeTicket({
    required String titleId,
    required String description,
    required List<File> attachments,
    required String requestId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();

      List<MultipartFile> filesAttachment = [];

      for (var file in attachments) {
        filesAttachment.add(await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last));
      }
      FormData formData = FormData.fromMap({
        'title_id': titleId,
        'description': description,
        // 'service_location_id': serviceLocationId,
        'request_id': requestId,
        if (filesAttachment.isNotEmpty) 'files[]': filesAttachment,
      });

      Response response = await DioProviderImpl().post(
        ApiEndpoints.makeTicket,
        headers: {
          'Authorization': token,
          'Content-Type': 'multipart/form-data'
        },
        body: formData,
      );

      printWrapped(response.data.toString());
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getTicketList() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.ticketList,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      printWrapped("support ticket list ${response.data}");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future viewTicket({required String ticketId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        "${ApiEndpoints.viewTicket}/$ticketId",
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future ticketReplyMessage(
      {required String id, required String replyMessage}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          "${ApiEndpoints.replyTicket}/$id",
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: FormData.fromMap({
            'message': replyMessage,
          }));
      printWrapped(response.data.toString());
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future invoiceDownloadApi({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.downloadInvoice}$requestId',
        headers: {'Authorization': token},
      );
      printWrapped(response.data.toString());
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getTermsAndPrivacyHtml({required bool isPrivacyPage}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        (isPrivacyPage)
            ? '${ApiEndpoints.termsAndPrivacyHtml}privacy'
            : '${ApiEndpoints.termsAndPrivacyHtml}terms',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future addressUpdated({
    required double myRouteLat,
    required double myRouteLng,
    required String myRouteAddress,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.addressUpdated,
        body: {
          'my_route_lat': myRouteLat,
          'my_route_lng': myRouteLng,
          'my_route_address': myRouteAddress,
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future enableMyRouteBooking({
    required bool isEnable,
    required double currentLat,
    required double currentLng,
    String? currentAddress,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      final Map<String, dynamic> body = {
        'is_enable': isEnable ? 1 : 0,
        'current_lat': currentLat,
        'current_lng': currentLng,
      };
      if (currentAddress != null && currentAddress.isNotEmpty) {
        body['current_address'] = currentAddress;
      }
      Response response = await DioProviderImpl().post(
        ApiEndpoints.enableMyRouteBooking,
        body: body,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future referalHistory() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.referalHistory,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future referralResponse() async {
    try {
      final token = await AppSharedPreference.getToken();

      Response response = await DioProviderImpl().get(
        ApiEndpoints.referralResponse,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      printWrapped("referral response ${response.data}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
