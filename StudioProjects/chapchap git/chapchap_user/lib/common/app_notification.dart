import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../core/network/network.dart';

// create an instance
FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin fltNotification =
    FlutterLocalNotificationsPlugin();
FlutterLocalNotificationsPlugin rideNotification =
    FlutterLocalNotificationsPlugin();
bool isGeneral = false;
String latestNotification = '';
int id = 0;

void notificationTapBackground(NotificationResponse notificationResponse) {
  isGeneral = true;
}

var androidDetails = const AndroidNotificationDetails(
  '54321',
  'normal_notification',
  enableVibration: true,
  enableLights: true,
  importance: Importance.high,
  playSound: true,
  priority: Priority.high,
  visibility: NotificationVisibility.private,
);

const iosDetails = DarwinNotificationDetails(
    presentAlert: true, presentBadge: true, presentSound: true);

var generalNotificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

var androiInit =
    const AndroidInitializationSettings('@mipmap/ic_launcher'); //for logo
var iosInit = const DarwinInitializationSettings(
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);
var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);

Future<void> initMessaging() async {
  await fltNotification.initialize(initSetting);

  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message?.data != null) {
      if (message?.data['push_type'] == 'general') {
        latestNotification = message?.data['message'];
        isGeneral = true;
      }
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      if (message.data['push_type'].toString() == 'general') {
        latestNotification = message.data['message'];
        if (message.data['image'].isNotEmpty) {
          _showBigPictureNotificationURLGeneral(message.data);
        } else {
          _showGeneralNotification(message.data);
        }} else if (message.data['notification_type'] == 'restart_tagxi_money_new_request') {
        // Gérer les nouvelles demandes restart_tagxiMoney pour les chauffeurs
        showrestart_tagxiMoneyNewRequestNotification(message.notification, message.data);
      } else if (message.data['notification_type'] == 'restart_tagxi_money_status_update') {
        // Gérer les notifications restart_tagxiMoney
        showrestart_tagxiMoneyNotification(message.notification, message.data);
      } else {
        showRideNotification(message.notification);
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['push_type'].toString() == 'general') {
      latestNotification = message.data['message'];
      isGeneral = true;
    }
  });
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final Response response = await DioProviderImpl().get(url);
  final File file = File(filePath);
  await file.writeAsBytes(Uint8List.fromList(response.data));
  return filePath;
}

Future<Uint8List> _getByteArrayFromUrl(String url) async {
  final Response response = await DioProviderImpl().get(url);
  return Uint8List.fromList(response.data);
}

Future<void> _showBigPictureNotificationURLGeneral(message) async {
  latestNotification = message['message'];
  if (Platform.isAndroid) {
    final ByteArrayAndroidBitmap bigPicture =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(message['image']));
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture);
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'notification_1',
      'general image notification',
      channelDescription: 'general notification with image',
      styleInformation: bigPictureStyleInformation,
      enableVibration: true,
      enableLights: true,
      importance: Importance.high,
      playSound: true,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    fltNotification.initialize(initSetting,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    await fltNotification.show(
        id++, message['title'], message['message'], notificationDetails);
  } else {
    final String bigPicturePath = await _downloadAndSaveFile(
        Uri.parse(message['image']).toString(), 'bigPicture.jpg');
    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: <DarwinNotificationAttachment>[
          DarwinNotificationAttachment(
            bigPicturePath,
          )
        ]);

    final NotificationDetails notificationDetails =
        NotificationDetails(iOS: iosDetails);
    fltNotification.initialize(initSetting,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    await fltNotification.show(
        id++, message['title'], message['message'], notificationDetails);
  }
  id = id++;
}

Future<void> _showGeneralNotification(message) async {
  latestNotification = message['message'];
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_1',
    'general notification',
    channelDescription: 'general notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true);
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  await fltNotification.show(
      id++, message['title'], message['message'], notificationDetails);
  id = id++;
}

Future<void> showOtpNotification(message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_1',
    'ride notification',
    channelDescription: 'ride notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  rideNotification.initialize(initSetting);
  await rideNotification.show(id++, message.title.toString(),
      message.body.toString(), notificationDetails);
  id = id++;
}

Future<void> showRideNotification(message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'notification_1',
    'ride notification',
    channelDescription: 'ride notification',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
  );
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  rideNotification.initialize(initSetting);
  await rideNotification.show(id++, message.title.toString(),
      message.body.toString(), notificationDetails);
  id = id++;
}

/// Affiche une notification pour les mises à jour restart_tagxiMoney
Future<void> showrestart_tagxiMoneyNotification(RemoteNotification? notification, Map<String, dynamic> data) async {
  if (notification == null) return;
  
  // Déterminer la couleur selon le statut (couleurs restart_tagxiMoney: bleu #0066CC, orange #FF6600)
  String status = data['status']?.toString() ?? 'pending';
  int notificationColor = 0xFF0066CC; // Bleu restart_tagxiMoney par défaut
  
  switch (status.toLowerCase()) {
    case 'pending':
      notificationColor = 0xFFFF6600; // Orange restart_tagxiMoney pour en attente
      break;
    case 'accepted':
    case 'assigned':
    case 'arrived':
      notificationColor = 0xFF0066CC; // Bleu restart_tagxiMoney pour en cours
      break;
    case 'processing':
    case 'in_progress':
      notificationColor = 0xFF0066CC; // Bleu restart_tagxiMoney
      break;
    case 'completed':
      notificationColor = 0xFF00CC66; // Vert pour succès
      break;
    case 'cancelled':
      notificationColor = 0xFF999999; // Gris pour annulé
      break;
    case 'failed':
      notificationColor = 0xFFCC0000; // Rouge pour échec
      break;
  }
  
  final AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'restart_tagxi_money_channel',
    'restart_tagxiMoney Notifications',
    channelDescription: 'Notifications pour les transactions restart_tagxiMoney',
    enableVibration: true,
    enableLights: true,
    importance: Importance.high,
    playSound: true,
    priority: Priority.high,
    visibility: NotificationVisibility.public,
    color: Color(notificationColor),
    styleInformation: BigTextStyleInformation(
      notification.body ?? '',
      contentTitle: notification.title,
    ),
  );
  
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  final NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  
  await fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  
  await fltNotification.show(
    id++,
    notification.title ?? 'restart_tagxiMoney',
    notification.body ?? 'Mise à jour de votre transaction',
    notificationDetails,
    payload: data['request_id']?.toString(),
  );
  
  id = id++;
}

/// Affiche une notification pour une nouvelle demande restart_tagxiMoney (pour les chauffeurs)
Future<void> showrestart_tagxiMoneyNewRequestNotification(RemoteNotification? notification, Map<String, dynamic> data) async {
  if (notification == null) return;
  
  // Déterminer la couleur selon le type (dépôt ou retrait)
  String type = data['type']?.toString() ?? 'deposit';
  int notificationColor = type == 'deposit' ? 0xFF0066CC : 0xFFFF6600; // Bleu pour dépôt, Orange pour retrait
  
  final AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'restart_tagxi_money_requests_channel',
    'Demandes restart_tagxiMoney',
    channelDescription: 'Notifications pour les nouvelles demandes restart_tagxiMoney',
    enableVibration: true,
    enableLights: true,
    importance: Importance.max,
    playSound: true,
    priority: Priority.max,
    visibility: NotificationVisibility.public,
    color: Color(notificationColor),
    styleInformation: BigTextStyleInformation(
      notification.body ?? '',
      contentTitle: notification.title,
    ),
    // Rendre la notification persistante jusqu'à ce que le chauffeur la lise
    ongoing: false,
    autoCancel: true,
  );
  
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    interruptionLevel: InterruptionLevel.timeSensitive,
  );
  
  final NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);
  
  await fltNotification.initialize(initSetting,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
  
  await fltNotification.show(
    id++,
    notification.title ?? 'Nouvelle Demande restart_tagxiMoney',
    notification.body ?? 'Une nouvelle demande est disponible',
    notificationDetails,
    payload: data['request_id']?.toString(),
  );
  
  id = id++;
}
