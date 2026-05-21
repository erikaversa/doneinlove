"""
content_service.py
Migration of: lib/shared-content.functions.ts
"""

import os
import re
import uuid

from PySide6.QtCore import Signal, Slot
from config import MAX_FILE_BYTES
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService


class ContentService(AsyncService):

    contentLoaded     = Signal(dict)
    contentLoadFailed = Signal(str)
    itemSaved         = Signal(dict)
    itemSaveFailed    = Signal(str)
    itemDeleted       = Signal(str)
    itemDeleteFailed  = Signal(str)

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str, str)
    def fetchContent(self, owner_id: str, kind: str) -> None:
        def work():
            profile_resp = (
                self._client.table("profiles")
                .select("full_name, nickname")
                .eq("id", owner_id)
                .maybe_single()
                .execute()
            )
            items_resp = (
                self._client.table("content_items")
                .select("id, kind, title, body, storage_path, caption, duration_seconds, created_at, recipient_user_id")
                .eq("owner_id", owner_id)
                .eq("kind", kind)
                .order("created_at", desc=True)
                .execute()
            )

            profile = profile_resp.data if profile_resp is not None else None
            owner_name = (
                (profile.get("full_name") or profile.get("nickname") or "A keeper")
                if profile else "A keeper"
            )
            items = items_resp.data or []

            signed_urls: dict = {}
            if kind in ("photo", "recording"):
                bucket = "photos" if kind == "photo" else "recordings"
                for item in items:
                    path = item.get("storage_path")
                    if not path:
                        continue
                    try:
                        url_resp = (
                            self._client.storage
                            .from_(bucket)
                            .create_signed_url(path, 3600)
                        )
                        signed_url = url_resp.get("signedURL") or url_resp.get("signedUrl")
                        if signed_url:
                            signed_urls[item["id"]] = signed_url
                            item["signed_url"] = signed_url
                    except Exception:
                        pass

            return {"owner_name": owner_name, "items": items, "signed_urls": signed_urls}

        self._run(work, self.contentLoaded.emit, self.contentLoadFailed)

    @Slot(str, str, str, str, str, str)
    def saveItem(self, owner_id: str, kind: str,
                 title: str = "", body: str = "",
                 caption: str = "", recipient_user_id: str = "") -> None:
        def work():
            payload: dict = {"owner_id": owner_id, "kind": kind}
            if title:             payload["title"]             = title
            if body:              payload["body"]              = body
            if caption:           payload["caption"]           = caption
            if recipient_user_id: payload["recipient_user_id"] = recipient_user_id

            response = (
                self._client.table("content_items")
                .insert(payload)
                .execute()
            )
            if response.data:
                return response.data[0]
            raise RuntimeError("Could not save item.")

        self._run(work, self.itemSaved.emit, self.itemSaveFailed)

    @Slot(str)
    def deleteItem(self, item_id: str) -> None:
        def work():
            self._client.table("content_items") \
                .delete() \
                .eq("id", item_id) \
                .execute()
            return item_id

        self._run(work, self.itemDeleted.emit, self.itemDeleteFailed)

    @Slot(str, str, str, str)
    def uploadFile(self, owner_id: str, kind: str,
                   file_path: str, mime_type: str) -> None:
        def work():
            size = os.path.getsize(file_path)
            if size > MAX_FILE_BYTES:
                raise ValueError("File too large (max 20 MB).")

            bucket = "photos" if kind == "photo" else "recordings"
            safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', os.path.basename(file_path))
            storage_path = f"{owner_id}/{uuid.uuid4()}-{safe_name}"

            with open(file_path, "rb") as f:
                file_bytes = f.read()

            self._client.storage.from_(bucket).upload(
                storage_path, file_bytes,
                {"content-type": mime_type, "upsert": "false"},
            )
            self._client.table("content_items").insert({
                "owner_id":     owner_id,
                "kind":         kind,
                "storage_path": storage_path,
            }).execute()
            return {"kind": kind, "storage_path": storage_path}

        self._run(work, self.itemSaved.emit, self.itemSaveFailed)
