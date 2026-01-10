import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'custom_loader.dart';
import 'custom_text.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ConnectivityService {
  ConnectivityService._internal();

  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  Connectivity get connectivity => _connectivity;

  void initialize() {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      String message;
      if (result.first == ConnectivityResult.mobile) {
        message = 'Connected to Mobile Network';
        scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));
        scaffoldMessengerKey.currentState?.clearSnackBars();
        // navigatorKey.currentState?.pop();
        _closeDialogIfOpen();
      } else if (result.first == ConnectivityResult.wifi) {
        message = 'Connected to WiFi';
        scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ));
        scaffoldMessengerKey.currentState?.clearSnackBars();
        // navigatorKey.currentState?.pop();
        _closeDialogIfOpen();
      } else {
        message = 'No Network Connection';
        if (navigatorKey.currentContext != null) {
          _showNoConnectionDialog(navigatorKey.currentContext!);
        }
      }
    });
  }

  Future<List<ConnectivityResult>> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }

  void _closeDialogIfOpen() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    } else {
      printWrapped("No routes to pop.");
    }
  }

  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.sizeOf(context);
        MediaQuery.sizeOf(context);
        return AlertDialog(
          title: const MyText(
            text: 'No Internet Connection',
            textStyle: TextStyle(fontSize: 20),
            maxLines: 2,
          ),
          content: SizedBox(
            height: size.height * 0.25,
            width: size.width * 0.8,
            child: Column(
              children: [
                Image.asset(
                  AppImages.noInternet,
                  height: size.height * 0.15,
                  width: size.width * 0.3,
                ),
                const SizedBox(height: 10),
                const MyText(
                  text: 'Please check your internet settings.',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
