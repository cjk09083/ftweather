import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const TAG = "ftweather";

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  enableVibration: true,
  enableLights: true,
  ledColor: Colors.blueAccent,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> setupFcmHandlers() async {
  FirebaseMessaging.onMessage.listen(handleForegroundMessage);

  FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    handleBackgroundMessage(initialMessage);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('$TAG Handling a background message');
  handleForegroundMessage(message);
}

void handleForegroundMessage(RemoteMessage message) {
  log('$TAG Got a message while in the foreground!');

  RemoteNotification? notification = message.notification;
  if (notification != null) {
    log('$TAG Message title (bg): ${notification.title}');
    log('$TAG Message body (bg): ${notification.body}');
  }
  AndroidNotification? android = message.notification?.android;

  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          icon: android?.smallIcon,
        ),
        iOS: const IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: "title:${notification.title}, body:${notification.body}",
    );
  }
}

void handleBackgroundMessage(RemoteMessage message) {
  log('$TAG Clicked a message while in the background!');

  RemoteNotification? notification = message.notification;

  if (notification != null) {
    log('$TAG Message title (bg): ${notification.title}');
    log('$TAG Message body (bg): ${notification.body}');
  }
}

Future<void> requestNotificationPermissions() async {
  await FirebaseMessaging.instance.requestPermission(
    announcement: true,
    carPlay: true,
    criticalAlert: true,
  );
}

Future<void> initializeLocalNotificationsPlugin() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
