"""
crew_service.py
Migration of: crew.tsx data loading + invite.functions.ts
Handles crew management for the owner.
"""

from PySide6.QtCore import Signal, Slot
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService


class CrewService(AsyncService):

    crewLoaded         = Signal(list, dict)
    crewLoadFailed     = Signal(str)
    inviteCreated      = Signal()
    inviteCreateFailed = Signal(str)
    memberRemoved      = Signal()
    memberRemoveFailed = Signal(str)

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str)
    def loadCrew(self, owner_id: str) -> None:
        def work():
            crew_resp = (
                self._client.table("crew")
                .select("*")
                .eq("owner_id", owner_id)
                .neq("status", "removed")
                .order("created_at", desc=True)
                .execute()
            )
            rows = crew_resp.data or []
            pending_ids = [r["id"] for r in rows if r["status"] == "pending"]
            links: dict = {}
            if pending_ids:
                links_resp = (
                    self._client.table("invite_links")
                    .select("crew_id, token, expires_at, used_at")
                    .in_("crew_id", pending_ids)
                    .execute()
                )
                for link in (links_resp.data or []):
                    links[link["crew_id"]] = {
                        "token":      link["token"],
                        "expires_at": link["expires_at"],
                        "used_at":    link["used_at"],
                    }
            return rows, links

        self._run(
            work,
            lambda data: self.crewLoaded.emit(data[0], data[1]),
            self.crewLoadFailed,
        )

    @Slot(str, str)
    def createInvite(self, name: str, email: str = "") -> None:
        def work():
            args: dict = {"_name": name}
            if email:
                args["_email"] = email
            self._client.rpc("create_invite_link", args).execute()

        self._run(
            work,
            lambda _: self.inviteCreated.emit(),
            self.inviteCreateFailed,
        )

    @Slot(str)
    def removeMember(self, crew_id: str) -> None:
        self._run(
            lambda: self._client.rpc("remove_from_crew", {"_crew_id": crew_id}).execute(),
            lambda _: self.memberRemoved.emit(),
            self.memberRemoveFailed,
        )
