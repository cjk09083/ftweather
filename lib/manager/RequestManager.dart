import 'package:geolocator/geolocator.dart';

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
