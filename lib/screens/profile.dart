import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_page/l10n/app_localizations.dart';
import 'package:login_page/screens/saved_articles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/screens/login.dart';
import 'package:login_page/providers.dart';
import 'package:login_page/main.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Guest';
    });
  }

  Future<void> _pickImage() async {
    try {
      if (Platform.isAndroid) {
        PermissionStatus status;

        if (Platform.version.contains("13") ||
            Platform.version.contains("14")) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }

        if (status.isDenied || status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.permissionDenied ??
                    'Permission denied',
              ),
            ),
          );
          return;
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        await ref
            .read(profileImageProvider.notifier)
            .setImagePath(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.noImageSelected ??
                  'No image selected',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.imagePickError(e.toString()) ??
                'Failed to pick image: $e',
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await ref.read(profileImageProvider.notifier).clearImagePath();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final imagePath = ref.watch(profileImageProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.profileTitle ?? 'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n?.logout ?? 'Logout',
            onPressed: _logout,
            color: colorScheme.onPrimary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primary.withOpacity(0.2),
                backgroundImage:
                    imagePath != null && File(imagePath).existsSync()
                        ? FileImage(File(imagePath))
                        : null,
                child:
                    imagePath == null || !File(imagePath).existsSync()
                        ? Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: colorScheme.primary,
                        )
                        : null,
              ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
            ),
            const SizedBox(height: 20),
            Text(
              _username.isNotEmpty ? _username : 'Guest',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.bookmark, color: colorScheme.onPrimary),
              label: Text(
                l10n?.savedArticles ?? 'Saved Articles',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedArticlesPage()),
                );
              },
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.darkMode ?? 'Dark Mode',
                  style: theme.textTheme.bodyLarge,
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.language ?? 'Language',
                  style: theme.textTheme.bodyLarge,
                ),
                DropdownButton<Locale>(
                  value: currentLocale,
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en', ''),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('hi', ''),
                      child: Text('हिन्दी'),
                    ),
                    DropdownMenuItem(
                      value: Locale('es', ''),
                      child: Text('Español'),
                    ),
                  ],
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      ref.read(localeProvider.notifier).state = newLocale;
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
