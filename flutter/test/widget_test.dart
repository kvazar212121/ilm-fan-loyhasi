import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ilm_fan/app/ilm_fan_app.dart';
import 'package:ilm_fan/data/app_tabs.dart';
import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/uzbmb_news.dart';
import 'package:ilm_fan/features/courses/courses_screen.dart';
import 'package:ilm_fan/features/news/news_screen.dart';
import 'package:ilm_fan/features/preparation/preparation_home_screen.dart';
import 'package:ilm_fan/features/shell/main_shell.dart';
import 'package:ilm_fan/features/tests/test_section_screen.dart';
import 'package:ilm_fan/models/user_profile.dart';

void main() {
  testWidgets('Kirish usuli roldan oldin ko‘rsatiladi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const IlmFanApp());

    expect(find.text('Kirish'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('1-QADAM'), findsNothing);
    expect(find.textContaining('Avval kirish usulini tanlang'), findsNothing);
    expect(find.text('Kim sifatida kirasiz?'), findsNothing);

    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();

    expect(find.text('Maqsadingiz nima?'), findsOneWidget);
    expect(find.text('Kim sifatida kirasiz?'), findsNothing);
    expect(find.text('Kirish usuliga'), findsNothing);
    expect(find.text('2-QADAM'), findsNothing);
    expect(find.text('O‘qituvchiman'), findsNWidgets(2));
    expect(find.text('O‘quvchiman'), findsOneWidget);

    await tester.tap(
      find.text('O‘quvchilarim uchun o‘quv materiallari yarataman'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Material yaratadigan faningizni tanlang.'),
      findsOneWidget,
    );
  });

  testWidgets('Mashq javobni tushuntiradi va xatoni saqlaydi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestSectionScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.student,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 ta'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('startPractice')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('startPractice')));
    await tester.pumpAndSettle();

    expect(find.text('12 × 8 nechaga teng?'), findsOneWidget);
    await tester.tap(find.text('80'));
    await tester.pumpAndSettle();

    expect(find.text('Bu safar adashdingiz'), findsOneWidget);
    expect(find.text('To‘g‘ri javob: 96'), findsOneWidget);
    expect(find.text('Yechimi'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('nextQuestion')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nextQuestion')));
    await tester.pumpAndSettle();
    expect(find.text('Test natijasi'), findsOneWidget);

    await tester.ensureVisible(find.text('Xatolarimni ko‘rish · 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xatolarimni ko‘rish · 1'));
    await tester.pumpAndSettle();
    expect(find.text('Xatolarim · 1'), findsOneWidget);
    expect(find.text('12 × 8 nechaga teng?'), findsOneWidget);
  });

  testWidgets('Reyting va bellashuv bo‘limlari ochiladi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestSectionScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.student,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bellashuv'));
    await tester.pumpAndSettle();
    expect(find.text('Tezkor bellashuv'), findsOneWidget);
    expect(find.text('10 soniyalik demo bellashuv'), findsOneWidget);

    await tester.tap(find.text('Reyting'));
    await tester.pumpAndSettle();
    expect(find.text('Haftalik reytingi'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
  });

  testWidgets('Sertifikat fani barcha test bo‘limlarida saqlanadi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestSectionScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.teacher,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sertifikat fani'), findsOneWidget);
    expect(find.text('Matematika'), findsOneWidget);
    expect(find.text('Fizika'), findsNothing);

    await tester.tap(find.text('Bellashuv'));
    await tester.pumpAndSettle();
    expect(find.text('Sertifikat fani'), findsOneWidget);
    expect(find.text('Fizika'), findsNothing);

    await tester.tap(find.text('Reyting'));
    await tester.pumpAndSettle();
    expect(find.text('Sertifikat fani'), findsOneWidget);
    expect(find.text('Fizika'), findsNothing);
  });

  testWidgets('Savoli yo‘q tanlangan fan uchun boshqa fan chiqmaydi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TestSectionScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.teacher,
              subjectFanId: 'kimyo',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kimyo testlari hali qo‘shilmagan'), findsOneWidget);
    expect(find.text('Fizika'), findsNothing);
    expect(find.text('12 × 8 nechaga teng?'), findsNothing);
    expect(
      find.text('Avtomobil 2 soatda 120 km yurdi. O‘rtacha tezligi qancha?'),
      findsNothing,
    );
  });

  testWidgets('Tayyorlov tanlangan fan darsini ochib, testga yo‘naltiradi', (
    WidgetTester tester,
  ) async {
    var openedTests = false;
    var openedCourses = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreparationHomeScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.teacher,
              subjectFanId: 'matematika',
            ),
            onOpenTests: () => openedTests = true,
            onOpenCourses: () => openedCourses = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Matematika'), findsOneWidget);
    expect(find.text('Arifmetika'), findsOneWidget);
    expect(find.text('Kinematika'), findsNothing);
    expect(find.text('0/4 dars'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('lesson-math-arithmetic')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lesson-math-arithmetic')));
    await tester.pumpAndSettle();
    expect(find.text('Asosiy tushuncha'), findsOneWidget);
    expect(find.text('80 ning 25 foizi: 80 × 25 ÷ 100 = 20.'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('practice-math-arithmetic')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-math-arithmetic')));
    await tester.pumpAndSettle();
    expect(openedTests, isTrue);

    await tester.tap(find.byKey(const ValueKey('lesson-math-arithmetic')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('finish-math-arithmetic')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('finish-math-arithmetic')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text('1/4 dars'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('openCourseCatalog')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('openCourseCatalog')));
    expect(openedCourses, isTrue);
  });

  testWidgets('Tayyorlovda boshqa fan materiali aralashtirilmaydi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreparationHomeScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.teacher,
              subjectFanId: 'kimyo',
            ),
            onOpenTests: _doNothing,
            onOpenCourses: _doNothing,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kimyo'), findsOneWidget);
    expect(find.text('Kimyo darslari tayyorlanmoqda'), findsOneWidget);
    expect(find.text('Matematika'), findsNothing);
    expect(find.text('Fizika'), findsNothing);
    expect(find.text('Arifmetika'), findsNothing);
  });

  testWidgets('Kursga tanishuv, qo‘shilish va progress ishlaydi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoursesScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.teacher,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Matematika attestatsiyasiga tayyorlov'), findsOneWidget);
    expect(find.text('Fizika attestatsiyasiga tayyorlov'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('course-math-attestation-demo')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('course-math-attestation-demo')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('course-action-math-attestation-demo')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Bepul tanishuv darsi'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Bepul tanishuv darsi'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('course-action-math-attestation-demo')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Davom etish'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('preview-math-attestation-demo')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('preview-math-attestation-demo')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dars mazmuni'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('course-lesson-action-math-att-intro')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('course-lesson-action-math-att-intro')),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 1000),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Kurslar ro‘yxatiga qaytish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mening kurslarim'));
    await tester.pumpAndSettle();
    expect(find.text('1/7 dars tugallangan'), findsOneWidget);
  });

  testWidgets('Kurslar faqat tanlangan fanga tegishli bo‘ladi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoursesScreen(
            profile: const UserProfile(
              firstName: 'Ali',
              lastName: 'Valiyev',
              role: RoleId.teacher,
              subjectFanId: 'kimyo',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kimyo'), findsOneWidget);
    expect(find.text('Kimyo kurslari tayyorlanmoqda'), findsOneWidget);
    expect(find.text('Matematika attestatsiyasiga tayyorlov'), findsNothing);
    expect(find.text('Fizika attestatsiyasiga tayyorlov'), findsNothing);
  });

  test('UZBMB sahifasidan rasmiy yangilik yozuvlari ajratiladi', () {
    final article = jsonEncode({
      'id': 250678,
      'category_id': 1545,
      'date': '2026-11-20 21:45:00',
      'title': 'Milliy sertifikat imtihoni bölib ötdi',
      'anons': 'Matematika oçiq va yoşlar uchun.',
      'views': 52,
      'anons_image': 'https://api-portal.gov.uz/image.jpg',
      'category_title': 'Yangiliklar',
    });
    final flightPayload = '6:["\$","\$f",null,{"data":{"data":[$article]}}]';
    final pageHtml =
        '<script>self.__next_f.push([1,${jsonEncode(flightPayload)}])</script>';

    final items = UzbmbNewsRepository.parsePage(pageHtml);

    expect(items, hasLength(1));
    expect(items.single.id, 250678);
    expect(items.single.title, contains('Milliy sertifikat'));
    expect(items.single.title, contains('bo‘lib o‘tdi'));
    expect(items.single.summary, contains('Matematika ochiq va yoshlar'));
    expect(items.single.sourceUri.toString(), contains('/news/view/250678'));
  });

  testWidgets(
    'Xabarlar tanlangan fan va umumiy sertifikat e’lonlarinigina ko‘rsatadi',
    (WidgetTester tester) async {
      final articles = [
        UzbmbNewsItem(
          id: 10,
          title: 'Matematika bo‘yicha milliy sertifikat natijalari',
          summary: 'Matematika fanidan test natijalari e’lon qilindi.',
          publishedAt: DateTime(2026, 11, 20),
          category: 'Yangiliklar',
          views: 20,
        ),
        UzbmbNewsItem(
          id: 11,
          title: 'Milliy sertifikatga ro‘yxatdan o‘tish boshlandi',
          summary: 'Barcha talabgorlar ro‘yxatdan o‘tishi mumkin.',
          publishedAt: DateTime(2026, 11, 19),
          category: 'Yangiliklar',
          views: 10,
        ),
        UzbmbNewsItem(
          id: 12,
          title: 'Fizika bo‘yicha milliy sertifikat imtihoni',
          summary: 'Fizika fanidan imtihon sanasi e’lon qilindi.',
          publishedAt: DateTime(2026, 11, 18),
          category: 'Yangiliklar',
          views: 9,
        ),
        UzbmbNewsItem(
          id: 13,
          title: 'Agentlik yangi qabul e’lon qildi',
          summary: 'Umumiy qabul bo‘yicha ma’lumot.',
          publishedAt: DateTime(2026, 11, 17),
          category: 'Yangiliklar',
          views: 5,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsScreen(
              profile: const UserProfile(
                firstName: 'Ali',
                lastName: 'Valiyev',
                role: RoleId.teacher,
                subjectFanId: 'matematika',
              ),
              repository: _MemoryNewsRepository(articles),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rasmiy e’lonlar'), findsOneWidget);
      expect(find.text('2 ta'), findsOneWidget);
      expect(
        find.text('Fizika bo‘yicha milliy sertifikat imtihoni'),
        findsNothing,
      );
      expect(find.text('Agentlik yangi qabul e’lon qildi'), findsNothing);
      expect(find.text('Barcha yangiliklar'), findsNothing);
      expect(appTabs.any((tab) => tab.id == 'news'), isTrue);
      expect(appTabs.any((tab) => tab.id == 'courses'), isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NewsScreen(
              profile: const UserProfile(
                firstName: 'Ali',
                lastName: 'Valiyev',
                role: RoleId.teacher,
                subjectFanId: 'fizika',
              ),
              repository: _MemoryNewsRepository(articles),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 ta'), findsOneWidget);
      expect(
        find.text('Matematika bo‘yicha milliy sertifikat natijalari'),
        findsNothing,
      );
      expect(
        find.text('Fizika bo‘yicha milliy sertifikat imtihoni'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Kurs o‘rniga Xabarlar tab ochiladi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainShell(
          profile: const UserProfile(
            firstName: 'Ali',
            lastName: 'Valiyev',
            role: RoleId.teacher,
            subjectFanId: 'matematika',
          ),
          newsRepository: _MemoryNewsRepository([
            UzbmbNewsItem(
              id: 12,
              title: 'Matematika sertifikat yangiligi',
              summary: 'Rasmiy e’lon.',
              publishedAt: DateTime(2026, 11, 21),
              category: 'Yangiliklar',
              views: 1,
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kurs'), findsNothing);
    await tester.tap(find.text('Xabarlar'));
    await tester.pumpAndSettle();

    expect(find.text('Rasmiy e’lonlar'), findsOneWidget);
    expect(find.text('Matematika sertifikat yangiligi'), findsOneWidget);
  });

  testWidgets(
    'Material yaratuvchi o‘qituvchida alohida menyu va profildan tayyorlov bor',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Grew',
              lastName: 'Greg',
              role: RoleId.teacherMaterials,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Darsliklar'), findsOneWidget);
      expect(find.text('Testlar'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('Hisobotlar'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Xabarlar'), findsNothing);
      expect(find.text('Tayyorlov'), findsNothing);
      expect(find.text('Darsliklar yaratish'), findsOneWidget);

      await tester.tap(find.text('Hisobotlar'));
      await tester.pumpAndSettle();
      expect(find.text('O‘quvchilar savollari va izohlari'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('«Tushunmadim» signallari'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('«Tushunmadim» signallari'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Sertifikatga tayyorlanish'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('openCertificatePreparation')));
      await tester.pumpAndSettle();
      expect(find.text('Arifmetika'), findsOneWidget);
    },
  );

  testWidgets(
    'Darslik muharririda bo‘lim, material va test qulfi qo‘shiladi',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Grew',
              lastName: 'Greg',
              role: RoleId.teacherMaterials,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Matematika: asosiy mavzular to‘plami'));
      await tester.pumpAndSettle();

      expect(find.text('Bo‘limlar va mavzular'), findsOneWidget);
      expect(find.text('Test ≥70%'), findsOneWidget);

      await tester.tap(find.text('2-mavzu. Amaliy mashqlar va grafiklar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('addMaterialBlockButton')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('pick-material-test')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick-material-test')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('blockTitleField')),
        'Oraliq nazorat',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('saveBlockButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('saveBlockButton')));
      await tester.pumpAndSettle();

      final topicScroll = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Oraliq nazorat'),
        250,
        scrollable: topicScroll,
      );
      expect(find.text('Oraliq nazorat'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('addMaterialBlockButton')),
        250,
        scrollable: topicScroll,
      );
      await tester.tap(find.byKey(const ValueKey('addMaterialBlockButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick-material-audio')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('blockTitleField')),
        'Formula tahlili',
      );
      await tester.tap(find.byKey(const ValueKey('audio-visual-gif')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('audioVisualField')),
        'yechim.gif',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('saveBlockButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('saveBlockButton')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('GIF bilan: yechim.gif'),
        250,
        scrollable: topicScroll,
      );
      expect(find.text('GIF bilan: yechim.gif'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('saveTopicButton')));
      await tester.pumpAndSettle();

      expect(find.text('Test ≥70%'), findsNWidgets(2));
    },
  );

  testWidgets(
    'O‘quvchi ko‘rinishida testdan o‘tilgach keyingi mavzu ochiladi va test muharriri ishlaydi',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Grew',
              lastName: 'Greg',
              role: RoleId.teacherMaterials,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Matematika: asosiy mavzular to‘plami'));
      await tester.pumpAndSettle();
      expect(find.text('ILM-4821'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('openStudentPreviewButton')));
      await tester.pumpAndSettle();
      expect(
        find.text('Qulflangan — oldingi mavzu testidan o‘ting'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('preview-topic-top-1')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('simulateTestPass')),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('simulateTestPass')));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byKey(const ValueKey('simulateTestPass')))).pop();
      await tester.pumpAndSettle();

      expect(
        find.text('Qulflangan — oldingi mavzu testidan o‘ting'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Profildan Darslik marketplace ochiladi va o‘z darsligini pullik joylash mumkin',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Grew',
              lastName: 'Greg',
              role: RoleId.teacherMaterials,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Darslik marketplace'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('openTextbookMarketplace')));
      await tester.pumpAndSettle();
      expect(find.text('Darsligimni marketplacega joylash'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('publishToMarketplaceButton')),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const ValueKey('publishPaidChip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('publishPaidChip')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('publishPriceField')),
        '59000',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirmPublishMarketplaceButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirmPublishMarketplaceButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('59 000 so‘m'), findsOneWidget);
      expect(find.text('Mening darsligim'), findsOneWidget);
    },
  );

  testWidgets(
    'Hisobotda izohga javob yoziladi va AI kitobdan test tuzadi',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Grew',
              lastName: 'Greg',
              role: RoleId.teacherMaterials,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hisobotlar'));
      await tester.pumpAndSettle();
      expect(find.text('O‘quvchilar savollari va izohlari'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView).last, const Offset(0, -240));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('reply-cmt-1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('teacherReplyField')),
        'Formula bo‘yicha -b/a olinadi.',
      );
      await tester.tap(find.byKey(const ValueKey('sendTeacherReplyButton')));
      await tester.pumpAndSettle();
      expect(
        find.text('Sizning javobingiz: Formula bo‘yicha -b/a olinadi.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Testlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('aiGenerateTestButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('aiBookSourceField')),
        '10-sinf Algebra, 3-bob',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('confirmAiGenerateTestButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('confirmAiGenerateTestButton')),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI test: 10-sinf Algebra, 3-bob'), findsOneWidget);
      expect(find.text('5 ta savol'), findsOneWidget);
    },
  );

  testWidgets(
    'O‘quvchiman tanlanganda 3 rol va bir nechta fan tanlash ishlaydi',
    (WidgetTester tester) async {
      await tester.pumpWidget(const IlmFanApp());

      await tester.tap(find.text('Google'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('selectLearnerCategory')));
      await tester.pumpAndSettle();

      expect(find.text('Maktab o‘quvchisi'), findsOneWidget);
      expect(find.text('Abituriyent'), findsOneWidget);
      expect(find.text('Talaba'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('learner-role-schoolStudent')));
      await tester.pumpAndSettle();

      expect(find.text('Qaysi fanlar?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('fan-option-matematika')));
      await tester.tap(find.byKey(const ValueKey('fan-option-fizika')));
      await tester.pumpAndSettle();

      expect(find.text('Davom etish (2 ta fan)'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('confirmFansButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirmFansButton')));
      await tester.pumpAndSettle();

      expect(find.text('Ism'), findsOneWidget);
    },
  );

  testWidgets(
    'Maktab o‘quvchisi va Talaba menyulari o‘ziga mos chiqadi',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Jasur',
              lastName: 'Karimov',
              role: RoleId.schoolStudent,
              subjectFanId: 'matematika',
              subjectFanIds: ['matematika', 'fizika'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Darsliklar'), findsOneWidget);
      expect(find.text('Testlar'), findsOneWidget);
      expect(find.text('Vazifalar'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Xabarlar'), findsNothing);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Fanlar: Matematika, Fizika'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Nilufar',
              lastName: 'Toshmatova',
              role: RoleId.universityStudent,
              subjectFanId: 'matematika',
              subjectFanIds: ['matematika', 'ingliz-tili'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Darsliklar'), findsOneWidget);
      expect(find.text('Kurslar'), findsOneWidget);
      expect(find.text('Testlar'), findsOneWidget);
      expect(find.text('Reels'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Vazifalar'), findsNothing);
    },
  );

  testWidgets(
    'Marketplace 2 ustunli karta va qidiruv bilan ishlaydi',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            profile: const UserProfile(
              firstName: 'Nilufar',
              lastName: 'Toshmatova',
              role: RoleId.universityStudent,
              subjectFanId: 'matematika',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('marketplaceGrid')), findsOneWidget);
      expect(find.byKey(const ValueKey('marketplaceSearchField')), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('marketplaceSearchField')),
        'Dilnoza',
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Matematika: tezkor formulalar va sxemalar'),
        findsOneWidget,
      );
      expect(find.text('Matematika: 0 dan DTMgacha to‘liq darslik'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('clearMarketplaceSearch')));
      await tester.pumpAndSettle();
      expect(
        find.text('Matematika: 0 dan DTMgacha to‘liq darslik'),
        findsOneWidget,
      );
    },
  );
}

class _MemoryNewsRepository implements NewsRepository {
  _MemoryNewsRepository(this.items);

  final List<UzbmbNewsItem> items;

  @override
  Future<List<UzbmbNewsItem>> fetchLatest() async => items;

  @override
  void dispose() {}
}

void _doNothing() {}
