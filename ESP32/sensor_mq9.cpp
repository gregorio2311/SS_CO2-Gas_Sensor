#include "sensor_mq9.h"
#include "config.h"
#include <Arduino.h>

float leerSensorMQ9() {
    int sensorValue = analogRead(MQ9_PIN);
    float RS = calculateRS(sensorValue); // Calcular resistencia del sensor
    float concentration = calculateConcentration(RS); // Calcular concentración de gas
    return concentration;
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
