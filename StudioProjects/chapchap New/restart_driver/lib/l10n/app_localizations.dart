import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('az'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @driverSubHeading.
  ///
  /// In en, this message translates to:
  /// **'Manage Pick-up and Delivery rides'**
  String get driverSubHeading;

  /// No description provided for @ownerSubHeading.
  ///
  /// In en, this message translates to:
  /// **'Optimize Drivers and Deliveries'**
  String get ownerSubHeading;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @emailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Email address or mobile number'**
  String get emailOrMobile;

  /// No description provided for @agreeTermsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the 1111 and 2222'**
  String get agreeTermsAndPrivacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @isThisCorrect.
  ///
  /// In en, this message translates to:
  /// **'Is this correct?'**
  String get isThisCorrect;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @otpSentMobile.
  ///
  /// In en, this message translates to:
  /// **'An One Time Password (OTP) has been sent to this number'**
  String get otpSentMobile;

  /// No description provided for @otpSentEmail.
  ///
  /// In en, this message translates to:
  /// **'An One Time Password (OTP) has been sent to this email'**
  String get otpSentEmail;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmail;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @preferNotSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotSay;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @signUsingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sign in using OTP'**
  String get signUsingOtp;

  /// No description provided for @signUsingPassword.
  ///
  /// In en, this message translates to:
  /// **'Sign in using Password'**
  String get signUsingPassword;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'DashBoard'**
  String get dashboard;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @ownerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// No description provided for @cabs.
  ///
  /// In en, this message translates to:
  /// **'Cabs'**
  String get cabs;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @digitalPayment.
  ///
  /// In en, this message translates to:
  /// **'Digital Payment'**
  String get digitalPayment;

  /// No description provided for @cabPerformance.
  ///
  /// In en, this message translates to:
  /// **'Cab Performance'**
  String get cabPerformance;

  /// No description provided for @rides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get rides;

  /// No description provided for @driverPerformance.
  ///
  /// In en, this message translates to:
  /// **'Driver Performance'**
  String get driverPerformance;

  /// No description provided for @weeklyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Weekly Earnings'**
  String get weeklyEarnings;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'Mins'**
  String get mins;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Informations'**
  String get vehicleInfo;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @referAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referAndEarn;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat With Us'**
  String get chatWithUs;

  /// No description provided for @makeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Make Complaint'**
  String get makeComplaint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @mapAppearance.
  ///
  /// In en, this message translates to:
  /// **'Map Appearance'**
  String get mapAppearance;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @comeBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Come back soon'**
  String get comeBackSoon;

  /// No description provided for @logoutSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure, you want to logout?'**
  String get logoutSure;

  /// No description provided for @deleteSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure, you want to delete account?'**
  String get deleteSure;

  /// No description provided for @chooseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Choose your complaint'**
  String get chooseComplaint;

  /// No description provided for @noNotificationAvail.
  ///
  /// In en, this message translates to:
  /// **'No Notification Available'**
  String get noNotificationAvail;

  /// No description provided for @adminChat.
  ///
  /// In en, this message translates to:
  /// **'Admin Chat'**
  String get adminChat;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @shareYourInvite.
  ///
  /// In en, this message translates to:
  /// **'Share your invite code'**
  String get shareYourInvite;

  /// No description provided for @referralCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied to clipboard'**
  String get referralCopied;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @transferMoney.
  ///
  /// In en, this message translates to:
  /// **'Transfer Money'**
  String get transferMoney;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount Here'**
  String get enterAmount;

  /// No description provided for @documentNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document Not Uploaded'**
  String get documentNotUploaded;

  /// No description provided for @fleetNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Fleet Not Assigned'**
  String get fleetNotAssigned;

  /// No description provided for @deleteDriver.
  ///
  /// In en, this message translates to:
  /// **'Delete Driver'**
  String get deleteDriver;

  /// No description provided for @deleteDriverSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete this driver?'**
  String get deleteDriverSure;

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driverName;

  /// No description provided for @enterDriverName.
  ///
  /// In en, this message translates to:
  /// **'Enter Driver Name'**
  String get enterDriverName;

  /// No description provided for @driverMobile.
  ///
  /// In en, this message translates to:
  /// **'Driver Mobile'**
  String get driverMobile;

  /// No description provided for @enterDriverMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter Driver Mobile'**
  String get enterDriverMobile;

  /// No description provided for @enterDriverEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Driver Email'**
  String get enterDriverEmail;

  /// No description provided for @driverEmail.
  ///
  /// In en, this message translates to:
  /// **'Driver Email'**
  String get driverEmail;

  /// No description provided for @enterDriverAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Driver Address'**
  String get enterDriverAddress;

  /// No description provided for @driverAddress.
  ///
  /// In en, this message translates to:
  /// **'Driver Address'**
  String get driverAddress;

  /// No description provided for @addDriver.
  ///
  /// In en, this message translates to:
  /// **'Add Driver'**
  String get addDriver;

  /// No description provided for @noDriversAdded.
  ///
  /// In en, this message translates to:
  /// **'No Drivers Added'**
  String get noDriversAdded;

  /// No description provided for @noVehicleCreated.
  ///
  /// In en, this message translates to:
  /// **'No Vehicles Created'**
  String get noVehicleCreated;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting For Approval'**
  String get waitingForApproval;

  /// No description provided for @assignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get assignDriver;

  /// No description provided for @chooseDriverAssign.
  ///
  /// In en, this message translates to:
  /// **'Choose Driver to Assign'**
  String get chooseDriverAssign;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @addNewVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add New Vehicle'**
  String get addNewVehicle;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Please select your vehicle type'**
  String get selectVehicleType;

  /// No description provided for @chooseVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Choose vehicle type'**
  String get chooseVehicleType;

  /// No description provided for @provideVehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Vehicle make'**
  String get provideVehicleMake;

  /// No description provided for @enterVehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle make'**
  String get enterVehicleMake;

  /// No description provided for @provideVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle model'**
  String get provideVehicleModel;

  /// No description provided for @enterVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle model'**
  String get enterVehicleModel;

  /// No description provided for @provideModelYear.
  ///
  /// In en, this message translates to:
  /// **'Vehicle model year'**
  String get provideModelYear;

  /// No description provided for @enterModelYear.
  ///
  /// In en, this message translates to:
  /// **'Enter model year'**
  String get enterModelYear;

  /// No description provided for @provideVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number'**
  String get provideVehicleNumber;

  /// No description provided for @enterVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Number'**
  String get enterVehicleNumber;

  /// No description provided for @provideVehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Vehicle color'**
  String get provideVehicleColor;

  /// No description provided for @enterVehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Color'**
  String get enterVehicleColor;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @vehicleAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Added Successfully'**
  String get vehicleAddedSuccess;

  /// No description provided for @driverAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Driver Added Succcessfully'**
  String get driverAddedSuccess;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @historyDetails.
  ///
  /// In en, this message translates to:
  /// **'History Details'**
  String get historyDetails;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @typeOfRide.
  ///
  /// In en, this message translates to:
  /// **'Type of Ride'**
  String get typeOfRide;

  /// No description provided for @fareBreakup.
  ///
  /// In en, this message translates to:
  /// **'Fare Breakup'**
  String get fareBreakup;

  /// No description provided for @basePrice.
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// No description provided for @taxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// No description provided for @distancePrice.
  ///
  /// In en, this message translates to:
  /// **'Distance Price'**
  String get distancePrice;

  /// No description provided for @timePrice.
  ///
  /// In en, this message translates to:
  /// **'Time Price'**
  String get timePrice;

  /// No description provided for @waitingPrice.
  ///
  /// In en, this message translates to:
  /// **'Waiting Price'**
  String get waitingPrice;

  /// No description provided for @convFee.
  ///
  /// In en, this message translates to:
  /// **'Convinience Fee'**
  String get convFee;

  /// No description provided for @paymentRecieved.
  ///
  /// In en, this message translates to:
  /// **'Payment Recieved'**
  String get paymentRecieved;

  /// No description provided for @noHistoryAvail.
  ///
  /// In en, this message translates to:
  /// **'No History Available'**
  String get noHistoryAvail;

  /// No description provided for @applyReferal.
  ///
  /// In en, this message translates to:
  /// **'Apply Referral'**
  String get applyReferal;

  /// No description provided for @enterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get enterReferralCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @requiredInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill out this form'**
  String get requiredInfo;

  /// No description provided for @welcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome 1111'**
  String get welcomeName;

  /// No description provided for @followSteps.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to begin your ride.'**
  String get followSteps;

  /// No description provided for @companyInfo.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyInfo;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @registerFor.
  ///
  /// In en, this message translates to:
  /// **'Register For'**
  String get registerFor;

  /// No description provided for @chooseServiceLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose your sevice location to register'**
  String get chooseServiceLocation;

  /// No description provided for @chooseServiceLoc.
  ///
  /// In en, this message translates to:
  /// **'Choose service location'**
  String get chooseServiceLoc;

  /// No description provided for @provideCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get provideCompanyName;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @provideCompanyAddress.
  ///
  /// In en, this message translates to:
  /// **'Company address'**
  String get provideCompanyAddress;

  /// No description provided for @enterCompanyAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter company address'**
  String get enterCompanyAddress;

  /// No description provided for @provideCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get provideCity;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get enterCity;

  /// No description provided for @providePostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get providePostalCode;

  /// No description provided for @enterPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter postal code'**
  String get enterPostalCode;

  /// No description provided for @provideTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'Company tax number'**
  String get provideTaxNumber;

  /// No description provided for @enterTaxNumer.
  ///
  /// In en, this message translates to:
  /// **'Enter tax number'**
  String get enterTaxNumer;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @submitNecessaryDocs.
  ///
  /// In en, this message translates to:
  /// **'Please submit the necessary documents'**
  String get submitNecessaryDocs;

  /// No description provided for @evaluatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Your document didn\'t meet our requirements'**
  String get evaluatingProfile;

  /// No description provided for @profileApprove.
  ///
  /// In en, this message translates to:
  /// **'Please review guidelines and resubmit'**
  String get profileApprove;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @enterValidEmailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email or mobile number'**
  String get enterValidEmailOrMobile;

  /// No description provided for @enterEmailOrMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter email or mobile number'**
  String get enterEmailOrMobile;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataFound;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocument;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @tripsTaken.
  ///
  /// In en, this message translates to:
  /// **'Trips Taken'**
  String get tripsTaken;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'LeaderBoard'**
  String get leaderboard;

  /// No description provided for @prev.
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @complaintDetails.
  ///
  /// In en, this message translates to:
  /// **'Complaint Details'**
  String get complaintDetails;

  /// No description provided for @writeYourComplaint.
  ///
  /// In en, this message translates to:
  /// **'Write your complaint here...'**
  String get writeYourComplaint;

  /// No description provided for @makeNewBookingToView.
  ///
  /// In en, this message translates to:
  /// **'Make new booking to view it here.'**
  String get makeNewBookingToView;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @vehicleMake.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Make'**
  String get vehicleMake;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @vehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Color'**
  String get vehicleColor;

  /// No description provided for @vehicleNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Not Assigned'**
  String get vehicleNotAssigned;

  /// No description provided for @modifyVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Modify Vehicle Info'**
  String get modifyVehicleInfo;

  /// No description provided for @tapToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload image'**
  String get tapToUploadImage;

  /// No description provided for @chooseExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Choose Expiry Date'**
  String get chooseExpiryDate;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @chooseYourSubscription.
  ///
  /// In en, this message translates to:
  /// **'Choose your Subscription'**
  String get chooseYourSubscription;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @continueWithoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Continue Without Plans'**
  String get continueWithoutPlans;

  /// No description provided for @continueWithoutPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Continue without plan will cause you to pay admin commission for each ride'**
  String get continueWithoutPlanDesc;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @weWillMissYou.
  ///
  /// In en, this message translates to:
  /// **'We will miss you!'**
  String get weWillMissYou;

  /// No description provided for @instantActivity.
  ///
  /// In en, this message translates to:
  /// **'Instant Activity'**
  String get instantActivity;

  /// No description provided for @instantRide.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instantRide;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @bidOnFare.
  ///
  /// In en, this message translates to:
  /// **'Bid On Fare'**
  String get bidOnFare;

  /// No description provided for @showBubbleIcon.
  ///
  /// In en, this message translates to:
  /// **'Appear on Top'**
  String get showBubbleIcon;

  /// No description provided for @pricePerDistance.
  ///
  /// In en, this message translates to:
  /// **'My Fare'**
  String get pricePerDistance;

  /// No description provided for @enterYourPriceBelow.
  ///
  /// In en, this message translates to:
  /// **'Enter your price below'**
  String get enterYourPriceBelow;

  /// No description provided for @enterYourPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter your price'**
  String get enterYourPrice;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaysEarnings;

  /// No description provided for @ridesTaken.
  ///
  /// In en, this message translates to:
  /// **'Rides Taken'**
  String get ridesTaken;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get userName;

  /// No description provided for @userMobile.
  ///
  /// In en, this message translates to:
  /// **'Customer Mobile'**
  String get userMobile;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @onTheWayToDrop.
  ///
  /// In en, this message translates to:
  /// **'On the way to drop location'**
  String get onTheWayToDrop;

  /// No description provided for @ridePrice.
  ///
  /// In en, this message translates to:
  /// **'Ride Price'**
  String get ridePrice;

  /// No description provided for @endRide.
  ///
  /// In en, this message translates to:
  /// **'End Ride'**
  String get endRide;

  /// No description provided for @notifyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Notify Admin'**
  String get notifyAdmin;

  /// No description provided for @notifiedToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Notified to Admin'**
  String get notifiedToAdmin;

  /// No description provided for @tripSummary.
  ///
  /// In en, this message translates to:
  /// **'Trip Summary'**
  String get tripSummary;

  /// No description provided for @howWasYourLastRide.
  ///
  /// In en, this message translates to:
  /// **'How was your last ride with 1111?'**
  String get howWasYourLastRide;

  /// No description provided for @leaveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Leave Feedback (Optional)'**
  String get leaveFeedback;

  /// No description provided for @slideToAccept.
  ///
  /// In en, this message translates to:
  /// **'Slide to Accept'**
  String get slideToAccept;

  /// No description provided for @rideWillCancelAutomatically.
  ///
  /// In en, this message translates to:
  /// **'This ride will be cancelled automatically after 1111 seconds.'**
  String get rideWillCancelAutomatically;

  /// No description provided for @onWayToPickup.
  ///
  /// In en, this message translates to:
  /// **'On the way to pick up'**
  String get onWayToPickup;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @selectReasonForCancel.
  ///
  /// In en, this message translates to:
  /// **'Please select the reason for cancellation'**
  String get selectReasonForCancel;

  /// No description provided for @arrivedWaiting.
  ///
  /// In en, this message translates to:
  /// **'Arrived, Waiting for customer'**
  String get arrivedWaiting;

  /// No description provided for @startRide.
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get startRide;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid email address'**
  String get enterValidEmail;

  /// No description provided for @minimumCharacRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters required'**
  String get minimumCharacRequired;

  /// No description provided for @enterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid mobile number'**
  String get enterValidMobile;

  /// No description provided for @pleaseEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'please enter mobile number'**
  String get pleaseEnterMobileNumber;

  /// No description provided for @pleaseEnterUserName.
  ///
  /// In en, this message translates to:
  /// **'Please enter user name'**
  String get pleaseEnterUserName;

  /// No description provided for @enterRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Please enter all required field'**
  String get enterRequiredField;

  /// No description provided for @subscriptionHeading.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active subscription, Please choose any subscription for additional benefits'**
  String get subscriptionHeading;

  /// No description provided for @pickImageFrom.
  ///
  /// In en, this message translates to:
  /// **'Pick Image From'**
  String get pickImageFrom;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @searchPlace.
  ///
  /// In en, this message translates to:
  /// **'Search Place'**
  String get searchPlace;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @chooseGoods.
  ///
  /// In en, this message translates to:
  /// **'Choose Goods'**
  String get chooseGoods;

  /// No description provided for @loose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get loose;

  /// No description provided for @qtyWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Qty with unit'**
  String get qtyWithUnit;

  /// No description provided for @captureLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Loading Image'**
  String get captureLoadingImage;

  /// No description provided for @captureGoodsLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Goods Loading Image'**
  String get captureGoodsLoadingImage;

  /// No description provided for @dispatchGoods.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Goods'**
  String get dispatchGoods;

  /// No description provided for @getUserSignature.
  ///
  /// In en, this message translates to:
  /// **'Get User Signature'**
  String get getUserSignature;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber;

  /// No description provided for @enterRideOtpDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP shown in the customer\'s app to begin the ride'**
  String get enterRideOtpDesc;

  /// No description provided for @rideVerification.
  ///
  /// In en, this message translates to:
  /// **'Ride Verification'**
  String get rideVerification;

  /// No description provided for @shipmentVerification.
  ///
  /// In en, this message translates to:
  /// **'Shipment Verification'**
  String get shipmentVerification;

  /// No description provided for @uploadShipmentProof.
  ///
  /// In en, this message translates to:
  /// **'Upload Shipment Proof'**
  String get uploadShipmentProof;

  /// No description provided for @dropImageHere.
  ///
  /// In en, this message translates to:
  /// **'Drop Image Here'**
  String get dropImageHere;

  /// No description provided for @supportedImage.
  ///
  /// In en, this message translates to:
  /// **'(Supports: 1111)'**
  String get supportedImage;

  /// No description provided for @drawSignature.
  ///
  /// In en, this message translates to:
  /// **'Draw your signature below'**
  String get drawSignature;

  /// No description provided for @confirmSignature.
  ///
  /// In en, this message translates to:
  /// **'Confirm Signature'**
  String get confirmSignature;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear Signature'**
  String get clearSignature;

  /// No description provided for @pickGoods.
  ///
  /// In en, this message translates to:
  /// **'Pick Goods'**
  String get pickGoods;

  /// No description provided for @complaintLengthError.
  ///
  /// In en, this message translates to:
  /// **'Complaint must be at least 10 characters long.'**
  String get complaintLengthError;

  /// No description provided for @addAContact.
  ///
  /// In en, this message translates to:
  /// **'Add a Contact'**
  String get addAContact;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get choosePlan;

  /// No description provided for @lowWalletBalanceForSubscription.
  ///
  /// In en, this message translates to:
  /// **'Your wallet doesn\'t have enough balance to pay for this subscription, please try another method or add money in wallet'**
  String get lowWalletBalanceForSubscription;

  /// No description provided for @cancelRideSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure wan\'t to cancel this ride?'**
  String get cancelRideSure;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @modifyDocument.
  ///
  /// In en, this message translates to:
  /// **'Modify Document'**
  String get modifyDocument;

  /// No description provided for @profileDeclined.
  ///
  /// In en, this message translates to:
  /// **'Profile Declined'**
  String get profileDeclined;

  /// No description provided for @reuploadDocs.
  ///
  /// In en, this message translates to:
  /// **'Kindly re-upload the required document'**
  String get reuploadDocs;

  /// No description provided for @userCancelledRide.
  ///
  /// In en, this message translates to:
  /// **'User cancelled this ride'**
  String get userCancelledRide;

  /// No description provided for @userCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'The user has cancelled the ride. You’re now available for other requests'**
  String get userCancelledDesc;

  /// No description provided for @userDeclinedBid.
  ///
  /// In en, this message translates to:
  /// **'User Declined Bid'**
  String get userDeclinedBid;

  /// No description provided for @userDeclinedBidDesc.
  ///
  /// In en, this message translates to:
  /// **'Please modify your amount and try again or try another ride'**
  String get userDeclinedBidDesc;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @selectCancelReasonError.
  ///
  /// In en, this message translates to:
  /// **'Please select any cancel reason'**
  String get selectCancelReasonError;

  /// No description provided for @getSignatureError.
  ///
  /// In en, this message translates to:
  /// **'Please get signature to proceed further'**
  String get getSignatureError;

  /// No description provided for @giveRatingsError.
  ///
  /// In en, this message translates to:
  /// **'Please give ratings'**
  String get giveRatingsError;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account will erase all personal data. Do you want to proceed?'**
  String get deleteText;

  /// No description provided for @welcomeToName.
  ///
  /// In en, this message translates to:
  /// **'Welcome to 1111'**
  String get welcomeToName;

  /// No description provided for @locationPermDesc.
  ///
  /// In en, this message translates to:
  /// **'111 uses your background location to track your trips and enhance the customer experience, even when the app is closed. It allows customers to locate you accurately and optimize your rides.'**
  String get locationPermDesc;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @lowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low balance in wallet'**
  String get lowBalance;

  /// No description provided for @yourId.
  ///
  /// In en, this message translates to:
  /// **'Your ID'**
  String get yourId;

  /// No description provided for @noComplaints.
  ///
  /// In en, this message translates to:
  /// **'No Complaint List Available'**
  String get noComplaints;

  /// No description provided for @complaintsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Complaint has been submitted.'**
  String get complaintsSubmitted;

  /// No description provided for @failToUpdateDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to update details'**
  String get failToUpdateDetails;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @rental.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get rental;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More...'**
  String get loadMore;

  /// No description provided for @noDataLeaderBoard.
  ///
  /// In en, this message translates to:
  /// **'No Data in Leaderboard.'**
  String get noDataLeaderBoard;

  /// No description provided for @addRankingText.
  ///
  /// In en, this message translates to:
  /// **'To add rankings, please start your ride'**
  String get addRankingText;

  /// No description provided for @googleMap.
  ///
  /// In en, this message translates to:
  /// **'Google Map'**
  String get googleMap;

  /// No description provided for @openstreet.
  ///
  /// In en, this message translates to:
  /// **'Open Street'**
  String get openstreet;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotification;

  /// No description provided for @deleteNotificationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to Delete\\nthis Notification?'**
  String get deleteNotificationContent;

  /// No description provided for @outStation.
  ///
  /// In en, this message translates to:
  /// **'Out Station'**
  String get outStation;

  /// No description provided for @returnTrip.
  ///
  /// In en, this message translates to:
  /// **'Return trip'**
  String get returnTrip;

  /// No description provided for @oneWayTrip.
  ///
  /// In en, this message translates to:
  /// **'One Way trip'**
  String get oneWayTrip;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @selectContact.
  ///
  /// In en, this message translates to:
  /// **'Select Contact'**
  String get selectContact;

  /// No description provided for @deleteContactContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to Delete\\nthis Contact?'**
  String get deleteContactContent;

  /// No description provided for @deleteSos.
  ///
  /// In en, this message translates to:
  /// **'Delete Sos'**
  String get deleteSos;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare '**
  String get fare;

  /// No description provided for @totalFare.
  ///
  /// In en, this message translates to:
  /// **'Total Fare'**
  String get totalFare;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @customerConvenienceFee.
  ///
  /// In en, this message translates to:
  /// **'Customer Convenience Fee'**
  String get customerConvenienceFee;

  /// No description provided for @tripEarnings.
  ///
  /// In en, this message translates to:
  /// **'Trip Earnings'**
  String get tripEarnings;

  /// No description provided for @discountFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Discount credited from wallet'**
  String get discountFromWallet;

  /// No description provided for @tripEarningsCapital.
  ///
  /// In en, this message translates to:
  /// **'TRIP EARNINGS'**
  String get tripEarningsCapital;

  /// No description provided for @tripInfo.
  ///
  /// In en, this message translates to:
  /// **'TRIP INFO'**
  String get tripInfo;

  /// No description provided for @rideLater.
  ///
  /// In en, this message translates to:
  /// **'Ride later'**
  String get rideLater;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @detailsUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Details updated successfully'**
  String get detailsUpdateSuccess;

  /// No description provided for @detailsUpdatefail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update details'**
  String get detailsUpdatefail;

  /// No description provided for @noDriverAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Driver Available to Assign'**
  String get noDriverAvailable;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Success!'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed!'**
  String get paymentFailed;

  /// No description provided for @noPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'No payment history yet.'**
  String get noPaymentHistory;

  /// No description provided for @bookingRideText.
  ///
  /// In en, this message translates to:
  /// **'Start your journey by booking a ride today!'**
  String get bookingRideText;

  /// No description provided for @subscriptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription Success'**
  String get subscriptionSuccess;

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription Expired'**
  String get subscriptionExpired;

  /// No description provided for @subscriptionSuccessDescOne.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active.\\nPlan A is valid until'**
  String get subscriptionSuccessDescOne;

  /// No description provided for @subscriptionSuccessDescTwo.
  ///
  /// In en, this message translates to:
  /// **'\\nEnjoy your benefits!'**
  String get subscriptionSuccessDescTwo;

  /// No description provided for @subscriptionFailedDescOne.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has expired.Weekly'**
  String get subscriptionFailedDescOne;

  /// No description provided for @subscriptionFailedDescTwo.
  ///
  /// In en, this message translates to:
  /// **'was valid until'**
  String get subscriptionFailedDescTwo;

  /// No description provided for @subscriptionFailedDescThree.
  ///
  /// In en, this message translates to:
  /// **'\\nRenew now to continue using our services.'**
  String get subscriptionFailedDescThree;

  /// No description provided for @referalShareOne.
  ///
  /// In en, this message translates to:
  /// **'Join me on 111! using my invite code 222 To make easy your ride'**
  String get referalShareOne;

  /// No description provided for @referalShareTwo.
  ///
  /// In en, this message translates to:
  /// **'To make easy your ride'**
  String get referalShareTwo;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enterNewPassword;

  /// No description provided for @rideDetails.
  ///
  /// In en, this message translates to:
  /// **'Ride details'**
  String get rideDetails;

  /// No description provided for @coupons.
  ///
  /// In en, this message translates to:
  /// **'Coupons'**
  String get coupons;

  /// No description provided for @choosePayment.
  ///
  /// In en, this message translates to:
  /// **'Choose Payment'**
  String get choosePayment;

  /// No description provided for @chooseStop.
  ///
  /// In en, this message translates to:
  /// **'Choose the stop you are completing'**
  String get chooseStop;

  /// No description provided for @taxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get taxi;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @enterPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter pickup location'**
  String get enterPickupLocation;

  /// No description provided for @whereToGo.
  ///
  /// In en, this message translates to:
  /// **'Where to go ?'**
  String get whereToGo;

  /// No description provided for @selectFromMap.
  ///
  /// In en, this message translates to:
  /// **'Select from map'**
  String get selectFromMap;

  /// No description provided for @bidAmount.
  ///
  /// In en, this message translates to:
  /// **'Bid Amount'**
  String get bidAmount;

  /// No description provided for @noRequest.
  ///
  /// In en, this message translates to:
  /// **'No requests right now!'**
  String get noRequest;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @searchResult.
  ///
  /// In en, this message translates to:
  /// **'Search Result'**
  String get searchResult;

  /// No description provided for @onlineCaps.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get onlineCaps;

  /// No description provided for @offlineCaps.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offlineCaps;

  /// No description provided for @waitingForUserResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for User response'**
  String get waitingForUserResponse;

  /// No description provided for @yourOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re Online'**
  String get yourOnline;

  /// No description provided for @yourOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re Offline'**
  String get yourOffline;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @incentives.
  ///
  /// In en, this message translates to:
  /// **'Incentives'**
  String get incentives;

  /// No description provided for @todayCaps.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayCaps;

  /// No description provided for @weeklyCaps.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get weeklyCaps;

  /// No description provided for @earnUptoText.
  ///
  /// In en, this message translates to:
  /// **'Earn up to'**
  String get earnUptoText;

  /// No description provided for @byCompletingRideText.
  ///
  /// In en, this message translates to:
  /// **'by completing 12 Rides'**
  String get byCompletingRideText;

  /// No description provided for @missedIncentiveText.
  ///
  /// In en, this message translates to:
  /// **'Sorry you missed this Incentive'**
  String get missedIncentiveText;

  /// No description provided for @earnedIncentiveText.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned the incentive!'**
  String get earnedIncentiveText;

  /// No description provided for @completeText.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeText;

  /// No description provided for @acheivedTargetText.
  ///
  /// In en, this message translates to:
  /// **'You successfully achieved your targets!'**
  String get acheivedTargetText;

  /// No description provided for @missedTargetText.
  ///
  /// In en, this message translates to:
  /// **'Missed! You did not complete your targets'**
  String get missedTargetText;

  /// No description provided for @selectDateForIncentives.
  ///
  /// In en, this message translates to:
  /// **'Select a date to view upcoming incentives'**
  String get selectDateForIncentives;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @customerPays.
  ///
  /// In en, this message translates to:
  /// **'Customer Pays'**
  String get customerPays;

  /// No description provided for @taxText.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxText;

  /// No description provided for @tripId.
  ///
  /// In en, this message translates to:
  /// **'TRIP ID'**
  String get tripId;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @paymentMethodSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment method updated successfully'**
  String get paymentMethodSuccess;

  /// No description provided for @recentWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Recent Withdrawal'**
  String get recentWithdrawal;

  /// No description provided for @requestWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Request Withdraw'**
  String get requestWithdraw;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @textAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get textAdd;

  /// No description provided for @textView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get textView;

  /// No description provided for @updatePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Update Payment Method'**
  String get updatePaymentMethod;

  /// No description provided for @registeredFor.
  ///
  /// In en, this message translates to:
  /// **'Registered for - 1111'**
  String get registeredFor;

  /// No description provided for @serviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Service Location'**
  String get serviceLocation;

  /// No description provided for @comapnyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get comapnyName;

  /// No description provided for @companyAddress.
  ///
  /// In en, this message translates to:
  /// **'Company Address'**
  String get companyAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @taxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax Number'**
  String get taxNumber;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @insufficientWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance to withdraw this amount'**
  String get insufficientWithdraw;

  /// No description provided for @waitingText.
  ///
  /// In en, this message translates to:
  /// **'After * minutes, a *** /min surcharge applies for additional waiting time.'**
  String get waitingText;

  /// No description provided for @waitingForApprovelText.
  ///
  /// In en, this message translates to:
  /// **'Your documents are under review.Approval will be given within 24 hours Please wait to start your earnings.!'**
  String get waitingForApprovelText;

  /// No description provided for @diagnotics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnotics;

  /// No description provided for @notGettingRequest.
  ///
  /// In en, this message translates to:
  /// **'Not getting request?'**
  String get notGettingRequest;

  /// No description provided for @documentMissingText.
  ///
  /// In en, this message translates to:
  /// **'Please add All the documents'**
  String get documentMissingText;

  /// No description provided for @rideFare.
  ///
  /// In en, this message translates to:
  /// **'Ride Fare'**
  String get rideFare;

  /// No description provided for @performanceAndRating.
  ///
  /// In en, this message translates to:
  /// **'Performance & Rating'**
  String get performanceAndRating;

  /// No description provided for @loginHourDetails.
  ///
  /// In en, this message translates to:
  /// **'Login Hour Details'**
  String get loginHourDetails;

  /// No description provided for @totalLoginHours.
  ///
  /// In en, this message translates to:
  /// **'Total Login Hrs'**
  String get totalLoginHours;

  /// No description provided for @averageLoginHrs.
  ///
  /// In en, this message translates to:
  /// **'Average Login Hrs/day'**
  String get averageLoginHrs;

  /// No description provided for @revenueDetails.
  ///
  /// In en, this message translates to:
  /// **'Revenue Details'**
  String get revenueDetails;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @averageRevenue.
  ///
  /// In en, this message translates to:
  /// **'Average Revenue /day'**
  String get averageRevenue;

  /// No description provided for @overallRatings.
  ///
  /// In en, this message translates to:
  /// **'Overall Ratings'**
  String get overallRatings;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @below.
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get below;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @bad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get bad;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @offlineConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go offline?'**
  String get offlineConfirmation;

  /// No description provided for @onlineSmall.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineSmall;

  /// No description provided for @offlineSmall.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineSmall;

  /// No description provided for @onrideSmall.
  ///
  /// In en, this message translates to:
  /// **'Onride'**
  String get onrideSmall;

  /// No description provided for @noWalletHistoryText.
  ///
  /// In en, this message translates to:
  /// **'No Wallet History Available...'**
  String get noWalletHistoryText;

  /// No description provided for @transferText.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferText;

  /// No description provided for @noContactsSos.
  ///
  /// In en, this message translates to:
  /// **'No contacts added'**
  String get noContactsSos;

  /// No description provided for @addContactSos.
  ///
  /// In en, this message translates to:
  /// **'For your security, add at least one\n person that we can call in an emergency.'**
  String get addContactSos;

  /// No description provided for @incentiveAlreadySelected.
  ///
  /// In en, this message translates to:
  /// **'Incentive already selected.'**
  String get incentiveAlreadySelected;

  /// No description provided for @incentiveNotAvailableWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly\'s incentive is not available.'**
  String get incentiveNotAvailableWeekly;

  /// No description provided for @incentiveNotAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s incentive is not available.'**
  String get incentiveNotAvailableToday;

  /// No description provided for @dailyCaps.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get dailyCaps;

  /// No description provided for @levelupText.
  ///
  /// In en, this message translates to:
  /// **'Level Up'**
  String get levelupText;

  /// No description provided for @rewardsText.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsText;

  /// No description provided for @levelupSuccessText.
  ///
  /// In en, this message translates to:
  /// **'25 rides completed so you earned the level 1 congrats for earning this level'**
  String get levelupSuccessText;

  /// No description provided for @levelText.
  ///
  /// In en, this message translates to:
  /// **'Level  '**
  String get levelText;

  /// No description provided for @myRewardsText.
  ///
  /// In en, this message translates to:
  /// **'My Rewards'**
  String get myRewardsText;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works?'**
  String get howItWorks;

  /// No description provided for @pointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Point History'**
  String get pointsHistory;

  /// No description provided for @pointsRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Point Redeemed'**
  String get pointsRedeemed;

  /// No description provided for @rideReward.
  ///
  /// In en, this message translates to:
  /// **'Ride Reward'**
  String get rideReward;

  /// No description provided for @yourPoints.
  ///
  /// In en, this message translates to:
  /// **'Your Points'**
  String get yourPoints;

  /// No description provided for @redeemPoints.
  ///
  /// In en, this message translates to:
  /// **'Redeem Points'**
  String get redeemPoints;

  /// No description provided for @redeemPointsToWallet.
  ///
  /// In en, this message translates to:
  /// **'Redeem point to wallet money.'**
  String get redeemPointsToWallet;

  /// No description provided for @redeemRateText.
  ///
  /// In en, this message translates to:
  /// **'Redeem rate is : *pt =z1'**
  String get redeemRateText;

  /// No description provided for @redeemedAmount.
  ///
  /// In en, this message translates to:
  /// **'Redeemed amount :s*'**
  String get redeemedAmount;

  /// No description provided for @howItWorksPointOne.
  ///
  /// In en, this message translates to:
  /// **'Earn points.'**
  String get howItWorksPointOne;

  /// No description provided for @howItWorksPointTwo.
  ///
  /// In en, this message translates to:
  /// **'Accumulate points in your account.'**
  String get howItWorksPointTwo;

  /// No description provided for @howItWorksPointThree.
  ///
  /// In en, this message translates to:
  /// **'Convert points to money when a certain \namount is reached.'**
  String get howItWorksPointThree;

  /// No description provided for @howItWorksPointFour.
  ///
  /// In en, this message translates to:
  /// **'Redeem converted points for discounts or \n cashback.'**
  String get howItWorksPointFour;

  /// No description provided for @rewardsGreaterText.
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than minimum reward points'**
  String get rewardsGreaterText;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @editBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Bank Details'**
  String get editBankDetails;

  /// No description provided for @bankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get bankDetails;

  /// No description provided for @distanceSelector.
  ///
  /// In en, this message translates to:
  /// **'Distance Selector'**
  String get distanceSelector;

  /// No description provided for @rideAtText.
  ///
  /// In en, this message translates to:
  /// **'Ride at'**
  String get rideAtText;

  /// No description provided for @rentalPackageText.
  ///
  /// In en, this message translates to:
  /// **'Rental Package'**
  String get rentalPackageText;

  /// No description provided for @tripsDoneText.
  ///
  /// In en, this message translates to:
  /// **'trips done'**
  String get tripsDoneText;

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get away;

  /// No description provided for @mi.
  ///
  /// In en, this message translates to:
  /// **'MI'**
  String get mi;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get km;

  /// No description provided for @pleaseSelectUserTypeText.
  ///
  /// In en, this message translates to:
  /// **'Please select the user type'**
  String get pleaseSelectUserTypeText;

  /// No description provided for @loginSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Login Successfully'**
  String get loginSuccessText;

  /// No description provided for @noSummaryText.
  ///
  /// In en, this message translates to:
  /// **'No summary for the day.'**
  String get noSummaryText;

  /// No description provided for @mapSettings.
  ///
  /// In en, this message translates to:
  /// **'Map Settings'**
  String get mapSettings;

  /// No description provided for @sosText.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosText;

  /// No description provided for @webViewText.
  ///
  /// In en, this message translates to:
  /// **'Web View'**
  String get webViewText;

  /// No description provided for @youCanEditText.
  ///
  /// In en, this message translates to:
  /// **'You can edit your'**
  String get youCanEditText;

  /// No description provided for @here.
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get here;

  /// No description provided for @enterOTPText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP'**
  String get enterOTPText;

  /// No description provided for @noRewardsTopText.
  ///
  /// In en, this message translates to:
  /// **'No Rewards Available!'**
  String get noRewardsTopText;

  /// No description provided for @noRewardSubText.
  ///
  /// In en, this message translates to:
  /// **'Achieve your target milestones to earn exciting rewards'**
  String get noRewardSubText;

  /// No description provided for @testOtp.
  ///
  /// In en, this message translates to:
  /// **'Login to your account with test OTP ***'**
  String get testOtp;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get choosePaymentMethod;

  /// No description provided for @openSetting.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSetting;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location access is needed for running the app, please enable it in settings and tap done'**
  String get locationAccess;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signup;

  /// No description provided for @manageFleet.
  ///
  /// In en, this message translates to:
  /// **'Manage Fleet'**
  String get manageFleet;

  /// No description provided for @fleetDetails.
  ///
  /// In en, this message translates to:
  /// **'Fleet Details'**
  String get fleetDetails;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'No Subscription Chosen Yet!'**
  String get noSubscription;

  /// No description provided for @noSubscriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium benefits by selecting \na subscription plan tailored to your needs.'**
  String get noSubscriptionContent;

  /// No description provided for @followStepsOwner.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps to empower fleet management'**
  String get followStepsOwner;

  /// No description provided for @validPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid postal code'**
  String get validPostalCode;

  /// No description provided for @outstationRides.
  ///
  /// In en, this message translates to:
  /// **'OUTSTATION RIDES'**
  String get outstationRides;

  /// No description provided for @biddingLimitText.
  ///
  /// In en, this message translates to:
  /// **'Bidding Limit Crossed'**
  String get biddingLimitText;

  /// No description provided for @fleetsUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Fleets Unassigned'**
  String get fleetsUnassigned;

  /// No description provided for @roundTrip.
  ///
  /// In en, this message translates to:
  /// **'Round Trip'**
  String get roundTrip;

  /// No description provided for @assinged.
  ///
  /// In en, this message translates to:
  /// **'Assinged'**
  String get assinged;

  /// No description provided for @unAssinged.
  ///
  /// In en, this message translates to:
  /// **'Unassinged'**
  String get unAssinged;

  /// No description provided for @validDateValue.
  ///
  /// In en, this message translates to:
  /// **'please enter valid date value'**
  String get validDateValue;

  /// No description provided for @chooseYourRideText.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Ride'**
  String get chooseYourRideText;

  /// No description provided for @outstationRejectText.
  ///
  /// In en, this message translates to:
  /// **'Bid rejected. Try with lower amount for \nbetter chances!'**
  String get outstationRejectText;

  /// No description provided for @outStatonSuccessText.
  ///
  /// In en, this message translates to:
  /// **'A user accepted your bid. Check it in Upcoming section.'**
  String get outStatonSuccessText;

  /// No description provided for @readyToPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready to Pickup'**
  String get readyToPickup;

  /// No description provided for @outStationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Once your bid is accepted by user, you will be notified in upcoming section'**
  String get outStationSuccess;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, User'**
  String get welcomeUser;

  /// No description provided for @welcomeDriver.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Driver'**
  String get welcomeDriver;

  /// No description provided for @welcomeOwner.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Owner'**
  String get welcomeOwner;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @minTime.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minTime;

  /// No description provided for @locationBackgroundServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Location background service running'**
  String get locationBackgroundServiceTitle;

  /// No description provided for @locationBackgroundServiceNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'1111 will continue to receive your location in background'**
  String get locationBackgroundServiceNotificationTitle;

  /// No description provided for @additionalCharges.
  ///
  /// In en, this message translates to:
  /// **'Additional Charges'**
  String get additionalCharges;

  /// No description provided for @phoneNumberNotValid.
  ///
  /// In en, this message translates to:
  /// **'The provided phone number is not valid.'**
  String get phoneNumberNotValid;

  /// No description provided for @otpSendTo.
  ///
  /// In en, this message translates to:
  /// **'OTP send to 1111'**
  String get otpSendTo;

  /// No description provided for @correctOtporResend.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct Otp or resend'**
  String get correctOtporResend;

  /// No description provided for @verifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verified Successfully'**
  String get verifiedSuccessfully;

  /// No description provided for @enterValidOtp.
  ///
  /// In en, this message translates to:
  /// **'please enter the valid OTP'**
  String get enterValidOtp;

  /// No description provided for @enterTheOtp.
  ///
  /// In en, this message translates to:
  /// **'please enter the OTP'**
  String get enterTheOtp;

  /// No description provided for @registerSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Registered Successfully'**
  String get registerSuccessfully;

  /// No description provided for @enterTheCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get enterTheCode;

  /// No description provided for @enterValidPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid password'**
  String get enterValidPassword;

  /// No description provided for @loginSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Login Successfully'**
  String get loginSuccessfully;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @getYourCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'allow location permission to get your current location'**
  String get getYourCurrentLocation;

  /// No description provided for @myServices.
  ///
  /// In en, this message translates to:
  /// **'My Services'**
  String get myServices;

  /// No description provided for @payAdmin.
  ///
  /// In en, this message translates to:
  /// **'Pay Admin'**
  String get payAdmin;

  /// No description provided for @yourDriverIsText.
  ///
  /// In en, this message translates to:
  /// **'Your Driver is'**
  String get yourDriverIsText;

  /// No description provided for @demoOtpText.
  ///
  /// In en, this message translates to:
  /// **'Login to your account with test OTP 123456'**
  String get demoOtpText;

  /// No description provided for @otpForLogin.
  ///
  /// In en, this message translates to:
  /// **'Otp for Login'**
  String get otpForLogin;

  /// No description provided for @cancellationFee.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Fee'**
  String get cancellationFee;

  /// No description provided for @reportsText.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsText;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get to;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @maximumRideFareError.
  ///
  /// In en, this message translates to:
  /// **'Offer ride fare must lesser than maximum fare.'**
  String get maximumRideFareError;

  /// No description provided for @minimumRideFareError.
  ///
  /// In en, this message translates to:
  /// **'Offer ride fare must be greater than minimum fare.'**
  String get minimumRideFareError;

  /// No description provided for @overlayPermission.
  ///
  /// In en, this message translates to:
  /// **'Please allow Overlay Permission to appear on other apps'**
  String get overlayPermission;

  /// No description provided for @incentiveEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Complete your First ride to unlock incentives!'**
  String get incentiveEmptyText;

  /// No description provided for @totalTripsKms.
  ///
  /// In en, this message translates to:
  /// **'Total Trip kms'**
  String get totalTripsKms;

  /// No description provided for @chargeDetails.
  ///
  /// In en, this message translates to:
  /// **'Charge Details'**
  String get chargeDetails;

  /// No description provided for @fillTheDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill the details'**
  String get fillTheDetails;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @dignosticsAssistText.
  ///
  /// In en, this message translates to:
  /// **'Not getting the expected response?**Let us assist you!'**
  String get dignosticsAssistText;

  /// No description provided for @dignosticsSolutionText.
  ///
  /// In en, this message translates to:
  /// **'We\'ll identify device-specific issues and**provide tailored solutions to resolve them.'**
  String get dignosticsSolutionText;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @internetConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Internet Connectivity'**
  String get internetConnectivity;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @notificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Notification Status'**
  String get notificationStatus;

  /// No description provided for @soundStatus.
  ///
  /// In en, this message translates to:
  /// **'Sound Status'**
  String get soundStatus;

  /// No description provided for @internetSubText.
  ///
  /// In en, this message translates to:
  /// **'We\'ll assess the stability of your current \ninternet connection.'**
  String get internetSubText;

  /// No description provided for @locationSubText.
  ///
  /// In en, this message translates to:
  /// **'We\'ll verify your GPS to ensure accurate \nlocation tracking.'**
  String get locationSubText;

  /// No description provided for @notificationSubText.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a test notification to you.'**
  String get notificationSubText;

  /// No description provided for @soundSubText.
  ///
  /// In en, this message translates to:
  /// **'A test sound will be sent to you.'**
  String get soundSubText;

  /// No description provided for @checkedText.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get checkedText;

  /// No description provided for @alertCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Is this your current location ?'**
  String get alertCurrentLocation;

  /// No description provided for @alertNotificationText.
  ///
  /// In en, this message translates to:
  /// **'Have you received the \nnotification?'**
  String get alertNotificationText;

  /// No description provided for @alertNotificationSubText.
  ///
  /// In en, this message translates to:
  /// **'If you have received the * then \ntap on the “YES” button.'**
  String get alertNotificationSubText;

  /// No description provided for @alertSoundText.
  ///
  /// In en, this message translates to:
  /// **'Have you received the \nrequest sound?'**
  String get alertSoundText;

  /// No description provided for @testSound.
  ///
  /// In en, this message translates to:
  /// **'Test Sound'**
  String get testSound;

  /// No description provided for @checkLocation.
  ///
  /// In en, this message translates to:
  /// **'Check Location'**
  String get checkLocation;

  /// No description provided for @checkNotification.
  ///
  /// In en, this message translates to:
  /// **'Check Notification'**
  String get checkNotification;

  /// No description provided for @diagnosticFinalAlertText.
  ///
  /// In en, this message translates to:
  /// **'We could not detect any problem with your device.'**
  String get diagnosticFinalAlertText;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @locationPermissionText.
  ///
  /// In en, this message translates to:
  /// **'Kindly turn on your location to continue.'**
  String get locationPermissionText;

  /// No description provided for @whyBackgroundLocation.
  ///
  /// In en, this message translates to:
  /// **'Why Background Location?'**
  String get whyBackgroundLocation;

  /// No description provided for @uploadedDoccumentDeclined.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Documents Declined'**
  String get uploadedDoccumentDeclined;

  /// No description provided for @clearNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear Notifications'**
  String get clearNotifications;

  /// No description provided for @clearNotificationsText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you clear all notifications?'**
  String get clearNotificationsText;

  /// No description provided for @waitingChargeText.
  ///
  /// In en, this message translates to:
  /// **'a* /min surcharge applies for additional waiting time.'**
  String get waitingChargeText;

  /// No description provided for @waitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get waitingForPayment;

  /// No description provided for @payBysender.
  ///
  /// In en, this message translates to:
  /// **'Pay by Sender'**
  String get payBysender;

  /// No description provided for @payByreceiver.
  ///
  /// In en, this message translates to:
  /// **'Pay by Receiver'**
  String get payByreceiver;

  /// No description provided for @instruction.
  ///
  /// In en, this message translates to:
  /// **'Instruction'**
  String get instruction;

  /// No description provided for @enterTheCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter the credentials'**
  String get enterTheCredentials;

  /// No description provided for @selectCards.
  ///
  /// In en, this message translates to:
  /// **'Select Cards'**
  String get selectCards;

  /// No description provided for @selectCardText.
  ///
  /// In en, this message translates to:
  /// **'You can choose which card numbers you want to display in the list of payment methods on the invoice.'**
  String get selectCardText;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetails;

  /// No description provided for @enterCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Card Details'**
  String get enterCardDetails;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCardText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure, you want to delete this card ?'**
  String get deleteCardText;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicket;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @selectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Title'**
  String get selectTitle;

  /// No description provided for @selectArea.
  ///
  /// In en, this message translates to:
  /// **'Select Area'**
  String get selectArea;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter Description'**
  String get enterDescription;

  /// No description provided for @ticketId.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID :'**
  String get ticketId;

  /// No description provided for @titleColonText.
  ///
  /// In en, this message translates to:
  /// **'Title :'**
  String get titleColonText;

  /// No description provided for @supportTicket.
  ///
  /// In en, this message translates to:
  /// **'Support Ticket'**
  String get supportTicket;

  /// No description provided for @assignTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to :'**
  String get assignTo;

  /// No description provided for @requestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestType;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get acknowledged;

  /// No description provided for @viewTicket.
  ///
  /// In en, this message translates to:
  /// **'View Ticket :'**
  String get viewTicket;

  /// No description provided for @supportType.
  ///
  /// In en, this message translates to:
  /// **'Support Type'**
  String get supportType;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not Assigned'**
  String get notAssigned;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments : '**
  String get attachments;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send '**
  String get send;

  /// No description provided for @fillTheMessageField.
  ///
  /// In en, this message translates to:
  /// **'Please Fill the message field'**
  String get fillTheMessageField;

  /// No description provided for @supportEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No support tickets found.'**
  String get supportEmptyText;

  /// No description provided for @supportEmptySubText.
  ///
  /// In en, this message translates to:
  /// **'Need help? Create a new support request.'**
  String get supportEmptySubText;

  /// No description provided for @replyText.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyText;

  /// No description provided for @messageText.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageText;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter Message...'**
  String get enterMessage;

  /// No description provided for @fileLimitReached.
  ///
  /// In en, this message translates to:
  /// **'File Limit Reached'**
  String get fileLimitReached;

  /// No description provided for @messageSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Reply Message Sent Successfully'**
  String get messageSuccessText;

  /// No description provided for @noMessagesHere.
  ///
  /// In en, this message translates to:
  /// **'No Messages Here'**
  String get noMessagesHere;

  /// No description provided for @noAttachmentsText.
  ///
  /// In en, this message translates to:
  /// **'No Attachments Here'**
  String get noAttachmentsText;

  /// No description provided for @uploadMaxFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File (Max: 8 Files)'**
  String get uploadMaxFile;

  /// No description provided for @filesUploaded.
  ///
  /// In en, this message translates to:
  /// **'File(s) Uploaded'**
  String get filesUploaded;

  /// No description provided for @fillTheRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Please Fill the required field'**
  String get fillTheRequiredField;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get requestId;

  /// No description provided for @ticketCreated.
  ///
  /// In en, this message translates to:
  /// **'Ticket Created'**
  String get ticketCreated;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssues;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @colorText.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorText;

  /// No description provided for @savedCards.
  ///
  /// In en, this message translates to:
  /// **'Saved Cards'**
  String get savedCards;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// No description provided for @invoiceSendContent.
  ///
  /// In en, this message translates to:
  /// **'Invoice send to your registered email'**
  String get invoiceSendContent;

  /// No description provided for @accountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Account not verified'**
  String get accountNotVerified;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify now'**
  String get verifyNow;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @airportSurgeFee.
  ///
  /// In en, this message translates to:
  /// **'Airport Surge Fee'**
  String get airportSurgeFee;

  /// No description provided for @deleteFleetText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure,do you want to delete this vehicle?'**
  String get deleteFleetText;

  /// No description provided for @commercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get commercial;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'subscribed'**
  String get subscribed;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'subscribe'**
  String get subscribe;

  /// No description provided for @yourPlanisExpired.
  ///
  /// In en, this message translates to:
  /// **'Your plan is expired'**
  String get yourPlanisExpired;

  /// No description provided for @yourSubscriptionisActive.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active'**
  String get yourSubscriptionisActive;

  /// No description provided for @rideEndConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to end the trip?'**
  String get rideEndConfirmationText;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @highDemandArea.
  ///
  /// In en, this message translates to:
  /// **'High Demand Area'**
  String get highDemandArea;

  /// No description provided for @endsInMins.
  ///
  /// In en, this message translates to:
  /// **'Ends in ** mins'**
  String get endsInMins;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get callSupport;

  /// No description provided for @enableMyrouteBooking.
  ///
  /// In en, this message translates to:
  /// **'Enable My Route Booking'**
  String get enableMyrouteBooking;

  /// No description provided for @disableMyrouteBooking.
  ///
  /// In en, this message translates to:
  /// **'Disable My Route Booking'**
  String get disableMyrouteBooking;

  /// No description provided for @myRouteBooking.
  ///
  /// In en, this message translates to:
  /// **'MyRouteBooking'**
  String get myRouteBooking;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @myrouteDisabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'My Route Booking has been disabled successfully'**
  String get myrouteDisabledSuccessfully;

  /// No description provided for @myRouteEnabledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'My Route Booking has been enabled successfully'**
  String get myRouteEnabledSuccessfully;

  /// No description provided for @preferenceTotal.
  ///
  /// In en, this message translates to:
  /// **'Preference Charges'**
  String get preferenceTotal;

  /// No description provided for @seatsTaken.
  ///
  /// In en, this message translates to:
  /// **'Seats taken'**
  String get seatsTaken;

  /// No description provided for @onGoingRides.
  ///
  /// In en, this message translates to:
  /// **'On-going rides'**
  String get onGoingRides;

  /// No description provided for @currentTrip.
  ///
  /// In en, this message translates to:
  /// **'Current trip'**
  String get currentTrip;

  /// No description provided for @activeRidesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have 2 active rides'**
  String get activeRidesMessage;

  /// No description provided for @referral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referral;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to'**
  String get sendCode;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Number'**
  String get changeNumber;

  /// No description provided for @pleaseEnterMobileOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number or email to continue.'**
  String get pleaseEnterMobileOrEmail;

  /// No description provided for @driverConnect.
  ///
  /// In en, this message translates to:
  /// **'Driver Connect'**
  String get driverConnect;

  /// No description provided for @loginAsDriver.
  ///
  /// In en, this message translates to:
  /// **'Login as Driver'**
  String get loginAsDriver;

  /// No description provided for @loginAsOwner.
  ///
  /// In en, this message translates to:
  /// **'Login as Owner'**
  String get loginAsOwner;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Dont Have an Account?'**
  String get dontHaveAnAccount;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @verifyYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyYourAccount;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself to get started.'**
  String get getStarted;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @strongPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get strongPassword;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get verifyPhone;

  /// No description provided for @verifyMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your mobile number'**
  String get verifyMobileNumber;

  /// No description provided for @confirmOtpNumber.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a one-time password (OTP) to this number to confirm your identity.'**
  String get confirmOtpNumber;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already Have an Account?'**
  String get alreadyHaveAccount;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @necessaryDocument.
  ///
  /// In en, this message translates to:
  /// **'Please submit the necessary documents for verification.'**
  String get necessaryDocument;

  /// No description provided for @completeYourRegistration.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your vehicle to complete your registration.'**
  String get completeYourRegistration;

  /// No description provided for @reuploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Reupload Document'**
  String get reuploadDocument;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectType;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocument;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get notUploaded;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocuments;

  /// No description provided for @returningDetails.
  ///
  /// In en, this message translates to:
  /// **'Returning Details'**
  String get returningDetails;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @fareBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Fare Breakdown'**
  String get fareBreakdown;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo so user can recognize you'**
  String get addProfilePhoto;

  /// No description provided for @enterNameIdOrPassport.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name as it appears on your ID or passport.'**
  String get enterNameIdOrPassport;

  /// No description provided for @enterYourGender.
  ///
  /// In en, this message translates to:
  /// **'Please enter your gender'**
  String get enterYourGender;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your valid email'**
  String get enterYourEmail;

  /// No description provided for @sendSmsCode.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send an SMS code for verification.'**
  String get sendSmsCode;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get yourReferralCode;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @referAndEarns.
  ///
  /// In en, this message translates to:
  /// **'Refer and earn'**
  String get referAndEarns;

  /// No description provided for @referralHistory.
  ///
  /// In en, this message translates to:
  /// **'Referral history'**
  String get referralHistory;

  /// No description provided for @noReferralHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No Referral History Found'**
  String get noReferralHistoryFound;

  /// No description provided for @shareYourCode.
  ///
  /// In en, this message translates to:
  /// **'Share your code'**
  String get shareYourCode;

  /// No description provided for @askFriendDownloadApp.
  ///
  /// In en, this message translates to:
  /// **'Ask friend to download the app'**
  String get askFriendDownloadApp;

  /// No description provided for @askYourFriendToDownload.
  ///
  /// In en, this message translates to:
  /// **'Ask your friends to download the 1111 app.'**
  String get askYourFriendToDownload;

  /// No description provided for @getRewarded.
  ///
  /// In en, this message translates to:
  /// **'Get rewarded'**
  String get getRewarded;

  /// No description provided for @earnCashBackYourFriend.
  ///
  /// In en, this message translates to:
  /// **'Earn cash back when your friends register and travel with 1111.'**
  String get earnCashBackYourFriend;

  /// No description provided for @enterPointsToRedeem.
  ///
  /// In en, this message translates to:
  /// **'Enter points to redeem'**
  String get enterPointsToRedeem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContact;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @addFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Add from contacts'**
  String get addFromContacts;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noDriversAssigned.
  ///
  /// In en, this message translates to:
  /// **'No driver assigned'**
  String get noDriversAssigned;

  /// No description provided for @noCardsAdded.
  ///
  /// In en, this message translates to:
  /// **'No cards added. Add a card to link to your wallet.'**
  String get noCardsAdded;

  /// No description provided for @addACard.
  ///
  /// In en, this message translates to:
  /// **'Add a card'**
  String get addACard;

  /// No description provided for @noWalletHistory.
  ///
  /// In en, this message translates to:
  /// **'No Wallet History'**
  String get noWalletHistory;

  /// No description provided for @noPaymentMethodLink.
  ///
  /// In en, this message translates to:
  /// **'No Payment methods linked. Link any payment method for seamless transactions.'**
  String get noPaymentMethodLink;

  /// No description provided for @linkBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Link a bank account'**
  String get linkBankAccount;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @selectRecipientType.
  ///
  /// In en, this message translates to:
  /// **'Select recipient type and enter details.'**
  String get selectRecipientType;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @myVehicle.
  ///
  /// In en, this message translates to:
  /// **'My Vehicle'**
  String get myVehicle;

  /// No description provided for @mySubscription.
  ///
  /// In en, this message translates to:
  /// **'My subscription'**
  String get mySubscription;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @myEarnings.
  ///
  /// In en, this message translates to:
  /// **'My Earnings'**
  String get myEarnings;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languages;

  /// No description provided for @rideRating.
  ///
  /// In en, this message translates to:
  /// **'Ride Rating'**
  String get rideRating;

  /// No description provided for @giveRatings.
  ///
  /// In en, this message translates to:
  /// **'Give Ratings'**
  String get giveRatings;

  /// No description provided for @shareRide.
  ///
  /// In en, this message translates to:
  /// **'Share Ride'**
  String get shareRide;

  /// No description provided for @onDemandRide.
  ///
  /// In en, this message translates to:
  /// **'On Demand Ride'**
  String get onDemandRide;

  /// No description provided for @instantPool.
  ///
  /// In en, this message translates to:
  /// **'Instant Pool'**
  String get instantPool;

  /// No description provided for @deliveryOutStation.
  ///
  /// In en, this message translates to:
  /// **'Delivery OutStation'**
  String get deliveryOutStation;

  /// No description provided for @deliveryRental.
  ///
  /// In en, this message translates to:
  /// **'Delivery Rental'**
  String get deliveryRental;

  /// No description provided for @deliveryRide.
  ///
  /// In en, this message translates to:
  /// **'Delivery Ride'**
  String get deliveryRide;

  /// No description provided for @scheduledRideAt.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Ride at'**
  String get scheduledRideAt;

  /// No description provided for @biddingRides.
  ///
  /// In en, this message translates to:
  /// **'Bidding Rides'**
  String get biddingRides;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @verifyEmailId.
  ///
  /// In en, this message translates to:
  /// **'Verify your email id'**
  String get verifyEmailId;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'az', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'az':
      return AppLocalizationsAz();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
