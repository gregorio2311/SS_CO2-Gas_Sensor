#ifndef CONFIG_H
#define CONFIG_H

#include <Arduino.h>

#define MQ9_PIN 33
#define RL 10000
#define Ro 931.0

#define TFT_GREY 0x5AEB

extern const char* ssid;
extern const char* password;
extern const char* mqtt_server;
extern const char* mqtt_username;
extern const char* mqtt_password;
extern const int mqtt_port;

extern const char* co2_topic;
extern const char* temp_topic;
extern const char* hum_topic;
extern const char* gas_topic;

#endif
