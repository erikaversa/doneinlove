"""
direct_chat_service.py

Direct chat with Gemini — no owner persona, no database persistence.
History lives in memory for the duration of the session.
"""

import asyncio
from PySide6.QtCore import QThread, Signal, Slot
from lib.al_gateway import create_doneinlove_ai_gateway_provider, DEFAULT_MODEL
from lib.worker import AsyncService

_SYSTEM_PROMPT = (
    "You are a helpful, warm AI assistant for Done In Love — "
    "an app that helps people leave heartfelt messages, memories, and letters "
    "for the people they love most. "
    "Be kind, thoughtful, and concise. "
    "If asked about the app, explain it gently: it lets people create a lasting "
    "presence for loved ones after they're gone."
)


class DirectChatService(AsyncService):
    messageReceived = Signal(str)
    messageFailed   = Signal(str)
    historyCleared  = Signal()

    def __init__(self):
        super().__init__()
        self._history: list[dict] = []
        try:
            self._ai = create_doneinlove_ai_gateway_provider()
        except Exception as e:
            print(f"DirectChatService: AI provider unavailable — {e}")
            self._ai = None

    @Slot(str)
    def sendMessage(self, user_message: str) -> None:
        if not self._ai:
            self.messageFailed.emit("AI provider not configured.")
            return

        self._history.append({"role": "user", "content": user_message})

        thread = _DirectChatThread(
            ai=self._ai,
            system_prompt=_SYSTEM_PROMPT,
            history=list(self._history),
        )
        thread.messageReceived.connect(self._on_reply)
        thread.messageFailed.connect(self.messageFailed)
        self._running.add(thread)
        thread.finished.connect(lambda: self._running.discard(thread))
        thread.start()

    def _on_reply(self, text: str) -> None:
        self._history.append({"role": "assistant", "content": text})
        self.messageReceived.emit(text)

    @Slot()
    def clearHistory(self) -> None:
        self._history.clear()
        self.historyCleared.emit()


class _DirectChatThread(QThread):
    messageReceived = Signal(str)
    messageFailed   = Signal(str)

    def __init__(self, ai, system_prompt, history):
        super().__init__()
        self._ai            = ai
        self._system_prompt = system_prompt
        self._history       = history

    def run(self):
        asyncio.run(self._send())

    async def _send(self):
        try:
            messages = [{"role": "system", "content": self._system_prompt}]
            messages.extend(self._history)
            response = await self._ai.chat.completions.create(
                model=DEFAULT_MODEL,
                messages=messages,
                max_tokens=1000,
            )
            self.messageReceived.emit(response.choices[0].message.content)
        except Exception as e:
            self.messageFailed.emit(str(e))
