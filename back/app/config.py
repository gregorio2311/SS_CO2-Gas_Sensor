import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# MongoDB Configuration
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DB_NAME = os.getenv("DB_NAME", "iot_sensors")
COLLECTION_NAME = os.getenv("COLLECTION_NAME")

# MQTT Configuration
MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC = os.getenv("MQTT_TOPIC")
MQTT_USERNAME = os.getenv("MQTT_USERNAME", "")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD", "")

# JWT Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# API Configuration
API_PREFIX = "/api/v1"
API_TITLE = "IoT Sensors API"
API_VERSION = "1.0.0"

# WebSocket Configuration
WS_PREFIX = "/ws"

# Collections
COLLECTIONS = {
    "users": "users",
    "devices": "devices",
    "sensors": "sensors",
    "sensor_data": "sensor_data"
} 