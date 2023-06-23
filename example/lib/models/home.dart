import 'package:flutter/material.dart';

import '../widgets/printer_config_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Pos Plugin Platform example app'),
        ),
        body: const ThermalPrinterConfig());
  }
}
