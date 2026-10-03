# Ustad Ji 🛠️

**AI-powered labor marketplace for home services.**

Book verified plumbers, electricians, and AC technicians in 3 taps — with AI price estimates, autonomous worker bidding, and live GPS tracking.

---

## 🎯 What It Does

- **AI Price Estimate** — Describe your problem in English or Urdu, get an instant baseline price from a knowledge base of 127+ repair patterns.
- **Agentic Auto-Bidding** — Nearby workers' AI agents compete on your job. You pick the winner by price, rating, and distance.
- **Live Tracking** — Watch your ustad approach in real time on the map. ETA updates every few seconds.
- **In-App Call & WhatsApp** — One tap opens the dialer or WhatsApp with the worker's verified Pakistani number.
- **Auto-Pilot for Workers** — Set-and-forget bidding. AI bids on matching jobs automatically.

---

## 🏗️ Architecture
┌─────────────────────┐ ┌──────────────────────┐
│ Flutter App │ HTTP │ FastAPI Backend │
│ (Web + Android) │ ──────► │ │
│ │ │ ┌────────────────┐ │
│ • Customer view │ │ │ RAG Service │ │
│ • Worker view │ │ │ (price match) │ │
│ • Live tracking │ │ └────────────────┘ │
│ • Call / WhatsApp │ │ ┌────────────────┐ │
└─────────────────────┘ │ │ Agent Service │ │
│ │ (auto-bid) │ │
│ └────────────────┘ │
└──────────────────────┘

text

---

## 🧠 The Two-Layer AI

| Layer | Role | File |
|---|---|---|
| **RAG** | Matches free-text problem description to a price + category using a keyword-scored knowledge base | `ustad_ji_backend/services/rag_service.py` |
| **Agentic** | Dispatches autonomous bidding agents to nearby workers and ranks bids by price × rating × distance | `ustad_ji_backend/services/agent_service.py` |

---

## 🗂️ Project Structure
ustad_ji/
├── README.md # This file
├── .gitignore
│
├── ustad_ji_backend/ # FastAPI backend
│ ├── main.py
│ ├── requirements.txt
│ ├── models/
│ │ └── schemas.py
│ ├── routers/
│ │ └── jobs.py
│ └── services/
│ ├── rag_service.py # RAG pricing layer
│ └── agent_service.py # Agentic bidding layer
│
└── ustad_ji_app/ # Flutter app
├── pubspec.yaml
└── lib/
├── main.dart
├── theme/
│ └── app_theme.dart
├── models/
│ ├── job_response.dart
│ ├── user_model.dart
│ └── service_category.dart
├── data/
│ └── mock_data.dart
├── state/
│ └── app_state.dart
├── services/
│ ├── api_service.dart
│ ├── auth_service.dart
│ ├── contact_actions.dart
│ └── job_store.dart
├── widgets/
│ ├── gradient_button.dart
│ ├── primary_text_field.dart
│ ├── category_card.dart
│ ├── stat_tile.dart
│ ├── estimate_card.dart
│ ├── job_tile.dart
│ └── ai_thinking_trace.dart
└── screens/
├── splash_screen.dart
├── onboarding_screen.dart
├── profile_screen.dart
├── auth/
│ ├── login_screen.dart
│ └── signup_screen.dart
├── customer/
│ ├── home_screen.dart
│ ├── post_job_screen.dart
│ ├── bookings_screen.dart
│ └── job_tracking_screen.dart
└── worker/
└── worker_dashboard.dart

text

---

## 🚀 Run Locally

### Prerequisites

- Python 3.10+
- Flutter 3.20+
- A modern browser (Chrome recommended)

### Backend

```bash
cd ustad_ji_backend
python -m venv venv
venv\Scripts\activate          # Windows
source venv/bin/activate       # macOS / Linux
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
Then open http://127.0.0.1:8000/docs for the interactive API explorer.

Frontend
bash
cd ustad_ji_app
flutter pub get
flutter run -d chrome
The Flutter app runs in mock mode by default (ApiService.useMock = true), so it works perfectly with no backend running — ideal for demos. To hit the real FastAPI backend, set ApiService.useMock = false in lib/services/api_service.dart.

🧪 Try These (Demo Flow)
Login — Enter any Pakistani number (e.g. 03001234567), tap Send Code, use the OTP shown in the SMS banner.

Post a job — Type AC leaking water and tap Get AI Estimate.

Watch the agent — AI thinking trace animates step-by-step.

See competing bids — 3 workers bid; winner is highlighted.

Confirm Booking — Opens the live tracking screen.

Live map — Worker pin moves toward your location, ETA counts down.

Call / WhatsApp — Opens dialer or WhatsApp with the worker's number.

Worker mode — Log out, sign in as Worker to see the dark dashboard with Auto-Pilot.

🛠️ Tech Stack
Frontend

Flutter 3.35+

flutter_map + OpenStreetMap tiles (no API key required)

geolocator for GPS

google_fonts (Inter)

flutter_animate for transitions

url_launcher for Call / WhatsApp actions

Backend

FastAPI 0.115

Pydantic 2.9

Uvicorn

AI Layer

RAG knowledge base with keyword scoring (127 repair patterns)

Agentic bid engine (rule-based, extensible to LLM)

Maps

OpenStreetMap — free, no API key, no vendor lock-in

🎨 Features
Customer
☑ Onboarding with 3-slide intro
☑ Pakistani phone validation (03XX-XXXXXXX)
☑ Deterministic OTP (demo mode — swap for real SMS easily)
☑ Home screen with 8 service categories
☑ AI price estimate with thinking trace
☑ Multi-worker competing bids
☑ Live map tracking with real device GPS
☑ Call & WhatsApp actions on verified worker number
☑ Rate & review sheet
☑ Booking history (All / Active / Completed tabs)
Worker
☑ Dark theme dashboard
☑ Earnings & bids stats
☑ Auto-Pilot toggle (AI bids automatically)
☑ Live incoming jobs feed
☑ Verified profile with rating
