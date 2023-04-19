import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MapModel>(context, listen: false);
    log("initialCameraPosition : ${model.mapPosition}");

    return Expanded(
      flex: 6,
      child: Stack(
        children: [
          NaverMap(
            // NaverMapController를 model에 전달
            onMapCreated: (controller) {
              model.setController(controller);
            },
            mapType: MapType.Basic,
            locationButtonEnable: true,
            initialCameraPosition: model.mapPosition, // MyModel에서 가져온 mapPosition 사용
            // initLocationTrackingMode: LocationTrackingMode.Follow, // 권한 획득 시 현재 위치를 따라가는 모드 설정
            markers: model.markers, // MapModel에서 가져온 markers 사용
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
