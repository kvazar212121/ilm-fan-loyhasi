# projectmem - ilm-fan-loyhasi

_Last updated: 2026-11-24_

## Project purpose
Replace this placeholder with a concise description of what this project does, who it serves, and the main technologies or runtime assumptions.

## Recent issues
- [DONE] #0002 QR login via Telegram on mobile stalls at 'Telefon ulandi — tasdiqlash kutilmoqda' because mobile browser suspends JS polling when user switches to Telegram app to tap Tasdiqlash; backend PollQRLogin does not inspect the linked TelegramLoginAttempt directly. [backend/src/auth/service/auth_service_qr.go + frontend/components/login/QrApproveFlow.tsx] (fixed)
- [DONE] #0001 skeleton-redis fails with FATAL CONFIG FILE ERROR requirepass wrong number of arguments when docker compose runs without --env-file ../.env [backend/docker/docker-compose.yml] (fixed)

## Decisions
- Build modular auth package in backend/src/auth/ adapting integrum-inc/id-backend patterns: Phone SMS OTP (etc.uz + local log), Telegram Bot deep-link/poll, Google OAuth PKCE + mobile ID token (phone optional for Google), registration tickets, JWT access+refresh sessions. [backend/src/auth/]
- Verified account linking (Google OAuth, Telegram bot confirmation, or SMS OTP) automatically merges duplicate accounts into the existing owner account in a single DB transaction, transferring identities/sessions, clearing unique fields on soft-deleted duplicate, and issuing fresh tokens. [backend/src/auth/service/auth_service_link.go]
- Added Steam-style browser QR code login (/login -> QR kod orqali kirish -> mobile browser /login/qr/[token]). Desktop receives a single-use 3-minute QR challenge (token in QR URL, secret poll token stored exclusively in desktop HttpOnly cookie ilm_qr_attempt). Mobile browser scan notifies...
- Added devsms.uz SMS provider (SMS_PROVIDER=devsms, POST <DEVSMS_BASE_URL>/send_sms.php with Bearer token and sender 4546) plus optional SMS_OTP_TEMPLATE override ({code}) alongside existing etc and log providers. Temporarily configured backend/.env with hubservis devsms settings and moderated...

## Notes
- No notes logged yet.

## Key files
- `backend/docker/docker-compose.yml`
- `backend/src/auth/`
- `../.env`
- `docker-compose.yml`
- `./../.env`
- `backend/src/auth/service/auth_service_link.go`
- `backend/src/auth/service/auth_service_qr.go + frontend/components/login/QrApproveFlow.tsx`
- `backend/.env`
- `/send_sms.php`

## Open questions
- None logged yet.
