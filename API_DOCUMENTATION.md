# CampusEarn — API Documentation

**Base URL:** `http://127.0.0.1:8000/api`  
**Auth:** JWT Bearer Token — include in every protected request:
```
Authorization: Bearer <access_token>
```

---

## 📑 Table of Contents

1. [Authentication](#1-authentication)
2. [User Profiles](#2-user-profiles)
3. [Jobs](#3-jobs)
4. [Applications](#4-applications)
5. [Chat](#5-chat)
6. [Notifications](#6-notifications)
7. [Error Responses](#7-error-responses)
8. [Data Models](#8-data-models)

---

## 1. Authentication

### POST `/api/auth/register/`
Register a new user account.

**Auth required:** No

**Request Body:**
```json
{
  "email": "student@example.com",
  "password": "securepass123",
  "first_name": "John",
  "last_name": "Doe",
  "role": "STUDENT"
}
```

| Field | Type | Required | Options |
|---|---|---|---|
| `email` | string | ✅ | Valid email |
| `password` | string | ✅ | Min 8 characters |
| `first_name` | string | ✅ | — |
| `last_name` | string | ✅ | — |
| `role` | string | ✅ | `STUDENT`, `EMPLOYER` |

**Response `201 Created`:**
```json
{
  "id": 1,
  "email": "student@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "STUDENT"
}
```

---

### POST `/api/auth/login/`
Login and receive JWT tokens.

**Auth required:** No

**Request Body:**
```json
{
  "email": "student@example.com",
  "password": "securepass123"
}
```

**Response `200 OK`:**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIs...",
  "refresh": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "email": "student@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "STUDENT",
    "student_profile": {
      "university": "MIT",
      "major": "Computer Science",
      "skills": "Python, Flutter",
      "availability": true,
      "bio": "Looking for part-time work"
    },
    "employer_profile": null
  }
}
```

> ⚠️ The `access` token expires in **60 minutes**. Use the `refresh` token to get a new one.

---

### POST `/api/auth/refresh/`
Refresh an expired access token.

**Auth required:** No

**Request Body:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response `200 OK`:**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

### POST `/api/auth/logout/`
Blacklist the refresh token (logout).

**Auth required:** ✅ Yes

**Request Body:**
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response `205 Reset Content`** *(empty body)*

---

## 2. User Profiles

### GET `/api/users/profile/`
Get the currently authenticated user's full profile.

**Auth required:** ✅ Yes  
**Allowed roles:** Any

**Response `200 OK`:**
```json
{
  "id": 1,
  "email": "student@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "STUDENT",
  "student_profile": {
    "university": "MIT",
    "major": "Computer Science",
    "skills": "Python, Flutter, Design",
    "availability": true,
    "bio": "Passionate developer looking for gigs"
  },
  "employer_profile": null
}
```

---

### PATCH `/api/users/student-profile/update/`
Update student profile fields.

**Auth required:** ✅ Yes  
**Allowed roles:** `STUDENT`

**Request Body (all fields optional):**
```json
{
  "university": "MIT",
  "major": "Computer Science",
  "skills": "Python, Flutter, React",
  "availability": true,
  "bio": "Looking for part-time opportunities"
}
```

**Response `200 OK`:**
```json
{
  "university": "MIT",
  "major": "Computer Science",
  "skills": "Python, Flutter, React",
  "availability": true,
  "bio": "Looking for part-time opportunities"
}
```

---

### PATCH `/api/users/employer-profile/update/`
Update employer / business profile fields.

**Auth required:** ✅ Yes  
**Allowed roles:** `EMPLOYER`

**Request Body (all fields optional):**
```json
{
  "company_name": "Acme Corp",
  "company_description": "We build great products",
  "website": "https://acmecorp.com"
}
```

**Response `200 OK`:**
```json
{
  "company_name": "Acme Corp",
  "company_description": "We build great products",
  "website": "https://acmecorp.com",
  "verified": false
}
```

---

## 3. Jobs

### GET `/api/jobs/nearby/`
Get jobs near a given location, filtered by radius.

**Auth required:** ✅ Yes  
**Allowed roles:** Any

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | ✅ | — | Latitude of the user |
| `lng` | float | ✅ | — | Longitude of the user |
| `radius` | float | ❌ | `10` | Search radius in kilometres |

**Example:** `GET /api/jobs/nearby/?lat=19.0760&lng=72.8777&radius=15`

**Response `200 OK`:**
```json
[
  {
    "id": 5,
    "title": "Campus Delivery Helper",
    "description": "Help deliver packages on campus",
    "location_name": "Mumbai University",
    "latitude": 19.0821,
    "longitude": 72.8808,
    "hourly_rate": "250.00",
    "hours_per_week": 10,
    "requirements": "Must have bicycle",
    "employer": 3,
    "employer_name": "Rahul",
    "employer_company": "QuickDeliver",
    "is_active": true,
    "created_at": "2026-04-10T08:30:00Z",
    "updated_at": "2026-04-10T08:30:00Z",
    "distance_km": 0.8
  }
]
```

> ℹ️ Results are sorted by distance ascending. `distance_km` is dynamically computed.

---

### GET `/api/jobs/employer/`
List all jobs posted by the authenticated employer.

**Auth required:** ✅ Yes  
**Allowed roles:** `EMPLOYER`

**Response `200 OK`:** Array of job objects (same schema as above, without `distance_km`).

---

### POST `/api/jobs/employer/`
Create a new job listing.

**Auth required:** ✅ Yes  
**Allowed roles:** `EMPLOYER`

**Request Body:**
```json
{
  "title": "Library Assistant",
  "description": "Help students find books and manage shelves",
  "location_name": "Central Library, Pune",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "hourly_rate": "180.00",
  "hours_per_week": 15,
  "requirements": "Good communication skills"
}
```

| Field | Type | Required |
|---|---|---|
| `title` | string | ✅ |
| `description` | string | ✅ |
| `location_name` | string | ✅ |
| `latitude` | float | ✅ |
| `longitude` | float | ✅ |
| `hourly_rate` | decimal string | ✅ |
| `hours_per_week` | integer | ❌ |
| `requirements` | string | ❌ |

**Response `201 Created`:** Full job object.

---

### GET `/api/jobs/employer/<id>/`
Get a single job by ID (employer only).

**Auth required:** ✅ Yes | **Allowed roles:** `EMPLOYER`

**Response `200 OK`:** Single job object.

---

### PUT/PATCH `/api/jobs/employer/<id>/`
Update an existing job.

**Auth required:** ✅ Yes | **Allowed roles:** `EMPLOYER` (owner only)

**Response `200 OK`:** Updated job object.

---

### DELETE `/api/jobs/employer/<id>/`
Delete a job listing.

**Auth required:** ✅ Yes | **Allowed roles:** `EMPLOYER` (owner only)

**Response `204 No Content`**

---

## 4. Applications

### GET `/api/applications/student/`
List all job applications made by the authenticated student.

**Auth required:** ✅ Yes  
**Allowed roles:** `STUDENT`

**Response `200 OK`:**
```json
[
  {
    "id": 12,
    "job": 5,
    "student": 1,
    "student_name": "John",
    "job_details": {
      "id": 5,
      "title": "Campus Delivery Helper",
      "employer_company": "QuickDeliver",
      ...
    },
    "message": "I am very interested in this role.",
    "status": "ACCEPTED",
    "created_at": "2026-04-11T10:00:00Z",
    "updated_at": "2026-04-12T09:00:00Z"
  }
]
```

---

### POST `/api/applications/student/`
Apply for a job.

**Auth required:** ✅ Yes  
**Allowed roles:** `STUDENT`

**Request Body:**
```json
{
  "job": 5,
  "message": "I have relevant experience and am highly motivated."
}
```

| Field | Type | Required |
|---|---|---|
| `job` | integer (Job ID) | ✅ |
| `message` | string | ❌ |

**Response `201 Created`:** Full application object.

**Error Responses:**
- `403` — Only students can apply
- `400` — `{"error": "Job ID is required."}`
- `400` — `{"error": "You have already applied for this job."}`

---

### GET `/api/applications/student/<id>/`
Get details of a specific application.

**Auth required:** ✅ Yes | **Allowed roles:** `STUDENT` (owner only)

**Response `200 OK`:** Single application object.

---

### GET `/api/applications/employer/`
List all applications received for the employer's jobs.

**Auth required:** ✅ Yes  
**Allowed roles:** `EMPLOYER`

**Response `200 OK`:** Array of application objects (same schema as student view).

---

### PATCH `/api/applications/employer/<id>/decision/`
Accept or reject an application. Automatically sends a notification to the student.

**Auth required:** ✅ Yes  
**Allowed roles:** `EMPLOYER` (job owner only)

**Request Body:**
```json
{
  "status": "ACCEPTED"
}
```

| Field | Value options |
|---|---|
| `status` | `ACCEPTED` or `REJECTED` |

**Response `200 OK`:** Updated application object.

**Error Responses:**
- `400` — `{"error": "Invalid status. Must be 'ACCEPTED' or 'REJECTED'."}`
- `404` — Application not found or not owned by this employer

> 🔔 A notification is automatically created for the student upon accept/reject.

---

## 5. Chat

> ⚠️ **Chat is only available when the application status is `ACCEPTED`.**  
> Both the student and employer of that specific application are permitted.

---

### GET `/api/chat/<app_id>/`
Retrieve all messages for a given application's chat.

**Auth required:** ✅ Yes  
**Allowed roles:** Student or Employer for that application

**URL Parameter:** `app_id` — The Application ID

**Response `200 OK`:**
```json
[
  {
    "id": 1,
    "application": 12,
    "sender": 1,
    "sender_name": "John",
    "sender_email": "student@example.com",
    "message": "Hello! I'm available to start Monday.",
    "is_read": true,
    "created_at": "2026-04-12T09:15:00Z"
  },
  {
    "id": 2,
    "application": 12,
    "sender": 3,
    "sender_name": "Rahul",
    "sender_email": "employer@example.com",
    "message": "Great! Please come in at 9 AM.",
    "is_read": false,
    "created_at": "2026-04-12T09:20:00Z"
  }
]
```

---

### POST `/api/chat/<app_id>/`
Send a message in a chat.

**Auth required:** ✅ Yes  
**Allowed roles:** Student or Employer for that application (status must be `ACCEPTED`)

**URL Parameter:** `app_id` — The Application ID

**Request Body:**
```json
{
  "message": "Hello! When should I start?"
}
```

**Response `201 Created`:**
```json
{
  "id": 3,
  "application": 12,
  "sender": 1,
  "sender_name": "John",
  "sender_email": "student@example.com",
  "message": "Hello! When should I start?",
  "is_read": false,
  "created_at": "2026-04-12T09:30:00Z"
}
```

**Error Responses:**
- `400` — `{"error": "Chat is only available for accepted applications."}`
- `403` — `{"error": "You do not have permission to send a message in this application."}`

---

### PATCH `/api/chat/message/<id>/read/`
Mark a message as read.

**Auth required:** ✅ Yes  
**Note:** Can only mark messages **sent by someone else** as read.

**Response `200 OK`:** Updated message object with `"is_read": true`.

---

## 6. Notifications

### GET `/api/notifications/`
List all notifications for the authenticated user.

**Auth required:** ✅ Yes

**Response `200 OK`:**
```json
[
  {
    "id": 7,
    "user": 1,
    "message": "Your application for 'Campus Delivery Helper' has been accepted.",
    "is_read": false,
    "created_at": "2026-04-12T09:00:00Z"
  }
]
```

---

### PATCH `/api/notifications/<id>/read/`
Mark a notification as read.

**Auth required:** ✅ Yes

**Response `200 OK`:**
```json
{
  "id": 7,
  "user": 1,
  "message": "Your application for 'Campus Delivery Helper' has been accepted.",
  "is_read": true,
  "created_at": "2026-04-12T09:00:00Z"
}
```

---

## 7. Error Responses

All endpoints follow a consistent error format:

| HTTP Code | Meaning | Example |
|---|---|---|
| `400 Bad Request` | Validation error or bad input | `{"field": ["This field is required."]}` |
| `401 Unauthorized` | Missing or invalid token | `{"detail": "Authentication credentials were not provided."}` |
| `403 Forbidden` | Valid token but wrong role/ownership | `{"error": "Only students can apply for jobs."}` |
| `404 Not Found` | Resource does not exist | `{"detail": "Not found."}` |
| `500 Internal Server Error` | Unexpected server error | — |

---

## 8. Data Models

### User
| Field | Type | Notes |
|---|---|---|
| `id` | integer | Auto-generated PK |
| `email` | string | Unique, used as login |
| `first_name` | string | — |
| `last_name` | string | — |
| `role` | enum | `STUDENT`, `EMPLOYER`, `ADMIN` |

### StudentProfile
| Field | Type | Notes |
|---|---|---|
| `university` | string | Optional |
| `major` | string | Optional |
| `skills` | string | Comma-separated |
| `availability` | boolean | Visible to employers |
| `bio` | string | Optional |

### EmployerProfile
| Field | Type | Notes |
|---|---|---|
| `company_name` | string | Optional |
| `company_description` | string | Optional |
| `website` | string | Optional URL |
| `verified` | boolean | Set by admin |

### Job
| Field | Type | Notes |
|---|---|---|
| `id` | integer | Auto PK |
| `title` | string | — |
| `description` | string | — |
| `location_name` | string | Human-readable |
| `latitude` | float | — |
| `longitude` | float | — |
| `hourly_rate` | decimal | In local currency |
| `hours_per_week` | integer | Optional |
| `requirements` | string | Optional |
| `employer` | FK → User | Set by server |
| `is_active` | boolean | Set by server |
| `distance_km` | float | Dynamic, nearby only |

### Application
| Field | Type | Notes |
|---|---|---|
| `id` | integer | Auto PK |
| `job` | FK → Job | — |
| `student` | FK → User | Set by server |
| `message` | string | Optional cover note |
| `status` | enum | `APPLIED`, `ACCEPTED`, `REJECTED` |
| `created_at` | datetime | — |
| `updated_at` | datetime | — |

### ChatMessage
| Field | Type | Notes |
|---|---|---|
| `id` | integer | Auto PK |
| `application` | FK → Application | Set by server |
| `sender` | FK → User | Set by server |
| `message` | string | The message text |
| `is_read` | boolean | Default: `false` |
| `created_at` | datetime | — |

### Notification
| Field | Type | Notes |
|---|---|---|
| `id` | integer | Auto PK |
| `user` | FK → User | Recipient |
| `message` | string | Notification text |
| `is_read` | boolean | Default: `false` |
| `created_at` | datetime | — |

---

## 🔧 Testing with cURL

### Register
```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mail.com","password":"pass1234","first_name":"Test","last_name":"User","role":"STUDENT"}'
```

### Login
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mail.com","password":"pass1234"}'
```

### Get Nearby Jobs
```bash
curl -X GET "http://127.0.0.1:8000/api/jobs/nearby/?lat=19.07&lng=72.87&radius=20" \
  -H "Authorization: Bearer <your_access_token>"
```

### Apply for Job
```bash
curl -X POST http://127.0.0.1:8000/api/applications/student/ \
  -H "Authorization: Bearer <your_access_token>" \
  -H "Content-Type: application/json" \
  -d '{"job":5,"message":"I am a great fit for this role."}'
```

### Send Chat Message
```bash
curl -X POST http://127.0.0.1:8000/api/chat/12/ \
  -H "Authorization: Bearer <your_access_token>" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello! Looking forward to working with you."}'
```

---

*CampusEarn API v1.0 — © 2026 Shahid Momin*
