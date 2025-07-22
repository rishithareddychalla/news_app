
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/screens/onboarding_page.dart';
import 'package:login_page/screens/profile.dart';
import 'package:login_page/screens/home_page.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D97F9)),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Matches HomePage
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D97F9), // Fallback for pages without flexibleSpace
          foregroundColor: Colors.white, // White back arrow and title
          elevation: 2,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D97F9),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900], // Matches HomePage dark mode
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D97F9), // Fallback
          foregroundColor: Colors.white, // White back arrow and title
          elevation: 2,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const OnboardingPage(),
    );
  }
}