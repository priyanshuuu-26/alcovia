## 🔌 API Integration Guide

Backend engineer should update only: /lib/api/api_service.dart

Functions to implement:
1. login(email, password)
2. getStudentStatus(studentId)
3. submitDailyCheckin(studentId, score, minutes)
4. markTaskComplete(studentId)

### Expected JSON responses
Login:
{ "token": "", "student_id": "", "name": "" }

Student Status:
{ "state": "normal" | "locked" | "remedial", "task": "string|null" }

Daily Check-in:
{ "status": "", "student_state": "" }

### ⚠️ Required headers
Authorization: Bearer <token>
Content-Type: application/json
