import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animations/animations.dart';


import 'firebase_options.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_notifier.dart';
import 'providers/courses_notifier.dart';

import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home/home_page.dart';
import 'screens/courses/courses_page.dart';
import 'screens/courses/course_detail_page.dart';
import 'screens/lessons/lesson_page.dart';
import 'screens/quiz/quiz_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/announcements/announcements_page.dart';
import 'screens/static/about_page.dart';
import 'screens/static/info_page.dart';
import 'screens/splash/splash_page.dart';
import 'screens/notifications/notification_page.dart';
import 'screens/profile/edit_profile_page.dart';





Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(
  create: (ctx) => AuthNotifier(
    ctx.read<AuthService>(),
    ctx.read<FirestoreService>(),
  ),
),
        ChangeNotifierProvider(
          create: (ctx) => CoursesNotifier(ctx.read<ApiService>()),
        ),
      ],
      child: const MiniLearnApp(),
    );
  }
}

class MiniLearnApp extends StatefulWidget {
  const MiniLearnApp({super.key});

  @override
  State<MiniLearnApp> createState() => _MiniLearnAppState();
}

class _MiniLearnAppState extends State<MiniLearnApp> {
  late GoRouter _router;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final auth = context.read<AuthNotifier>();
      _router = _createRouter(auth);
      _inited = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MiniLearn',
      theme: ThemeData(useMaterial3: true),
      routerConfig: _router,
    );
  }

  CustomTransitionPage _fadeThrough(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  GoRouter _createRouter(AuthNotifier auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final loggedIn = auth.loggedIn;
        final goingAuth = state.matchedLocation == '/login' ||
    state.matchedLocation == '/register' ||
    state.matchedLocation == '/splash';


        if (!loggedIn && !goingAuth) return '/login';
        if (loggedIn && goingAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(
  path: '/profile',
  pageBuilder: (context, state) => _fadeThrough(state, const EditProfilePage()),
),
        GoRoute(
  path: '/notifications',
  pageBuilder: (context, state) => _fadeThrough(state, const NotificationsPage()),
),
         GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeThrough(state, const SplashPage()),
      ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _fadeThrough(state, const LoginPage()),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => _fadeThrough(state, const RegisterPage()),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _fadeThrough(state, const HomePage()),
        ),
        GoRoute(
          path: '/courses',
          pageBuilder: (context, state) => _fadeThrough(state, const CoursesPage()),
        ),
        GoRoute(
          path: '/courses/:courseId',
          pageBuilder: (context, state) {
            final id = state.pathParameters['courseId']!;
            return _fadeThrough(state, CourseDetailPage(id: id));
          },
        ),
        GoRoute(
          path: '/lesson/:lessonId',
          pageBuilder: (context, state) {
            final id = state.pathParameters['lessonId']!;
            return _fadeThrough(state, LessonPage(lessonId: id));
          },
        ),
        GoRoute(
          path: '/quiz/:quizId',
          pageBuilder: (context, state) {
            final id = state.pathParameters['quizId']!;
            return _fadeThrough(state, QuizPage(quizId: id));
          },
        ),
        GoRoute(
          path: '/announcements',
          pageBuilder: (context, state) => _fadeThrough(state, const AnnouncementsPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _fadeThrough(state, const ProfilePage()),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => _fadeThrough(state, const AboutPage()),
        ),
        GoRoute(
          path: '/info',
          pageBuilder: (context, state) => _fadeThrough(state, const InfoPage()),
        ),
      ],
    );
  }
}
