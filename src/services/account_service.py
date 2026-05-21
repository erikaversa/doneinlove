"""
account_service.py
Migration of: lib/account.functions.ts

Handles user profile reads and updates.
"""

from PySide6.QtCore import Signal, Slot
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService


class AccountService(AsyncService):

    profileLoaded  = Signal(dict)
    profileFailed  = Signal(str)
    profileUpdated = Signal()

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str)
    def loadProfile(self, user_id: str) -> None:
        def work():
            response = (
                self._client.table("profiles")
                .select("id, email, full_name, nickname, successor_user_id, account_status, created_at")
                .eq("id", user_id)
                .single()
                .execute()
            )
            return response.data or {}

        def on_ok(data):
            if data:
                self.profileLoaded.emit(data)
            else:
                self.profileFailed.emit("Profile not found.")

        self._run(work, on_ok, self.profileFailed)

    @Slot(str, str, str)
    def updateProfile(self, user_id: str, full_name: str, nickname: str) -> None:
        def work():
            self._client.table("profiles").update({
                "full_name": full_name or None,
                "nickname":  nickname or None,
            }).eq("id", user_id).execute()

        self._run(work, lambda _: self.profileUpdated.emit(), self.profileFailed)
