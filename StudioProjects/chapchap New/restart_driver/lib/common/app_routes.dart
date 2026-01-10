import 'package:flutter/material.dart';
import 'package:restart_tagxi/features/account/presentation/pages/help/page/help_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/page/support_ticket.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/page/view_ticket_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/otp_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/signup_mobile_page.dart';
import 'package:restart_tagxi/features/home/presentation/pages/review_page/page/review_page.dart';
import '../features/account/presentation/pages/account_page.dart';
import '../features/account/presentation/pages/admin_chat/page/admin_chat.dart';
import '../features/account/presentation/pages/company_info/page/company_information_page.dart';
import '../features/account/presentation/pages/complaint/page/complaint_list.dart';
import '../features/account/presentation/pages/complaint/page/complaint_page.dart';
import '../features/account/presentation/pages/driver_report/pages/reports_page.dart';
import '../features/account/presentation/pages/levelup/page/driver_levels_page.dart';
import '../features/account/presentation/pages/dashboard/page/driver_performance_page.dart';
import '../features/account/presentation/pages/myroute_booking/page/myroute_booking.dart';
import '../features/account/presentation/pages/myroute_booking/page/myroute_map_page.dart';
import '../features/account/presentation/pages/rewards/page/rewards_page.dart';
import '../features/account/presentation/pages/fleet_driver/page/fleet_drivers_page.dart';
import '../features/account/presentation/pages/earnings/page/earnings_page.dart';
import '../features/account/presentation/pages/profile/page/profile_info_page.dart';
import '../features/account/presentation/pages/settings/page/faq_page.dart';
import '../features/account/presentation/pages/dashboard/page/fleet_dashboard_page.dart';
import '../features/account/presentation/pages/history/page/history_page.dart';
import '../features/account/presentation/pages/incentive/page/incentive_page.dart';
import '../features/account/presentation/pages/leaderboard/page/leaderboard_page.dart';
import '../features/account/presentation/pages/settings/page/map_settings.dart';
import '../features/account/presentation/pages/notification/page/notification_page.dart';
import '../features/account/presentation/pages/dashboard/page/owner_dashboard.dart';
import '../features/account/presentation/pages/refferal/page/referral_page.dart';
import '../features/account/presentation/pages/settings/page/settings_page.dart';
import '../features/account/presentation/pages/settings/page/terms_privacy_policy_view_page.dart';
import '../features/account/presentation/pages/sos/page/sos_page.dart';
import '../features/account/presentation/pages/subscription/page/subscription_page.dart';
import '../features/account/presentation/pages/history/page/trip_summary_history.dart';
import '../features/account/presentation/pages/profile/page/update_details.dart';
import '../features/account/presentation/pages/vehicle_info/page/vehicle_data_page.dart';
import '../features/account/presentation/pages/wallet/page/wallet_page.dart';
import '../features/account/presentation/pages/wallet/page/withdraw_page.dart';
import '../features/account/presentation/pages/wallet/widget/card_list_widget.dart';
import '../features/auth/presentation/pages/user_choose_page.dart';
import '../features/driverprofile/presentation/pages/driver_profile_pages.dart';
import '../features/home/presentation/pages/home_page/page/diagnostic_page.dart';
import '../core/error/error_page.dart';
import '../features/account/presentation/pages/paymentgateways.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/apply_refferal_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/update_password_page.dart';
import '../features/auth/presentation/pages/verify_page.dart';
import '../features/home/presentation/pages/home_page/page/home_page.dart';
import '../features/landing/presentation/page/landing_page.dart';
import '../features/language/presentation/page/choose_language_page.dart';
import '../features/loading/presentation/loader.dart';
import 'app_arguments.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoutes(RouteSettings routeSettings) {
    late Route<dynamic> pageRoute;
    Object? arg = routeSettings.arguments;

    switch (routeSettings.name) {
      case LoaderPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const LoaderPage(),
        );
        break;
      case LandingPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => LandingPage(
            args: arg as LandingPageArguments,
          ),
        );
        break;
      case ChooseLanguagePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ChooseLanguagePage(
            args: arg != null ? arg as ChangeLanguageArguments : null,
          ),
        );
        break;
      case AuthPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => AuthPage(
            arg: arg as AuthPageArguments,
          ),
        );
        break;
      case VerifyPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => VerifyPage(
            arg: arg as VerifyArguments,
          ),
        );
        break;
      case RegisterPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => RegisterPage(
            arg: arg as RegisterPageArguments,
          ),
        );
        break;
      case ApplyRefferalPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const ApplyRefferalPage(),
        );
        break;
      case ForgotPasswordPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ForgotPasswordPage(
            arg: arg as ForgotPasswordPageArguments,
          ),
        );
        break;
      case UpdatePasswordPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => UpdatePasswordPage(
            arg: arg as UpdatePasswordPageArguments,
          ),
        );
        break;
      case HomePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => HomePage(
            args: (arg != null) ? arg as HomePageArguments : null,
          ),
        );
        break;
      case AccountPage.routeName:
        pageRoute = PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AccountPage(arg: arg as AccountPageArguments),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            final curvedAnimation =
                CurvedAnimation(parent: animation, curve: curve);
            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        );
        break;
      case DriverProfilePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) =>
              DriverProfilePage(args: arg as VehicleUpdateArguments),
        );
        break;
      case ProfileInfoPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const ProfileInfoPage(),
        );
        break;
      case RouteBooking.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const RouteBooking(),
        );
        break;
      case NotificationPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const NotificationPage(),
        );
        break;
      case HistoryPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) =>
              HistoryPage(args: arg as HistoryAccountPageArguments),
        );
        break;
      case ReferralPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ReferralPage(
            args: arg as ReferralArguments,
          ),
        );
        break;
      case ComplaintListPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ComplaintListPage(
            args: arg as ComplaintListPageArguments,
          ),
        );
        break;
      case HistoryTripSummaryPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) =>
              HistoryTripSummaryPage(arg: arg as TripHistoryPageArguments),
        );
        break;
      case VehicleDataPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => VehicleDataPage(
            args: arg as VehicleDataArguments,
          ),
        );
        break;
      case FleetDriversPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const FleetDriversPage(),
        );
        break;
      case ComplaintPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ComplaintPage(
            arg: arg as ComplaintPageArguments,
          ),
        );
        break;
      case UpdateDetails.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => UpdateDetails(
            arg: arg as UpdateDetailsArguments,
          ),
        );
        break;
      case SettingsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const SettingsPage());
        break;
      case FaqPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const FaqPage(),
        );
        break;
      case MapSettingsPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const MapSettingsPage(),
        );
        break;
      // case FavoriteLocationPage.routeName:
      //   pageRoute = MaterialPageRoute(
      //     builder: (context) => const FavoriteLocationPage(),
      //   );
      //   break;
      case WalletHistoryPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const WalletHistoryPage(),
        );
        break;

      case SosPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => SosPage(arg: arg as SOSPageArguments),
        );
        break;
      case DiagnosticPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const DiagnosticPage(),
        );
        break;
      case AdminChat.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const AdminChat(),
        );
        break;
      case EarningsPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => EarningsPage(
            args: arg as EarningArguments,
          ),
        );
        break;
      case OwnerDashboard.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => OwnerDashboard(
            args: arg as OwnerDashboardArguments,
          ),
        );
        break;
      case FleetDashboard.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => FleetDashboard(
            args: arg as FleetDashboardArguments,
          ),
        );
        break;
      case DriverPerformancePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => DriverPerformancePage(
            args: arg as DriverDashboardArguments,
          ),
        );
        break;
      case PaymentGatewaysPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => PaymentGatewaysPage(
            arg: arg as PaymentGateWayPageArguments,
          ),
        );
        break;
      case LeaderboardPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const LeaderboardPage(),
        );
        break;
      case SubscriptionPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => SubscriptionPage(
            args: arg as SubscriptionPageArguments,
          ),
        );
        break;
      case WithdrawPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => WithdrawPage(
            arg: arg as WithdrawPageArguments,
          ),
        );
        break;
      case CompanyInformationPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const CompanyInformationPage(),
        );
        break;
      case IncentivePage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => const IncentivePage(),
        );
        break;
      case SelectUserPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const SelectUserPage());
        break;
      case DriverLevelsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const DriverLevelsPage());
        break;
      case RewardsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const RewardsPage());
        break;
      case ReportsPage.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const ReportsPage());
        break;
      case CardListWidget.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => CardListWidget(
            arg: arg as PaymentMethodArguments,
          ),
        );
        break;
      case SupportTicketPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => SupportTicketPage(
            args: arg as SupportTicketPageArguments,
          ),
        );
        break;
      case ViewTicketPage.routeName:
        pageRoute = MaterialPageRoute(
          builder: (context) => ViewTicketPage(
            args: arg as ViewTicketPageArguments,
          ),
        );
        break;
      case TermsPrivacyPolicyViewPage.routeName:
        pageRoute = MaterialPageRoute(
            builder: (context) => TermsPrivacyPolicyViewPage(
                  args: arg as TermsAndPrivacyPolicyArguments,
                ));
        break;
      case MyRouteMapWidget.routeName:
        pageRoute =
            MaterialPageRoute(builder: (context) => const MyRouteMapWidget());
        break;
      case LoginPage.routeName:
        pageRoute = MaterialPageRoute(builder: (context) => const LoginPage());
        break;
      case SignupMobilePage.routeName:
        pageRoute = MaterialPageRoute(
            builder: (context) => SignupMobilePage(
                  arg: arg as SignupMobilePageArguments,
                ));
        break;
      case OtpPage.routeName:
        pageRoute = MaterialPageRoute(
            builder: (context) => OtpPage(
                  arg: arg as OtpPageArguments,
                ));
        break;
      case HelpPage.routeName:
        pageRoute = MaterialPageRoute(builder: (context) => const HelpPage());
        break;
      case ReviewPage.routeName:
        pageRoute = MaterialPageRoute(builder: (context) => const ReviewPage());
        break;
      default:
        pageRoute = MaterialPageRoute(
          builder: (context) => const LoaderPage(),
        );
    }
    return pageRoute;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (context) => const ErrorPage());
  }
}
