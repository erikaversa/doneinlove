"""
types.py
Migration of: integrations/supabase/types.ts

Python dataclasses mirroring every Supabase table row.
Used by all services for type safety and autocomplete.
"""

from dataclasses import dataclass, field
from typing import Optional, Literal
from datetime import datetime


# ── Enums ─────────────────────────────────────────────────────────────────────

AccountStatus = Literal["active", "suspended", "deleted"]
ContentKind   = Literal["note", "photo", "recording", "letter"]
CrewStatus    = Literal["pending", "active", "removed"]


# ── Table: profiles ───────────────────────────────────────────────────────────

@dataclass
class Profile:
    id:                  str
    created_at:          str
    account_status:      AccountStatus        = "active"
    email:               Optional[str]        = None
    full_name:           Optional[str]        = None
    nickname:            Optional[str]        = None
    successor_user_id:   Optional[str]        = None


# ── Table: crew ───────────────────────────────────────────────────────────────

@dataclass
class CrewMember:
    id:              str
    owner_id:        str
    member_name:     str
    created_at:      str
    status:          CrewStatus              = "pending"
    member_email:    Optional[str]           = None
    member_user_id:  Optional[str]           = None
    accepted_at:     Optional[str]           = None


# ── Table: invite_links ───────────────────────────────────────────────────────

@dataclass
class InviteLink:
    id:          str
    crew_id:     str
    token:       str
    expires_at:  str
    created_at:  str
    used_at:     Optional[str]  = None
    used_by:     Optional[str]  = None


# ── Table: content_items ──────────────────────────────────────────────────────

@dataclass
class ContentItem:
    id:                  str
    owner_id:            str
    kind:                ContentKind
    created_at:          str
    body:                Optional[str]   = None
    caption:             Optional[str]   = None
    title:               Optional[str]   = None
    storage_path:        Optional[str]   = None
    duration_seconds:    Optional[int]   = None
    recipient_user_id:   Optional[str]   = None


# ── Table: ai_conversations ───────────────────────────────────────────────────

@dataclass
class AiConversation:
    id:               str
    owner_id:         str
    member_user_id:   str
    title:            str
    created_at:       str
    updated_at:       str


# ── Table: ai_messages ────────────────────────────────────────────────────────

@dataclass
class AiMessage:
    id:                str
    conversation_id:   str
    content:           str
    role:              str   # "user" | "assistant"
    created_at:        str


# ── Table: successor_pending ──────────────────────────────────────────────────

@dataclass
class SuccessorPending:
    user_id:            str
    last_prompted_at:   str
    dismissed_at:       Optional[str] = None


# ── Helper — dict → dataclass ─────────────────────────────────────────────────

def profile_from_dict(d: dict) -> Profile:
    return Profile(**{k: v for k, v in d.items() if k in Profile.__dataclass_fields__})

def crew_member_from_dict(d: dict) -> CrewMember:
    return CrewMember(**{k: v for k, v in d.items() if k in CrewMember.__dataclass_fields__})

def invite_link_from_dict(d: dict) -> InviteLink:
    return InviteLink(**{k: v for k, v in d.items() if k in InviteLink.__dataclass_fields__})

def content_item_from_dict(d: dict) -> ContentItem:
    return ContentItem(**{k: v for k, v in d.items() if k in ContentItem.__dataclass_fields__})

def ai_conversation_from_dict(d: dict) -> AiConversation:
    return AiConversation(**{k: v for k, v in d.items() if k in AiConversation.__dataclass_fields__})

def ai_message_from_dict(d: dict) -> AiMessage:
    return AiMessage(**{k: v for k, v in d.items() if k in AiMessage.__dataclass_fields__})


# ── Constants (mirrors TypeScript Constants) ──────────────────────────────────

ACCOUNT_STATUSES: list[AccountStatus] = ["active", "suspended", "deleted"]
CONTENT_KINDS:    list[ContentKind]   = ["note", "photo", "recording", "letter"]
CREW_STATUSES:    list[CrewStatus]    = ["pending", "active", "removed"]
