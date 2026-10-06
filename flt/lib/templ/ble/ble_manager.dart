import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cardsys/cardsysstruct.dart';
import 'ble_constants.dart';
const String _namePrefsKeyPrefix = 'kairo_device_name_';

class BleManager extends ChangeNotifier {
  final List<MoistureDevice> devices = [];

  final Guid _serviceGuid = Guid(BleIds.service);

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  final Map<String, BluetoothDevice> _bleDevices = {};
  final Map<String, StreamSubscription> _connectionSubs = {};
  final Map<String, BluetoothCharacteristic> _writeChars = {};

  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  bool isScanning = false;

  BleManager() {
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      adapterState = state;
      notifyListeners();
      if (state == BluetoothAdapterState.on) {
        startScan();
      }
    });
  }

  MoistureDevice? _findById(String id) {
    for (final d in devices) {
      if (d.id == id) return d;
    }
    return null;
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<void> startScan() async {
    if (isScanning) return;
    if (await FlutterBluePlus.isSupported == false) return;
    if (adapterState != BluetoothAdapterState.on) return;
    if (!await _ensurePermissions()) return;

    isScanning = true;
    notifyListeners();

    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen(
      (results) {
        for (final r in results) {
          final isKairoSensor = r.advertisementData.serviceUuids.any((g) => g.str.toLowerCase() == BleIds.service.toLowerCase(), );
          if (isKairoSensor) _onSensorFound(r);
        }
      },
      onError: (_) {},
    );

    await FlutterBluePlus.startScan(
      withServices: [_serviceGuid],
      timeout: const Duration(seconds: 15),
    );

    FlutterBluePlus.isScanning.where((s) => s == false).first.then((_) {
      isScanning = false;
      notifyListeners();
    });
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  void _onSensorFound(ScanResult result) {
    final id = result.device.remoteId.str;
    final existing = _findById(id);

    if (existing == null) {
      final advertisedName = result.advertisementData.advName;
      final name =
          advertisedName.isNotEmpty ? advertisedName : 'Moisture Sensor ($id)';
      final device = MoistureDevice(id: id, name: name);
      devices.add(device);
      notifyListeners();
      _connect(device, result.device);
      _applySavedName(device);
      return;
    }

    if (existing.linkState == DeviceLinkState.disconnected) {
      _connect(existing, result.device);
    }
  }

  Future<void> _connect(MoistureDevice device, BluetoothDevice bleDevice) async {
    device.setLinkState(DeviceLinkState.connecting);
    _bleDevices[device.id] = bleDevice;

    await _connectionSubs[device.id]?.cancel();
    _connectionSubs[device.id] = bleDevice.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) {
        device.setLinkState(DeviceLinkState.connected);
      } else if (state == BluetoothConnectionState.disconnected) {
        device.setLinkState(DeviceLinkState.disconnected);
      }
    });

    try {
      await bleDevice.connect(
        license: License.free,
        timeout: const Duration(seconds: 12),
      );
      await _configureAndSubscribe(device, bleDevice);
    } catch (_) {
      device.setLinkState(DeviceLinkState.disconnected);
    }
  }

  Future<void> _configureAndSubscribe(
    MoistureDevice device,
    BluetoothDevice bleDevice,
  ) async {
    final services = await bleDevice.discoverServices();

    BluetoothService? service;
    for (final s in services) {
      if (s.uuid.str.toLowerCase() == BleIds.service.toLowerCase()) {
        service = s;
        break;
      }
    }
    if (service == null) return;

    BluetoothCharacteristic? writeChar;
    BluetoothCharacteristic? readChar;
    for (final c in service.characteristics) {
      final uuid = c.uuid.str.toLowerCase();
      if (uuid == BleIds.writeCharacteristic.toLowerCase()) writeChar = c;
      if (uuid == BleIds.readCharacteristic.toLowerCase()) readChar = c;
    }

    if (writeChar == null || readChar == null) return;
    _writeChars[device.id] = writeChar;
    await writeChar.write(_intervalPayload(kReadingInterval), withoutResponse: false);

    await readChar.setNotifyValue(true);
    readChar.onValueReceived.listen((value) {
      final moisture = _parseReading(value);
      if (moisture != null) device.addReading(moisture);
    });
  }

  Future<void> calibrateDry(MoistureDevice device) => _writeOpcode(device, BleOpcode.calibrateDry);

  Future<void> calibrateWet(MoistureDevice device) => _writeOpcode(device, BleOpcode.calibrateWet);

  Future<bool> _writeOpcode(MoistureDevice device, int opcode) async {
    final char = _writeChars[device.id];
    if (char == null || device.linkState != DeviceLinkState.connected) {
      return false;
    }
    try {
      await char.write([opcode], withoutResponse: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> renameDevice(MoistureDevice device, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == device.name) return;
    device.setName(trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_namePrefsKeyPrefix${device.id}', trimmed);
  }

  Future<void> _applySavedName(MoistureDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('$_namePrefsKeyPrefix${device.id}');
    if (savedName != null && savedName.isNotEmpty) {
      device.setName(savedName);
    }
  }

  List<int> _intervalPayload(Duration interval) {
    final bytes = ByteData(4)..setUint32(0, interval.inSeconds, Endian.little);
    return [BleOpcode.setIntervalSeconds, ...bytes.buffer.asUint8List()];
  }

  double? _parseReading(List<int> value) {
    if (value.length < 4) return null;
    final bytes = Uint8List.fromList(value.sublist(0, 4));
    final percent = ByteData.sublistView(bytes).getFloat32(0, Endian.little);
    if (percent.isNaN) return null;
    return percent.clamp(0, 100);
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _adapterSub?.cancel();
    for (final sub in _connectionSubs.values) {
      sub.cancel();
    }
    for (final bleDevice in _bleDevices.values) {
      bleDevice.disconnect();
    }
    super.dispose();
  }
}
