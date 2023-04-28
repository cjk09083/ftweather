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
    consumeSymbolTapEvents: false,     // 심볼 터치가 맵 터치 이벤트를 소비

  );

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MapModel>(context, listen: true);

    return Expanded(
      flex: 6,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Stack(
          children: [
            NaverMap(
              options: option,
              onMapReady: (controller) {
                model.setController(controller);
              },
              onMapTapped: (point, latLng) {
                log("$TAG onMapTapped point: $point, latLng: $latLng");
                model.selectMap(remake: true , latLng: latLng);
              },
              onSymbolTapped: (symbol){
                log("$TAG onSymbolTapped symbol: ${symbol.caption}");
                // model.selectMap(remake: true , latLng: symbol.position);
              },
            ),

            AnimatedPositioned(
              top: model.showTappedPos ? 0 : -50,
              right: 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "위도: ${model.selAreaMarker.position.latitude.toStringAsFixed(7)},"
                        " 경도: ${model.selAreaMarker.position.longitude.toStringAsFixed(7)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 15,
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
      ),
    );
  }

}
