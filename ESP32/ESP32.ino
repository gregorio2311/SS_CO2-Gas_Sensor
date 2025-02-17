#include <Wire.h>  
#include "config.h"
#include "wifi_mqtt.h"
#include "sensor_scd30.h"
#include "sensor_mq9.h"
#include <TFT_eSPI.h>
TFT_eSPI tft = TFT_eSPI();


void setup() {
    Serial.begin(9600);
    Wire.begin(); 
    scanI2C();
    iniciarSensorSCD30();
    conectarWiFi();
    configurarMQTT();
    tft.init();
    tft.setRotation(1);
    tft.fillScreen(TFT_BLACK);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setTextSize(2);

    tft.setCursor(10, 10);
    tft.println("Ambiente");
    tft.drawLine(0, 40, 240, 40, TFT_GREY);

}

void loop() {
    manejarMQTT();

    float co2, temp, hum;
    float gas = leerSensorMQ9();
    if (leerSensorSCD30(co2, temp, hum)) {
        publicarDatosMQTT(co2, temp, hum, gas);
    } 

   /* float gas = leerSensorMQ9();
    publicarGasMQTT(gas);*/
    Serial.println("Actualizando pantalla con valores...");
    Serial.printf("CO2: %.2f ppm, Temp: %.2f C, Hum: %.2f%%, ch4: %.1f ppm\n", co2, temp, hum, gas);
    tft.fillRect(10, 50, 250, 200, TFT_BLACK); 

    tft.setCursor(10, 60);
    tft.printf("CO2: %.1f ppm", co2);

    tft.setCursor(10, 100);
    tft.printf("Temp: %.1f C", temp);

    tft.setCursor(10, 140);
    tft.printf("Humidity: %.1f %%", hum);

    tft.setCursor(10, 180);
    tft.printf("CH4 / Gas LP: %.1f ppm", gas);
    delay(3000);
}


