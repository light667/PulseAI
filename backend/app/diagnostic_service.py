import os
import pickle
import faiss
import csv
import numpy as np
import gc
from sentence_transformers import SentenceTransformer
from mistralai.client import MistralClient
from typing import List, Dict, Any

DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data")
INDEX_PATH = os.path.join(DATA_DIR, "rag_index.faiss")
DOCS_PATH = os.path.join(DATA_DIR, "rag_docs.pkl")
CSV_PATH = os.path.join(DATA_DIR, "rag_clean.csv")


class DiagnosticSystem:
    def __init__(self):
        self.api_key = os.getenv("MISTRAL_API_KEY")
        if not self.api_key:
            print("WARNING: MISTRAL_API_KEY not set. Using fallback mode.")
            self.client = None
        else:
            self.client = MistralClient(api_key=self.api_key)
        
        self.embedder = None
        self.index = None
        self.docs = []
        self.symptoms_list = self._get_default_symptoms()
        self.use_rag = False
        self._index_loaded = False
        
        print("Initializing Diagnostic System (Lazy Mode)...")
        # Load symptoms from CSV if available (lightweight)
        try:
            if os.path.exists(CSV_PATH):
                print(f"Found CSV at {CSV_PATH}")
                self._load_symptoms()
            else:
                print(f"CSV not found, using default symptoms")
        except Exception as e:
            print(f"Error loading symptoms: {e}")
        
        print("✅ Diagnostic System initialized (RAG will load on first use)")

    def _get_embedder(self):
        if self.embedder is None:
            print("Loading Embedding Model (Lazy Load)...")
            self.embedder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
        return self.embedder

    def _get_default_symptoms(self):
        """Return common symptoms list as fallback"""
        return sorted([
            "fever", "headache", "cough", "fatigue", "sore throat", "shortness of breath",
            "chest pain", "nausea", "vomiting", "diarrhea", "abdominal pain", "dizziness",
            "back pain", "joint pain", "muscle pain", "skin rash", "itching", "swelling",
            "weakness", "loss of appetite", "weight loss", "night sweats", "chills",
            "difficulty breathing", "wheezing", "runny nose", "nasal congestion",
            "sneezing", "eye pain", "blurred vision", "ear pain", "hearing loss",
            "difficulty swallowing", "hoarseness", "palpitations", "irregular heartbeat",
            "high blood pressure", "low blood pressure", "anxiety", "depression",
            "insomnia", "confusion", "memory loss", "numbness", "tingling",
            "tremors", "seizures", "loss of consciousness", "bruising", "bleeding",
            "frequent urination", "painful urination", "blood in urine", "constipation",
            "bloating", "heartburn", "indigestion", "loss of taste", "loss of smell"
        ])
    
    def _load_symptoms(self):
        symptoms = set()
        try:
            with open(CSV_PATH, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    if 'Symptoms' in row and row['Symptoms']:
                        parts = [p.strip() for p in row['Symptoms'].split(',')]
                        symptoms.update(parts)
            if symptoms:
                self.symptoms_list = sorted(list(symptoms))
                print(f"Loaded {len(self.symptoms_list)} symptoms from CSV")
        except Exception as e:
            print(f"Error loading symptoms: {e}")

    def _lazy_load_rag(self):
        """Charge l'index RAG uniquement lors de la première utilisation"""
        if self._index_loaded:
            return
        
        try:
            if os.path.exists(INDEX_PATH) and os.path.exists(DOCS_PATH):
                print("🔄 Lazy loading FAISS index...")
                self.index = faiss.read_index(INDEX_PATH)
                with open(DOCS_PATH, "rb") as f:
                    self.docs = pickle.load(f)
                print(f"✅ FAISS index loaded with {len(self.docs)} documents")
                self.use_rag = True
            elif os.path.exists(CSV_PATH):
                print("🔄 Building FAISS index from CSV...")
                self.rebuild_index()
                if self.index and self.docs:
                    self.use_rag = True
                    print(f"✅ RAG index built with {len(self.docs)} documents")
            else:
                print("⚠️  No RAG data available")
                self.use_rag = False
            
            self._index_loaded = True
        except Exception as e:
            print(f"❌ Error loading RAG: {e}")
            self.use_rag = False
            self._index_loaded = True

    def rebuild_index(self):
        if not os.path.exists(CSV_PATH):
            print("CSV not found, cannot build index.")
            return

        print("Reading CSV for index build...")
        documents = []
        try:
            with open(CSV_PATH, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    disease = row.get('Disease', 'Unknown')
                    symp = row.get('Symptoms', '')
                    doc = f"Disease: {disease}. Symptoms: {symp}"
                    documents.append(doc)
            
            self.docs = documents
            
            # Encode
            embedder = self._get_embedder()
            print("Encoding documents...")
            embeddings = embedder.encode(documents)
            
            dimension = embeddings.shape[1]
            self.index = faiss.IndexFlatL2(dimension)
            self.index.add(np.array(embeddings).astype('float32'))
            
            # Save
            faiss.write_index(self.index, INDEX_PATH)
            with open(DOCS_PATH, "wb") as f:
                pickle.dump(self.docs, f)
            print("Index built and saved.")
            
            # Cleanup memory
            del embeddings
            gc.collect()
            
        except Exception as e:
            print(f"Error rebuilding index: {e}")

    def get_symptoms(self) -> List[str]:
        return self.symptoms_list

    def diagnose(self, symptoms: List[str], use_ai: bool = True) -> Dict:
        """
        Effectue un diagnostic basé sur les symptômes fournis
        
        Args:
            symptoms: Liste des symptômes
            use_ai: Si True, utilise l'IA pour le diagnostic
            
        Returns:
            Dict contenant le diagnostic, la confiance et les recommandations
        """
        # Charger RAG si pas encore fait (lazy loading)
        if not self._index_loaded:
            self._lazy_load_rag()
        
        # Convertir la liste de symptômes en chaîne
        user_symptoms = ", ".join(symptoms)
        
        if not use_ai or not self.client:
            return self._fallback_diagnosis_dict(user_symptoms)
            
        try:
            # ÉTAPE 1: Recherche RAG
            context = ""
            rag_diseases = []
            
            if self.use_rag and self.index and self.docs:
                embedder = self._get_embedder()
                query_vector = embedder.encode([user_symptoms]).astype('float32')
                k = min(5, len(self.docs))
                D, I = self.index.search(query_vector, k)
                
                retrieved_docs = []
                if len(I) > 0:
                    for idx, i in enumerate(I[0]):
                        if 0 <= i < len(self.docs):
                            retrieved_docs.append(f"Document {idx+1}: {self.docs[i]}")
                            doc_text = self.docs[i]
                            if "Disease:" in doc_text:
                                disease_name = doc_text.split("Disease:")[1].split(".")[0].strip()
                                rag_diseases.append(disease_name)
                
                if retrieved_docs:
                    context = "\n\n".join(retrieved_docs)
            
            # ÉTAPE 2: Génération du diagnostic avec Mistral
            if context and rag_diseases:
                prompt = f"""Tu es un assistant médical IA. Analyse les symptômes en te basant sur le contexte médical.

CONTEXTE MÉDICAL:
{context}

SYMPTÔMES DU PATIENT:
{user_symptoms}

MALADIES IDENTIFIÉES:
{', '.join(rag_diseases)}

INSTRUCTIONS:
1. Analyse les maladies identifiées et leur correspondance avec les symptômes
2. Classe-les par ordre de probabilité
3. Fournis des recommandations médicales appropriées
4. Sois empathique et professionnel
5. Ajoute l'avertissement que ceci ne remplace pas un diagnostic médical professionnel

Réponds de manière structurée et claire."""
            else:
                prompt = f"""Tu es un assistant médical IA. Analyse ces symptômes de manière générale et prudente.

SYMPTÔMES: {user_symptoms}

Fournis:
1. Une analyse générale
2. Des recommandations de consultation
3. L'avertissement que ceci ne remplace pas un diagnostic professionnel"""

            messages = [{"role": "user", "content": prompt}]
            chat_response = self.client.chat(
                model="mistral-tiny",
                messages=messages,
            )

            diagnosis_text = chat_response.choices[0].message.content
            
            return {
                "diagnosis": diagnosis_text,
                "confidence": "Moyenne à Élevée" if context else "Faible",
                "recommendations": [
                    "Consultez un médecin pour confirmation",
                    "Surveillez l'évolution de vos symptômes",
                    "En cas d'urgence, contactez les services d'urgence"
                ]
            }
            
        except Exception as e:
            print(f"Error during diagnosis: {e}")
            return self._fallback_diagnosis_dict(user_symptoms)
    
    def _fallback_diagnosis_dict(self, user_symptoms: str) -> Dict:
        """Fallback response when Mistral API is unavailable"""
        return {
            "diagnosis": f"""Diagnostic préliminaire pour: {user_symptoms}

⚠️ LIMITATION: Le système de diagnostic complet n'est pas disponible actuellement.

RECOMMANDATIONS GÉNÉRALES:
1. Consultation médicale recommandée pour évaluation professionnelle
2. Surveillez l'évolution de vos symptômes (intensité, durée, nouveaux symptômes)
3. En cas d'urgence (douleur thoracique intense, difficulté respiratoire sévère, etc.), consultez immédiatement
4. Mesures générales: repos, hydratation, éviter l'automédication

⚠️ AVERTISSEMENT: Ce message ne remplace EN AUCUN CAS un diagnostic médical professionnel. Consultez un médecin pour une évaluation appropriée.""",
            "confidence": "Très Faible (Mode Dégradé)",
            "recommendations": [
                "Consultez un médecin dès que possible",
                "Notez vos symptômes et leur évolution",
                "En urgence: appelez le 15, 112 ou rendez-vous aux urgences"
            ]
        }
