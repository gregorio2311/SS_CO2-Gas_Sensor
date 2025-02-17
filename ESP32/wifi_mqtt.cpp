#include "wifi_mqtt.h"
#include "config.h"
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

WiFiClientSecure espClient;
PubSubClient client(espClient);

void conectarWiFi() {
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("WiFi conectado");
}

void configurarMQTT() {
    espClient.setInsecure();
    client.setServer(mqtt_server, mqtt_port);
}

void manejarMQTT() {
    if (!client.connected()) {
        while (!client.connect("ESP32Client", mqtt_username, mqtt_password)) {
            Serial.println("Reintentando conexión MQTT...");
            delay(500);
        }
    }
    client.loop();
}

void publicarDatosMQTT(float co2, float temp, float hum, float gas) {
    StaticJsonDocument<200> jsonDoc;
    jsonDoc["CO2"] = co2;
    jsonDoc["temperature"] = temp;
    jsonDoc["humidity"] = hum;
    jsonDoc["CH4"] = gas;

    char mensaje[256];
    serializeJson(jsonDoc, mensaje); // Convertir JSON a String

    client.publish("sensor/datos", mensaje); // 📡 Publicar en un solo tópico
    Serial.println("📡 Datos enviados a MQTT: " + String(mensaje));
}
