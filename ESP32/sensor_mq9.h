#ifndef SENSOR_MQ9_H
#define SENSOR_MQ9_H

float leerSensorMQ9();
float calculateRS(int analogValue);
float calculateConcentration(float RS);
#endif
