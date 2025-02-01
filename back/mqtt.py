import paho.mqtt.client as mqtt
import ssl

# Configuración personalizada de HiveMQ
MQTT_BROKER = "XXXX"
MQTT_PORT = XXXX
MQTT_USER = "XXXX"
MQTT_PASSWORD = "XXXX"

# Tópicos
CO2_TOPIC = "sensor/co2"
TEMP_TOPIC = "sensor/temperature"
HUM_TOPIC = "sensor/humidity"
GAS_TOPIC = "sensor/gas"

def on_connect(client, userdata, flags, rc):
    print("Conectado a HiveMQ con código:", rc)
    client.subscribe([(CO2_TOPIC, 0), (TEMP_TOPIC, 0), (HUM_TOPIC, 0), (GAS_TOPIC, 0)])

def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8")
    print(f"Mensaje recibido en {msg.topic}: {payload}")

# Configurar cliente MQTT con autenticación
client = mqtt.Client()
client.username_pw_set(MQTT_USER, MQTT_PASSWORD)  # Configurar credenciales

# Habilitar TLS para conexión segura
client.tls_set(cert_reqs=ssl.CERT_NONE)

# Asignar funciones de callback
client.on_connect = on_connect
client.on_message = on_message

# Conectar con el broker
client.connect(MQTT_BROKER, MQTT_PORT, 60)

print("Escuchando mensajes de HiveMQ...")
client.loop_forever()
