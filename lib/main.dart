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
  await Firebase.initializeApp();
  log('$TAG Handling a background message');
  // 알림 정보
  RemoteNotification? notification = message.notification;
  parseFcm(notification);
}


Future<void> fcmInit() async {
  // 알림 권한
  await FirebaseMessaging.instance.requestPermission(
    announcement: true,
    carPlay: true,
    criticalAlert: true,
  );
  // await FirebaseMessaging.instance.subscribeToTopic('ftweather');

  // 알림 초기화
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: true, requestBadgePermission: true, requestAlertPermission: true);
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: _onSelectNotification);

  // FirebaseMessaging 인스턴스 생성
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final fcmToken = await messaging.getToken();
  log('$TAG fcmToken : $fcmToken');

  // 앱이 백그라운드 상태에서 알림을 클릭하여 실행되었을 때의 초기 메시지를 가져옵니다.
  bgClickedAndroid();
  bgClickedIos();

  // 앱이 포그라운드 상태일 때 메시지 처리
  onMessage();

  // 앱이 백그라운드 상태일 때 메시지 처리
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  }

void onMessage() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('$TAG Got a message while in the foreground!');
  
    // 알림 표시
    RemoteNotification? notification = message.notification;
    log('$TAG Message title (fg): ${notification?.title}');
    log('$TAG Message body (fg): ${notification?.body}');
  
    AndroidNotification? android = message.notification?.android;
    if (notification != null ) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: (android != null)?android.smallIcon:null,
          ),
          iOS: const IOSNotificationDetails(
              presentAlert: true, presentBadge: true,  presentSound: true,),
        ),
        payload: "title:${notification.title}, body:${notification.body}",
      );
    }else{
      if (notification == null) log('$TAG Message notification null ');
    }
  });
}



// 포그라운드 알림 클릭 처리를 위한 콜백 함수
Future<void> _onSelectNotification(String? payload) async {
  log('$TAG Clicked a message while in the foreground!');
  if (payload != null) {
    log('$TAG Message payload: $payload');
  }
}

// 백그라운드 알림 클릭 처리를 위한 콜백 함수 (android)
Future<void> bgClickedAndroid() async {
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    log('$TAG Clicked a message while in the background! (Android)');
    RemoteNotification? notification = initialMessage.notification;
    parseFcm(notification);
  }
}

// 백그라운드 알림 클릭 처리를 위한 콜백 함수 (ios)
void bgClickedIos() {
  Stream<RemoteMessage> stream = FirebaseMessaging.onMessageOpenedApp;
  stream.listen((RemoteMessage event) async {
    log('$TAG Clicked a message while in the background! (iOS)');
    RemoteNotification? notification = event.notification;
    parseFcm(notification);
  });
}

// 메세지 클릭 오픈 후 처리 함수
void parseFcm(RemoteNotification? notification) {
  log('$TAG Message title (bg): ${notification?.title}');
  log('$TAG Message body (bg): ${notification?.body}');
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
