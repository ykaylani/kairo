import 'package:flutter/material.dart';
import 'dart:ui';

import 'cardsysstruct.dart';
import 'cardsyschr.dart';
import '../colors.dart';

class DeviceDropdownMenu extends StatelessWidget {
  final MoistureDevice device;
  const DeviceDropdownMenu({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(

          decoration: const BoxDecoration(
            color: ColorsMain.surfaceGlass,
            border: Border(top: BorderSide(color: ColorsMain.borderGlass, width: 1)),
          ),

          padding: const EdgeInsets.all(24.0),
          height: MediaQuery.of(context).size.height * 0.5,

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: ColorsMain.textOnGradPrimary,
                    ),
                  ),
                  Text(
                    '${device.lastMoisture.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: device.lastMoisture < 20 ? ColorsMain.error : ColorsMain.textOnGradPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8.0),
              const Text("Moisture History", style: TextStyle(color: ColorsMain.textOnGradSecondary)),
              const SizedBox(height: 16.0),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 24.0, top: 24.0, bottom: 8.0, left: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: ColorsMain.borderGlass, width: 1),
                  ),
                  child: MoistureChart(history: device.history),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// --- The Card Template & Open Function ---
class DeviceCard extends StatelessWidget {
  final MoistureDevice device;

  const DeviceCard({Key? key, required this.device}) : super(key: key);

  void _openDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => DeviceDropdownMenu(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(

        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(

          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(

            decoration: BoxDecoration(
              color: ColorsMain.surfaceGlass,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: ColorsMain.borderGlass, width: 1),
            ),

            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openDropdown(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(

                      device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: ColorsMain.textOnGradPrimary,
                      ),
                    ),

                    subtitle: Text(
                      'Last measured: ${device.lastMoisture.toStringAsFixed(1)}%',
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
          ),
        ),
      ),
    );
  }
}