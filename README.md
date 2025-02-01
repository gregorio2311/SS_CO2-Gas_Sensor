# SS_CO2-Gas_Sensor

Prototipo basado en microprocesadores para la medición de gas y CO₂ en el ambiente. Este proyecto integra sensores, una pantalla TFT y un ESP32 para la lectura y visualización de datos.

---

## **Materiales Necesarios**

### **1. ESP32-WROOM**
Microcontrolador principal del proyecto. Más información y referencia de pines disponible aquí:
[ESP32-WROOM Pin Reference](https://lastminuteengineers.com/esp32-pinout-reference/)

---

### **2. SCD30 (Sensor de CO₂)**
Sensor de dióxido de carbono con alta precisión y funcionalidad avanzada. Incluye documentación sobre uso, ensamblaje y calibración:
[Sensirion SCD30 Manual](https://sensirion.com/products/catalog/SCD30)
[SCD30 Libreria](https://github.com/Sensirion/arduino-i2c-scd30/tree/master/pinouts)

---

### **3. 2.8-INCH TFT LCD Display**
Pantalla táctil para mostrar los valores medidos por los sensores. Información de conexión y pinout disponible aquí:
[Interfacing 2.8-inch TFT LCD with ESP32](https://electropeak.com/learn/interfacing-2-8-inch-tft-lcd-touch-screen-with-esp32/)

---

### **4. MQ-9 (Sensor de gas)**
Sensor analógico para detectar gases como monóxido de carbono. Es simple de conectar mediante entrada analógica. Consulta el manual aquí:
[MQ-9 Datasheet](https://www.pololu.com/file/0J314/MQ9.pdf)
[MQ-9 Datasheet](https://www.electronicoscaldas.com/datasheet/MQ-9_Hanwei.pdf?srsltid=AfmBOoqJuYeODnqje9ZiwBc63UbbHD0YJeurQ5MU0pAK_PhJCSdb5fEC)
[Otros sensores y caracteristicas](https://www.luisllamas.es/arduino-detector-gas-mq/)
[calibracion](https://electropeak.com/learn/how-to-calibrate-and-use-mq9-gas-sensor-w-arduino/)

---

## **Ejemplo de Conexión**
Consulta este ejemplo para una referencia sobre cómo conectar el sensor, la pantalla y el ESP32:
[Ejemplo de conexión](https://www.14core.com/wiring-senserion-scd30-co2-sensor-in-esp32-tft-display/)

> **Notas Importantes:**
> - Este ejemplo utiliza una pantalla distinta. 
> - El diagrama del ESP32 puede no ser completamente preciso; úsalo únicamente como referencia de software.

---

## **Librerías Necesarias**

1. **TFT_eSPI:**
   - La librería requiere modificaciones en el archivo `setup.h`.
   - by bodmer
   
2. **Sensirion I2C SCD30:**
   - by sensirion.
   
3. **Sensirion Core:**
   - by sensirion.

4. **ArduinoHttpClient:**
   - by arduino.

5. **Arduino_ESP32_OTA:**
   - by arduino.

6. **PubSubClient:**
   - by Nick O’Leary.

---

## **Pasos para Implementar**
1. **Configura el ESP32-WROOM:**
   - Conecta correctamente los pines de acuerdo con las referencias proporcionadas.
   
2. **Instala las Librerías Necesarias:**
   - Descarga e instala las librerías desde los enlaces recomendados.
   
3. **Carga el Código en el ESP32:**
   - Ajusta las configuraciones necesarias en el archivo `setup.h` para la pantalla TFT.
   - Sube el código al ESP32 utilizando el Arduino IDE.

4. **Calibra el SCD30:**
   - Sigue las instrucciones del manual de calibración del sensor.

5. **Verifica el Funcionamiento:**
   - Asegúrate de que los datos del SCD30 y MQ-9 se muestran correctamente en la pantalla TFT.

---

## **Referencias**
- [ESP32-WROOM Pin Reference](https://lastminuteengineers.com/esp32-pinout-reference/)
- [SCD30 Manual](https://sensirion.com/products/catalog/SCD30)
- [SCD30 Libreria](https://github.com/Sensirion/arduino-i2c-scd30/tree/master/pinouts)
- [TFT LCD Pinout & Connection](https://electropeak.com/learn/interfacing-2-8-inch-tft-lcd-touch-screen-with-esp32/)
- [MQ-9 Datasheet](https://www.pololu.com/file/0J314/MQ9.pdf)
- [Módulo de alimentación para protoboard](https://www.electronicadiy.com/products/modulo-de-alimentacion-para-protoboard-3-3v-5v-usb)
- [Tutorial conexion HiveMQ](https://www.youtube.com/watch?v=IQu67UkoNQ4&t=1281s)
---