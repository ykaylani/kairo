class BleIds {
  BleIds._();

  static const String service = "ad45ddb6-3376-494a-8b34-b514ba2e9eaa";
  static const String writeCharacteristic = "860c22f1-60a3-411e-b575-c0ecd08cef5d";
  static const String readCharacteristic = "a5b242ef-c4ff-45d4-87e0-7b95439b7763";
}

class BleOpcode {
  BleOpcode._();

  static const int calibrateDry = 0x01;
  static const int setIntervalSeconds = 0x02;
  static const int calibrateWet = 0x03;
}

const Duration kReadingInterval = Duration(minutes: 30);
