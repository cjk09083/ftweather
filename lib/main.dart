import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Home.dart';
import 'MyModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

const TAG = "ftweather";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseMessaging 인스턴스 생성
  fcmInit();

  await requestLocationPermission();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyModel(),
      child: const MaterialApp(
        title: 'Flutter Weather App',
        home: Home(),
      ),
    );
  }
}

// 알림 채널 생성 (Android)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  enableVibration: true,
  enableLights: true,
  ledColor: Colors.blueAccent,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// 백그라운드 상태에서 메시지 처리하는 함수
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('$TAG Handling a background message');
  // 알림 정보
  RemoteNotification? notification = message.notification;
  log('$TAG Message title: ${notification?.title}');
  log('$TAG Message body: ${notification?.body}');
}


Future<void> fcmInit() async {
  // 알림 권한
  final settings = await FirebaseMessaging.instance.requestPermission(
    announcement: true,
    carPlay: true,
    criticalAlert: true,
  );
  await FirebaseMessaging.instance.subscribeToTopic('ftweather');

  // 알림 초기화
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: _onSelectNotification);

  // FirebaseMessaging 인스턴스 생성
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final fcmToken = await messaging.getToken();
  log('$TAG fcmToken : $fcmToken');

  // 앱이 백그라운드 상태에서 알림을 클릭하여 실행되었을 때의 초기 메시지를 가져옵니다.
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  bgClicked(initialMessage);

  // 앱이 포그라운드 상태일 때 메시지 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('$TAG Got a message while in the foreground!');

    // 알림 표시
    RemoteNotification? notification = message.notification;
    log('$TAG Message title: ${notification?.title}');
    log('$TAG Message body: ${notification?.body}');

    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: android.smallIcon,
          ),
        ),
        payload: "title:${notification.title}, body:${notification.body}"
      );
    }
  });

  // 앱이 백그라운드 상태일 때 메시지 처리
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  }


// 포그라운드 알림 클릭 처리를 위한 콜백 함수
Future<void> _onSelectNotification(String? payload) async {
  if (payload != null) {
    log('$TAG Clicked a message while in the foreground!');
    log('$TAG Message payload: $payload');
  }
}

// 백그라운드 알림 클릭 처리를 위한 콜백 함수
void bgClicked(RemoteMessage? initialMessage) {
   if (initialMessage != null) {
    log('$TAG Clicked a message while in the background!');
    RemoteNotification? notification = initialMessage.notification;
    log('$TAG Message title: ${notification?.title}');
    log('$TAG Message body: ${notification?.body}');
  }
}

// 위치 서비스 권한 요청 함수
Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // 사용자가 위치 권한을 거부한 경우 처리
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // 사용자가 위치 권한을 영구적으로 거부한 경우 처리
    return;
  }

  // 권한이 허용된 경우 처리
}
