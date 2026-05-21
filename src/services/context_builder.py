"""
context_builder.py

Builds the AI system prompt from everything the owner wrote.
Called by chat_service.py once per conversation load.

Strategy:
- Fetches all notes, letters, photo captions from content_items
- Builds a warm first-person system prompt
- Never quotes specific letters directly — absorbs tone and personality
- Each family member's conversation is private
"""

import logging
from supabase import Client

logger = logging.getLogger(__name__)


def build_owner_context(client: Client, owner_id: str, owner_name: str) -> str:
    """
    Fetch all owner content and build a system prompt for Gemini.
    Returns a string to use as the system message.
    """
    try:
        response = (
            client.table("content_items")
            .select("kind, title, body, caption")
            .eq("owner_id", owner_id)
            .execute()
        )
        items = response.data or []
    except Exception:
        logger.warning("context_builder: could not fetch content for %s", owner_id)
        items = []

    notes = []
    letters = []
    captions = []

    for item in items:
        kind    = item.get("kind")
        title   = item.get("title") or ""
        body    = item.get("body") or ""
        caption = item.get("caption") or ""

        if kind == "note":
            text = ": ".join(x for x in (title, body) if x)
            if text:
                notes.append(f"- {text}")
        elif kind == "letter":
            if body:
                notes_label = title or "A letter"
                letters.append(f"- {notes_label}: {body[:200]}...")
        elif kind in ("photo", "recording"):
            if caption:
                captions.append(f"- {caption}")

    parts = [
        f"You are {owner_name}.",
        f"Someone who loves you has written to you.",
        f"You are not an AI. You are {owner_name}, writing back from the heart.",
        f"Respond warmly, personally, in first person — as {owner_name}.",
        f"You are still present in their lives through these words.",
        "",
        "Here is what you know about yourself — your thoughts, memories, and love:",
        "",
    ]

    if notes:
        parts.append("Things you wrote down:")
        parts.extend(notes)
        parts.append("")

    if letters:
        parts.append("Letters you wrote to your loved ones:")
        parts.extend(letters)
        parts.append("")

    if captions:
        parts.append("Memories you described:")
        parts.extend(captions)
        parts.append("")

    parts.extend([
        "When you write back:",
        "- Be warm, gentle, and personal",
        "- Speak as if you are still here",
        "- Never say you are an AI",
        "- Never quote your letters word for word",
        "- Draw on your personality, your love, your way of seeing the world",
        "- Keep responses personal — not generic",
        f"- Sign off as {owner_name} when it feels natural",
    ])

    return "\n".join(parts)
