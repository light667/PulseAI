#!/usr/bin/env python3
"""
Script de test pour le backend unifié PulseAI
Teste les endpoints du chatbot et du diagnostic
"""

import requests
import json
import sys
from typing import Dict, Any

# Configuration
BASE_URL = "https://pulseai-fi9m.onrender.com"  # URL du backend déployé sur Render
COLORS = {
    'GREEN': '\033[92m',
    'RED': '\033[91m',
    'YELLOW': '\033[93m',
    'BLUE': '\033[94m',
    'END': '\033[0m'
}


def print_colored(text: str, color: str):
    """Affiche du texte coloré"""
    print(f"{COLORS.get(color, '')}{text}{COLORS['END']}")


def test_health() -> bool:
    """Test de santé du backend"""
    print_colored("\n🔍 Test 1: Health Check", 'BLUE')
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_colored(f"✅ Health check réussi: {json.dumps(data, indent=2)}", 'GREEN')
            return True
        else:
            print_colored(f"❌ Échec: Status {response.status_code}", 'RED')
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def test_root() -> bool:
    """Test de l'endpoint racine"""
    print_colored("\n🔍 Test 2: Root Endpoint", 'BLUE')
    try:
        response = requests.get(f"{BASE_URL}/", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_colored(f"✅ Root endpoint réussi", 'GREEN')
            print(f"   Service: {data.get('service')}")
            print(f"   Version: {data.get('version')}")
            print(f"   Endpoints: {data.get('endpoints')}")
            return True
        else:
            print_colored(f"❌ Échec: Status {response.status_code}", 'RED')
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def test_chatbot() -> bool:
    """Test du chatbot Lyra"""
    print_colored("\n🔍 Test 3: Chatbot Lyra", 'BLUE')
    try:
        payload = {
            "message": "Bonjour, je me sens stressé",
            "history": []
        }
        response = requests.post(
            f"{BASE_URL}/chat",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print_colored("✅ Chatbot réussi", 'GREEN')
            print(f"   Réponse: {data.get('response')[:200]}...")
            print(f"   Historique: {len(data.get('history', []))} messages")
            return True
        else:
            print_colored(f"❌ Échec: Status {response.status_code}", 'RED')
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def test_symptoms() -> bool:
    """Test de récupération des symptômes"""
    print_colored("\n🔍 Test 4: Liste des symptômes", 'BLUE')
    try:
        response = requests.get(f"{BASE_URL}/symptoms", timeout=10)
        if response.status_code == 200:
            data = response.json()
            symptoms = data.get('symptoms', [])
            print_colored(f"✅ Symptômes récupérés: {len(symptoms)} symptômes", 'GREEN')
            print(f"   Exemples: {symptoms[:5]}")
            return True
        else:
            print_colored(f"❌ Échec: Status {response.status_code}", 'RED')
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def test_diagnostic() -> bool:
    """Test du diagnostic médical"""
    print_colored("\n🔍 Test 5: Diagnostic médical", 'BLUE')
    try:
        payload = {
            "symptoms": ["fever", "headache", "fatigue"],
            "use_ai": True
        }
        response = requests.post(
            f"{BASE_URL}/diagnostic",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print_colored("✅ Diagnostic réussi", 'GREEN')
            print(f"   Diagnostic: {data.get('diagnosis')[:200]}...")
            print(f"   Confiance: {data.get('confidence')}")
            print(f"   Recommandations: {len(data.get('recommendations', []))}")
            return True
        else:
            print_colored(f"❌ Échec: Status {response.status_code}", 'RED')
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def test_diagnostic_stats() -> bool:
    """Test des statistiques du diagnostic"""
    print_colored("\n🔍 Test 6: Statistiques du diagnostic", 'BLUE')
    try:
        response = requests.get(f"{BASE_URL}/diagnostic/stats", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print_colored("✅ Stats récupérées", 'GREEN')
            print(f"   Total symptômes: {data.get('total_symptoms')}")
            print(f"   RAG activé: {data.get('rag_enabled')}")
            print(f"   Modèle: {data.get('model')}")
            return True
        else:
            print_colored(f"❌ Échec: Status {response.status_code}", 'RED')
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def test_session_management() -> bool:
    """Test de la gestion des sessions"""
    print_colored("\n🔍 Test 7: Gestion des sessions", 'BLUE')
    try:
        # Créer une session
        response = requests.post(f"{BASE_URL}/api/sessions", timeout=10)
        if response.status_code == 200:
            session_data = response.json()
            session_id = session_data.get('session_id')
            print_colored(f"✅ Session créée: {session_id}", 'GREEN')
            
            # Envoyer un message à la session
            payload = {"content": "Comment aller mieux?"}
            response = requests.post(
                f"{BASE_URL}/api/sessions/{session_id}/messages",
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                print_colored("✅ Message envoyé à la session", 'GREEN')
                return True
            else:
                print_colored(f"❌ Échec envoi message: Status {response.status_code}", 'RED')
                return False
        else:
            print_colored(f"❌ Échec création session: Status {response.status_code}", 'RED')
            return False
    except Exception as e:
        print_colored(f"❌ Erreur: {e}", 'RED')
        return False


def main():
    """Fonction principale"""
    print_colored("=" * 60, 'BLUE')
    print_colored("🧪 Tests du Backend Unifié PulseAI", 'BLUE')
    print_colored(f"📍 URL: {BASE_URL}", 'BLUE')
    print_colored("=" * 60, 'BLUE')
    
    tests = [
        ("Health Check", test_health),
        ("Root Endpoint", test_root),
        ("Chatbot Lyra", test_chatbot),
        ("Liste des symptômes", test_symptoms),
        ("Diagnostic médical", test_diagnostic),
        ("Statistiques diagnostic", test_diagnostic_stats),
        ("Gestion des sessions", test_session_management),
    ]
    
    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print_colored(f"❌ Erreur critique dans {name}: {e}", 'RED')
            results.append((name, False))
    
    # Résumé
    print_colored("\n" + "=" * 60, 'BLUE')
    print_colored("📊 RÉSUMÉ DES TESTS", 'BLUE')
    print_colored("=" * 60, 'BLUE')
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        color = 'GREEN' if result else 'RED'
        print_colored(f"{status} - {name}", color)
    
    print_colored(f"\n📈 Score: {passed}/{total} tests réussis", 'BLUE')
    
    if passed == total:
        print_colored("\n🎉 Tous les tests sont passés! Le backend est prêt.", 'GREEN')
        return 0
    else:
        print_colored(f"\n⚠️  {total - passed} test(s) échoué(s). Vérifiez les logs.", 'YELLOW')
        return 1


if __name__ == "__main__":
    sys.exit(main())
