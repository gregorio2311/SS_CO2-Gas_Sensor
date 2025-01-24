#include <Arduino.h>
#include <SensirionI2cScd30.h>
#include <Wire.h>
#include <TFT_eSPI.h> // Hardware-specific library
#include <SPI.h>

// Sensor object
SensirionI2cScd30 sensor;

#define MQ9_PIN 33 // Pin analógico para el MQ-9
#define RL 10000 // Resistencia de carga en ohmios (RL)
#define Ro 10000.0 // Valor calibrado de Ro en aire limpio (ajústalo experimentalmente)

TFT_eSPI tft = TFT_eSPI();       // Invoke custom library

#define TFT_GREY 0x5AEB
#define LOOP_PERIOD 35 // Display updates every 35 ms

float ltx = 0;    // Saved x coord of bottom of needle
uint16_t osx = 120, osy = 120; // Saved x & y coords
uint32_t updateTime = 0;       // time for next update

int old_analog =  -999; // Value last displayed

void analogMeter(bool isCO2);
void plotNeedle(int value, byte ms_delay, bool isCO2);

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

    tft.init();
    tft.setRotation(0);
    tft.fillScreen(TFT_BLACK);

    analogMeter(true); // Draw analogue meter for CO2
    analogMeter(false); // Draw analogue meter for gas concentration

    updateTime = millis(); // Next update time
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
    Serial.println(" ppm");

    if (updateTime <= millis()) {
        updateTime = millis() + LOOP_PERIOD;

        // Update CO2 meter
        plotNeedle(co2, 0, true);

        // Update gas concentration meter
        plotNeedle(concentration, 0, false);
    }

    delay(1500); // Wait before updating again
}

// #########################################################################
//  Draw the analogue meter on the screen
// #########################################################################
void analogMeter(bool isCO2)
{
    // Meter outline
    tft.fillRect(0, 0, 239, 126, TFT_GREY);
    tft.fillRect(5, 3, 230, 119, TFT_WHITE);

    tft.setTextColor(TFT_BLACK);  // Text colour

    // Draw ticks every 5 degrees from -50 to +50 degrees (100 deg. FSD swing)
    for (int i = -50; i < 51; i += 5) {
        // Long scale tick length
        int tl = 15;

        // Coordinates of tick to draw
        float sx = cos((i - 90) * 0.0174532925);
        float sy = sin((i - 90) * 0.0174532925);
        uint16_t x0 = sx * (100 + tl) + 120;
        uint16_t y0 = sy * (100 + tl) + 140;
        uint16_t x1 = sx * 100 + 120;
        uint16_t y1 = sy * 100 + 140;

        // Coordinates of next tick for zone fill
        float sx2 = cos((i + 5 - 90) * 0.0174532925);
        float sy2 = sin((i + 5 - 90) * 0.0174532925);
        int x2 = sx2 * (100 + tl) + 120;
        int y2 = sy2 * (100 + tl) + 140;
        int x3 = sx2 * 100 + 120;
        int y3 = sy2 * 100 + 140;

        if (isCO2) {
            // Green zone limits
            if (i >= -50 && i < 0) {
                tft.fillTriangle(x0, y0, x1, y1, x2, y2, TFT_GREEN);
                tft.fillTriangle(x1, y1, x2, y2, x3, y3, TFT_GREEN);
            }

            // Orange zone limits
            if (i >= 0 && i < 30) {
                tft.fillTriangle(x0, y0, x1, y1, x2, y2, TFT_ORANGE);
                tft.fillTriangle(x1, y1, x2, y2, x3, y3, TFT_ORANGE);
            }

            // Red zone limits
            if (i >= 30 && i < 50) {
                tft.fillTriangle(x0, y0, x1, y1, x2, y2, TFT_RED);
                tft.fillTriangle(x1, y1, x2, y2, x3, y3, TFT_RED);
            }
        } else {
            // Green zone limits
            if (i >= 0 && i < 25) {
                tft.fillTriangle(x0, y0, x1, y1, x2, y2, TFT_GREEN);
                tft.fillTriangle(x1, y1, x2, y2, x3, y3, TFT_GREEN);
            }

            // Orange zone limits
            if (i >= 25 && i < 50) {
                tft.fillTriangle(x0, y0, x1, y1, x2, y2, TFT_ORANGE);
                tft.fillTriangle(x1, y1, x2, y2, x3, y3, TFT_ORANGE);
            }
        }

        // Short scale tick length
        if (i % 25 != 0) tl = 8;

        // Recalculate coords incase tick length changed
        x0 = sx * (100 + tl) + 120;
        y0 = sy * (100 + tl) + 140;
        x1 = sx * 100 + 120;
        y1 = sy * 100 + 140;

        // Draw tick
        tft.drawLine(x0, y0, x1, y1, TFT_BLACK);

        // Check if labels should be drawn, with position tweaks
        if (i % 25 == 0) {
            // Calculate label positions
            x0 = sx * (100 + tl + 10) + 120;
            y0 = sy * (100 + tl + 10) + 140;
            if (isCO2) {
                switch (i / 25) {
                    case -2: tft.drawCentreString("0", x0, y0 - 12, 2); break;
                    case -1: tft.drawCentreString("2500", x0, y0 - 9, 2); break;
                    case 0: tft.drawCentreString("5000", x0, y0 - 6, 2); break;
                    case 1: tft.drawCentreString("7500", x0, y0 - 9, 2); break;
                    case 2: tft.drawCentreString("10000", x0, y0 - 12, 2); break;
                }
            } else {
                switch (i / 25) {
                    case -2: tft.drawCentreString("0", x0, y0 - 12, 2); break;
                    case -1: tft.drawCentreString("25", x0, y0 - 9, 2); break;
                    case 0: tft.drawCentreString("50", x0, y0 - 6, 2); break;
                    case 1: tft.drawCentreString("75", x0, y0 - 9, 2); break;
                    case 2: tft.drawCentreString("100", x0, y0 - 12, 2); break;
                }
            }
        }

        // Now draw the arc of the scale
        sx = cos((i + 5 - 90) * 0.0174532925);
        sy = sin((i + 5 - 90) * 0.0174532925);
        x0 = sx * 100 + 120;
        y0 = sy * 100 + 140;
        // Draw scale arc, don't draw the last part
        if (i < 50) tft.drawLine(x0, y0, x1, y1, TFT_BLACK);
    }

    if (isCO2) {
        tft.drawString("CO2 ppm", 5, 119 - 20, 2); // Units at bottom left
    } else {
        tft.drawString("%RH", 5 + 230 - 40, 119 - 20, 2); // Units at bottom right
        tft.drawCentreString("%RH", 120, 70, 4); // Comment out to avoid font 4
    }
    tft.drawRect(5, 3, 230, 119, TFT_BLACK); // Draw bezel line

    plotNeedle(0, 0, isCO2); // Put meter needle at 0
}

// #########################################################################
// Update needle position
// This function is blocking while needle moves, time depends on ms_delay
// 10ms minimises needle flicker if text is drawn within needle sweep area
// Smaller values OK if text not in sweep area, zero for instant movement but
// does not look realistic... (note: 100 increments for full scale deflection)
// #########################################################################
void plotNeedle(int value, byte ms_delay, bool isCO2)
{
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    char buf[8]; dtostrf(value, 4, 0, buf);
    tft.drawRightString(buf, 40, 119 - 20, 2);

    if (isCO2) {
        value = map(value, 0, 10000, -50, 50); // Map CO2 value to angle
    } else {
        value = map(value, 0, 100, -50, 50); // Map gas concentration value to angle
    }

    if (value < -50) value = -50; // Limit value to emulate needle end stops
    if (value > 50) value = 50;

    // Move the needle until new value reached
    while (!(value == old_analog)) {
        if (old_analog < value) old_analog++;
        else old_analog--;

        if (ms_delay == 0) old_analog = value; // Update immediately if delay is 0

        float sdeg = map(old_analog, -50, 50, -150, -30); // Map value to angle
        // Calculate tip of needle coords
        float sx = cos(sdeg * 0.0174532925);
        float sy = sin(sdeg * 0.0174532925);

        // Calculate x delta of needle start (does not start at pivot point)
        float tx = tan((sdeg + 90) * 0.0174532925);

        // Erase old needle image
        tft.drawLine(120 + 20 * ltx - 1, 140 - 20, osx - 1, osy, TFT_WHITE);
        tft.drawLine(120 + 20 * ltx, 140 - 20, osx, osy, TFT_WHITE);
        tft.drawLine(120 + 20 * ltx + 1, 140 - 20, osx + 1, osy, TFT_WHITE);

        // Re-plot text under needle
        tft.setTextColor(TFT_BLACK);
        if (isCO2) {
            tft.drawString("CO2 ppm", 5, 119 - 20, 2); // Units at bottom left
        } else {
            tft.drawCentreString("%RH", 120, 70, 4); // Comment out to avoid font 4
        }

        // Store new needle end coords for next erase
        ltx = tx;
        osx = sx * 98 + 120;
        osy = sy * 98 + 140;

        // Draw the needle in the new position, magenta makes needle a bit bolder
        // draws 3 lines to thicken needle
        tft.drawLine(120 + 20 * ltx - 1, 140 - 20, osx - 1, osy, TFT_RED);
        tft.drawLine(120 + 20 * ltx, 140 - 20, osx, osy, TFT_MAGENTA);
        tft.drawLine(120 + 20 * ltx + 1, 140 - 20, osx + 1, osy, TFT_RED);

        // Slow needle down slightly as it approaches new position
        if (abs(old_analog - value) < 10) ms_delay += ms_delay / 5;

        // Wait before next update
        delay(ms_delay);
    }
}
