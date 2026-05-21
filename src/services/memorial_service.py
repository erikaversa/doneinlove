from PySide6.QtCore import Signal, Slot
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService


class MemorialService(AsyncService):

    memorialsLoaded    = Signal(list)
    memorialsLoadFailed = Signal(str)
    crewLeft           = Signal()
    crewLeaveFailed    = Signal(str)

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str)
    def loadMemorials(self, user_id: str) -> None:
        def work():
            response = (
                self._client.table("crew")
                .select("owner_id, profiles!crew_owner_id_fkey(full_name, nickname)")
                .eq("member_user_id", user_id)
                .eq("status", "active")
                .execute()
            )
            result = []
            for r in (response.data or []):
                profile = r.get("profiles") or {}
                result.append({
                    "owner_id":   r["owner_id"],
                    "owner_name": profile.get("full_name") or profile.get("nickname") or "A keeper",
                })
            return result

        self._run(work, self.memorialsLoaded.emit, self.memorialsLoadFailed)

    @Slot(str)
    def leaveCrew(self, owner_id: str) -> None:
        self._run(
            lambda: self._client.rpc("leave_crew", {"_owner_id": owner_id}).execute(),
            lambda _: self.crewLeft.emit(),
            self.crewLeaveFailed,
        )
