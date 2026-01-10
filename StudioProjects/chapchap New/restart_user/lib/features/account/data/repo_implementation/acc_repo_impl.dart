import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:restart_tagxi/features/account/domain/models/card_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/make_ticket_model.dart';
import 'package:restart_tagxi/features/account/domain/models/referal_response_model.dart';
import 'package:restart_tagxi/features/account/domain/models/referalhistory_model.dart';
import 'package:restart_tagxi/features/account/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_names_model.dart';
import 'package:restart_tagxi/features/account/domain/models/view_ticket_model.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/failure.dart';
import '../../domain/models/admin_chat_history_model.dart';
import '../../domain/models/admin_chat_model.dart';
import '../../domain/models/delete_account_model.dart';
import '../../domain/models/faq_model.dart';
import '../../domain/models/history_model.dart';
import '../../domain/models/logout_model.dart';
import '../../domain/models/makecomplaint_model.dart';
import '../../domain/models/notifications_model.dart';
import '../../domain/models/payment_method_model.dart';
import '../../domain/models/walletpage_model.dart';
import '../../domain/repositories/acc_repo.dart';
import '../repository/acc_api.dart';

class AccRepositoryImpl implements AccRepository {
  final AccApi _accApi;

  AccRepositoryImpl(this._accApi);

  // Notification
  @override
  Future<Either<Failure, NotificationResponseModel>>
      getUserNotificationsDetails({String? pageNo}) async {
    try {
      Response response = await _accApi.getNotificationsApi(pageNo: pageNo);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        final notificationResponseModel =
            NotificationResponseModel.fromJson(response.data);
        return Right(notificationResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // logout
  @override
  Future<Either<Failure, LogoutResponseModel>> logout() async {
    try {
      Response response = await _accApi.logoutApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        final logoutResponseModel = LogoutResponseModel.fromJson(response.data);
        return Right(logoutResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // delete account
  @override
  Future<Either<Failure, DeleteAccountResponseModel>> deleteAccount() async {
    try {
      Response response = await _accApi.deleteAccountApi();
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        final deleteAccountResponseModel =
            DeleteAccountResponseModel.fromJson(response.data);
        return Right(deleteAccountResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  // make complaint
  @override
  Future<Either<Failure, ComplaintResponseModel>> makeComplaintList(
      {String? complaintType}) async {
    try {
      Response response =
          await _accApi.makeComplaintsApi(complaintType: complaintType);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        final complaintResponseModel =
            ComplaintResponseModel.fromJson(response.data);
        return Right(complaintResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

//history
  @override
  Future<Either<Failure, HistoryResponseModel>> getUserHistoryDetails(
      String historyFilter,
      {String? pageNo}) async {
    HistoryResponseModel historyResponseModel;
    try {
      Response response =
          await _accApi.getHistoryApi(historyFilter, pageNo: pageNo);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        historyResponseModel = HistoryResponseModel.fromJson(response.data);
      }
    } on FetchDataException catch (e) {
      debugPrint('getUserHistoryDetails Error: $e');
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(historyResponseModel);
  }

  //Delete notification
  @override
  Future<Either<Failure, dynamic>> deleteNotification(String id) async {
    try {
      Response response = await _accApi.deleteNotification(id);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  //ClearAll notification
  @override
  Future<Either<Failure, dynamic>> clearAllNotification() async {
    try {
      Response response = await _accApi.clearAllNotification();
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  //make complaint button
  @override
  Future<Either<Failure, dynamic>> makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId) async {
    try {
      Response response = await _accApi.makeComplaintButton(
          complaintTitleId, complaintText, requestId);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  //Faq
  @override
  Future<Either<Failure, FaqResponseModel>> getFaqDetails() async {
    FaqResponseModel faqDataResponseModel;
    try {
      Response response = await _accApi.getFaqLists();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          faqDataResponseModel = FaqResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(faqDataResponseModel);
  }

  @override
  Future<Either<Failure, WalletResponseModel>> getWalletHistoryDetails(
      int page) async {
    try {
      Response response = await _accApi.getWalletHistoryLists(page);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        debugPrint("Wallet Success");
        final walletDataResponseModel =
            WalletResponseModel.fromJson(response.data);
        return Right(walletDataResponseModel);
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, dynamic>> moneyTransfer({
    required String transferMobile,
    required String role,
    required String transferAmount,
  }) async {
    dynamic amountTransfered;
    try {
      Response response = await _accApi.moneytransfers(
          transferMobile: transferMobile,
          role: role,
          transferAmount: transferAmount);
      debugPrint('transfer status code ${response.statusCode}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          amountTransfered = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(amountTransfered);
  }

  //update button
  @override
  Future<Either<Failure, dynamic>> updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      required String profileImage,
      required String mobile,
      required String country,
      String? mapType,
      bool? updateFcmToken}) async {
    dynamic updateval;
    try {
      Response response = await _accApi.updateDetailsButton(
          email: email,
          name: name,
          gender: gender,
          profileImage: profileImage,
          mapType: mapType,
          mobile: mobile,
          country: country,
          updateFcmToken: updateFcmToken);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          updateval = response.data;
          debugPrint('deleteContact $updateval');
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(updateval);
  }

  @override
  Future<Either<Failure, dynamic>> deleteFav(String id) async {
    dynamic deleteFavAddress;
    try {
      Response response = await _accApi.deleteFavAddress(id);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          deleteFavAddress = response.data;
          debugPrint('deleteContact hhh $deleteFavAddress');
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(deleteFavAddress);
  }

  @override
  Future<Either<Failure, dynamic>> addFavAddress({
    required String address,
    required String name,
    required String lat,
    required String lng,
  }) async {
    dynamic addFavourite;
    try {
      Response response = await _accApi.addFavouriteAddress(
          address: address, name: name, lat: lat, lng: lng);
      debugPrint('add fav status code ${response.statusCode}');
      debugPrint('addfav address $addFavourite');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          addFavourite = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(addFavourite);
  }

  @override
  Future<Either<Failure, dynamic>> addSos({
    required String name,
    required String number,
  }) async {
    dynamic addContact;
    try {
      Response response = await _accApi.addSosContacts(
        name: name,
        number: number,
      );
      debugPrint('add sos status code ${response.statusCode}');
      debugPrint('addContact $addContact');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          addContact = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(addContact);
  }

  @override
  Future<Either<Failure, dynamic>> deleteSos(String id) async {
    dynamic deleteContact;
    try {
      Response response = await _accApi.deleteSosContacts(id);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          deleteContact = response.data;
          debugPrint('deleteContact hhh $deleteContact');
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(deleteContact);
  }

  @override
  Future<Either<Failure, AdminChatModel>> sendAdminMessage({
    required String newChat,
    required String message,
    required String chatId,
  }) async {
    AdminChatModel sendAdminMessage;
    try {
      Response response = await _accApi.sendAdminMessage(
        newChat: newChat,
        message: message,
        chatId: chatId,
      );
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          sendAdminMessage = AdminChatModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(sendAdminMessage);
  }

  @override
  Future<Either<Failure, AdminChatHistoryModel>>
      getAdminChatHistoryDetails() async {
    AdminChatHistoryModel adminChatHistory;
    try {
      Response response = await _accApi.getAdminChatHistoryLists();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          adminChatHistory = AdminChatHistoryModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(adminChatHistory);
  }

  @override
  Future<Either<Failure, dynamic>> adminMessageSeenDetails(
      String chatId) async {
    dynamic adminMessageSeen;
    try {
      Response response = await _accApi.adminMessageSeen(chatId);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          adminMessageSeen = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(adminMessageSeen);
  }

  @override
  Future<Either<Failure, PaymentAuthModel>> stripeSetupIntent() async {
    PaymentAuthModel paymentAuthenticationResponse;
    try {
      Response response = await _accApi.stripeSetupIntent();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          paymentAuthenticationResponse =
              PaymentAuthModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(paymentAuthenticationResponse);
  }

  @override
  Future<Either<Failure, dynamic>> stripeSaveCardDetails({
    required String paymentMethodId,
    required String last4Number,
    required String cardType,
    required String validThrough,
  }) async {
    dynamic saveCardResponse;
    try {
      // Response response = await _accApi.stripeSetupIntent();
      Response response = await _accApi.stripeSaveCardDetails(
          paymentMethodId: paymentMethodId,
          last4Number: last4Number,
          cardType: cardType,
          validThrough: validThrough);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          saveCardResponse = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(saveCardResponse);
  }

  @override
  Future<Either<Failure, CardListModel>> cardList() async {
    CardListModel cardListResponse;
    try {
      Response response = await _accApi.cardList();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          cardListResponse = CardListModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(cardListResponse);
  }

  @override
  Future<Either<Failure, dynamic>> deleteCard({required String cardId}) async {
    dynamic deleteCardResponse;
    try {
      Response response = await _accApi.deleteCard(cardId: cardId);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          deleteCardResponse = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(deleteCardResponse);
  }

  @override
  Future<Either<Failure, dynamic>> addMoneyToWalletFromCard({
    required String amount,
    required String cardToken,
  }) async {
    dynamic addMoneyResponse;
    try {
      Response response = await _accApi.addMoneyToWalletFromCard(
          amount: amount, cardToken: cardToken);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          addMoneyResponse = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(addMoneyResponse);
  }

  //support ticket
  @override
  Future<Either<Failure, TicketNamesModel>> supportTicketTitles(
      {required bool isFromRequest}) async {
    TicketNamesModel ticketNamesModel;
    try {
      Response response =
          await _accApi.supportTicketTitles(isFromRequest: isFromRequest);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          ticketNamesModel = TicketNamesModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(ticketNamesModel);
  }

  @override
  Future<Either<Failure, ServiceLocationModel>> getServiceLocation() async {
    ServiceLocationModel serviceLocationModel;
    try {
      Response response = await _accApi.getServiceLocation();
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
  Future<Either<Failure, MakeTicketModel>> makeTicket({
    required String titleId,
    required String description,
    required String serviceLocationId,
    required List<File> attachments,
    required String requestId,
  }) async {
    MakeTicketModel makeTicketModel;
    try {
      Response response = await _accApi.makeTicket(
          titleId: titleId,
          description: description,
          serviceLocationId: serviceLocationId,
          attachments: attachments,
          requestId: requestId);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          makeTicketModel = MakeTicketModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(makeTicketModel);
  }

  @override
  Future<Either<Failure, TicketListModel>> getTicketList() async {
    TicketListModel ticketListModel;
    try {
      Response response = await _accApi.getTicketList();
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
          ticketListModel = TicketListModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(ticketListModel);
  }

  @override
  Future<Either<Failure, ViewTicketModel>> viewTicket(
      {required String ticketId}) async {
    ViewTicketModel viewTicketModel;
    try {
      Response response = await _accApi.viewTicket(ticketId: ticketId);
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
          viewTicketModel = ViewTicketModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(viewTicketModel);
  }

  @override
  Future<Either<Failure, ReplyMessage>> ticketReplyMessage(
      {required String id, required String replyMessage}) async {
    ReplyMessage replyMessageModel;
    try {
      Response response =
          await _accApi.ticketReplyMessage(id: id, replyMessage: replyMessage);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400 || response.statusCode == 500) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else {
          replyMessageModel = ReplyMessage.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(replyMessageModel);
  }

  @override
  Future<Either<Failure, dynamic>> invoiceDownload(
      {required String requestId}) async {
    dynamic responseModel;
    try {
      Response response =
          await _accApi.invoiceDownloadApi(requestId: requestId);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        return Left(GetDataFailure(message: response.data["message"]));
      } else {
        responseModel = response.data;
      }
    } on FetchDataException catch (e) {
      debugPrint('getUserHistoryDetails Error: $e');
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(responseModel);
  }

  @override
  Future<Either<Failure, dynamic>> getTermsAndPrivacyHtml(
      {required bool isPrivacyPage}) async {
    try {
      Response response =
          await _accApi.getTermsAndPrivacyHtml(isPrivacyPage: isPrivacyPage);
      if (response.statusCode == 200) {
        return Right(response.data);
      } else {
        return Left(GetDataFailure(message: response.statusMessage ?? 'Error'));
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ReferralResponse>> referalHistory() async {
    ReferralResponse referralResponse;
    try {
      Response response = await _accApi.referalHistory();
      final responseData = response.data;
      if (responseData == null || responseData == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (responseData is Map<String, dynamic> &&
          responseData.containsKey('error')) {
        return Left(GetDataFailure(message: responseData['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final message = (responseData is Map<String, dynamic>)
            ? responseData['message']
            : 'Error';
        return Left(GetDataFailure(message: message ?? 'Error'));
      } else {
        if (responseData is Map<String, dynamic>) {
          referralResponse = ReferralResponse.fromJson(responseData);
        } else {
          return Left(GetDataFailure(message: 'Invalid response format'));
        }
      }
    } on FetchDataException catch (e) {
      debugPrint('referalHistory Error: $e');
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(referralResponse);
  }

  @override
  Future<Either<Failure, ReferralResponseData>> referalResponse() async {
    ReferralResponseData referralResponse;
    try {
      Response response = await _accApi.referralResponse();
      final responseData = response.data;
      if (responseData == null || responseData == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (responseData is Map<String, dynamic> &&
          responseData.containsKey('error')) {
        return Left(GetDataFailure(message: responseData['error']));
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final message = (responseData is Map<String, dynamic>)
            ? responseData['message']
            : 'Error';
        return Left(GetDataFailure(message: message ?? 'Error'));
      } else {
        if (responseData is Map<String, dynamic>) {
          referralResponse = ReferralResponseData.fromJson(responseData);
        } else {
          return Left(GetDataFailure(message: 'Invalid response format'));
        }
      }
    } on FetchDataException catch (e) {
      debugPrint('referalResponse Error: $e');
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(referralResponse);
  }
}
