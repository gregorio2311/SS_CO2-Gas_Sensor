#ifndef SENSOR_SCD30_H
#define SENSOR_SCD30_H

void scanI2C();
void iniciarSensorSCD30();
bool leerSensorSCD30(float &co2, float &temp, float &hum);

#endif
