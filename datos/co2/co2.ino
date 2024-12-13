
#include <Arduino.h>
#include <SensirionI2cScd30.h>
#include <Wire.h>
#include <TFT_eSPI.h> // TFT display library
#include <SPI.h>

// Sensor and TFT display objects
SensirionI2cScd30 sensor;
TFT_eSPI tft = TFT_eSPI();

#define TFT_GREY 0x5AEB

void setup() {
    // Initialize Serial Monitor
    Serial.begin(9600);
    while (!Serial) { delay(100); }

    // Initialize I2C and sensor
    Wire.begin();
    sensor.begin(Wire, SCD30_I2C_ADDR_61);

    // Stop any previous measurements and reset the sensor
    sensor.stopPeriodicMeasurement();
    sensor.softReset();
    delay(2000);

    // Start periodic measurements
    if (sensor.startPeriodicMeasurement(0) != NO_ERROR) {
        Serial.println("Error initializing the SCD30 sensor.");
        while (1);
    }

    // Initialize TFT display
    tft.init();
    tft.setRotation(1);
    tft.fillScreen(TFT_BLACK);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setTextSize(2);

    // Draw static screen layout
    tft.setCursor(10, 10);
    tft.println("CO2 Monitor");
    tft.drawLine(0, 40, 240, 40, TFT_GREY);
}

void loop() {
    // Variables for sensor readings
    float co2 = 0.0, temperature = 0.0, humidity = 0.0;

    // Read data from the sensor
    if (sensor.blockingReadMeasurementData(co2, temperature, humidity) != NO_ERROR) {
        Serial.println("Error reading data from the SCD30 sensor.");
        delay(2000);
        return;
    }

    // Print values to Serial Monitor
    Serial.print("CO2: "); Serial.print(co2); Serial.print(" ppm	");
    Serial.print("Temp: "); Serial.print(temperature); Serial.print(" C	");
    Serial.print("Humidity: "); Serial.print(humidity); Serial.println(" %");

    // Update TFT display with sensor data
    tft.fillRect(10, 50, 220, 180, TFT_BLACK); // Clear previous data

    tft.setCursor(10, 60);
    tft.printf("CO2: %.1f ppm", co2);

    tft.setCursor(10, 100);
    tft.printf("Temp: %.1f C", temperature);

    tft.setCursor(10, 140);
    tft.printf("Humidity: %.1f %%", humidity);

    delay(1500); // Wait before updating again
}
