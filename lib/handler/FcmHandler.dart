import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const TAG = "ftweather";

// Android 알림 채널 생성
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  enableVibration: true,
  enableLights: true,
  ledColor: Colors.blueAccent,
);

// 로컬 알림 플러그인 초기화
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// FCM 핸들러 설정
Future<void> setupFcmHandlers() async {
  // FirebaseMessaging 인스턴스 생성
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // firebase message 토큰 생성
  final fcmToken = await messaging.getToken();
  log('$TAG fcmToken : $fcmToken');

  // 포그라운드 상태에서 메세지 수신 시 호출될 핸들러
  FirebaseMessaging.onMessage.listen(handleForegroundMessage);

  // 백그라운드 상태에서 메세지를 클릭하여 맵을 열 때 호출될 핸들러 (iOS)
  FirebaseMessaging.onMessageOpenedApp.listen(openBackgroundMessage);

  // 백그라운드 상태에서 메세지 수신 시 호출될 핸들러
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 백그라운드 상태에서 메세지를 클릭하여 맵을 열 때 처리할 초기 메세지 (Android)
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) openBackgroundMessage(initialMessage, type: "Android");

}

// 백그라운드 메시지 수신시 핸들러 (Android)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('$TAG Got a message while in the background!');
  readNotify(message);
}

// 포그라운드 메시지 핸들러
void handleForegroundMessage(RemoteMessage message) {
  log('$TAG Got a message while in the foreground!');

  RemoteNotification? notification = message.notification;
  readNotify(message);

  AndroidNotification? android = message.notification?.android;
  if (notification != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,                          // 알림 id, 고정시 알림창이 쌓이지않고 갱신된다.
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(          // Android
          channel.id,
          channel.name,
          icon: android?.smallIcon,
        ),
        iOS: const IOSNotificationDetails(            // iOS
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: "title:${notification.title}, body:${notification.body}",  // 클릭시 전달될 payload
    );
  }
}


// 포그라운드 알림 클릭 처리를 위한 콜백 함수
Future<void> _onSelectNotification(String? payload) async {
  log('$TAG Clicked a message while in the foreground!');
  if (payload != null) {
    log('$TAG Message payload: $payload');
  }
}

// 백그라운드 메시지 클릭 처리를 위한 콜백 함수
void openBackgroundMessage(RemoteMessage message, {String? type}) {
  type ??= 'iOS';
  log('$TAG Clicked a message while in the background! ($type)');
  Map data = readNotify(message);
}

// 알림 권한 요청 (iOS)
Future<void> requestNotificationPermissions() async {
  await FirebaseMessaging.instance.requestPermission(
    announcement: true,
    carPlay: true,
    criticalAlert: true,
  );
}

Map readNotify(RemoteMessage message){
  RemoteNotification? notification = message.notification;
  if (notification != null) {
    log('$TAG Message title (bg): ${notification.title}');
    log('$TAG Message body (bg): ${notification.body}');

    Map data = message.data;
    log('$TAG Data : $data');
    return data;
  }

  return {};
}

// 알림 초기화
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

  // 알림 초기화 (플랫폼별 설정, 포그라운드 클릭시 처리 핸들러)
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: _onSelectNotification);
}
