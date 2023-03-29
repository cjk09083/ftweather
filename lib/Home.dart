import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

import 'MyModel.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  final CameraPosition _mapPosition = const CameraPosition(
    target: LatLng(37.5666805, 126.9784147),
    zoom: 15,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather App'),
      ),
      body: Center(
        child: NaverMap(
          mapType: MapType.Hybrid,
          initialCameraPosition: _mapPosition,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<MyModel>(context, listen: false).addMarker();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
