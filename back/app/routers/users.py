from fastapi import APIRouter, Depends, HTTPException, Form
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, timedelta
from typing import List

from ..models import User, UserCreate, Device, Token
from ..auth import get_password_hash, verify_password, create_access_token, get_current_active_user
from ..dependencies import get_database
from ..config import API_PREFIX, COLLECTIONS, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter(
    prefix=f"{API_PREFIX}/users",
    tags=["users"]
)

@router.post("/register", response_model=User)
async def register_user(user: UserCreate, db: AsyncIOMotorClient = Depends(get_database)):
    db_user = await db[COLLECTIONS["users"]].find_one({"email": user.email})
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    user_dict = user.dict()
    user_dict["password"] = hashed_password
    user_dict["created_at"] = datetime.utcnow()
    
    result = await db[COLLECTIONS["users"]].insert_one(user_dict)
    user_dict["id"] = str(result.inserted_id)
    return User(**user_dict)

@router.post("/login", response_model=Token)
async def login_user(
    email: str = Form(...),
    password: str = Form(...),
    db: AsyncIOMotorClient = Depends(get_database)
):
    user = await db[COLLECTIONS["users"]].find_one({"email": email})
    if not user or not verify_password(password, user["password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["email"]}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@router.get("/{user_id}/devices", response_model=List[Device])
async def get_user_devices(
    user_id: str,
    current_user: User = Depends(get_current_active_user),
    db: AsyncIOMotorClient = Depends(get_database)
):
    if str(current_user.id) != user_id:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    devices = await db[COLLECTIONS["devices"]].find({"owner_id": user_id}).to_list(None)
    return [Device(**device) for device in devices] 