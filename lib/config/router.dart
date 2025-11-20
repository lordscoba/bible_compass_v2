import 'package:bible_compass_app/domain/models/user/user.dart';
import 'package:bible_compass_app/domain/providers/authproviders.dart';
import 'package:bible_compass_app/presentation/pages/admin/categories/category.dart';
import 'package:bible_compass_app/presentation/pages/admin/home.dart';
import 'package:bible_compass_app/presentation/pages/admin/subscription/subscription.dart';
import 'package:bible_compass_app/presentation/pages/admin/users/users.dart';
import 'package:bible_compass_app/presentation/pages/admin/verses/verse.dart';
import 'package:bible_compass_app/presentation/pages/auth/login.dart';
import 'package:bible_compass_app/presentation/pages/auth/signup.dart';
import 'package:bible_compass_app/presentation/pages/auth/verify.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/bible.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/category.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/favorite.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/home.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/keywords.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/profile.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/sub.dart';
import 'package:bible_compass_app/presentation/pages/dashboard/userverse.dart';
import 'package:bible_compass_app/presentation/pages/error.dart';
import 'package:bible_compass_app/presentation/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Makes GoRouter rebuild when a Riverpod provider emits new values.
class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(WidgetRef ref, ProviderListenable<dynamic> listenable) {
    ref.listen<dynamic>(listenable, (_, _) {
      notifyListeners();
    });
  }
}

class MyRouter extends ConsumerStatefulWidget {
  const MyRouter({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyRouterState();
}

class _MyRouterState extends ConsumerState<MyRouter> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      errorBuilder: (context, state) => const ErrorScreen(),
      refreshListenable: GoRouterRefresh(ref, authStatusProvider),

      redirect: (context, state) {
        final loc = state.matchedLocation;

        // Read login status synchronously
        final isLoggedIn = ref
            .read(authStatusProvider)
            .maybeWhen(data: (v) => v, orElse: () => false);

        // Splash is always first entry point — do not skip
        if (loc == '/splash') {
          return null; // ✅ always stay until splash decides next
        }

        // Only these routes are protected
        final protectedRoots = <String>[
          '/profile',
          '/sub',
          '/favorite',
          '/admin',
          '/admin/users',
          '/admin/categories',
          '/admin/subscription',
        ];
        final isProtected = protectedRoots.any(
          (p) => loc == p || loc.startsWith('$p/'),
        );

        // Force login for protected routes
        if (!isLoggedIn && isProtected) {
          return '/login';
        }

        // Prevent logged-in users from going back to auth pages
        final isAuthRoute =
            loc == '/login' || loc == '/signup' || loc == '/verify';
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        // All other routes (home, category, keywords, etc.) are open
        return null;
      },

      routes: [
        // splash
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),

        // auth
        GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/verify', builder: (_, _) => const VerifyUserScreen()),

        // dashboard
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/category', builder: (_, _) => const CategoryPage()),
        GoRoute(path: '/bible', builder: (_, _) => const BibleApi()),
        GoRoute(
          path: '/keywords/:catid',
          builder: (_, state) =>
              KeywordPage(catId: state.pathParameters['catid']!),
        ),
        GoRoute(
          path: '/verse/:keywid',
          builder: (_, state) =>
              UserVersePage(keywId: state.pathParameters['keywid']!),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(path: '/sub', builder: (_, _) => const SubPage()),
        GoRoute(path: '/favorite', builder: (_, _) => const FavouritePage()),

        // admin
        GoRoute(path: '/admin', builder: (_, _) => const AdminHome()),
        GoRoute(path: '/admin/users', builder: (_, _) => const AdminUsers()),
        GoRoute(
          path: '/admin/categories',
          builder: (_, _) => const AdminCategory(),
        ),
        GoRoute(
          path: '/admin/subscription',
          builder: (_, _) => const AdminSubscription(),
        ),
        GoRoute(
          path: '/admin/verses/:keywid',
          builder: (_, state) =>
              AdminVerses(keywid: state.pathParameters['keywid']),
        ),
      ],
    );

    return MaterialApp.router(
      builder: (context, child) {
        const scale = 1.0;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(scale)),
          child: child!,
        );
      },
      theme: (() {
        const brandGreen = Color(0xFF0BA37F);
        final base = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: brandGreen,
            primary: brandGreen,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.latoTextTheme(),
        );
        return base.copyWith(
          appBarTheme: base.appBarTheme.copyWith(
            backgroundColor: base.colorScheme.primary,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white, size: 28),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: base.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: base.colorScheme.primary,
            ),
          ),
        );
      })(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
