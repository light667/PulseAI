from supabase import create_client, Client
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

def get_supabase_client() -> Client:
    url: str = settings.SUPABASE_URL
    key: str = settings.SUPABASE_KEY
    if not url or not key:
        logger.warning("SUPABASE_URL or SUPABASE_KEY is missing in environment.")
    return create_client(url, key) if url and key else None

supabase_client = get_supabase_client()
