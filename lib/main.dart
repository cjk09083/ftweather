import 'package:flutter/material.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:provider/provider.dart';
import 'manager/FcmManager.dart';
import 'manager/RequestManager.dart';
import 'screen/Home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await fcmInit();                          // firebase 초기화 및 fcm 관련 설정
  await requestLocationPermission();        // 위치 권한 획득

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MapModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Weather App',
      home: Home(),
    );
  }
}
