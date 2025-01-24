#include <Arduino.h>
#include <SensirionI2cScd30.h>
#include <Wire.h>
#include <TFT_eSPI.h> // TFT display library
#include <SPI.h>

// Sensor and TFT display objects
SensirionI2cScd30 sensor;
TFT_eSPI tft = TFT_eSPI();

#define TFT_GREY 0x5AEB
#define MQ9_PIN 33 // Pin analógico para el MQ-9
#define RL 10000 // Resistencia de carga en ohmios (RL)
#define Ro 931.0 // Valor calibrado de Ro en aire limpio (ajústalo experimentalmente)

void setup() {
    // Initialize Serial Monitor
    Serial.begin(9600);
    while (!Serial) { delay(100); }

    // Initialize I2C and SCD30 sensor
    Wire.begin();
    sensor.begin(Wire, SCD30_I2C_ADDR_61);

    // Stop any previous measurements and reset the SCD30 sensor
    sensor.stopPeriodicMeasurement();
    sensor.softReset();
    delay(2000);

    // Start periodic measurements for SCD30
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
    tft.println("Ambiente");
    tft.drawLine(0, 40, 240, 40, TFT_GREY);

}

float calculateRS(int analogValue) {
    float VRL = analogValue * (5.0 / 1023.0); // Convertir lectura a voltaje
    float RS = ((5.0 / VRL) - 1) * RL; // Calcular resistencia del sensor
    return RS;
}

float calculateConcentration(float RS) {
    float ratio = RS / Ro; // Relación Rs/Ro
    // Calcular ppm con la curva del datasheet para gas combustible
    float ppm = pow(10, ((log10(ratio) - 0.3) / -0.6)); // Relación logarítmica (simplificada)
    return ppm;
}

void loop() {
    // Variables for sensor readings
    float co2 = 0.0, temperature = 0.0, humidity = 0.0;

    // Read data from SCD30 sensor
    if (sensor.blockingReadMeasurementData(co2, temperature, humidity) != NO_ERROR) {
        Serial.println("Error reading data from the SCD30 sensor.");
        delay(2000);
        return;
    }

    // Force recalibration with a new CO2 reference concentration after 2 minutes
    static unsigned long startTime = millis();
    if (millis() - startTime > 120000) { // 2 minutes
        uint16_t co2RefConcentration = 450; // Example reference concentration
        if (sensor.forceRecalibration(co2RefConcentration) != NO_ERROR) {
            Serial.println("Error forcing recalibration.");
        }


        // Get the current CO2 reference concentration
        uint16_t currentRefConcentration;
        if (sensor.getForceRecalibrationStatus(currentRefConcentration) != NO_ERROR) {
            Serial.println("Error getting recalibration status.");
        } else {
            Serial.print("Current CO2 reference concentration: ");
            Serial.println(currentRefConcentration);
        }

        // Reset start time to avoid repeated recalibration
        startTime = millis();
    }

    // Read data from MQ-9 sensor
    int sensorValue = analogRead(MQ9_PIN);
    float RS = calculateRS(sensorValue); // Calcular resistencia del sensor
    float concentration = calculateConcentration(RS); // Calcular concentración de gas

    // Print values to Serial Monitor
    Serial.print("CO2: "); Serial.print(co2); Serial.print(" ppm\t");
    Serial.print("Temp: "); Serial.print(temperature); Serial.print(" C\t");
    Serial.print("Humidity: "); Serial.print(humidity); Serial.println(" %");
    Serial.print("MQ-9 Analog Value: "); Serial.print(sensorValue);
    Serial.print(" Rs: "); Serial.print(RS);
    Serial.print(" ohm | Concentración de Gas: "); Serial.print(concentration);

    // Update TFT display with sensor data
    tft.fillRect(10, 50, 220, 200, TFT_BLACK); // Clear previous data

    // SCD30 data
    tft.setCursor(10, 60);
    tft.printf("CO2: %.1f ppm", co2);

    tft.setCursor(10, 100);
    tft.printf("Temp: %.1f C", temperature);

    tft.setCursor(10, 140);
    tft.printf("Humidity: %.1f %%", humidity);

    // MQ-9 data
    tft.setCursor(10, 180);
    tft.printf("CH4 / Gas LP: %.1f ppm", concentration);

    delay(1500); // Wait before updating again
}
