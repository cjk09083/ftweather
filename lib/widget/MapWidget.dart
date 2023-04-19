import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MapWidget extends StatelessWidget {
  MapWidget({Key? key}) : super(key: key);

  NaverMapViewOptions option = const NaverMapViewOptions(
    initialCameraPosition: NCameraPosition(
        target: NLatLng(37.5666805, 126.9784147),
        zoom: 15,
        bearing: 0,
        tilt: 0
    ),
    mapType: NMapType.basic,
    locationButtonEnable: true,
  );

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MapModel>(context, listen: false);

    return Expanded(
      flex: 6,
      child: Stack(
        children: [
          NaverMap(
            options: option,
            onMapReady: (controller) {
              model.setController(controller);
            },
            onMapTapped: (point, latLng) {
              log("$TAG onMapTapped point: $point, latLng: $latLng");
              model.allOverlayClose();
            },
            onSymbolTapped: (symbol){
              log("$TAG onSymbolTapped symbol: $symbol");
              model.allOverlayClose();
            },
            // initLocationTrackingMode: LocationTrackingMode.Follow, // 권한 획득 시 현재 위치를 따라가는 모드 설정
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // addMarker() 메서드를 호출하여 현재 위치에 마커 추가
                model.addMarker(context);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
