import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ftweather/config/Key.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:provider/provider.dart';
import 'manager/FcmManager.dart';
import 'manager/RequestManager.dart';
import 'screen/Home.dart';

const TAG = "ftweather"; // 로그 태그

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await nMapInit();                         // NaverMaps 초기화
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

Future<void> nMapInit() async {

  await NaverMapSdk.instance.initialize(
      clientId: nMapKey,
      onAuthFailed: (error) {
        log('$TAG Auth failed: $error');
      });
}

void fToast(String msg ,{ double size = 16.0, Color color = Colors.red}){
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.blueAccent,
      textColor: color,
      fontSize: size
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
