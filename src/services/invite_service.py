"""
invite_service.py
Migration of: lib/invite.functions.ts

Handles all 3 invite paths:
  Path A — direct signup, no invite
  Path B — invite link, new user
  Path C — invite link, existing user → silent auto-link

Key rules:
  - Max 5 active crew members per owner
  - One person can be crew for multiple owners
  - No email confirmation for invited users
  - service role key NEVER used — all via anon key + RLS
"""

from PySide6.QtCore import Signal, Slot
from config import INVITE_BASE_URL
from lib.supabase_client import client as _supabase
from lib.worker import AsyncService


class InviteService(AsyncService):

    inviteCreated      = Signal(dict)
    inviteCreateFailed = Signal(str)

    inviteLookupDone   = Signal(dict)
    inviteLookupFailed = Signal(str)

    inviteRedeemed     = Signal(str)
    inviteRedeemFailed = Signal(str)

    crewLoaded         = Signal(list)
    crewLoadFailed     = Signal(str)

    memberRemoved      = Signal()
    memberRemoveFailed = Signal(str)

    crewLeft           = Signal()
    crewLeaveFailed    = Signal(str)

    def __init__(self):
        super().__init__()
        self._client = _supabase

    @Slot(str, str)
    def createInvite(self, name: str, email: str = "") -> None:
        def work():
            args: dict = {"_name": name}
            if email:
                args["_email"] = email
            response = self._client.rpc("create_invite_link", args).execute()
            if response.data:
                return response.data[0]
            raise RuntimeError("Could not create invite link.")

        self._run(work, self.inviteCreated.emit, self.inviteCreateFailed)

    @Slot(str)
    def lookupInvite(self, token: str) -> None:
        def work():
            response = self._client.rpc("lookup_invite", {"_token": token}).execute()
            if response.data:
                return response.data[0]
            raise RuntimeError("Invalid invitation token.")

        self._run(work, self.inviteLookupDone.emit, self.inviteLookupFailed)

    @Slot(str)
    def redeemInvite(self, token: str) -> None:
        def work():
            response = self._client.rpc("redeem_invite_link", {"_token": token}).execute()
            if response.data:
                return response.data
            raise RuntimeError("Could not redeem invitation.")

        self._run(work, self.inviteRedeemed.emit, self.inviteRedeemFailed)

    @Slot(str)
    def loadCrew(self, owner_id: str) -> None:
        def work():
            response = (
                self._client.table("crew")
                .select("*")
                .eq("owner_id", owner_id)
                .order("created_at")
                .execute()
            )
            if response.data is not None:
                return response.data
            raise RuntimeError("Could not load crew.")

        self._run(work, self.crewLoaded.emit, self.crewLoadFailed)

    @Slot(str)
    def removeMember(self, crew_id: str) -> None:
        self._run(
            lambda: self._client.rpc("remove_from_crew", {"_crew_id": crew_id}).execute(),
            lambda _: self.memberRemoved.emit(),
            self.memberRemoveFailed,
        )

    @Slot(str)
    def leaveCrew(self, owner_id: str) -> None:
        self._run(
            lambda: self._client.rpc("leave_crew", {"_owner_id": owner_id}).execute(),
            lambda _: self.crewLeft.emit(),
            self.crewLeaveFailed,
        )

    @staticmethod
    def buildInviteUrl(token: str) -> str:
        return f"{INVITE_BASE_URL}/{token}"
