from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from langchain_mistralai import ChatMistralAI, MistralAIEmbeddings
from langchain_community.vectorstores import SupabaseVectorStore
from langchain_core.prompts import PromptTemplate
from app.core.database import supabase_client
from app.core.config import settings

router = APIRouter()

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    user_id: Optional[str] = None
    language: Optional[str] = "en"

class ChatResponse(BaseModel):
    reply: str

# Define Lyra's system prompt
LYRA_SYSTEM_PROMPT = """
You are Lyra, a highly intelligent, empathetic, and professional AI medical assistant designed for the PulseAI platform serving all of Africa.
Your primary role is triage, providing preliminary medical assessments, answering health-related questions based STRICTLY on the provided medical context.
Do NOT invent medical facts. If the context does not contain the answer, state clearly that you cannot replace a real doctor and recommend consulting a professional.
Always adopt a caring, reassuring tone.
Language requirement: Reply in {language}.

CONTEXT RETRIEVED:
{context}

CONVERSATION HISTORY:
{history}
"""

@router.post("/chat", response_model=ChatResponse)
async def lyra_chat(request: ChatRequest):
    if not supabase_client:
        raise HTTPException(status_code=500, detail="Database not connected.")
        
    try:
        # Get the latest user query
        user_query = request.messages[-1].content
        
        # Format history
        history_str = "\n".join([f"{msg.role.capitalize()}: {msg.content}" for msg in request.messages[:-1]])
        
        # 1. Retrieve the context
        embeddings = MistralAIEmbeddings(model="mistral-embed")
        vector_store = SupabaseVectorStore(
            client=supabase_client,
            embedding=embeddings,
            table_name="documents",
            query_name="match_documents"
        )
        
        # Fetch top 5 relevant chunks
        docs = vector_store.similarity_search(user_query, k=5)
        context_str = "\n\n".join([d.page_content for d in docs])
        
        # 2. Setup Mistral LLM
        llm = ChatMistralAI(model="mistral-large-latest", mistral_api_key=settings.MISTRAL_API_KEY)
        
        prompt = PromptTemplate(
            input_variables=["language", "context", "history", "user_query"],
            template=LYRA_SYSTEM_PROMPT + "\nHuman: {user_query}\nLyra: "
        )
        
        chain = prompt | llm
        
        response = chain.invoke({
            "language": request.language,
            "context": context_str,
            "history": history_str,
            "user_query": user_query
        })
        
        return ChatResponse(reply=response.content)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
