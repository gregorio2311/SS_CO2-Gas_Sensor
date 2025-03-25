from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
from typing import List, Dict
from bson import ObjectId

from ..models import Device, DeviceCreate, ShareDeviceRequest, WebSocketMessage, User
from ..auth import get_current_active_user, get_current_user
from ..dependencies import get_database
from ..config import API_PREFIX, WS_PREFIX, COLLECTIONS

router = APIRouter(
    prefix=f"{API_PREFIX}/devices",
    tags=["devices"]
)

# Variables globales para WebSocket
active_connections: Dict[str, List[WebSocket]] = {}

@router.post("", response_model=Device)
async def create_device(
    device: DeviceCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncIOMotorClient = Depends(get_database)
):
    device_dict = device.dict()
    device_dict["owner_id"] = str(current_user.id)
    device_dict["created_at"] = datetime.utcnow()
    device_dict["admins"] = [str(current_user.id)]
    device_dict["clients"] = []
    device_dict["sensors"] = []
    
    result = await db[COLLECTIONS["devices"]].insert_one(device_dict)
    device_dict["id"] = str(result.inserted_id)
    return Device(**device_dict)

@router.get("/{device_id}", response_model=Device)
async def get_device(
    device_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncIOMotorClient = Depends(get_database)
):
    device = await db[COLLECTIONS["devices"]].find_one({"_id": ObjectId(device_id)})
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    
    if str(current_user.id) not in device["admins"] and str(current_user.id) not in device["clients"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    device["id"] = str(device["_id"])
    return Device(**device)

@router.post("/{device_id}/share")
async def share_device(
    device_id: str,
    share_request: ShareDeviceRequest,
    current_user: User = Depends(get_current_active_user),
    db: AsyncIOMotorClient = Depends(get_database)
):
    device = await db[COLLECTIONS["devices"]].find_one({"_id": ObjectId(device_id)})
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    
    if str(current_user.id) not in device["admins"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    target_user = await db[COLLECTIONS["users"]].find_one({"email": share_request.user_email})
    if not target_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if share_request.role == "admin":
        await db[COLLECTIONS["devices"]].update_one(
            {"_id": ObjectId(device_id)},
            {"$addToSet": {"admins": str(target_user["_id"])}}
        )
    else:
        await db[COLLECTIONS["devices"]].update_one(
            {"_id": ObjectId(device_id)},
            {"$addToSet": {"clients": str(target_user["_id"])}}
        )
    
    return {"message": "Device shared successfully"}

@router.websocket(f"{WS_PREFIX}/{{device_id}}")
async def websocket_endpoint(
    websocket: WebSocket,
    device_id: str,
    token: str = Depends(get_current_user)
):
    await websocket.accept()
    
    if device_id not in active_connections:
        active_connections[device_id] = []
    active_connections[device_id].append(websocket)
    
    try:
        while True:
            data = await websocket.receive_text()
            # Procesar mensajes recibidos si es necesario
    except WebSocketDisconnect:
        active_connections[device_id].remove(websocket)
        if not active_connections[device_id]:
            del active_connections[device_id] 