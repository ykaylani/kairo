# Kairo

an ESP32 sensor that reads a capacitive probe and reports over Bluetooth Low Energy, and a Flutter app that discovers, connects to, names, and charts readings from any number of these sensors.

## Structure

```
kairo/
├── app/ # Flutter mobile app
│   └── lib/
│       ├── main.dart
│       └── templ/
│           ├── colors.dart
│           ├── btntemp.dart
│           ├── bgshps.dart
│           ├── ble/
│           │   ├── ble_constants.dart # UUIDs + wire protocol
│           │   └── ble_manager.dart # scanning, connections, BLE I/O
│           └── cardsys/
│               ├── cardsysstruct.dart # MoistureDevice/MoistureEvent models
│               ├── cardsyslk.dart # device card + detail sheet UI
│               └── cardsyschr.dart # moisture history chart
└── firmware/
    └── kairo_sensor/
        └── kairo_sensor.ino # ESP32 Arduino sketch
```

## How it works

Every physical sensor advertises the **same** BLE Service UUID — that identifies the *protocol*, not the individual unit, the same way every USB flash drive reports the same USB storage class regardless of which drive it is. The app tells sensors apart by each one's own BLE hardware address instead, so any number of sensors can be scanned, connected to, and tracked at once.

| | UUID |
|---|---|
| Service | `ad45ddb6-3376-494a-8b34-b514ba2e9eaa` |
| Write characteristic (config, phone → sensor) | `860c22f1-60a3-411e-b575-c0ecd08cef5d` |
| Read characteristic (data, sensor → phone, notify) | `a5b242ef-c4ff-45d4-87e0-7b95439b7763` |

**Config protocol**: single byte opcode written to the write characteristic, sometimes followed by a payload:

| Opcode | Payload | Meaning |
|---|---|---|
| `0x01` | none | Calibrate dry (capture the current reading as the dry-soil/air baseline) |
| `0x02` | 4 bytes, little-endian `uint32` | Set report interval, in seconds |
| `0x03` | none | Calibrate wet (capture the current reading as the fully-saturated baseline) |

**Reading format**: pushed via notify on the read characteristic: 4 bytes, a little-endian IEEE-754 `float32`, the moisture percentage (0–100).

## Calibrating a sensor

Each physical sensor needs a one-time, two-point calibration, done from the app:

1. Open the sensor's card, place the probe in dry soil (or just air), and tap **Calibrate Dry**.
2. Dip the probe in a cup of water and tap **Calibrate Wet**.

Both buttons are disabled unless the sensor shows as connected. Calibration is stored on the sensor itself (flash).

## Naming a sensor

Tap the pencil icon next to a sensor's name in its detail sheet to rename it. The name is saved on the phone (via `shared_preferences`), keyed by the sensor's BLE address, so it's restored automatically the next time that sensor is found.

## Known limitations

- Calibration has no on-device acknowledgment yet , so the app assumes success once the write completes.
- One phone connection per sensor at a time.
- Report interval not to be used for real application (testing only)