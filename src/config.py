import os
from pathlib import Path
_env_path = Path(__file__).parent.parent / ".env"
if _env_path.exists():
    from dotenv import load_dotenv
    load_dotenv(_env_path)


APP_NAME = os.environ.get("APP_NAME", "doneinlove")
EMAIL_FROM = os.environ.get("EMAIL_FROM", "noreply@doneinlove.day0ea.com")

MAX_FILE_BYTES  = 20 * 1024 * 1024  # 20MB

SUPABASE_URL = os.environ.get("SUPABASE_URL")
INVITE_BASE_URL = os.environ.get("INVITE_BASE_URL")

SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY")
SUPABASE_PUBLISHABLE_KEY = os.environ.get("SUPABASE_PUBLISHABLE_KEY")
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")

if not SUPABASE_PUBLISHABLE_KEY:
    SUPABASE_PUBLISHABLE_KEY = SUPABASE_ANON_KEY


# Fail fast in production
if os.environ.get("ENV") == "production":
    missing = [k for k in ("SUPABASE_URL","SUPABASE_ANON_KEY","GEMINI_API_KEY","INVITE_BASE_URL") if not os.environ.get(k)]
    if missing:
        raise RuntimeError(f"Missing required env vars: {missing}")
