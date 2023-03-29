import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

import 'MyModel.dart';

class Home extends StatelessWidget {
  // super.key를 전달하여 Key를 받을 수 있는 선택적 인자를 추가
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // mapPosition과 markers를 MyModel에서 가져옴
    final mapPosition = Provider.of<MyModel>(context).mapPosition;
    final model = Provider.of<MyModel>(context, listen: false);
    final markers = Provider.of<MyModel>(context).markers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather App'),
      ),
      body: Center(
        child: NaverMap(
          // NaverMapController를 model에 전달
          onMapCreated: (controller) {
            model.setController(controller);
          },
          mapType: MapType.Hybrid,
          initialCameraPosition: mapPosition, // MyModel에서 가져온 mapPosition 사용
          // initLocationTrackingMode: LocationTrackingMode.Follow, // 권한 획득 시 현재 위치를 따라가는 모드 설정
          markers: markers, // MyModel에서 가져온 markers 사용
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // addMarker() 메서드를 호출하여 현재 위치에 마커 추가
          Provider.of<MyModel>(context, listen: false).addMarker();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
