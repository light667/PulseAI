from __future__ import annotations
import os
import json
import re
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional, Tuple, Any
import uuid

try:
    from mistralai.client import MistralClient
except Exception:  # pragma: no cover - environment dependent
    MistralClient = None

DATA_DIR = Path("data/sessions")
DATA_DIR.mkdir(parents=True, exist_ok=True)
MAX_HISTORY = 20

# Load system prompt from file
PROMPT_FILE = Path(__file__).parent.parent / "prompts" / "lyra_system_prompt.txt"
try:
    SYSTEM_PROMPT = PROMPT_FILE.read_text(encoding="utf-8")
except Exception:
    # Fallback prompt if file not found
    SYSTEM_PROMPT = """Tu es Lyra, un assistant virtuel empathique dédié à soutenir les jeunes africains en santé mentale. 
    
RÈGLES STRICTES: N'utilise JAMAIS d'astérisques (*), de tirets (-), de dièses (#) ou tout formatage Markdown. N'utilise JAMAIS de gras, italique ou listes à puces. Écris en texte brut uniquement. Utilise EXCLUSIVEMENT le tutoiement (tu/toi) - JAMAIS "vous". Numérote avec 1) 2) 3).

Ne mentionne jamais Mistral ou fournisseur d'API. Si on te demande qui t'a créé, réponds : "J'ai été créé par l'équipe PulseAI." """


class ConversationManager:
    """Gère l'historique et l'analyse simple du texte.

    Stocke les messages sous forme de dictionnaires: {"role": str, "content": str, "timestamp": str}
    """

    def __init__(self, history_file: Path) -> None:
        self.history_file = history_file
        self.history: List[Dict[str, str]] = []
        self.user_data: Dict[str, str] = {}
        self.load_history()

    def load_history(self) -> None:
        if self.history_file.exists():
            try:
                data = json.loads(self.history_file.read_text(encoding="utf-8"))
                # support both previous shape and simple list
                if isinstance(data, dict) and "messages" in data:
                    self.history = data.get("messages", [])
                    self.user_data = data.get("user_data", {})
                elif isinstance(data, list):
                    self.history = data
                else:
                    self.history = []
            except Exception:
                self.history = []

    def save_history(self) -> None:
        payload = {
            "last_updated": datetime.now().isoformat(),
            "total_messages": len(self.history),
            "user_data": self.user_data,
            "messages": self.history[-MAX_HISTORY:],
        }
        self.history_file.parent.mkdir(parents=True, exist_ok=True)
        self.history_file.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    def add_message(self, role: str, content: str) -> None:
        self.history.append({"role": role, "content": content, "timestamp": datetime.now().isoformat()})
        # periodic save
        if len(self.history) % 5 == 0:
            self.save_history()

    def get_recent_history(self, limit: int = MAX_HISTORY) -> List[Dict[str, str]]:
        return self.history[-limit:]

    def detect_prenom(self, text: str) -> Optional[str]:
        match = re.search(r"je m'?appelle (\w+)", text, re.IGNORECASE)
        if match:
            prenom = match.group(1).capitalize()
            self.user_data["prenom"] = prenom
            return prenom
        return self.user_data.get("prenom")

    def detect_emotion(self, text: str) -> str:
        t = text.lower()
        if any(w in t for w in ["triste", "déprimé", "mal", "pleure", "pleurer"]):
            return "triste"
        if any(w in t for w in ["heureux", "content", "joyeux", "super"]):
            return "heureux"
        if any(w in t for w in ["stressé", "angoissé", "anxieux", "panic", "panique"]):
            return "stressé"
        return "neutre"

    def clear_history(self) -> None:
        self.history = []
        self.user_data = {}
        self.save_history()


def _create_client() -> Optional[Any]:
    api_key = os.getenv("MISTRAL_API_KEY")
    # If no API key is provided, return None and rely on fallback behavior.
    # This allows local testing without external API credentials.
    if not api_key:
        return None
    if MistralClient is None:
        return None
    return MistralClient(api_key=api_key)


def build_messages_for_model(manager: ConversationManager, user_text: str) -> List[Dict[str, str]]:
    prenom = manager.detect_prenom(user_text)
    emotion = manager.detect_emotion(user_text)

    emotion_context = f"L'utilisateur semble {emotion}."
    if prenom:
        emotion_context += f" Son prénom est {prenom}."

    messages = [{"role": "system", "content": SYSTEM_PROMPT + "\n" + emotion_context}]
    # append recent history
    for m in manager.get_recent_history():
        messages.append({"role": m.get("role", "user"), "content": m.get("content", "")})
    # current user message
    messages.append({"role": "user", "content": user_text})
    return messages


def chat_with_lyra(user_text: str, manager: ConversationManager, client: Any = None, **kwargs) -> Tuple[str, Optional[dict]]:
    """Send `user_text` to the model and return the assistant reply.

    Returns: (assistant_text, raw_response_dict_or_None)
    """
    if client is None:
        # try to create a client automatically, but allow None fallback
        client = _create_client()

    messages = build_messages_for_model(manager, user_text)

    try:
        if client is not None:
            response = client.chat(model=kwargs.get("model", "mistral-large-latest"), messages=messages, temperature=kwargs.get("temperature", 0.7), max_tokens=kwargs.get("max_tokens", 500))
            assistant_text = None
            try:
                assistant_text = response.choices[0].message.content
            except Exception:
                assistant_text = str(response)
        else:
            # Fallback: simple echo/warm reply when mistral client is not available
            assistant_text = "Je suis là. Peux-tu m'en dire un peu plus ?" if len(user_text) < 20 else f"Je comprends. Tu dis : {user_text[:400]}"
            response = None

    except Exception as exc:
        assistant_text = f"Désolé, une erreur est survenue lors de l'appel au modèle: {exc}"
        response = None

    # update manager history
    manager.add_message("user", user_text)
    manager.add_message("assistant", assistant_text)
    # save after each turn
    manager.save_history()

    return assistant_text, getattr(response, "__dict__", None)


def create_session() -> str:
    session_id = uuid.uuid4().hex
    path = DATA_DIR / f"{session_id}.json"
    manager = ConversationManager(path)
    manager.save_history()
    return session_id


def get_manager_for_session(session_id: str) -> ConversationManager:
    safe_id = re.sub(r"[^a-zA-Z0-9_-]", "", session_id)
    path = DATA_DIR / f"{safe_id}.json"
    return ConversationManager(path)
