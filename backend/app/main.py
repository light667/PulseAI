from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import chatbot, localization

app = FastAPI(
    title="PulseAI Continental Backend API",
    description="Backend service for PulseAI medical triage, RAG diagnostics, and dynamic AI localization.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chatbot.router, prefix="/api/v1/bot", tags=["Chatbot"])
app.include_router(localization.router, prefix="/api/v1/locale", tags=["Localization"])

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Welcome to the PulseAI API Backend"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
