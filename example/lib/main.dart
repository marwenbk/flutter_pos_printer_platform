import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:provider/provider.dart';

import 'models/home.dart';
import 'providers/thermal_print.dart';
// import 'package:gbk_codec/gbk_codec.dart';

void main() {
  // Register DartPingIOS
  if (Platform.isIOS) {
    DartPingIOS.register();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrinterService?>(
        create: (_) => PrinterService(),
        child: MaterialApp(
          title: 'Flutter Pos Plugin Platform example app',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const Home(),
        ));
  }
}
