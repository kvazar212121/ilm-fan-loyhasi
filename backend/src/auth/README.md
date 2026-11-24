# `backend/src/auth` — Autentifikatsiya moduli

`backend/src/auth/` — Ilm Fan platformasining mustaqil, modulli autentifikatsiya paketi (Web Next.js + Mobile Flutter uchun).

## Kirish usullari
1. **Telefon raqam (SMS OTP)** — `POST /api/v1/auth/otp/sms` → `POST /api/v1/auth/otp/verify`
   - `SMS_PROVIDER=log` (default, local dev): 4 xonali OTP kodni konsol logiga chiqaradi.
   - `SMS_PROVIDER=etc`: `sms.etc.uz` (`/single-sms`) orqali haqiqiy SMS yuboradi.
   - Cheklovlar: 2 daqiqa TTL, 3 ta urinish, 60 soniya qayta yuborish pauzasi, kuniga 5 ta SMS.
2. **Google (telefon raqam majburiy EMAS)**
   - Web (OAuth 2.0 + PKCE `S256`): `POST /api/v1/auth/google/start` → `POST /api/v1/auth/google/callback`
   - Flutter / Mobile (native Google Sign-In): `POST /api/v1/auth/google/id-token`
3. **Telegram Bot**
   - `POST /api/v1/auth/telegram/start` → `deep_link` (`https://t.me/<bot>?start=<token>`)
   - Foydalanuvchi botda telefon raqamini yuboradi va **✅ Tasdiqlash** tugmasini bosadi (`cmd/telegram-bot`)
   - Client `POST /api/v1/auth/telegram/poll` bilan holatni tekshiradi.

## Ro‘yxatdan o‘tish va sessiya endpoint’lari
- `POST /api/v1/auth/registration/inspect` — profil formasi uchun oldindan to‘ldiriladigan ma’lumotlar
- `POST /api/v1/auth/register` — `registration_token` + `role` + `fan_ids` + `first_name` + `last_name` + `avatar_url`
  - Qabul qilinadigan rollar: `teacher` (`cert-teacher`), `teacherMaterials` (`guide-teacher`), `student` (`applicant`), `schoolStudent` (`pupil`), `universityStudent`
- `POST /api/v1/auth/refresh` — Refresh tokenni aylantirish (rotation) va yangi Access JWT olish
- `POST /api/v1/auth/logout` — Sessiyani bekor qilish (Bearer token)
- `GET /api/v1/auth/me` — Joriy foydalanuvchi va ulangan kirish usullari (Bearer token)

## Telegram botni ishga tushirish
`TELEGRAM_BOT_TOKEN` va `TELEGRAM_BOT_USERNAME` ni `.env` ga yozib:
```bash
cd backend/docker
docker compose --profile telegram up --build -d
```
