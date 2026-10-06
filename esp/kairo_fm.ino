#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <Preferences.h>

#define SERVICE_UUID "ad45ddb6-3376-494a-8b34-b514ba2e9eaa"
#define WRITE_UUID "860c22f1-60a3-411e-b575-c0ecd08cef5d" // Characteristic for configuration
#define READ_UUID "a5b242ef-c4ff-45d4-87e0-7b95439b7763" // Characteristic for data retrieval

#define MS_IO 32

#define CMD_CALIBRATE_DRY 0x01
#define CMD_SET_INTERVAL_SEC 0x02
#define CMD_CALIBRATE_WET 0x03

#define DRY_BASELINE_DEFAULT 62
#define WET_BASELINE_DEFAULT 28

#define REPORT_INTERVAL_DEFAULT_SEC 1800UL

Preferences prefs;

BLECharacteristic* kairo_read = nullptr;
BLECharacteristic* kairo_write = nullptr;

uint32_t dryBaseline = DRY_BASELINE_DEFAULT;
uint32_t wetBaseline = WET_BASELINE_DEFAULT;
unsigned long reportIntervalMs = REPORT_INTERVAL_DEFAULT_SEC * 1000UL;
unsigned long lastReportMs = 0;
volatile bool deviceConnected = false;


uint32_t readRawTouch(int samples) {
  uint32_t sum = 0;
  for (int i = 0; i < samples; i++) {
    sum += touchRead(MS_IO);
    delay(5);
  }
  return sum / samples;
}

void calibrateDry() {
  Serial.println("[Calibrate] Capturing dry baseline...");
  dryBaseline = readRawTouch(16);
  prefs.putUInt("dryBase", dryBaseline);
  Serial.printf("[Calibrate] Dry baseline set to %u\n", dryBaseline);
}

void calibrateWet() {
  Serial.println("[Calibrate] Capturing wet baseline...");
  wetBaseline = readRawTouch(16);
  prefs.putUInt("wetBase", wetBaseline);
  Serial.printf("[Calibrate] Wet baseline set to %u\n", wetBaseline);
}

void setReportInterval(uint32_t seconds) {
  if (seconds < 10) seconds = 10;
  reportIntervalMs = (unsigned long)seconds * 1000UL;
  prefs.putUInt("intervalSec", seconds);
  Serial.printf("[Config] Report interval set to %u s\n", seconds);
}

float readMoisturePercent() {
  uint32_t raw = readRawTouch(8);
  float percent = 100.0f * ((float)dryBaseline - (float)raw) /
                  ((float)dryBaseline - (float)wetBaseline);
  if (percent < 0.0f) percent = 0.0f;
  if (percent > 100.0f) percent = 100.0f;
  return percent;
}

void sendReading() {
  float percent = readMoisturePercent();
  Serial.printf("[Loop] Moisture: %.1f%%\n", percent);

  uint8_t payload[4];
  memcpy(payload, &percent, sizeof(percent));
  kairo_read->setValue(payload, sizeof(payload));
  kairo_read->notify();
}

class KairoServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* server) {
    Serial.println("[BLE] Phone connected");
    deviceConnected = true;

    lastReportMs = millis() - reportIntervalMs + 3000;
  }

  void onDisconnect(BLEServer* server) {
    Serial.println("[BLE] Phone disconnected - resuming advertising");
    deviceConnected = false;
    BLEDevice::startAdvertising();
  }
};

class KairoConfigCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* characteristic) {
    uint8_t* data = characteristic->getData();
    size_t len = characteristic->getLength();
    if (len < 1) return;

    uint8_t opcode = data[0];
    switch (opcode) {
      case CMD_CALIBRATE_DRY:
        calibrateDry();
        break;

      case CMD_CALIBRATE_WET:
        calibrateWet();
        break;

      case CMD_SET_INTERVAL_SEC:
        if (len >= 5) {
          uint32_t seconds;
          memcpy(&seconds, data + 1, sizeof(seconds));
          setReportInterval(seconds);
        } else {
          Serial.println("[Config] Malformed set-interval command");
        }
        break;

      default:
        Serial.printf("[Config] Unknown opcode 0x%02X\n", opcode);
    }
  }
};


void initializeBLE() {
  Serial.println("Device Open");
  BLEDevice::init("Kairo Moisture Sensor");

  Serial.println("BLE Server Setup");
  BLEServer* ble_server = BLEDevice::createServer();
  ble_server->setCallbacks(new KairoServerCallbacks());

  BLEService* kairo_service = ble_server->createService(SERVICE_UUID);

  Serial.println("BLE Characteristic Setup");
  kairo_read = kairo_service->createCharacteristic(
    READ_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  kairo_read->addDescriptor(new BLE2902());

  kairo_write = kairo_service->createCharacteristic(
    WRITE_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  kairo_write->setCallbacks(new KairoConfigCallbacks());

  kairo_service->start();

  Serial.println("Starting advertising");
  BLEAdvertising* advertising = BLEDevice::getAdvertising();
  advertising->addServiceUUID(SERVICE_UUID);
  advertising->setScanResponse(true);
  advertising->setMinPreferred(0x06); // helps iOS connection issues
  advertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void setup() {
  Serial.begin(115200);

  prefs.begin("kairo", false);
  dryBaseline = prefs.getUInt("dryBase", DRY_BASELINE_DEFAULT);
  wetBaseline = prefs.getUInt("wetBase", WET_BASELINE_DEFAULT);
  uint32_t storedIntervalSec = prefs.getUInt("intervalSec", REPORT_INTERVAL_DEFAULT_SEC);
  reportIntervalMs = (unsigned long)storedIntervalSec * 1000UL;

  Serial.printf(
    "Loaded dry baseline=%u, wet baseline=%u, interval=%us\n",
    dryBaseline, wetBaseline, storedIntervalSec
  );

  initializeBLE();
}

void loop() {
  unsigned long now = millis();
  if (now - lastReportMs >= reportIntervalMs) {
    lastReportMs = now;
    if (deviceConnected) {
      sendReading();
    } else {
      Serial.println("No phone connected");
    }
  }

  Serial.println(touchRead(MS_IO));
  delay(200);
}
