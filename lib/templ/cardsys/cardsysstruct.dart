import 'package:flutter/material.dart';

// Represents a single row in your CSV
class MoistureEvent {
  final DateTime time;
  final int eventNo;
  final double moisture;

  MoistureEvent({required this.time, required this.eventNo, required this.moisture});
}

// Represents the Device
class MoistureDevice {
  final String name;
  final double lastMoisture;
  final List<MoistureEvent> history;

  MoistureDevice({required this.name, required this.lastMoisture, required this.history});
}

// --- PLACEHOLDER DATA ---
final List<MoistureDevice> placeholderDevices = [
  MoistureDevice(
    name: "Living Room Fern",
    lastMoisture: 42.5,
    history: [
      MoistureEvent(time: DateTime.now().subtract(const Duration(hours: 4)), eventNo: 1, moisture: 60.0),
      MoistureEvent(time: DateTime.now().subtract(const Duration(hours: 3)), eventNo: 2, moisture: 55.0),
      MoistureEvent(time: DateTime.now().subtract(const Duration(hours: 2)), eventNo: 3, moisture: 48.0),
      MoistureEvent(time: DateTime.now().subtract(const Duration(hours: 1)), eventNo: 4, moisture: 42.5),
    ],
  ),
  MoistureDevice(
    name: "Porch Tomato",
    lastMoisture: 12.0,
    history: [], // Empty history test
  ),
];