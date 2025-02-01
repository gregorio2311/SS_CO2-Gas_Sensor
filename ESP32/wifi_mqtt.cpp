#include "wifi_mqtt.h"
#include "config.h"
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>

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

void publicarDatosMQTT(float co2, float temp, float hum) {
    client.publish(co2_topic, String(co2).c_str());
    client.publish(temp_topic, String(temp).c_str());
    client.publish(hum_topic, String(hum).c_str());
}

void publicarGasMQTT(float gas) {
    client.publish(gas_topic, String(gas).c_str());
}
