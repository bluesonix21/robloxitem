import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/asset_model.dart';
import '../features/asset_detail/asset_detail_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/create/create_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/editor/editor_screen.dart';
import '../features/home/home_screen.dart';
import '../features/my_designs/my_designs_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/premium/premium_paywall_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/templates/templates_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(_authStateProvider);
  const bypassAuthFlag = bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);
  final bypassAuth = bypassAuthFlag && !kReleaseMode;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authState,
    redirect: (context, state) {
      final isLoggedIn = bypassAuth ? true : authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/auth';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/';

      // Allow splash screen to handle navigation
      if (isSplash) return null;

      // If not logged in, redirect to auth (unless already there or onboarding)
      if (!isLoggedIn && !isLoggingIn && !isOnboarding) {
        return '/auth';
      }

      // If logged in and trying to access auth, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const AppStartupScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _platformPage(
          context,
          state,
          OnboardingScreen(
            onComplete: () => context.go('/auth'),
          ),
        ),
      ),

      // Auth
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _platformPage(
          context,
          state,
          const AuthScreen(),
        ),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/templates',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TemplatesScreen(),
            ),
          ),
          GoRoute(
            path: '/create',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreateScreen(),
            ),
          ),
          GoRoute(
            path: '/discover',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverScreen(),
            ),
          ),
          GoRoute(
            path: '/my-designs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyDesignsScreen(),
            ),
          ),
        ],
      ),

      // Editor (full screen)
      GoRoute(
        path: '/editor/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _platformPage(context, state, EditorScreen(designId: id));
        },
      ),

      // Asset Detail
      GoRoute(
        path: '/asset/:id',
        pageBuilder: (context, state) {
          final asset = state.extra as Asset?;
          if (asset == null) {
            return _platformPage(
              context,
              state,
              const Scaffold(
                body: Center(child: Text('Asset bulunamadı')),
              ),
            );
          }
          return _platformPage(context, state, AssetDetailScreen(asset: asset));
        },
      ),

      // Premium Paywall
      GoRoute(
        path: '/premium',
        pageBuilder: (context, state) {
          final featureTitle = state.extra as String?;
          return _platformPage(
            context,
            state,
            PremiumPaywallScreen(featureTitle: featureTitle),
          );
        },
      ),

      // Search
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) {
          final query = state.extra as String?;
          return _platformPage(context, state, SearchScreen(initialQuery: query));
        },
      ),

      // Settings
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _platformPage(context, state, const SettingsScreen()),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _platformPage(context, state, const ProfileScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Sayfa bulunamadı: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

Page<T> _platformPage<T>(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
    return CupertinoPage<T>(key: state.pageKey, child: child);
  }
  return MaterialPage<T>(key: state.pageKey, child: child);
}

/// Main navigation shell with bottom nav bar
class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends ConsumerWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getIndexFromLocation(location);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final route = _getLocationFromIndex(index);
        context.go(route);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Ana Sayfa',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Şablonlar',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle_rounded),
          label: 'Oluştur',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Keşfet',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder_rounded),
          label: 'Tasarımlar',
        ),
      ],
    );
  }

  int _getIndexFromLocation(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/templates':
        return 1;
      case '/create':
        return 2;
      case '/discover':
        return 3;
      case '/my-designs':
        return 4;
      default:
        return 0;
    }
  }

  String _getLocationFromIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/templates';
      case 2:
        return '/create';
      case 3:
        return '/discover';
      case 4:
        return '/my-designs';
      default:
        return '/home';
    }
  }
}

/// Auth state notifier for router refresh
class _AuthStateNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  _AuthStateNotifier() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final newState = event.session != null;
      if (_isLoggedIn != newState) {
        _isLoggedIn = newState;
        notifyListeners();
      }
    });

    // Check initial state
    _isLoggedIn = Supabase.instance.client.auth.currentSession != null;
  }

  bool get isLoggedIn => _isLoggedIn;
}

final _authStateProvider = Provider<_AuthStateNotifier>((ref) {
  return _AuthStateNotifier();
});

/// App startup screen that handles splash, onboarding, and auth redirection
class AppStartupScreen extends ConsumerStatefulWidget {
  const AppStartupScreen({super.key});

  @override
  ConsumerState<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends ConsumerState<AppStartupScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // Show splash for minimum 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    const bypassAuthFlag = bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);
    final bypassAuth = bypassAuthFlag && !kReleaseMode;
    if (bypassAuth) {
      context.go('/home');
      return;
    }

    // Check if onboarding is complete
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    // Check auth state
    final session = Supabase.instance.client.auth.currentSession;

    if (!onboardingComplete) {
      context.go('/onboarding');
    } else if (session != null) {
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
