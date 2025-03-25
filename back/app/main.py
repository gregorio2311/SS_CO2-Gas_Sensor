import asyncio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from datetime import datetime

from .config import API_TITLE, API_VERSION
from .mqtt_handler import MQTTHandler
from .dependencies import get_database
from .routers import users, devices, sensors

app = FastAPI(title=API_TITLE, version=API_VERSION)

# Configuración CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Montar archivos estáticos
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Variables globales
mqtt_handler = None

@app.on_event("startup")
async def startup_event():
    global mqtt_handler
    
    # Inicializar MongoDB
    db = await get_database()
    
    # Crear índices
    await db.users.create_index("email", unique=True)
    await db.devices.create_index("owner_id")
    await db.sensors.create_index("device_id")
    
    # Inicializar MQTT
    loop = asyncio.get_event_loop()
    mqtt_handler = MQTTHandler(
        save_callback=lambda data: save_to_mongo(data),
        loop=loop
    )
    mqtt_handler.connect()

@app.on_event("shutdown")
async def shutdown_event():
    if mqtt_handler:
        mqtt_handler.disconnect()

# Incluir routers
app.include_router(users.router)
app.include_router(devices.router)
app.include_router(sensors.router)

# Función auxiliar para guardar datos en MongoDB
async def save_to_mongo(data: dict):
    db = await get_database()
    document = {
        "device_id": data.get("device_id"),
        "sensor_id": data.get("sensor_id"),
        "value": data.get("value"),
        "unit": data.get("unit"),
        "timestamp": datetime.utcnow()
    }
    await db.sensor_data.insert_one(document)
    
    # Notificar a través de WebSocket
    if document["device_id"] in devices.active_connections:
        message = WebSocketMessage(
            type="sensor:data",
            data=document
        )
        for connection in devices.active_connections[document["device_id"]]:
            await connection.send_json(message.dict())
