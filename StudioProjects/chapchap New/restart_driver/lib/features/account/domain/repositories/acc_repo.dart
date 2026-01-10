import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_data_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_level_models.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_performance_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_points_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_rewards_model.dart';
import 'package:restart_tagxi/features/account/domain/models/earnings_model.dart';
import 'package:restart_tagxi/features/account/domain/models/faq_model.dart';
import 'package:restart_tagxi/features/account/domain/models/incentive_model.dart';
import 'package:restart_tagxi/features/account/domain/models/make_ticket_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_vehicle_model.dart';
import 'package:restart_tagxi/features/account/domain/models/leader_board_model.dart';
import 'package:restart_tagxi/features/account/domain/models/fleet_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/referal_response_model.dart';
import 'package:restart_tagxi/features/account/domain/models/report_section_model.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_model.dart';
import 'package:restart_tagxi/features/account/domain/models/bank_details_update_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_names_model.dart';
import 'package:restart_tagxi/features/account/domain/models/view_ticket_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_request_model.dart';
import 'package:restart_tagxi/features/account/domain/models/referalhistory_model.dart';
import '../../../../core/network/failure.dart';
import '../models/admin_chat_history_model.dart';
import '../models/admin_chat_model.dart';
import '../models/card_list_model.dart';
import '../models/enable_routebooking_model.dart';
import '../models/history_model.dart';
import '../models/logout_model.dart';
import '../models/makecomplaint_model.dart';
import '../models/notifications_model.dart';
import '../models/payment_method_model.dart';
import '../models/route_address_update_model.dart';
import '../models/walletpage_model.dart';

abstract class AccRepository {
  Future<Either<Failure, NotificationResponseModel>>
      getUserNotificationsDetails({String? pageNo});

  Future<Either<Failure, dynamic>> deleteAccount();

  Future<Either<Failure, dynamic>> readyToPickup({required String requestId});

  Future<Either<Failure, ComplaintResponseModel>> makeComplaintList(
      {String? complaintType});

  Future<Either<Failure, dynamic>> deleteNotification(String id);

  Future<Either<Failure, dynamic>> clearAllNotification();

  Future<Either<Failure, dynamic>> makeComplaintButton(
      String complaintTitleId, String complaintText, String requestId);

  Future<Either<Failure, HistoryResponseModel>> getUserHistoryDetails(
      String historyFilter,
      {String? pageNo});

  Future<Either<Failure, LogoutResponseModel>> logout();

  Future<Either<Failure, FaqResponseModel>> getFaqDetails();

  Future<Either<Failure, WalletResponseModel>> getWalletHistoryDetails(
      int page);

  Future<Either<Failure, dynamic>> moneyTransfer({
    required String transferMobile,
    required String role,
    required String transferAmount,
  });

  Future<Either<Failure, dynamic>> addSos({
    required String name,
    required String number,
  });

  Future<Either<Failure, dynamic>> deleteSos(String id);

  Future<Either<Failure, dynamic>> updateDetailsButton(
      {required String email,
      required String name,
      required String gender,
      String? mapType,
      required String profileImage,
      bool? updateFcmToken,
      String? mobile,
      String? country});

  Future<Either<Failure, AdminChatModel>> sendAdminMessage({
    required String newChat,
    required String message,
    required String chatId,
  });

  Future<Either<Failure, AdminChatHistoryModel>> getAdminChatHistoryDetails();

  Future<Either<Failure, dynamic>> adminMessageSeenDetails(String chatId);

  Future<Either<Failure, EarningsModel>> getEarnings();

  Future<Either<Failure, SubscriptionListModel>> getSubscriptionList();

  Future<Either<Failure, SubscriptionSuccessModel>> makeSubscriptionPlan(
      int paymentOpt, int amount, int planId);

  Future<Either<Failure, DriverRewardsPointsModel>> rewardPointsPost(
      {required String amount});

  Future<Either<Failure, DriverDataModel>> getDrivers();

  Future<Either<Failure, DriverDataModel>> deleteDrivers(
      {required String driverId});

  Future<Either<Failure, OwnerVehicleModel>> getVehicles();

  Future<Either<Failure, OwnerVehicleModel>> assignDriver(
      {required String fleetId, required String driverId});

  Future<Either<Failure, DriverDataModel>> addDrivers(
      {required String name,
      required String email,
      required String mobile,
      required String address});

  Future<Either<Failure, DailyEarningsModel>> getDailyEarnings(
      {required String date});

  Future<Either<Failure, OwnerDashboardModel>> getOwnerDashboard();

  Future<Either<Failure, DriverLevelsModel>> getDriverLevels(int page);

  Future<Either<Failure, DriverRewardsModel>> getDriverRewards(int page);

  Future<Either<Failure, FleetDashboardModel>> getFleetDashboard(
      {required String fleetId});

  Future<Either<Failure, DriverPerformanceModel>> getDriverPerformance(
      {required String driverId});

  Future<Either<Failure, LeaderBoardModel>> getLeaderBoard(
      {required int type, required String lat, required String lng});

  Future<Either<Failure, IncentiveModel>> getIncentive({required int type});

  Future<Either<Failure, ReportModel>> getReportSection(
      {required String fromDate, required String toDate});

  Future<Either<Failure, BankDetailsModel>> getBankDetails();

  Future<Either<Failure, BankDetailsUpdateModel>> updateBankDetails(
      {required dynamic body});

  Future<Either<Failure, WithdrawModel>> getWithdrawData(int page);

  Future<Either<Failure, WithdrawRequestModel>> requestWithdraw(
      {required String amount});

  Future<Either<Failure, PaymentAuthModel>> stripeSetupIntent();

  Future<Either<Failure, dynamic>> stripeSaveCardDetails({
    required String paymentMethodId,
    required String last4Number,
    required String cardType,
    required String validThrough,
  });

  Future<Either<Failure, CardListModel>> cardList();

  Future<Either<Failure, dynamic>> deleteCard({required String cardId});

  Future<Either<Failure, dynamic>> addMoneyToWalletFromCard({
    required String amount,
    required String cardToken,
    String? planId,
  });

  //support ticket
  Future<Either<Failure, TicketNamesModel>> supportTicketTitles(
      {required bool isFromRequest});

  Future<Either<Failure, MakeTicketModel>> makeTicket({
    required String titleId,
    required String description,
    required List<File> attachments,
    required String requestId,
  });

  Future<Either<Failure, TicketListModel>> getTicketList();

  Future<Either<Failure, ViewTicketModel>> viewTicket(
      {required String ticketId});

  Future<Either<Failure, ReplyMessage>> ticketReplyMessage(
      {required String id, required String replyMessage});

  Future<Either<Failure, dynamic>> invoiceDownload({required String requestId});

  Future<Either<Failure, dynamic>> getTermsAndPrivacyHtml(
      {required bool isPrivacyPage});

  Future<Either<Failure, AddMyRouteAddressResponse>> addressUpdated(
      {required double myRouteLat,
      required double myRouteLng,
      required String myRouteAddress});

  Future<Either<Failure, EnableMyRouteBookingResponse>> enableMyRouteBooking({
    required bool isEnable,
    required double currentLat,
    required double currentLng,
    required String currentAddress,
  });

  Future<Either<Failure, ReferralResponse>> referalHistory();

  Future<Either<Failure, ReferralResponseData>> referalResponse();
}
