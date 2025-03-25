from fastapi import APIRouter, Depends, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
from bson import ObjectId

from ..models import Sensor, SensorCreate, CalibrationRequest, WebSocketMessage, User
from ..auth import get_current_active_user
from ..dependencies import get_database
from ..config import API_PREFIX, COLLECTIONS
from .devices import active_connections

router = APIRouter(
    prefix=f"{API_PREFIX}/sensors",
    tags=["sensors"]
)

@router.post("", response_model=Sensor)
async def create_sensor(
    sensor: SensorCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncIOMotorClient = Depends(get_database)
):
    device = await db[COLLECTIONS["devices"]].find_one({"_id": ObjectId(sensor.device_id)})
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    
    if str(current_user.id) not in device["admins"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    sensor_dict = sensor.dict()
    sensor_dict["created_at"] = datetime.utcnow()
    sensor_dict["last_value"] = None
    sensor_dict["last_update"] = None
    sensor_dict["is_calibrating"] = False
    
    result = await db[COLLECTIONS["sensors"]].insert_one(sensor_dict)
    sensor_dict["id"] = str(result.inserted_id)
    
    await db[COLLECTIONS["devices"]].update_one(
        {"_id": ObjectId(sensor.device_id)},
        {"$push": {"sensors": str(result.inserted_id)}}
    )
    
    return Sensor(**sensor_dict)

@router.post("/{sensor_id}/calibrate")
async def calibrate_sensor(
    sensor_id: str,
    calibration: CalibrationRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncIOMotorClient = Depends(get_database)
):
    sensor = await db[COLLECTIONS["sensors"]].find_one({"_id": ObjectId(sensor_id)})
    if not sensor:
        raise HTTPException(status_code=404, detail="Sensor not found")
    
    device = await db[COLLECTIONS["devices"]].find_one({"_id": ObjectId(sensor["device_id"])})
    if str(current_user.id) not in device["admins"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    await db[COLLECTIONS["sensors"]].update_one(
        {"_id": ObjectId(sensor_id)},
        {
            "$set": {
                "is_calibrating": True,
                "last_value": calibration.calibration_value,
                "last_update": datetime.utcnow()
            }
        }
    )
    
    # Notificar a través de WebSocket
    if sensor["device_id"] in active_connections:
        message = WebSocketMessage(
            type="sensor:calibration",
            data={
                "sensor_id": sensor_id,
                "status": "in_progress",
                "value": calibration.calibration_value
            }
        )
        for connection in active_connections[sensor["device_id"]]:
            await connection.send_json(message.dict())
    
    return {"message": "Calibration started"} 