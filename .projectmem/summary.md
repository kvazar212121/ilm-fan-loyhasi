# projectmem - ilm_fan_loyhasi

_Last updated: 2026-11-25_

## Project purpose
Replace this placeholder with a concise description of what this project does, who it serves, and the main technologies or runtime assumptions.

## Recent issues
- [DONE] #0001 flutter build apk --release failed on :image_picker_android:lintVitalAnalyzeRelease with NoSuchMethodError: java.util.List.removeLast() because JDK 17 was used instead of JDK 21 required by newer Android Lint. [flutter/android (image_picker_android:lintVitalAnalyzeRelease)] (fixed)

## Decisions
- Flutter app: RoleId.teacherMaterials uses dedicated bottom tabs (Darsliklar, Testlar, Reels, Hisobotlar, Profil) without Yangiliklar or Tayyorlov; Sertifikatga tayyorlanish is accessible via a button inside ProfileTabScreen.
- Flutter teacher textbook builder: hierarchical TeacherTextbook -> TextbookSection (Bo'lim) -> TextbookTopic (Mavzu) -> LessonMaterialBlock (Matn, PDF, Video darslik, Ovozli tushuntirish, Rasm, Oraliq test) with sequentialLock and per-topic requireTestPassToUnlockNext + passingScorePercent...
- Ovozli tushuntirish (LessonMaterialType.audio) blocks pair audio with a visual accompaniment (AudioVisualKind.image or AudioVisualKind.gif), selectable via ChoiceChip and ImagePicker gallery or filename.
- Completed all 4 teacherMaterials feature sets: (1) Textbook student preview with live test-lock simulation, class invite code, homework block, maxAttempts/timeLimit rules; (2) Full TestEditorScreen with A/B/C/D, open-answer, matching questions, text/voice solutions, A/B paper variant generator...
- Added Darslik marketplace (TextbookMarketplaceScreen): accessible from ProfileTabScreen for RoleId.teacherMaterials (with publish flow for free/paid textbooks synced from TeacherLessonsScreen) and directly as the 'textbooks' tab for RoleId.student.
- Added textbook comment/Q&A loop (students comment in TextbookStudentPreviewScreen -> synced via MainShell to TeacherReportsScreen where teachers reply) and AI Test Generator from book/PDF/darslik/text in TeacherTestsScreen.
- Split learner login into O'quvchiman -> 3 sub-roles (schoolStudent: Maktab o'quvchisi, student: Abituriyent, universityStudent: Talaba) with multi-subject FanPicker and tailored 5-tab menus per role (including SchoolTasksScreen with invite-code group join).
- Updated TextbookMarketplaceScreen to a 2-column Play Market style card grid (GridView.builder with banner, rating, grade/own badge, action button, and tap-to-open detail bottom sheet) plus live search bar filtering by title, author, subject, or grade.
- Aligned Flutter login flow with backend/src/auth & frontend/components/login: HttpAuthApi (/otp/sms, /otp/verify, /telegram/start, /telegram/poll, /google/start, /registration/inspect, /registration/verify-phone, /register, /logout), PhoneOtpStep, TelegramStep, and ProfileForm with birth_date...
- Pointed Flutter HttpAuthApi default baseUrl to live server https://sat-ilmfan.gvazar.uz/api/auth/* with in-memory cookie jar (ilm_access, ilm_refresh, ilm_reg_token, ilm_tg_attempt) matching the Next.js auth BFF.
- Simplified Flutter mobile onboarding: removed creator/teacherMaterials role from mobile login; after personal details, users pick one of 3 preparation goals: (1) Milliy sertifikatlarga tayyorlov (single subject -> backend role 'teacher'), (2) OTMlarga tayyorlov (multi-subject -> 'student'), (3)...
- Removed Xabarlar (news) tab from all bottom navigation bars and removed Rasmiy xabarlar button from ProfileTabScreen in Flutter app.
- Implemented native in-app Google Sign-In in Flutter using google_sign_in 7.2.0 (GoogleSignInNativeAuth -> POST /api/auth/google/id-token) and added Next.js proxy route frontend/app/api/auth/google/id-token/route.ts forwarding to Go backend /api/v1/auth/google/id-token.

## Notes
- Initial commit: Ilm Fan tayyorlov platformasi.
- Flutter gotcha (SDK 3.14 / material_ui): Never wrap ListTile directly inside a DecoratedBox with a background color; Flutter asserts that ink splashes may be invisible. Use Material(color: Colors.white, shape: RoundedRectangleBorder(...), clipBehavior: Clip.antiAlias, child: ListTile(...)) instead.
- New feature: feat(flutter): o'qituvchi materiallari, darslik marketplace va 3 o'quvchi roli [flutter/android/app/src/main/kotlin/uz/ilm/fan/ilm_fan/MainActivity.kt]

## Key files
- `Next.js`
- `backend/src/entrypoint/http/handlers/health/health_handler.go`
- `frontend/components/profile/MySections.tsx`
- `backend/docker/entrypoint.sh`
- `backend/src/core/domain/ports/wsport/middleware.go`
- `backend/src/infrastructure/db/gormdb.go`
- `backend/.dockerignore`
- `backend/go.mod`
- `backend/src/infrastructure/echohttp/mapper/echo_mapper.go`
- `backend/src/core/application/response/response.go`
- `backend/src/core/domain/ports/payment/payment_provider.go`
- `backend/src/infrastructure/gorillaws/consumer.go`
- `frontend/components/landing/Audiences.tsx`
- `backend/src/infrastructure/gateway/response/.gitkeep`
- `backend/src/core/application/tasks/process_entity_task.go`
- `frontend/app/globals.css`
- `backend/src/infrastructure/file/html_renderer_impl.go`
- `frontend/public/window.svg`
- `backend/migration/versions/prod/.gitkeep`
- `frontend/components/teacher/CourseCreateShell.tsx`

## Open questions
- None logged yet.
