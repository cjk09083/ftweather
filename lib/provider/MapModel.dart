import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';

import '../main.dart';

class MapModel extends ChangeNotifier {

  // 초기 카메라 위치 설정
  final CameraPosition _mapPosition = const CameraPosition(
    target: LatLng(37.5666805, 126.9784147),
    zoom: 15,
  );

  // 카메라 위치를 가져오는 getter
  CameraPosition get mapPosition => _mapPosition;

  // NaverMapController 변수
  NaverMapController? _controller;

  // 마커 목록 관리
  final List<Marker> _markers = [];
  List<Marker> get markers => _markers;

  // NaverMapController 초기화 메서드
  void setController(NaverMapController controller) {
    _controller = controller;
  }

  // 현재 위치에 마커를 추가하는 메서드
  Future<void> addMarker(BuildContext context) async {
    // 로그 출력
    log("$TAG : addMarker");

    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Marker 추가"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      _createMarker(nameController.text);
                    }
                  },
                  child: const Text("추가하기"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 마커 생성 및 목록에 추가하는 메서드
  void _createMarker(String name) async {
    // NaverMapController가 초기화되었는지 확인
    if (_controller != null) {
      // 현재 카메라 위치 가져오기
      CameraPosition currentCameraPosition = await _controller!.getCameraPosition();
      // 로그 출력
      log("$TAG : Camera Pos $currentCameraPosition");

      final now = DateTime.now();
      final timeWithoutMicroseconds = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
      final createdAt = timeWithoutMicroseconds.toString().replaceAll('.000', '');


      // 현재 위치에 마커 추가
      final marker = Marker(
        markerId: (_markers.length.toString()),
        position: currentCameraPosition.target,
        captionText: name,
        infoWindow: "$name\n"
            "lat: ${currentCameraPosition.target.latitude.toStringAsFixed(7)}\n"
            "lon: ${currentCameraPosition.target.longitude.toStringAsFixed(7)}\n"
            "$createdAt",
      );

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      log("$TAG : Real Pos $position");

      // 마커 목록에 추가
      _markers.add(marker);
    }

    // 마커가 추가되었음을 알림
    notifyListeners();
  }

  void removeMarker(int index) {
    _markers.removeAt(index);
    notifyListeners();
  }
}
