import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MarkerList extends StatelessWidget {
  MarkerList({Key? key}) : super(key: key);

  List<int> flexList = [20,40,30,15];

  Color borderColor = Colors.grey.shade400;

  @override
  Widget build(BuildContext context) {
    final mapModel = Provider.of<MapModel>(context, listen: true);
    final markers = mapModel.markers;
    return Expanded(
      flex: 4,
      child:
      ReorderableListView(
        header: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Row(
            children: [
              buildHeader('이름', flex: flexList[0], size: 13, weight: FontWeight.bold),
              buildDivider(thick: 1),
              buildHeader('경도, 위도', flex: flexList[1], size: 13, weight: FontWeight.bold),
              buildDivider(thick: 1),
              buildHeader('수정일', flex: flexList[2], size: 13, weight: FontWeight.bold),
              buildDivider(thick: 1),
              buildHeader('보기', flex: flexList[3], size: 13, weight: FontWeight.bold),
            ],
          ),
        ),
        onReorder: (int oldIndex, int newIndex) {
          mapModel.moveIndex(oldIndex, newIndex);
        },
        children: List.generate(
          markers.length,
          (index) {
            NMarker marker = markers[index];
            final name = marker.caption!.text;
            final lat = marker.position.latitude.toStringAsFixed(7);
            final lng = marker.position.longitude.toStringAsFixed(7);
            String createdAt = marker.info.id;
            createdAt = createdAt.substring(0,createdAt.indexOf("."));

            return Slidable(
              key: UniqueKey(),
              startActionPane: ActionPane(		// 좌에서 우로 슬라이드
                extentRatio: 0.2,				// 슬라이드시 기존 위젯을 가리는 비율 (0 ~ 1)
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context){mapModel.showMarkerEdit(context, index);},
                    backgroundColor: Colors.green,
                    icon: Icons.edit,
                    // label: "이름변경",
                    autoClose: true,			// 외부 클릭시 자동 close
                  ),
                ],
              ),

              endActionPane: ActionPane(		// 우에서 좌로 슬라이드
                extentRatio: 0.2,
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context){mapModel.showMarkerDelete(context, index);},
                    backgroundColor: Colors.red,
                    icon: Icons.delete_forever_rounded,
                    // label: "삭제",
                    autoClose: true,
                  ),
                ],
              ),

              child: GestureDetector(
                key: ValueKey(markers[index]),			// 리스트 요소 Key 지정
                onTap: (){
                  Provider.of<MapModel>(context, listen: false).moveCamera(index);
                },
                child: ListTile(
                  shape: Border(bottom: BorderSide(color: borderColor)),
                  title: Row(
                    children: [
                      buildHeader(name, flex: flexList[0], ),
                      buildDivider(),
                      buildHeader('$lat,\n$lng', flex: flexList[1], ),
                      buildDivider(),
                      buildHeader(createdAt, flex: flexList[2], ),
                      buildDivider(),
                      Expanded(flex: flexList[3],
                        child: IconButton(
                          onPressed: () {
                            // Provider.of<MapModel>(context, listen: false).removeMarker(index);
                          },
                          /*
                          Icons.wb_sunny: 맑은 날씨를 나타내는 아이콘
                          Icons.cloud: 흐린 날씨를 나타내는 아이콘
                          Icons.flash_on: 번개를 나타내는 아이콘
                          Icons.grain: 눈이나 비를 나타내는 아이콘
                          Icons.beach_access: 해변과 관련된 아이콘
                          Icons.umbrella: 우산을 나타내는 아이콘
                          */
                          icon: const Icon(Icons.cloud_circle,
                            color: Colors.blueAccent,
                          ),
                          iconSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            );
          },
        ),
      ),
    );
  }

  Widget buildHeader(String text,
      {int flex = 1, double size = 12, weight = FontWeight.normal, color = Colors.black}) {
    return Expanded(
        flex: flex,
        child: Text(text,textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: size, fontWeight: weight)
        )
    );
  }

  Widget buildDivider({double thick = 0.0}) {
    return SizedBox(
      height: 30,
      child: VerticalDivider(
        color: Colors.black,
        width: 1,
        thickness: thick,
      ),
    );
  }
}
