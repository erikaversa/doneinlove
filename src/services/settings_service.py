"""
settings_service.py
Migration of: settings.tsx data loading
Handles profile + successor management.
"""

from PySide6.QtCore import Signal, Slot
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService


class SettingsService(AsyncService):

    profileLoaded       = Signal(dict)
    profileLoadFailed   = Signal(str)
    crewLoaded          = Signal(list)
    crewLoadFailed      = Signal(str)
    profileSaved        = Signal()
    profileSaveFailed   = Signal(str)
    successorSaved      = Signal()
    successorSaveFailed = Signal(str)

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str)
    def loadProfile(self, user_id: str) -> None:
        def work():
            response = (
                self._client.table("profiles")
                .select("full_name, nickname, successor_user_id")
                .eq("id", user_id)
                .maybe_single()
                .execute()
            )
            return response.data if response is not None else {}

        self._run(work, self.profileLoaded.emit, self.profileLoadFailed)

    @Slot(str)
    def loadActiveCrew(self, user_id: str) -> None:
        def work():
            response = (
                self._client.table("crew")
                .select("member_user_id, member_name")
                .eq("owner_id", user_id)
                .eq("status", "active")
                .execute()
            )
            return [r for r in (response.data or []) if r.get("member_user_id")]

        self._run(work, self.crewLoaded.emit, self.crewLoadFailed)

    @Slot(str, str, str)
    def saveProfile(self, user_id: str, full_name: str, nickname: str) -> None:
        def work():
            self._client.table("profiles").update({
                "full_name": full_name or None,
                "nickname":  nickname or None,
            }).eq("id", user_id).execute()

        self._run(
            work,
            lambda _: self.profileSaved.emit(),
            self.profileSaveFailed,
        )

    @Slot(str)
    def saveSuccessor(self, successor_id: str) -> None:
        self._run(
            lambda: self._client.rpc("set_successor", {"_successor_id": successor_id}).execute(),
            lambda _: self.successorSaved.emit(),
            self.successorSaveFailed,
        )
