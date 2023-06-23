import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:provider/provider.dart';

import '../providers/thermal_print.dart';

class ThermalPrinterConfig extends StatefulWidget {
  const ThermalPrinterConfig({super.key});

  @override
  State<ThermalPrinterConfig> createState() => _ThermalPrinterConfigState();
}

class _ThermalPrinterConfigState extends State<ThermalPrinterConfig> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    _portController.text =
        Provider.of<PrinterService>(context, listen: false).port;
    super.initState();
  }

  @override
  void dispose() {
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: Provider.of<PrinterService>(context)
                                        .selectedPrinter ==
                                    null ||
                                Provider.of<PrinterService>(context).isConnected
                            ? null
                            : () => Provider.of<PrinterService>(context,
                                    listen: false)
                                .connectDevice(),
                        child:
                            const Text("Connect", textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: Provider.of<PrinterService>(context)
                                        .selectedPrinter ==
                                    null ||
                                !Provider.of<PrinterService>(context)
                                    .isConnected
                            ? null
                            : () => Provider.of<PrinterService>(context,
                                    listen: false)
                                .disconnect(),
                        child: const Text("Disconnect",
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButtonFormField<PrinterType>(
                value: Provider.of<PrinterService>(context).printerType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.print,
                    size: 24,
                  ),
                  labelText: "Type Printer Device",
                  labelStyle: TextStyle(fontSize: 18.0),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                items: <DropdownMenuItem<PrinterType>>[
                  if (Platform.isAndroid || Platform.isIOS)
                    const DropdownMenuItem(
                      value: PrinterType.bluetooth,
                      child: Text("bluetooth"),
                    ),
                  if (Platform.isAndroid || Platform.isWindows)
                    const DropdownMenuItem(
                      value: PrinterType.usb,
                      child: Text("usb"),
                    ),
                  const DropdownMenuItem(
                    value: PrinterType.network,
                    child: Text("Wifi"),
                  ),
                ],
                onChanged: (PrinterType? value) {
                  if (value != null) {
                    Provider.of<PrinterService>(context, listen: false)
                        .changePrinterType(value);
                  }
                },
              ),
              Visibility(
                visible: Provider.of<PrinterService>(context).printerType ==
                        PrinterType.bluetooth &&
                    Platform.isAndroid,
                child: SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.only(bottom: 20.0, left: 20),
                  title: const Text(
                    "This device supports ble (low energy)",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 19.0),
                  ),
                  value: Provider.of<PrinterService>(context).isBle,
                  onChanged: (bool? value) {
                    Provider.of<PrinterService>(context, listen: false)
                        .changeIsBle(value ?? false);
                  },
                ),
              ),
              Visibility(
                visible: Provider.of<PrinterService>(context).printerType ==
                        PrinterType.bluetooth &&
                    Platform.isAndroid,
                child: SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.only(bottom: 20.0, left: 20),
                  title: const Text(
                    "reconnect",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 19.0),
                  ),
                  value: Provider.of<PrinterService>(context).reconnect,
                  onChanged: (bool? value) =>
                      Provider.of<PrinterService>(context, listen: false)
                          .changeReconnect(value ?? false),
                ),
              ),
              Column(
                  children: Provider.of<PrinterService>(context)
                      .devices
                      .map(
                        (device) => ListTile(
                          title: Text('${device.deviceName}'),
                          subtitle: Platform.isAndroid &&
                                  Provider.of<PrinterService>(context)
                                          .printerType ==
                                      PrinterType.usb
                              ? null
                              : Visibility(
                                  visible: !Platform.isWindows,
                                  child: Text("${device.address}")),
                          onTap: () {
                            // do something
                            Provider.of<PrinterService>(context, listen: false)
                                .selectDevice(device);
                          },
                          leading: (device.typePrinter == PrinterType.usb &&
                                          Platform.isWindows
                                      ? device.deviceName ==
                                          Provider.of<PrinterService>(context)
                                              .selectedPrinter
                                              ?.deviceName
                                      : device.vendorId != null &&
                                          Provider.of<PrinterService>(context)
                                                  .selectedPrinter
                                                  ?.vendorId ==
                                              device.vendorId) ||
                                  (device.address != null &&
                                      Provider.of<PrinterService>(context)
                                              .selectedPrinter
                                              ?.address ==
                                          device.address)
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : null,
                          trailing: OutlinedButton(
                            onPressed: Provider.of<PrinterService>(context)
                                            .selectedPrinter ==
                                        null ||
                                    device.deviceName !=
                                        Provider.of<PrinterService>(context)
                                            .selectedPrinter
                                            ?.deviceName
                                ? null
                                : () async => await Provider.of<PrinterService>(
                                        context,
                                        listen: false)
                                    .printReceiveTest(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 20),
                              child: Text("Print test ticket",
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      )
                      .toList()),
              Visibility(
                visible: Provider.of<PrinterService>(context).printerType ==
                        PrinterType.network &&
                    Platform.isWindows,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                      controller: _ipController,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      decoration: const InputDecoration(
                        label: Text("Ip Address"),
                        prefixIcon: Icon(Icons.wifi, size: 24),
                      ),
                      onChanged:
                          Provider.of<PrinterService>(context, listen: false)
                              .setIpAddress),
                ),
              ),
              Visibility(
                visible: Provider.of<PrinterService>(context).printerType ==
                        PrinterType.network &&
                    Platform.isWindows,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                      controller: _portController,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      decoration: const InputDecoration(
                        label: Text("Port"),
                        prefixIcon: Icon(Icons.numbers_outlined, size: 24),
                      ),
                      onChanged:
                          Provider.of<PrinterService>(context, listen: false)
                              .setPort),
                ),
              ),
              Visibility(
                visible: Provider.of<PrinterService>(context).printerType ==
                        PrinterType.network &&
                    Platform.isWindows,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: OutlinedButton(
                    onPressed: () async {
                      if (_ipController.text.isNotEmpty) {
                        Provider.of<PrinterService>(context, listen: false)
                            .setIpAddress(_ipController.text);
                      }
                      await Provider.of<PrinterService>(context, listen: false)
                          .printReceiveTest();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                      child: Text("Print test ticket",
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
