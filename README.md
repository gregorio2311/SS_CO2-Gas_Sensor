# SS_CO2-Gas_Sensor
Prototipo con microprocesadores para la medición de Gas y CO2 en el ambiente

Materiales:

esp32-wroom:
https://lastminuteengineers.com/esp32-pinout-reference/
nota: esp32-wroom pin reference

SCD30:
https://sensirion.com/products/catalog/SCD30
nota: Incluye manuales de uso, ensamblaje, calibracion. 

2.8 INCH TFT LCD Display:
https://electropeak.com/learn/interfacing-2-8-inch-tft-lcd-touch-screen-with-esp32/
nota: pin reference y conexion a esp32-wroom

MQ-9 FC-22:
https://www.pololu.com/file/0J314/MQ9.pdf
nota: componente simple solo hay que conectar entrada analoga

Ejemplo de conexion sensor-pantalla-esp32:
https://www.14core.com/wiring-senserion-scd30-co2-sensor-in-esp32-tft-display/
nota: Pantalla distinta, esp32-diagram mal, usar solo como soft_reference.

nota:faltan agregar las librerias necesarias para algunos componentes
tft display(requiere modificar setup.h)
esp32-wroom
SCD30

estas pueden ser agregadas desde github o desde arduino