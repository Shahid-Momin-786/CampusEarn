# CampusEarn 🎓💼

> A hyperlocal student job marketplace that connects students with nearby employers for part-time, campus, and gig work.

---

## 📌 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Screenshots](#screenshots)
- [Roles & Permissions](#roles--permissions)
- [Author](#author)

---

## Overview

**CampusEarn** is a full-stack mobile/web application built to bridge the gap between students seeking flexible work opportunities and local employers looking for affordable short-term talent. Students can discover nearby jobs, apply with a single tap, track their application status in real time, and chat directly with employers after being accepted — all within a clean, modern interface.

---

## ✅ Features

### Student
| Feature | Description |
|---|---|
| 🔐 Register / Login | JWT-based authentication |
| 🗺️ Browse Jobs | Haversine-based geo-filtered job feed |
| ✅ Apply for Job | One-tap application with optional message |
| 📋 Track Applications | View APPLIED / ACCEPTED / REJECTED status |
| 💬 Live Chat | Chat with employer after application is accepted |
| 🔔 Notifications | In-app alerts when application status changes |
| 👤 Edit Profile | Update university, major, skills, bio, availability |

### Employer
| Feature | Description |
|---|---|
| 🔐 Register / Login | JWT-based authentication |
| 📝 Post Jobs | Create job listings with location, pay, requirements |
| 👥 View Applicants | Review all applicants for posted jobs |
| ✅ Accept / Reject | Accept or reject with a single tap |
| 💬 Live Chat | Chat with accepted students |
| 🔔 Notifications | Badge icon with unread message counter |
| 🏢 Business Profile | Manage company name, description, website |

### Admin
| Feature | Description |
|---|---|
| 🔐 Admin Login | Superuser access |
| 📊 Overview | Platform-wide stats |
| ✅ Verification | Review and verify employer accounts |
| 👥 User Management | View and manage all users |
| 🚩 Reports | Handle flagged content |

---

## 🛠️ Tech Stack

### Backend
| Technology | Purpose |
|---|---|
| **Python 3.11+** | Core language |
| **Django 4.x** | Web framework |
| **Django REST Framework** | REST API layer |
| **SimpleJWT** | JWT authentication |
| **SQLite** (dev) / **PostgreSQL** (prod) | Database |
| **Haversine formula** | Distance-based job filtering |

### Frontend
| Technology | Purpose |
|---|---|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Provider** | State management |
| **Dio** | HTTP client |
| **flutter_secure_storage** | Secure JWT token storage |
| **Google Fonts** | Typography (Inter, Outfit) |

---

## 📁 Project Structure

```
CampusEarn/
├── backend/                   # Django REST API
│   ├── users/                 # Auth, Student & Employer profiles
│   ├── jobs/                  # Job listings, geo-filtering
│   ├── applications/          # Job applications, Accept/Reject
│   ├── chat/                  # Real-time messaging (polling)
│   ├── notifications/         # In-app notification system
│   └── campusearn/            # Django settings & root URLs
│
└── frontend/                  # Flutter application
    └── lib/
        ├── core/              # Theme, API config
        ├── models/            # Data models (User, Job, Application, Chat...)
        ├── services/          # API service classes
        ├── providers/         # State management (Auth, Job, App, Chat, Notif)
        └── screens/
            ├── auth/          # Login & Register screens
            ├── student/       # Student dashboard + 4 tabs
            ├── employer/      # Employer dashboard + 4 tabs
            ├── admin/         # Admin dashboard + 5 tabs
            ├── chat/          # Chat detail screen
            └── notifications/ # Notifications screen
```

---

## 🚀 Getting Started

### Prerequisites

- Python 3.11+
- Flutter 3.x & Dart SDK
- pip & virtualenv

---

### Backend Setup

```bash
# 1. Navigate to backend
cd CampusEarn/backend

# 2. Create & activate virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # macOS/Linux

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run migrations
python manage.py migrate

# 5. Create a superuser (admin)
python manage.py createsuperuser

# 6. (Optional) Seed sample jobs
python manage.py shell < seed_jobs.py

# 7. Start the development server
python manage.py runserver
```

> Backend runs at: `http://127.0.0.1:8000`  
> Admin panel: `http://127.0.0.1:8000/admin`

---

### Frontend Setup

```bash
# 1. Navigate to frontend
cd CampusEarn/frontend

# 2. Install Flutter dependencies
flutter pub get

# 3. Run on Chrome (Web)
flutter run -d chrome --web-port 8080

# 4. Run on Android emulator / device
flutter run -d android
```

> Make sure the backend is running before launching the Flutter app.

---

## 🔌 API Reference

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/register/` | Register a new user |
| `POST` | `/api/auth/login/` | Login and get JWT tokens |
| `POST` | `/api/auth/refresh/` | Refresh access token |
| `POST` | `/api/auth/logout/` | Blacklist refresh token |

### User Profile
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/users/profile/` | Get current user profile |
| `PATCH` | `/api/users/student-profile/update/` | Update student profile |
| `PATCH` | `/api/users/employer-profile/update/` | Update employer profile |

### Jobs
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/jobs/?lat=&lng=&radius=` | Get nearby jobs |
| `POST` | `/api/jobs/create/` | Create a job (employer only) |
| `GET` | `/api/jobs/employer/` | Get employer's posted jobs |

### Applications
| Method | Endpoint | Description |
|---|---|---|
| `GET/POST` | `/api/applications/student/` | Student: view or apply |
| `GET` | `/api/applications/employer/` | Employer: view all applicants |
| `PATCH` | `/api/applications/<id>/decision/` | Accept or reject application |

### Chat
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/chat/<app_id>/` | Get messages for an application |
| `POST` | `/api/chat/<app_id>/` | Send a message (ACCEPTED only) |

### Notifications
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/notifications/` | Get all notifications |
| `PATCH` | `/api/notifications/<id>/read/` | Mark notification as read |

---

## 👥 Roles & Permissions

| Action | Student | Employer | Admin |
|---|:---:|:---:|:---:|
| Browse jobs | ✅ | ✅ | ✅ |
| Apply for job | ✅ | ❌ | ❌ |
| Post job | ❌ | ✅ | ❌ |
| Accept/Reject applicants | ❌ | ✅ | ❌ |
| Chat (after ACCEPTED) | ✅ | ✅ | ❌ |
| Manage all users | ❌ | ❌ | ✅ |
| Django admin panel | ❌ | ❌ | ✅ |

---

## 🔒 Security

- JWT tokens stored in `flutter_secure_storage` (encrypted on device)
- All API endpoints require authentication (`IsAuthenticated`)
- Chat is restricted to the specific employer and student of an **ACCEPTED** application
- Token blacklisting on logout via `djangorestframework-simplejwt`

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#6B4EFF` (Purple) |
| Secondary | `#03DAC6` (Teal) |
| Background | `#0F172A` (Dark Navy) |
| Surface | `#1E293B` |
| Success | `#10B981` |
| Error | `#EF4444` |
| Font | Inter (body), Outfit (headings) |

---

## 👤 Author

**Shahid Momin**  
Full Stack Developer | Flutter & Django  
📧 Available for collaboration

---

## 📄 License

This project is built as a portfolio/demonstration project.  
All rights reserved © 2026 CampusEarn.
