#ifndef WIFI_MQTT_H
#define WIFI_MQTT_H

void conectarWiFi();
void configurarMQTT();
void manejarMQTT();
void publicarDatosMQTT(float co2, float temp, float hum);
void publicarGasMQTT(float gas);

#endif
