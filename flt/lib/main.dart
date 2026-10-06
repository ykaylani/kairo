import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:ui';

import 'templ/btntemp.dart';
import 'templ/colors.dart';
import 'templ/bgshps.dart';

import 'templ/ble/ble_manager.dart';
import 'templ/cardsys/cardsyslk.dart';

void main() { runApp(const Kairo()); }

class Kairo extends StatelessWidget {
  const Kairo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Kairo',
      home: Homepage(title: 'Kairo - Dashboard'),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.title});
  final String title;

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  late final BleManager _bleManager;

  @override
  void initState() {
    super.initState();
    // Starts listening for Kairo sensors as soon as Bluetooth is on.
    _bleManager = BleManager();
  }

  @override
  void dispose() {
    _bleManager.dispose();
    super.dispose();
  }

  Widget _statusCard({required IconData icon, required String message}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: ColorsMain.surfaceGlass,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: ColorsMain.borderGlass, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: ColorsMain.textOnGradSecondary),
            const SizedBox(height: 12.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorsMain.textOnGradSecondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the necessary top padding dynamically
    final topOffset = MediaQuery.of(context).padding.top + kToolbarHeight + 16.0;

    return Scaffold(
      // 1. This tells the background to flow all the way to the top of the screen
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        // 2. Make the default AppBar background completely transparent
          backgroundColor: Colors.transparent,
          elevation: 0,

          // 3. Create the frosted glass effect behind the AppBar content
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: ColorsMain.surfaceGlass,
                  border: Border(
                      bottom: BorderSide(color: ColorsMain.borderGlass, width: 1)
                  ),
                ),
              ),
            ),
          ),

          title: Text(
            widget.title,
            style: const TextStyle(color: ColorsMain.textOnGradPrimary), // Ensure text stays white
          ),
          actionsPadding: const EdgeInsets.only(right: 16.0),

          actions: <Widget>[
            TemplateButtonTI(
              label: "Settings",
              icon: Icons.settings,
              func: () {},
              backColor: ColorsMain.btn,
              ictColor: ColorsMain.textOnBtn,
            )
          ]
      ),

      body: GlassBackground(
        numberOfShapes: 14,
        // Rebuilds whenever a sensor is discovered/lost, Bluetooth turns
        // on/off, or a scan starts/stops. Per-sensor data updates (a new
        // reading) are handled inside DeviceCard itself, not here.
        child: ListenableBuilder(
          listenable: _bleManager,
          builder: (context, _) {
            if (_bleManager.adapterState != BluetoothAdapterState.on) {
              return Padding(
                padding: EdgeInsets.only(top: topOffset),
                child: _statusCard(
                  icon: Icons.bluetooth_disabled,
                  message: "Turn on Bluetooth to find your Kairo moisture sensors.",
                ),
              );
            }

            if (_bleManager.devices.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: topOffset),
                child: _statusCard(
                  icon: Icons.bluetooth_searching,
                  message: _bleManager.isScanning
                      ? "Scanning for moisture sensors…"
                      : "No sensors found yet. Tap the button below to scan again.",
                ),
              );
            }

            return ListView.builder(
              // Tell the list NOT to cache the visual state of the children
              addRepaintBoundaries: true,

              padding: EdgeInsets.only(top: topOffset, bottom: 80.0),
              itemCount: _bleManager.devices.length,
              itemBuilder: (context, index) {
                return DeviceCard(device: _bleManager.devices[index], bleManager: _bleManager);
              },
            );
          },
        ),
      ),

      floatingActionButton: TemplateButtonIcon(
        icon: Icons.bluetooth_searching,
        iconSize: 36,
        func: () => _bleManager.startScan(),
        backColor: ColorsMain.btn,
        ictColor: ColorsMain.textOnBtn,
      ),
    );
  }
}
