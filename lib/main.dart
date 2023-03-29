import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Home.dart';
import 'MyModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyModel(),
      child: MaterialApp(
        title: 'Flutter Weather App',
        home: Home(),
      ),
    );
  }
}
