from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional, List, Dict
from enum import Enum

class UserRole(str, Enum):
    ADMIN = "admin"
    CLIENT = "client"

class UserBase(BaseModel):
    email: EmailStr
    name: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: str
    created_at: datetime
    devices: List[str] = []

    class Config:
        from_attributes = True

class DeviceBase(BaseModel):
    name: str
    location: Optional[Dict[str, float]] = None  # {latitude: float, longitude: float}

class DeviceCreate(DeviceBase):
    user_id: str

class Device(DeviceBase):
    id: str
    created_at: datetime
    owner_id: str
    admins: List[str] = []
    clients: List[str] = []
    sensors: List[str] = []

    class Config:
        from_attributes = True

class SensorType(str, Enum):
    CO2 = "CO2"
    CH4 = "CH4"
    TEMPERATURE = "temperature"
    HUMIDITY = "humidity"

class SensorBase(BaseModel):
    name: str
    type: SensorType
    unit: str
    device_id: str

class SensorCreate(SensorBase):
    pass

class Sensor(SensorBase):
    id: str
    created_at: datetime
    last_value: Optional[float] = None
    last_update: Optional[datetime] = None
    is_calibrating: bool = False

    class Config:
        from_attributes = True

class SensorData(BaseModel):
    device_id: str
    sensor_id: str
    value: float
    timestamp: datetime
    unit: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class ShareDeviceRequest(BaseModel):
    user_email: EmailStr
    role: UserRole

class CalibrationRequest(BaseModel):
    sensor_id: str
    calibration_value: float

class WebSocketMessage(BaseModel):
    type: str
    data: dict
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class SensorDataResponse(BaseModel):
    data: list[SensorData]

class FilterParams(BaseModel):
    timestamp_inicio: Optional[datetime] = None
    timestamp_fin: Optional[datetime] = None
    cantidad: Optional[int] = None
    co2: bool = True
    ch4: bool = True
    temperatura: bool = True
    humedad: bool = True 