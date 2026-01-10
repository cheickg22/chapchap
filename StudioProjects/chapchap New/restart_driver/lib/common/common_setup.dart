import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../di/locator.dart' as locator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/pushnotification/push_notification.dart';
import '../core/utils/connectivity_check.dart';
import 'app_constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (AppConstants.packageName == '' || AppConstants.signKey == '') {
    var val = await PackageInfo.fromPlatform();
    AppConstants.packageName = val.packageName;
    AppConstants.signKey = val.buildSignature;
  }
  if (message.data['push_type'].toString() == 'meta-request') {
    if (Platform.isAndroid) {
      AndroidIntent intent = const AndroidIntent(
        action: 'action_view',
        package: 'package name here',
        componentName: 'package name here.MainActivity',
      );
      await intent.launch();
    }
  }
}

Future<void> commonSetup() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConstants.stripPublishKey.isNotEmpty) {
    Stripe.publishableKey = AppConstants.stripPublishKey;
    Stripe.merchantIdentifier =
        'merchant.com.example'; // Replace with your Apple Pay merchant identifier (if applicable)
    Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
  }

  WakelockPlus.enable();
  if (Platform.isAndroid) {
    // ignore: deprecated_member_use
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  if (AppConstants.packageName == '' || AppConstants.signKey == '') {
    var val = await PackageInfo.fromPlatform();
    AppConstants.packageName = val.packageName;
    AppConstants.signKey = val.buildSignature;
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (Platform.isAndroid || Platform.isIOS) {
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await initializeService();
  }
  ConnectivityService().initialize();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: AppConstants.firbaseApiKey,
          appId: AppConstants.firebaseAppId,
          messagingSenderId: AppConstants.firebasemessagingSenderId,
          projectId: AppConstants.firebaseProjectId));
  await locator.init();

  PushNotification().initMessaging();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Bloc.observer = const SimpleBlocObserver();
}

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stopService");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: false,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized

  Timer.periodic(const Duration(minutes: 10), (timer) async {
    try {
      if (userData != null) {
        Position position = await Geolocator.getCurrentPosition();
        String driverId =
            "driver_${userData!.id}"; // Replace with actual inputData['id']

        await FirebaseDatabase.instance
            .ref()
            .child('drivers/$driverId')
            .update({
          'date': DateTime.now().toString(),
          'l': {'0': position.latitude, '1': position.longitude},
          'updated_at': ServerValue.timestamp
        });
        printWrapped(
            "Location updated: ${position.latitude}, ${position.longitude}");
      }
    } catch (e) {
      printWrapped("Error updating location: $e");
    }
  });
}

class SimpleBlocObserver extends BlocObserver {
  const SimpleBlocObserver();

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- bloc: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- bloc: ${bloc.runtimeType}, change: $change');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    debugPrint(
        'onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- bloc: ${bloc.runtimeType}, error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- bloc: ${bloc.runtimeType}');
  }
}
