# projectmem - ilm_fan_loyhasi

_Last updated: 2026-11-23_

## Project purpose
Replace this placeholder with a concise description of what this project does, who it serves, and the main technologies or runtime assumptions.

## Recent issues
- No issues logged yet.

## Decisions
- Flutter app: RoleId.teacherMaterials uses dedicated bottom tabs (Darsliklar, Testlar, Reels, Hisobotlar, Profil) without Yangiliklar or Tayyorlov; Sertifikatga tayyorlanish is accessible via a button inside ProfileTabScreen.
- Flutter teacher textbook builder: hierarchical TeacherTextbook -> TextbookSection (Bo'lim) -> TextbookTopic (Mavzu) -> LessonMaterialBlock (Matn, PDF, Video darslik, Ovozli tushuntirish, Rasm, Oraliq test) with sequentialLock and per-topic requireTestPassToUnlockNext + passingScorePercent...
- Ovozli tushuntirish (LessonMaterialType.audio) blocks pair audio with a visual accompaniment (AudioVisualKind.image or AudioVisualKind.gif), selectable via ChoiceChip and ImagePicker gallery or filename.
- Completed all 4 teacherMaterials feature sets: (1) Textbook student preview with live test-lock simulation, class invite code, homework block, maxAttempts/timeLimit rules; (2) Full TestEditorScreen with A/B/C/D, open-answer, matching questions, text/voice solutions, A/B paper variant generator...
- Added Darslik marketplace (TextbookMarketplaceScreen): accessible from ProfileTabScreen for RoleId.teacherMaterials (with publish flow for free/paid textbooks synced from TeacherLessonsScreen) and directly as the 'textbooks' tab for RoleId.student.
- Added textbook comment/Q&A loop (students comment in TextbookStudentPreviewScreen -> synced via MainShell to TeacherReportsScreen where teachers reply) and AI Test Generator from book/PDF/darslik/text in TeacherTestsScreen.
- Split learner login into O'quvchiman -> 3 sub-roles (schoolStudent: Maktab o'quvchisi, student: Abituriyent, universityStudent: Talaba) with multi-subject FanPicker and tailored 5-tab menus per role (including SchoolTasksScreen with invite-code group join).
- Updated TextbookMarketplaceScreen to a 2-column Play Market style card grid (GridView.builder with banner, rating, grade/own badge, action button, and tap-to-open detail bottom sheet) plus live search bar filtering by title, author, subject, or grade.

## Notes
- Initial commit: Ilm Fan tayyorlov platformasi.
- Flutter gotcha (SDK 3.14 / material_ui): Never wrap ListTile directly inside a DecoratedBox with a background color; Flutter asserts that ink splashes may be invisible. Use Material(color: Colors.white, shape: RoundedRectangleBorder(...), clipBehavior: Clip.antiAlias, child: ListTile(...)) instead.

## Key files
- `frontend/app/tests/page.tsx`
- `frontend/app/textbooks/page.tsx`
- `backend/src/infrastructure/docs/swagger.yaml`
- `frontend/app/reels/page.tsx`
- `backend/go.sum`
- `frontend/app/page.tsx`
- `backend/src/entrypoint/http/interceptor/middlewares/jwt_auth_middleware.go`
- `frontend/app/tayyorlovlar/page.tsx`
- `frontend/components/landing/Hero.tsx`
- `backend/src/infrastructure/asyncq/asyncq.go`
- `backend/src/entrypoint/http/interceptor/wsmiddlewares/.gitkeep`
- `frontend/components/teacher/TeacherPageHeader.tsx`
- `backend/src/entrypoint/http/interceptor/permissions/authenticated_user_permission.go`
- `frontend/app/courses/page.tsx`
- `backend/src/infrastructure/asyncq/context_impl.go`
- `frontend/components/reels/ReelRules.tsx`
- `backend/src/infrastructure/db/database.go`
- `frontend/components/tayyorlov/tayyorlov-fans.ts`
- `backend/src/infrastructure/docs/swagger.json`
- `backend/src/infrastructure/persistence/models/user_model.go`

## Open questions
- None logged yet.
