# CampusEarn: Hyperlocal Student Job Marketplace

## Overview

A production-ready, full-stack platform where students find part-time jobs near their campus, employers post and manage listings, and admins oversee everything. Built with Django (backend) + Flutter (frontend).

---

## Project Architecture

```
CampsEarn/
├── backend/               ← Django Project
│   ├── campusearn/        ← Core Django Settings
│   ├── users/             ← Custom User + Auth
│   ├── jobs/              ← Job Listings
│   ├── applications/      ← Job Applications
│   ├── chat/              ← Messaging System
│   ├── ratings/           ← Rating System
│   ├── notifications/     ← Notification System
│   ├── requirements.txt
│   └── manage.py
└── frontend/              ← Flutter App
    ├── lib/
    │   ├── screens/
    │   ├── providers/
    │   ├── models/
    │   ├── services/
    │   └── widgets/
    └── pubspec.yaml
```

---

## Development Phases

### Phase 1 (NOW): Django Setup + Custom User + JWT Auth
- Django project init + PostgreSQL config
- Custom User model with roles (Student, Employer, Admin)
- StudentProfile + EmployerProfile models
- JWT auth endpoints: Register, Login, Logout, Token Refresh
- Role-based permissions

### Phase 2: Jobs + Applications System
- Job model with location fields (lat/lng)
- Application model with status tracking
- CRUD APIs for jobs and applications
- Haversine-based nearby job filtering

### Phase 3: Chat + Notifications
- ChatMessage model (tied to accepted applications)
- REST-based send/fetch message APIs
- Notification model and basic triggers

### Phase 4: Flutter Frontend
- Provider-based state management
- Dio for API integration
- All screens: Login, Dashboard, Jobs, Chat, Profile, Map

### Phase 5: Google Maps + Testing
- Google Maps integration in Flutter
- Backend: return lat/lng with jobs
- Testing auth flows + API edge cases

---

## Step 1 - Detailed Implementation

### Django Apps to Create
- `users` — Custom User (email-based login), StudentProfile, EmployerProfile

### Key Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| Auth backend | Simple JWT | No third-party dependency, full control |
| User model | AbstractBaseUser | Full control over fields |
| Login field | Email (not username) | Modern UX standard |
| Roles | CharField choices | Simple, no extra table needed |
| Password hashing | Django built-in | Secure, PBKDF2 by default |

### Files to Create (Step 1)

#### Backend Setup
- `backend/requirements.txt`
- `backend/campusearn/settings.py`
- `backend/campusearn/urls.py`

#### Users App
- `backend/users/models.py` — CustomUser, StudentProfile, EmployerProfile
- `backend/users/serializers.py` — Register, Login, Profile serializers
- `backend/users/views.py` — Auth views
- `backend/users/urls.py` — URL routing
- `backend/users/permissions.py` — Role-based permissions
- `backend/users/admin.py` — Admin registration

---

## Verification Plan

### Automated
- Run `python manage.py check` — ensure no model errors
- Run `python manage.py makemigrations && migrate` — DB tables created
- Test endpoints via curl or Postman

### Manual API Tests
```
POST /api/auth/register/   → 201 Created
POST /api/auth/login/      → 200 + tokens
POST /api/auth/refresh/    → 200 + new access token
POST /api/auth/logout/     → 200 (blacklist token)
GET  /api/users/profile/   → 200 (protected, JWT required)
```
