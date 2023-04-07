import 'package:firebase_core/firebase_core.dart';
import 'package:ftweather/handler/FcmHandler.dart';

const TAG = "ftweather";

Future<void> fcmInit() async {
  // Firebase core 앱 초기화
  await Firebase.initializeApp();

  // FCM 핸들러(인스턴스) 생성 및 설정
  await setupFcmHandlers();

  // FCM 알림 권한 요청
  await requestNotificationPermissions();

  // FCM 알림 초기화
  await initializeLocalNotificationsPlugin();
}

