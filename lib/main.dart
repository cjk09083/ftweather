import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/fcm_manager.dart';
import 'lib/location_manager.dart';
import 'provider/MapModel.dart';
import 'screen/Home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await fcmInit();                          // firebase 초기화 및 fcm 관련 설정
  await requestLocationPermission();        // 위치 권한 획득

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
