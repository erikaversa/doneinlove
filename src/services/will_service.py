"""
will_service.py
Migration of: will.tsx
Handles will document upload, list, open, delete.
Storage bucket: wills
"""

import os
import time
import re

from PySide6.QtCore import Signal, Slot
from config import MAX_FILE_BYTES
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService

ALLOWED_TYPES = [
    "application/pdf",
    "image/png",
    "image/jpeg",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
]


class WillService(AsyncService):

    filesLoaded      = Signal(list)
    filesLoadFailed  = Signal(str)
    fileUploaded     = Signal()
    fileUploadFailed = Signal(str)
    fileOpened       = Signal(str)
    fileOpenFailed   = Signal(str)
    fileDeleted      = Signal()
    fileDeleteFailed = Signal(str)

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str)
    def loadFiles(self, user_id: str) -> None:
        def work():
            response = self._client.storage.from_("wills").list(
                user_id,
                {"sortBy": {"column": "updated_at", "order": "desc"}},
            )
            files = []
            for f in response:
                if not f.get("name"):
                    continue
                meta = f.get("metadata") or {}
                files.append({
                    "name":       f["name"],
                    "path":       f"{user_id}/{f['name']}",
                    "size":       meta.get("size", 0),
                    "updated_at": f.get("updated_at") or f.get("created_at") or "",
                })
            return files

        self._run(work, self.filesLoaded.emit, self.filesLoadFailed)

    @Slot(str, str, str)
    def uploadFile(self, user_id: str, file_path: str, mime_type: str) -> None:
        def work():
            size = os.path.getsize(file_path)
            if size > MAX_FILE_BYTES:
                raise ValueError("File too large (max 20 MB).")
            if mime_type not in ALLOWED_TYPES:
                raise ValueError("Use PDF, Word, JPG or PNG.")

            original_name = os.path.basename(file_path)
            safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', original_name)
            storage_path = f"{user_id}/{int(time.time())}-{safe_name}"

            with open(file_path, "rb") as f:
                file_bytes = f.read()

            self._client.storage.from_("wills").upload(
                storage_path, file_bytes,
                {"content-type": mime_type, "upsert": "false"},
            )

        self._run(
            work,
            lambda _: self.fileUploaded.emit(),
            self.fileUploadFailed,
        )

    @Slot(str)
    def openFile(self, path: str) -> None:
        def work():
            response = self._client.storage.from_("wills").create_signed_url(path, 60)
            url = response.get("signedURL") or response.get("signedUrl")
            if not url:
                raise RuntimeError("Could not generate link.")
            return url

        self._run(work, self.fileOpened.emit, self.fileOpenFailed)

    @Slot(str)
    def deleteFile(self, path: str) -> None:
        self._run(
            lambda: self._client.storage.from_("wills").remove([path]),
            lambda _: self.fileDeleted.emit(),
            self.fileDeleteFailed,
        )

    @staticmethod
    def fmt_size(n: int) -> str:
        if n < 1024:
            return f"{n} B"
        if n < 1024 * 1024:
            return f"{n / 1024:.1f} KB"
        return f"{n / 1024 / 1024:.1f} MB"
