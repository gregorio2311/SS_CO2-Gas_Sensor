import asyncio
import paho.mqtt.client as mqtt
import ssl
import json
from datetime import datetime
from fastapi import FastAPI, HTTPException, Query
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
from dotenv import load_dotenv
import os

# Cargar variables de entorno
load_dotenv()

app = FastAPI()

# 🔹 Configuración de MongoDB
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
COLLECTION_NAME = os.getenv("COLLECTION_NAME")

client = AsyncIOMotorClient(MONGO_URI)
db = client[DB_NAME]
collection = db[COLLECTION_NAME]

# 🔹 Configuración de HiveMQ Cloud
MQTT_BROKER = os.getenv("MQTT_BROKER")
MQTT_PORT = int(os.getenv("MQTT_PORT"))
MQTT_TOPIC = os.getenv("MQTT_TOPIC")
MQTT_USERNAME = os.getenv("MQTT_USERNAME")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD")

# 🔹 Obtener el loop de FastAPI
loop = asyncio.get_event_loop()

# 🔹 Función asíncrona para guardar datos en MongoDB con timestamp
async def save_to_mongo(data):
    document = {
        "timestamp": datetime.utcnow().isoformat(),
        "CO2": data.get("CO2"),
        "temperature": data.get("temperature"),
        "humidity": data.get("humidity"),
        "CH4": data.get("CH4")
    }
    await collection.insert_one(document)
    print(f"✅ Guardado en MongoDB: {document}")

# 🔹 Callback MQTT para recibir mensajes
def on_message(client, userdata, message):
    try:
        data = json.loads(message.payload.decode())
        print(f"📥 Mensaje recibido en {message.topic}: {data}")

        # Enviar la tarea al loop de FastAPI
        future = asyncio.run_coroutine_threadsafe(save_to_mongo(data), loop)
        future.result()  # Bloquea hasta que la tarea termine (previene errores)
    except Exception as e:
        print(f"⚠️ Error procesando mensaje: {e}")

# 🔹 Configuración del Cliente MQTT con TLS
mqtt_client = mqtt.Client()
mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
mqtt_client.tls_set_context(ssl.create_default_context())

mqtt_client.on_message = on_message

# 🔹 Conectar y suscribirse al tópico

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Conectado exitosamente a HiveMQ Cloud")
        client.subscribe(MQTT_TOPIC)
        print(f"📡 Suscrito a: {MQTT_TOPIC}")
    else:
        print(f"⚠️ Error de conexión MQTT. Código: {rc}")

mqtt_client.on_connect = on_connect
mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
mqtt_client.loop_start()  # Ejecutar MQTT en segundo plano

# 🔹 Endpoint para obtener datos filtrados
@app.get("/sensores/filtrar")
async def get_sensores_filtrados(
    timestamp_inicio: str = Query(None, description="Fecha inicio en formato ISO 8601"),
    timestamp_fin: str = Query(None, description="Fecha fin en formato ISO 8601"),
    cantidad: int = Query(None, description="Cantidad de datos a obtener"),
    co2: bool = Query(True, description="Incluir datos de CO2"),
    ch4: bool = Query(True, description="Incluir datos de CH4"),
    temperatura: bool = Query(True, description="Incluir datos de temperatura"),
    humedad: bool = Query(True, description="Incluir datos de humedad")
):
    try:
        filtro = {}
        
        if timestamp_inicio and timestamp_fin:
            filtro["timestamp"] = {"$gte": timestamp_inicio, "$lte": timestamp_fin}
        
        consulta = collection.find(filtro).sort("timestamp", -1)
        
        if cantidad:
            consulta = consulta.limit(cantidad)
        
        datos = await consulta.to_list(None)
        
        for dato in datos:
            dato["_id"] = str(dato["_id"])
            if not co2:
                dato.pop("CO2", None)
            if not ch4:
                dato.pop("CH4", None)
            if not temperatura:
                dato.pop("temperature", None)
            if not humedad:
                dato.pop("humidity", None)
        
        return {"data": datos}
    except Exception as e:
        print(f"⚠️ Error al obtener datos de MongoDB: {e}")
        raise HTTPException(status_code=500, detail="Error al obtener datos de MongoDB")

# 🔹 Endpoint para verificar que la API está corriendo
@app.get("/")
def read_root():
    return {"message": "API MQTT conectada a MongoDB y HiveMQ Cloud"}


from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permitir acceso desde cualquier origen
    allow_credentials=True,
    allow_methods=["*"],  # Permitir todos los métodos HTTP
    allow_headers=["*"],  # Permitir todos los headers
)
