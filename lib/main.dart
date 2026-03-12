import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/fake_call_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: KavachColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const KavachApp());
}

class KavachApp extends StatelessWidget {
  const KavachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: KavachStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: KavachRoutes.dashboard,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  // ── Theme ────────────────────────────────────────────────────────────────
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: KavachColors.background,
      colorScheme: const ColorScheme.dark(
        primary: KavachColors.primary,
        secondary: KavachColors.accent,
        surface: KavachColors.surface,
        background: KavachColors.background,
        error: KavachColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: KavachColors.textPrimary,
        onBackground: KavachColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KavachColors.surface,
        foregroundColor: KavachColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KavachColors.surfaceCard,
        contentTextStyle: KavachTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KavachSizes.radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Routing ──────────────────────────────────────────────────────────────
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case KavachRoutes.dashboard:
        page = const DashboardScreen();
        break;
      case KavachRoutes.fakeCall:
        page = const FakeCallScreen();
        break;
      // Placeholder screens for routes not yet implemented
      case KavachRoutes.map:
        page = _PlaceholderScreen(title: KavachStrings.navMap, icon: Icons.map_rounded);
        break;
      case KavachRoutes.safeWalk:
        page = _PlaceholderScreen(title: KavachStrings.navSafeWalk, icon: Icons.directions_walk_rounded);
        break;
      case KavachRoutes.report:
        page = _PlaceholderScreen(title: KavachStrings.navReport, icon: Icons.flag_rounded);
        break;
      case KavachRoutes.community:
        page = _PlaceholderScreen(title: KavachStrings.navCommunity, icon: Icons.group_rounded);
        break;
      default:
        page = const DashboardScreen();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        );
      },
      transitionDuration: KavachDurations.normal,
    );
  }
}

/// Temporary scaffold for routes not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KavachColors.background,
      appBar: AppBar(
        title: Text(title, style: KavachTextStyles.headline2.copyWith(fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: KavachColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: KavachColors.accent.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              '$title Coming Soon',
              style: KavachTextStyles.headline2.copyWith(color: KavachColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is under development.',
              style: KavachTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
