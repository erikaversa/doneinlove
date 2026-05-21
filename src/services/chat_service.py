"""
chat_service.py
Migration of: api/chat.ts

Handles AI conversations where family members write to
the owner's AI — powered by Gemini via al_gateway.py.

Flow:
  1. Family member opens owner's space (Mode B)
  2. loadOrCreateConversation — fetches/creates thread, builds system prompt once
  3. sendMessage — AI responds AS the owner, warm first-person
  4. Conversation is private per family member
"""

import asyncio
from PySide6.QtCore import QThread, Signal, Slot
from lib.supabase_client import client as _supabase
from lib.al_gateway import create_doneinlove_ai_gateway_provider, DEFAULT_MODEL
from lib.worker import AsyncService
from services.context_builder import build_owner_context


class ChatService(AsyncService):

    conversationLoaded  = Signal(dict)
    conversationFailed  = Signal(str)
    conversationCleared = Signal()
    clearFailed         = Signal(str)
    messageReceived     = Signal(str)
    messageFailed       = Signal(str)
    messageSaved        = Signal()

    def __init__(self):
        super().__init__()
        self._client = _supabase
        self._system_prompt: str = ""
        try:
            self._ai = create_doneinlove_ai_gateway_provider()
        except Exception as e:
            print(f"ChatService: AI provider unavailable — {e}")
            self._ai = None

    @Slot(str, str)
    def loadOrCreateConversation(self, owner_id: str, member_user_id: str) -> None:
        def work():
            # Fetch owner name for the system prompt
            profile_resp = (
                self._client.table("profiles")
                .select("full_name, nickname")
                .eq("id", owner_id)
                .maybe_single()
                .execute()
            )
            d = profile_resp.data or {}
            owner_name = d.get("full_name") or d.get("nickname") or "A keeper"

            # Find or create conversation
            response = (
                self._client.table("ai_conversations")
                .select("id, title")
                .eq("owner_id", owner_id)
                .eq("member_user_id", member_user_id)
                .order("updated_at", desc=True)
                .limit(1)
                .execute()
            )
            if response.data:
                conv_id = response.data[0]["id"]
            else:
                ins = (
                    self._client.table("ai_conversations")
                    .insert({
                        "owner_id":       owner_id,
                        "member_user_id": member_user_id,
                        "title":          "Our conversation",
                    })
                    .execute()
                )
                conv_id = ins.data[0]["id"]

            msgs = (
                self._client.table("ai_messages")
                .select("id, role, content, created_at")
                .eq("conversation_id", conv_id)
                .order("created_at")
                .execute()
            )

            context = build_owner_context(self._client, owner_id, owner_name)
            return {"id": conv_id, "messages": msgs.data or [], "_context": context}

        def on_ok(data):
            self._system_prompt = data.pop("_context", "")
            self.conversationLoaded.emit(data)

        self._run(work, on_ok, self.conversationFailed)

    @Slot(str, str, str, str, list)
    def sendMessage(
        self,
        owner_id: str,
        owner_name: str,
        conversation_id: str,
        user_message: str,
        history: list,
    ) -> None:
        if not self._ai:
            self.messageFailed.emit("AI provider not configured.")
            return

        thread = _ChatThread(
            client=self._client,
            ai=self._ai,
            system_prompt=self._system_prompt,
            conversation_id=conversation_id,
            user_message=user_message,
            history=history,
        )
        thread.messageReceived.connect(self.messageReceived)
        thread.messageFailed.connect(self.messageFailed)
        thread.messageSaved.connect(self.messageSaved)
        self._running.add(thread)
        thread.finished.connect(lambda: self._running.discard(thread))
        thread.start()

    @Slot(str)
    def clearConversation(self, conversation_id: str) -> None:
        def work():
            self._client.table("ai_messages") \
                .delete() \
                .eq("conversation_id", conversation_id) \
                .execute()

        def on_done(_):
            self._system_prompt = ""
            self.conversationCleared.emit()

        self._run(work, on_done, self.clearFailed)


class _ChatThread(QThread):
    messageReceived = Signal(str)
    messageFailed   = Signal(str)
    messageSaved    = Signal()

    def __init__(self, client, ai, system_prompt,
                 conversation_id, user_message, history):
        super().__init__()
        self._client          = client
        self._ai              = ai
        self._system_prompt   = system_prompt
        self._conversation_id = conversation_id
        self._user_message    = user_message
        self._history         = history

    def run(self):
        asyncio.run(self._send())

    async def _send(self):
        try:
            self._client.table("ai_messages").insert({
                "conversation_id": self._conversation_id,
                "role":            "user",
                "content":         self._user_message,
            }).execute()

            messages = [{"role": "system", "content": self._system_prompt}]
            for msg in self._history:
                messages.append({"role": msg["role"], "content": msg["content"]})
            messages.append({"role": "user", "content": self._user_message})

            response = await self._ai.chat.completions.create(
                model=DEFAULT_MODEL,
                messages=messages,
                max_tokens=1000,
            )
            ai_text = response.choices[0].message.content

            self._client.table("ai_messages").insert({
                "conversation_id": self._conversation_id,
                "role":            "assistant",
                "content":         ai_text,
            }).execute()

            self.messageSaved.emit()
            self.messageReceived.emit(ai_text)

        except Exception as e:
            self.messageFailed.emit(str(e))
