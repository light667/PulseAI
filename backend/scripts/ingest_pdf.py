import sys
import os
from pathlib import Path

# Add the parent directory to sys.path to access app.core
sys.path.append(str(Path(__file__).resolve().parent.parent))

from app.core.config import settings
from app.core.database import supabase_client
from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_mistralai import MistralAIEmbeddings
from langchain_community.vectorstores import SupabaseVectorStore

PDF_PATH = "/home/light667/Dev/PulseAI/Medical_book.pdf"

def ingest_pdf():
    if not supabase_client:
        print("Error: Supabase client not initialized. Check your .env file.")
        return

    print(f"Loading PDF from {PDF_PATH}...")
    loader = PyPDFLoader(PDF_PATH)
    documents = loader.load()
    print(f"Loaded {len(documents)} pages.")

    print("Splitting text into chunks...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
        separators=["\n\n", "\n", " ", ""]
    )
    docs = text_splitter.split_documents(documents)
    print(f"Split into {len(docs)} chunks.")

    print("Initializing Mistral Embeddings...")
    embeddings_model = MistralAIEmbeddings(model="mistral-embed")

    print("Inserting chunks into Supabase Vector Store...")
    # This assumes the 'documents' table exists and matches the schema
    vector_store = SupabaseVectorStore.from_documents(
        docs,
        embeddings_model,
        client=supabase_client,
        table_name="documents",
        query_name="match_documents"
    )
    print("Ingestion complete!")

if __name__ == "__main__":
    ingest_pdf()
