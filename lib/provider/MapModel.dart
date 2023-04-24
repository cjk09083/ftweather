import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:ftweather/widget/MarkerDialog.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class MapModel extends ChangeNotifier {

  // NaverMapController 변수
  NaverMapController? _controller;
  NaverMapController? get controller => _controller;

  // 마커 목록 관리
  final List<NMarker> _markers = [];
  List<NMarker> get markers => _markers;

  // 인포 목록 관리
  final List<NInfoWindow> _infoWindows = [];
  List<NInfoWindow> get infoWindows => _infoWindows;

  // 인포 데이터 목록 관리
  final List<InfoData> _infoList = [];

  // 선택된 좌표 타입 0:마커 생성 불가능, 1:가능
  int selectType = 0;
  // 선택 좌표 표시 마커
  NMarker selAreaMarker = NMarker(id: "select", position: const NLatLng(0,0));

  // 생성 완료 플래그
  bool loadComp = false;

  // 맵 상단 좌표 표시
  bool _showTappedPos = false;
  bool get showTappedPos => _showTappedPos;


  // NaverMapController 초기화 메서드
  void setController(NaverMapController controller) {
    _controller = controller;
    _controller!.clearOverlays();
    waitForLoadComp();
  }

  Future<void> waitForLoadComp() async {
    while (!loadComp) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    log("마커 추가 : ${_markers.length}");
    _infoWindows.clear();
    for (int i = 0; i < _markers.length; i++) {
      NMarker marker = _markers[i];
      _controller!.addOverlay(marker);

      InfoData infoData = _infoList[i];
      NInfoWindow onMarkerInfoWindow = NInfoWindow.onMarker(
          id: infoData.id,
          text: infoData.text,
      );
      _infoWindows.add(onMarkerInfoWindow);
      marker.setOnTapListener((NMarker marker) {
        // selectMap(remake: false);
        closeInfoAll();
        marker.openInfoWindow(onMarkerInfoWindow);
      });

    }

  }

  MapModel() {
    initializeMarkers();
  }

  void initializeMarkers() async {
    log("initializeMarkers");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String markerList = prefs.getString('marker') ?? '[]';
    String infoList = prefs.getString('info') ?? '[]';
    _markers.addAll(markerFromJson(markerList));
    _infoList.addAll(infoFromJson(infoList));

    loadComp = true;
    notifyListeners();
  }

  // 현재 위치에 마커를 추가하는 메서드
  Future<void> addMarker(BuildContext context) async {
    // 로그 출력
    log("$TAG : addMarker");

    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if(!selAreaMarker.isVisible || selectType == 0){
      fToast("맵에서 위치를 선택해주세요.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MarkerDialog(
          formKey: formKey,
          lat: selAreaMarker.position.latitude,
          lon: selAreaMarker.position.longitude,
          nameController: nameController,
          onConfirm: () {_createMarker(nameController.text);},
        );
      },
    );
  }

  // 마커 생성 및 목록에 추가하는 메서드
  void _createMarker(String name) async {
    // NaverMapController가 초기화되었는지 확인
    if (_controller != null) {
      // 현재 카메라 위치 가져오기
      // NCameraPosition currentCameraPosition = await _controller!.getCameraPosition();
      // NLatLng cameraLatLng = currentCameraPosition.target;
      NLatLng newMarkerPos = selAreaMarker.position;

      log("$TAG : New Marker Pos $newMarkerPos");

      final now = DateTime.now();
      final createdAt = now.toString();

      String infoText = "$name\n"
          "lat: ${newMarkerPos.latitude.toStringAsFixed(7)}\n"
          "lon: ${newMarkerPos.longitude.toStringAsFixed(7)}\n"
          "$createdAt";

      // 현재 위치에 마커 추가
      final marker = NMarker(
        id: createdAt,
        position: newMarkerPos,
        caption: NOverlayCaption(text: name),
      );

      final onMarkerInfoWindow = NInfoWindow.onMarker(
          id: marker.info.id,
          text: infoText
      );

      // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // log("$TAG : Real Pos $position");

      marker.setOnTapListener((NMarker marker) {
        // selectMap(remake: false);
        closeInfoAll();
        marker.openInfoWindow(onMarkerInfoWindow);
      });


      // 마커 목록에 추가
      _markers.add(marker);
      _infoList.add(InfoData(marker.info.id, infoText));
      _infoWindows.add(onMarkerInfoWindow);
      _controller!.addOverlay(marker);

      // 기본 맵 선택 마커 제거
      _controller!.deleteOverlay(selAreaMarker.info);
      selectType = 0;
      _showTappedPos = false;

      // 마커 리스트 -> json String으로 변환
      await saverMarkers();
    }

    // 마커가 추가되었음을 알림
    notifyListeners();
  }

  Future<void> saverMarkers() async {

    // 마커 리스트 -> json String으로 변환
    String jsonMarker = markerToJson(_markers);
    String jsonInfo = infoToJson(_infoList);

    log('$TAG Markers to Json : $jsonMarker');

    // jsonData 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('marker', jsonMarker);
    prefs.setString('info', jsonInfo);

  }

  Future<void> removeMarker(int index) async {
    _markers.removeAt(index);
    _infoList.removeAt(index);
    _infoWindows.removeAt(index);
    // 마커 리스트 -> json String으로 변환
    await saverMarkers();
    notifyListeners();
  }

  Future<void> moveCamera(int index) async {
    if (_controller != null) {
      NMarker marker = _markers[index];
      NLatLng markerLatLng = NLatLng(
          marker.position.latitude, marker.position.longitude);
      log('$TAG moverCamera to : $markerLatLng');
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: markerLatLng,
      );

      await _controller!.updateCamera(cameraUpdate);
      notifyListeners();
    }
  }


  String infoToJson(List<InfoData> info) {
    List<Map<String, dynamic>> infoList = info.map((info) {
      return {
        'id': info.id,
        'name': info.text,
      };
    }).toList();

    return json.encode(infoList);
  }

  String markerToJson(List<NMarker> markers) {
    List<Map<String, dynamic>> markerList = markers.map((marker) {
      return {
        'id': marker.info.id,
        'name': marker.caption!.text,
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
      };
    }).toList();

    return json.encode(markerList);
  }

  List<NMarker> markerFromJson(String jsonString) {
    List<dynamic> markerList = json.decode(jsonString);

    List<NMarker> newMarkers =  markerList.map((marker) {
      NLatLng position = NLatLng(marker['latitude'], marker['longitude']);
      NMarker newMarker = NMarker(
        id: marker['id'],
        position: position,
        caption: NOverlayCaption(text: marker['name']??''),
      );
      return newMarker;
    }).toList();

    return newMarkers;
  }


  List<InfoData> infoFromJson(String jsonString) {
    List<dynamic> infoList = json.decode(jsonString);
    List<InfoData> newInfoList =  infoList.map((info) {
      return InfoData(info['id'], info['name'] );
    }).toList();
    return newInfoList;
  }

  void closeInfoAll(){
    log('$TAG closeAllInfo ${_infoWindows.length}');
    for(NInfoWindow window in _infoWindows){
      if(window.isAdded) window.close();
    }
  }

  void selectMap({bool remake = false, NLatLng latLng = const NLatLng(0.0, 0.0)}) {
    _showTappedPos = remake;
    // 열린 InfoWindow 닫기
    closeInfoAll();
    // 기존 마커 제거
    if(selAreaMarker.isAdded) {
      _controller!.deleteOverlay(selAreaMarker.info);
      selectType = 0;
    }
    // 새로운 좌표에  마커 재생성
    if (remake) {
      selAreaMarker = NMarker(id: DateTime.now().toString(), position: latLng,
          anchor: const NPoint(0.5,0.5),
          size: const Size(35,35),
          iconTintColor: Colors.red,
          icon: const NOverlayImage.fromAssetImage('assets/focus.png'),
      );
      selAreaMarker.setOnTapListener((NMarker marker) {
        log("$TAG onTap selAreaMarker $marker");
        // selectMap(remake: true, latLng: marker.position);
      });
      _controller!.addOverlay(selAreaMarker);
      selectType = 1;
    }
    notifyListeners();
  }

  Future<void> moveIndex(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    final marker = _markers.removeAt(oldIndex);
    _markers.insert(newIndex, marker);

    final infoWin = _infoWindows.removeAt(oldIndex);
    _infoWindows.insert(newIndex, infoWin);

    final info = _infoList.removeAt(oldIndex);
    _infoList.insert(newIndex, info);

    log('${_markers[oldIndex].caption!.text} Move $oldIndex => $newIndex');

    await saverMarkers();
    notifyListeners();
  }

}

class InfoData {
  String id, text;
  InfoData(this.id, this.text);
}
