import 'package:firebase_core/firebase_core.dart';
import 'fcm_message_handler.dart';

const TAG = "ftweather";

Future<void> fcmInit() async {
  await Firebase.initializeApp();

  await setupFcmHandlers();

  await requestNotificationPermissions();

  await initializeLocalNotificationsPlugin();
}
