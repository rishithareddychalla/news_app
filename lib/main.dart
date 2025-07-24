import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/l10n/app_localizations.dart';
import 'package:login_page/screens/home_page.dart';
import 'package:login_page/screens/login.dart';
import 'package:login_page/providers.dart';
import 'package:login_page/screens/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    final email = prefs.getString('email');
    final username = prefs.getString('username');

    if (onboardingComplete && email != null && username != null) {
      return HomePage(username: username);
    }
    return const OnboardingPage();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'My News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1976D2),
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1976D2),
          primaryContainer: const Color(
            0xFF99CFFF,
          ), // Lighter shade of 0xFF0D97F9
          onPrimary: Colors.white,
          surface: Colors.grey[100]!,
          onSurface: Colors.black,
          error: Colors.red,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF1976D2),
        scaffoldBackgroundColor: Colors.grey[900]!,
        cardColor: Colors.grey[800]!,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1976D2),
          primaryContainer: const Color(
            0xFF005DD9,
          ), // Darker shade of 0xFF0D97F9
          onPrimary: Colors.white,
          surface: Colors.grey[800]!,
          onSurface: Colors.white,
          error: Colors.red,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('es', ''),
      ],
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data ?? const OnboardingPage();
        },
      ),
    );
  }
}
