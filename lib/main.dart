import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/splash_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Labeling',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: SplashPage(),
    );
  }
}
