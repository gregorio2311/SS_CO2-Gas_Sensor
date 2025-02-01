#include "sensor_scd30.h"
#include <Wire.h>  
#include <SensirionI2cScd30.h>

SensirionI2cScd30 sensor;

void scanI2C() {
    byte error, address;
    int nDevices = 0;
    for (address = 1; address < 127; address++) {
        Wire.beginTransmission(address);
        error = Wire.endTransmission();
        if (error == 0) {
            Serial.printf("I2C encontrado en 0x%X\n", address);
            nDevices++;
        }
    }
    if (nDevices == 0) Serial.println("No se encontraron dispositivos I2C.");
}

void iniciarSensorSCD30() {
    Wire.begin();  
    sensor.begin(Wire, SCD30_I2C_ADDR_61);
    delay(5000);
    sensor.softReset();
    delay(2000);
    sensor.startPeriodicMeasurement(0);
}

bool leerSensorSCD30(float &co2, float &temp, float &hum) {
    return (sensor.readMeasurementData(co2, temp, hum) == NO_ERROR);
}
