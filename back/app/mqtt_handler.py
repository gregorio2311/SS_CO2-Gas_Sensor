import paho.mqtt.client as mqtt
import ssl
import json
from datetime import datetime
import asyncio
from .config import (
    MQTT_BROKER,
    MQTT_PORT,
    MQTT_TOPIC,
    MQTT_USERNAME,
    MQTT_PASSWORD,
)

class MQTTHandler:
    def __init__(self, save_callback, loop):
        self.mqtt_client = mqtt.Client()
        self.save_callback = save_callback
        self.loop = loop
        self._configure_client()

    def _configure_client(self):
        self.mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
        self.mqtt_client.tls_set_context(ssl.create_default_context())
        self.mqtt_client.on_connect = self._on_connect
        self.mqtt_client.on_message = self._on_message

    def _on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print("✅ Conectado exitosamente a HiveMQ Cloud")
            client.subscribe(MQTT_TOPIC)
            print(f"📡 Suscrito a: {MQTT_TOPIC}")
        else:
            print(f"⚠️ Error de conexión MQTT. Código: {rc}")

    def _on_message(self, client, userdata, message):
        try:
            data = json.loads(message.payload.decode())
            print(f"📥 Mensaje recibido en {message.topic}: {data}")
            
            # Ejecutar el callback de guardado en el loop de eventos
            future = asyncio.run_coroutine_threadsafe(
                self.save_callback(data), 
                self.loop
            )
            future.result()
        except Exception as e:
            print(f"⚠️ Error procesando mensaje MQTT: {e}")

    def connect(self):
        self.mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
        self.mqtt_client.loop_start()

    def disconnect(self):
        self.mqtt_client.loop_stop()
        self.mqtt_client.disconnect() 