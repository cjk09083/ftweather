import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:provider/provider.dart';

class MarkerList extends StatelessWidget {
  MarkerList({Key? key}) : super(key: key);

  List<int> flexList = [20,40,30,15];

  @override
  Widget build(BuildContext context) {
    final markers = Provider.of<MapModel>(context).markers;
    return Expanded(
      flex: 4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(flex: flexList[0], child: const Text('이름',textAlign: TextAlign.center,),),
                Expanded(flex: flexList[1], child: const Text('경도, 위도',textAlign: TextAlign.center,),),
                Expanded(flex: flexList[2], child: const Text('시간',textAlign: TextAlign.center,),),
                Expanded(flex: flexList[3], child: const Text('삭제',textAlign: TextAlign.center,),),
              ],
            ),
          ),
          const Divider(color: Colors.black,height: 5,),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: markers.length,
              itemBuilder: (BuildContext context, int index) {
                final markerInfo = markers[index].infoWindow!.split("\n");
                final name = markerInfo[0];
                final lat = markerInfo[1].substring(5);
                final lng = markerInfo[2].substring(5);
                final createdAt = markerInfo[3];
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(flex: flexList[0],
                        child: Text(name,textAlign: TextAlign.center,),
                      ),
                      Expanded(flex: flexList[1],
                        child: Text('$lat,\n$lng',textAlign: TextAlign.center,),
                      ),
                      Expanded(flex: flexList[2],
                        child: Text(createdAt,textAlign: TextAlign.center,),
                      ),
                      Expanded(flex: flexList[3],
                        child: IconButton(
                          onPressed: () {
                            Provider.of<MapModel>(context, listen: false).removeMarker(index);
                          },
                          icon: const Icon(Icons.delete_forever_rounded),
                          iconSize: 35,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
