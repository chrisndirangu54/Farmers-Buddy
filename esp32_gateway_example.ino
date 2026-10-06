// Farmers Buddy reference gateway skeleton. Replace placeholders with your secure provisioning flow.
#include <WiFi.h>
#include <HTTPClient.h>

const int SOIL_PIN = 34;
const int PUMP_RELAY = 26;
const int SAFE_MIN_MOISTURE = 25;
const int SAFE_MAX_RUN_SECONDS = 180;

void setup() {
  Serial.begin(115200);
  pinMode(PUMP_RELAY, OUTPUT);
  digitalWrite(PUMP_RELAY, LOW); // fail-safe default OFF
}

void loop() {
  int raw = analogRead(SOIL_PIN);
  int moisture = map(raw, 4095, 0, 0, 100);
  Serial.printf("soil_moisture=%d%%\n", moisture);

  // Production design: send signed telemetry to an HTTPS/MQTT gateway and accept only
  // authenticated, expiring commands. Never expose relay control directly to the internet.
  delay(30000);
}
