import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Home.dart';
import 'MyModel.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestLocationPermission();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyModel(),
      child: MaterialApp(
        title: 'Flutter Weather App',
        home: Home(),
      ),
    );
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
