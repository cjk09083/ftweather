import 'package:flutter/material.dart';
import 'package:ftweather/provider/MapModel.dart';
import 'package:ftweather/widget/MapWidget.dart';
import 'package:ftweather/widget/MarkerList.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather App'),
      ),
      body: Column(
        children: [
          MapWidget(),
          MarkerList(),
        ],
      ),
    );
  }
}
