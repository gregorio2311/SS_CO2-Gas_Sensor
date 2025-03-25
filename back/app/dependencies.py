from motor.motor_asyncio import AsyncIOMotorClient
from .config import MONGO_URI, DB_NAME

# Variable global para el cliente MongoDB
mongo_client = None

async def get_database():
    global mongo_client
    if mongo_client is None:
        mongo_client = AsyncIOMotorClient(MONGO_URI)
    return mongo_client[DB_NAME] 