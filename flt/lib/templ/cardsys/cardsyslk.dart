import 'package:flutter/material.dart';
import 'dart:ui';

import 'cardsysstruct.dart';
import 'cardsyschr.dart';
import '../colors.dart';
import '../btntemp.dart';
import '../ble/ble_manager.dart';

class DeviceDropdownMenu extends StatelessWidget {
  final MoistureDevice device;
  final BleManager bleManager;

  const DeviceDropdownMenu({Key? key, required this.device, required this.bleManager}) : super(key: key);

  Future<void> _renameDevice(BuildContext context) async {
    final controller = TextEditingController(text: device.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorsMain.surface,
        title: const Text('Rename sensor'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Living Room Fern'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      bleManager.renameDevice(device, newName);
    }
  }

  Future<void> _runCalibration(BuildContext context, Future<void> Function() action, String successMessage) async {
    if (device.linkState != DeviceLinkState.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sensor must be connected to calibrate.')),
      );
      return;
    }
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
        child: Container(

          decoration: const BoxDecoration(
            color: ColorsMain.surfaceGlass,
            border: Border(top: BorderSide(color: ColorsMain.borderGlass, width: 1)),
          ),

          padding: const EdgeInsets.all(24.0),
          height: MediaQuery.of(context).size.height * 0.7,

          // Rebuilds live as new readings arrive from the sensor while this
          // sheet is open.
          child: ListenableBuilder(
            listenable: device,
            builder: (context, _) {
              final moisture = device.lastMoisture;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                device.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsMain.textOnGradPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _renameDevice(context),
                              icon: const Icon(Icons.edit, size: 18.0, color: ColorsMain.textOnGradSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 18.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        moisture == null ? '—' : '${moisture.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: (moisture != null && moisture < 20)
                              ? ColorsMain.error
                              : ColorsMain.textOnGradPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0),
                  Text(_statusLine(device), style: const TextStyle(color: ColorsMain.textOnGradSecondary)),
                  const SizedBox(height: 16.0),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 24.0, top: 24.0, bottom: 8.0, left: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: ColorsMain.borderGlass, width: 1),
                      ),
                      child: MoistureChart(history: device.history),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  const Text(
                    "Calibrate: place the probe in dry soil (or air) and tap Dry, "
                    "then dip it in a cup of water and tap Wet.",
                    style: TextStyle(color: ColorsMain.textOnGradSecondary, fontSize: 12.0),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: TemplateButtonTI(
                          label: "Calibrate Dry",
                          icon: Icons.wb_sunny_outlined,
                          backColor: ColorsMain.btn,
                          ictColor: ColorsMain.textOnBtn,
                          func: () => _runCalibration(
                            context,
                            () => bleManager.calibrateDry(device),
                            'Dry baseline captured.',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TemplateButtonTI(
                          label: "Calibrate Wet",
                          icon: Icons.water_drop_outlined,
                          backColor: ColorsMain.btn,
                          ictColor: ColorsMain.textOnBtn,
                          func: () => _runCalibration(
                            context,
                            () => bleManager.calibrateWet(device),
                            'Wet baseline captured.',
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _statusLine(MoistureDevice device) {
    switch (device.linkState) {
      case DeviceLinkState.connecting:
      case DeviceLinkState.discovered:
        return "Connecting…";
      case DeviceLinkState.disconnected:
        return "Disconnected — showing last known history";
      case DeviceLinkState.connected:
        return device.history.isEmpty
            ? "Connected — waiting for first reading"
            : "Moisture History";
    }
  }
}

// --- The Card Template & Open Function ---
class DeviceCard extends StatelessWidget {
  final MoistureDevice device;
  final BleManager bleManager;

  const DeviceCard({Key? key, required this.device, required this.bleManager}) : super(key: key);

  void _openDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => DeviceDropdownMenu(device: device, bleManager: bleManager),
    );
  }

  Color _statusDotColor(DeviceLinkState state) {
    switch (state) {
      case DeviceLinkState.connected:
        return ColorsMain.secondary;
      case DeviceLinkState.connecting:
      case DeviceLinkState.discovered:
        return ColorsMain.textOnGradSecondary;
      case DeviceLinkState.disconnected:
        return ColorsMain.error;
    }
  }

  String _subtitle(MoistureDevice device) {
    final moisture = device.lastMoisture;
    switch (device.linkState) {
      case DeviceLinkState.discovered:
        return "Found — connecting…";
      case DeviceLinkState.connecting:
        return "Connecting…";
      case DeviceLinkState.disconnected:
        return moisture == null
            ? "Disconnected"
            : "Disconnected — last ${moisture.toStringAsFixed(1)}%";
      case DeviceLinkState.connected:
        return moisture == null
            ? "Connected — needs calibration"
            : "Last measured: ${moisture.toStringAsFixed(1)}%";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: device,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: ColorsMain.surfaceGlass,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: ColorsMain.borderGlass, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: () => _openDropdown(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.circle, size: 10, color: _statusDotColor(device.linkState)),
                  title: Text(
                    device.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: ColorsMain.textOnGradPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _subtitle(device),
                    style: const TextStyle(color: ColorsMain.textOnGradSecondary),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 30.0,
                    color: ColorsMain.textOnGradPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
