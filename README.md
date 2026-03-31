<div align="center">

# 🏥 PulseAI — Accélérer l'accès aux soins avec l'IA

**Transformez l'accès aux soins de santé en Afrique grâce à l'intelligence artificielle**

[![Netlify Status](https://img.shields.io/badge/Web-Live-success?style=for-the-badge&logo=netlify)](https://thepulseai.netlify.app)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-blue?style=for-the-badge&logo=flutter)](https://thepulseai.netlify.app)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

---

## 🚀 Accès Rapide

| Plateforme | Lien | Description |
|------------|------|-------------|
| 🌐 **Site Web Principal** | [thepulseai.netlify.app](https://thepulseai.netlify.app) | Site vitrine et présentation du projet |
| 💻 **Application Web** | [pulseai-a0548.web.app](https://pulseai-a0548.web.app/) | Version web complète de l'application |
| 🏥 **Dashboard Hôpitaux** | [pulseai-hospitals.netlify.app](https://pulseai-hospitals.netlify.app/) | Gestion des établissements de santé |
| 📱 **APK Android** | [Télécharger v3.0.0](https://github.com/light667/PulseAI/releases/download/v3.0.0/app-release.apk) | Application mobile Android |
| 📖 **Documentation** | [docs/](docs/) | Documentation technique complète |
| 🔗 **Code Source** | [github.com/neuractif-initiatives/ai4y-delta-lom25](https://github.com/neuractif-initiatives/ai4y-delta-lom25) | Repository GitHub du projet |

</div>

---

## 🎯 Problématique

### Les défis actuels du système de santé africain

| Défi | Impact |
|------|--------|
| 🏥 **Accès limité en zones rurales** | Manque de spécialistes et d'infrastructures médicales dans les régions éloignées |
| 🚑 **Hôpitaux urbains saturés** | Coordination fragile, files d'attente interminables, ressources mal optimisées |
| 🧠 **Santé mentale négligée** | Besoin croissant de soutien psychologique chez les jeunes, peu de ressources disponibles |
| 💊 **Médicaments contrefaits** | Prolifération de faux médicaments mettant en danger la santé publique *(Phase 2 en développement)* |

---

## 💡 Notre Solution

PulseAI offre **4 fonctionnalités clés** pour révolutionner l'accès aux soins :

### 1️⃣ **RuralDiag** — Diagnostic Intelligent
```
🔍 Sélection de symptômes (liste + voix)
🤖 Analyse IA avec RAG (Retrieval-Augmented Generation)
📋 Diagnostic détaillé lisible et écoutable
📊 Historique des consultations
```

### 2️⃣ **SmartHosp** — Recherche d'Hôpitaux
```
📍 Géolocalisation automatique
🏥 Liste triée par distance et disponibilité
🗺️ Itinéraires en temps réel
📡 Données live des établissements (lits, services, médecins)
```

### 3️⃣ **MedScan** — Détection de Contrefaçons *(Phase 2)*
```
📸 Scan de médicaments
🔬 Vérification d'authenticité par IA
⚠️ Alertes en temps réel
```

### 4️⃣ **Lyra** — Assistant Mental Virtuel
```
💬 Thérapeute virtuelle disponible 24/7
🧘 Gestion du stress, concentration, motivation
🎧 Réponses textuelles et audio
🌱 Conseils de bien-être personnalisés
```

---

## 🛠️ Tech Stack

### Langages
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)

### Frameworks & Bibliothèques
- **Backend** : FastAPI, FAISS (vector search), Sentence Transformers
- **Mobile** : Flutter 3.x (Android, iOS, Web)
- **Web** : Vanilla JavaScript, HTML5, CSS3
- **Base de données** : 
  - **Dashboard Web** : Supabase (PostgreSQL + Auth + RLS + Realtime)
  - **Application Mobile** : Firebase (Firestore + Auth + Hosting)

### Intelligence Artificielle
- **Modèles** : RAG (Retrieval-Augmented Generation) avec embeddings
- **Vector Database** : FAISS pour recherche sémantique
- **NLP** : Analyse de symptômes, génération de diagnostics
- **TTS** : Text-to-Speech pour accessibilité

### Hébergement & Déploiement
- **Site Web** : Netlify (CI/CD automatique)
- **Dashboard Hôpitaux** : Netlify + Supabase Cloud
- **Backend API** : Render (conteneurs Docker)
- **Application Mobile Web** : Firebase Hosting
- **Application Mobile Android** : APK direct download, Play Store (à venir)

---

## 🚀 Installation & Lancement

### Prérequis

```bash
# Versions minimales requises
Python 3.10+
Node.js 18+
Flutter 3.0+
Git
```

### 📦 1. Cloner le repository

```bash
git clone https://github.com/neuractif-initiatives/ai4y-delta-lom25.git
cd ai4y-delta-lom25
```

### 🐍 2. Backend (FastAPI)

```bash
cd backend

# Créer environnement virtuel
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# Installer dépendances
pip install -r requirements.txt

# Lancer le serveur
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Variables d'environnement** : Créer un fichier `.env` (voir [`backend/.env.example`](backend/.env.example))

**Tests** :
```bash
pytest backend/test_backend.py -v
```

### 🌐 3. Dashboard Web

```bash
cd "DASHBOARD WEB PULSEAI"

# Configuration Supabase
cp src/config.example.js src/config.js
# Éditer config.js avec vos clés Supabase

# Installer dépendances
npm install

# Lancer en mode développement
npm run dev
```

**Configuration** : Éditer `public/src/config.js` avec vos clés Supabase

### 📱 4. Application Mobile (Flutter)

```bash
cd MOBILEAPP/pulseai

# Installer dépendances
flutter pub get

# Lancer sur émulateur/appareil
flutter run

# Build APK release
flutter build apk --release
```

**Configuration** : 
- Firebase : `android/app/google-services.json`
- Supabase : Clés dans le code (à externaliser)

---

## 📖 Guide d'Utilisation

### 🌟 Parcours Utilisateur Complet

#### 1️⃣ **Accès au Site**
Ouvrez votre navigateur et allez sur : **[thepulseai.netlify.app](https://thepulseai.netlify.app)**

#### 2️⃣ **Page d'Accueil du Site**
- 📥 Téléchargez l'APK Android : [app-release.apk](https://github.com/light667/PulseAI/releases/download/v3.0.0/app-release.apk)
- 🌐 Ou utilisez la version web directement : [pulseai-a0548.web.app](https://pulseai-a0548.web.app/)
- 🏥 Accédez au dashboard hôpitaux : [pulseai-hospitals.netlify.app](https://pulseai-hospitals.netlify.app/)

#### 3️⃣ **Lancement de l'Application**
- Parcourez les écrans d'introduction
- Appuyez sur **"Suivant"** ou **"Passer"**

#### 4️⃣ **Connexion & Inscription**
- 🌍 Choisissez votre langue
- ✏️ **"Créer un compte"** pour la première visite
- 🔐 Renseignez vos informations
- ↪️ Redirection automatique vers l'accueil

#### 5️⃣ **Page d'Accueil de l'App**
- 👤 **Profil** en haut à droite
- 📋 **Mini carnet de santé** (poids, taille, groupe sanguin)
- 💡 **Conseils de bien-être quotidien**
- 🎴 **4 cartes fonctionnalités** principales
- 🔽 **Barre de navigation** en bas

---

### 🔧 Utilisation des Fonctionnalités

#### 🩺 **RuralDiag — Diagnostic Intelligent**

1. Appuyez sur **"RuralDiag"** ou **"Diag"** dans la barre de navigation
2. Sélectionnez vos **symptômes** dans la liste
3. Ajoutez des **précisions écrites** ou utilisez le **mode vocal** 🎤
4. Validez pour lancer l'**analyse IA**
5. Consultez le **diagnostic détaillé**
6. 🔊 Écoutez la synthèse avec le bouton **"Écouter"**

#### 🏥 **SmartHosp — Recherche d'Hôpitaux**

1. Ouvrez **"SmartHosp"** ou **"Hôpital"**
2. Autorisez l'accès à votre **géolocalisation** 📍
3. Consultez la liste des **hôpitaux les plus proches**
4. Triez par **distance** et **disponibilité**
5. Affichez les **détails** (services, lits, médecins)
6. Obtenez l'**itinéraire** pour vous y rendre 🗺️

#### 🧠 **Lyra — Assistant Mental Virtuel**

1. Accédez à **"Lyra"** via la barre de navigation
2. Discutez avec la **thérapeute virtuelle** 💬
3. Obtenez de l'aide pour :
   - 😰 Gestion du stress
   - 🎯 Concentration
   - 💪 Motivation
   - 🌱 Bien-être général
4. 🔊 Écoutez les réponses avec le bouton audio
a
#### 💊 **MedScan** *(Phase 2 — En développement)*

Fonctionnalité à venir pour détecter les médicaments contrefaits.

#### ⚙️ **Paramètres**

Personnalisez vos préférences et informations personnelles.

---

## 📚 Documentation Technique

### Architecture du Projet

```
📁 ai4y-delta-lom25/
├── 📁 backend/              # API FastAPI + Services IA
│   ├── app/
│   │   ├── main.py          # Point d'entrée API
│   │   ├── diagnostic_service.py   # RAG + FAISS
│   │   └── lyra_service.py         # Assistant Lyra
│   ├── data/                # Corpus médical + Index
│   └── Dockerfile           # Déploiement Render
│
├── 📁 DASHBOARD WEB PULSEAI/    # Dashboard hôpitaux
│   ├── public/              # Pages HTML + assets
│   └── src/                 # JS modules (auth, API)
│
├── 📁 MOBILEAPP/pulseai/    # App Flutter
│   ├── lib/                 # Code Dart
│   ├── android/             # Config Android
│   └── ios/                 # Config iOS
│
├── 📁 CHATBOT/              # Lyra notebooks
├── 📁 Diagnostic Model/     # RAG data & FAISS index
├── 📁 PulseAI Website General/  # Site vitrine
└── 📁 docs/                 # Documentation détaillée
```

### Documentation Détaillée

- 📖 [Backend API](docs/BACKEND.md) — Architecture, endpoints, déploiement
- 📖 [Dashboard Web](docs/DASHBOARD.md) — Gestion hôpitaux, temps réel
- 📖 [Application Mobile](docs/MOBILEAPP.md) — Flutter, features, build
- 📖 [Chatbot Lyra](docs/CHATBOT_LYRA.md) — Prompts, intégration
- 📖 [Modèle Diagnostic](docs/DIAGNOSTIC_MODEL.md) — RAG, FAISS, pipeline
- 📖 [Guide Démo Hackathon](docs/DEMO_HACKATHON.md) — Présentation jury

---

## 👥 Équipe & Contributions

### Auteurs

**PulseAI Team** — Neuractif Initiatives

| Membre | Rôle | Responsabilités |
|--------|------|-----------------|
| **Light DJOSSOU** | 🎯 Chef de Projet & IA Lead | Vision produit, coordination équipe, architecture globale • Modèles RAG & embeddings • Corpus médical & FAISS • Dashboard hôpitaux Supabase |
| **SEGUE Freeman** | 🐍 Ingénieur Backend | API FastAPI, services IA, déploiement Render • Intégration RAG & endpoints |
| **DOH Ben** | 🌐 Développeur Frontend Web | Chatbot Lyra • Dashboard hôpitaux • Site vitrine général sur Netlify |
| **KOUMI Rejoice** | 📱 Développeuse Mobile | Application Flutter (Android/iOS/Web) • UI/UX design • Features mobiles & géolocalisation |

### Contribuer

Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour les guidelines de contribution.

---

## 🔒 Sécurité

Consultez [SECURITY.md](SECURITY.md) pour reporter des vulnérabilités.

---

## 📄 Licence

Ce projet est sous licence **MIT** — voir [LICENSE](LICENSE)

---

## 🌍 Impact Social

### Objectifs de Développement Durable (ODD)

- 🎯 **ODD 3** : Bonne santé et bien-être
- 🎯 **ODD 9** : Industrie, innovation et infrastructure
- 🎯 **ODD 10** : Réduction des inégalités

### Métriques Cibles

- 📈 **100 000+** utilisateurs en 12 mois
- 🏥 **500+** hôpitaux partenaires
- 🌍 **10+** pays africains couverts
- ⚡ **< 2s** temps de réponse diagnostic

---

## 🙏 Remerciements

Merci aux jurys du hackathon et à tous ceux qui croient en **PulseAI** et l'innovation pour la santé en Afrique.

---

<div align="center">

**Fait avec ❤️ pour l'Afrique**

[⭐ Star ce projet](https://github.com/neuractif-initiatives/ai4y-delta-lom25) si vous croyez en notre mission !

</div>
