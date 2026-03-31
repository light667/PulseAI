import sys
import os
import pandas as pd
from pathlib import Path

# Add the parent directory to sys.path to access app.core
sys.path.append(str(Path(__file__).resolve().parent.parent))

from app.core.config import settings
from app.core.database import supabase_client
from langchain.docstore.document import Document
from langchain_mistralai import MistralAIEmbeddings
from langchain_community.vectorstores import SupabaseVectorStore

DATA_DIR = "/home/light667/Dev/PulseAI"

def ingest_csvs():
    if not supabase_client:
        print("Error: Supabase client not initialized. Check your .env file.")
        return

    print("Loading CSV datasets...")
    try:
        df_dataset = pd.read_csv(os.path.join(DATA_DIR, "dataset.csv"))
        df_desc = pd.read_csv(os.path.join(DATA_DIR, "disease_description.csv"))
        df_severity = pd.read_csv(os.path.join(DATA_DIR, "symptom_severity.csv"))
    except Exception as e:
        print(f"Error loading CSVs: {e}")
        return

    # Create mapping of symptom to severity
    df_severity['Symptom'] = df_severity['Symptom'].str.strip()
    severity_map = dict(zip(df_severity['Symptom'], df_severity['Symptom_severity']))

    # Create mapping of disease to description
    df_desc['Disease'] = df_desc['Disease'].str.strip()
    desc_map = dict(zip(df_desc['Disease'], df_desc['Symptom_Description']))

    print("Processing disease symptom profiles into semantic text chunks...")
    disease_profiles = {}

    for index, row in df_dataset.iterrows():
        disease = str(row['Disease']).strip()
        symptoms = [str(x).strip() for x in row[1:] if pd.notna(x) and str(x).strip().lower() != 'nan' and str(x).strip() != '']
        
        if disease not in disease_profiles:
            disease_profiles[disease] = set()
            
        disease_profiles[disease].update(symptoms)

    docs = []
    for disease, symptoms in disease_profiles.items():
        description = desc_map.get(disease, "No specific description available.")
        
        symptom_details = []
        for s in symptoms:
            # clean symptom name
            clean_s = s.replace('_', ' ').title()
            sev = severity_map.get(s, "Unknown")
            symptom_details.append(f"{clean_s} (Severity: {sev})")
            
        symptoms_str = ", ".join(symptom_details)
        
        content = (
            f"Disease Name: {disease}\n"
            f"Description: {description}\n"
            f"Associated Symptoms: {symptoms_str}\n"
        )
        
        doc = Document(page_content=content, metadata={"source": "dataset", "disease": disease})
        docs.append(doc)

    print(f"Created {len(docs)} composite disease documents.")

    print("Initializing Mistral Embeddings...")
    embeddings_model = MistralAIEmbeddings(model="mistral-embed")

    print("Inserting formatted CSV chunks into Supabase Vector Store...")
    SupabaseVectorStore.from_documents(
        docs,
        embeddings_model,
        client=supabase_client,
        table_name="documents",
        query_name="match_documents"
    )
    print("CSV data ingestion complete!")

if __name__ == "__main__":
    ingest_csvs()
