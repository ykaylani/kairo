import 'package:flutter/foundation.dart';

enum DeviceLinkState { discovered, connecting, connected, disconnected }

class MoistureEvent {
  final DateTime time;
  final double moisture;

  MoistureEvent({required this.time, required this.moisture});
}

class MoistureDevice extends ChangeNotifier {
  final String id;
  String name;
  DeviceLinkState linkState;
  double? lastMoisture;

  final List<MoistureEvent> history = [];

  MoistureDevice({
    required this.id,
    required this.name,
    this.linkState = DeviceLinkState.discovered,
  });

  void setName(String newName) {
    if (name == newName) return;
    name = newName;
    notifyListeners();
  }

  void setLinkState(DeviceLinkState state) {
    if (linkState == state) return;
    linkState = state;
    notifyListeners();
  }

  void addReading(double moisturePercent, {DateTime? time}) {
    history.add(MoistureEvent(time: time ?? DateTime.now(), moisture: moisturePercent));
    lastMoisture = moisturePercent;
    notifyListeners();
  }
}
