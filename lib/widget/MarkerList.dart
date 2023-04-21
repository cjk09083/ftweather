import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Row(
              children: [
                buildHeader('이름', flex: flexList[0], size: 13, weight: FontWeight.bold),
                buildDivider(thick: 1),
                buildHeader('경도, 위도', flex: flexList[1], size: 13, weight: FontWeight.bold),
                buildDivider(thick: 1),
                buildHeader('등록일', flex: flexList[2], size: 13, weight: FontWeight.bold),
                buildDivider(thick: 1),
                buildHeader('삭제', flex: flexList[3], size: 13, weight: FontWeight.bold),
              ],
            ),
          ),
          const Divider(color: Colors.black, thickness: 1,),
          Expanded(
            child: markerListView(markers),
          ),
        ],
      ),
    );
  }

  ListView markerListView(List<NMarker> markers) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(color:Colors.black),
      itemCount: markers.length,
      itemBuilder: (BuildContext context, int index) {
        NMarker marker = markers[index];
        final name = marker.caption!.text;
        final lat = marker.position.latitude.toStringAsFixed(6);
        final lng = marker.position.longitude.toStringAsFixed(6);
        final createdAt = marker.info.id;
        return GestureDetector(
          onTap: (){
            Provider.of<MapModel>(context, listen: false).moveCamera(index);
          },
          child: ListTile(
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
                      Provider.of<MapModel>(context, listen: false).removeMarker(index);
                    },
                    icon: const Icon(Icons.delete_forever_rounded),
                    iconSize: 30,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      height: 20,
      child: VerticalDivider(
        color: Colors.black,
        width: 1,
        thickness: thick,
      ),
    );
  }
}
