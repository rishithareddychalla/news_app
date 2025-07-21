import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_page/screens/login.dart'; // 👈 Adjust path as needed

/// Theme provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _username = '';
  File? _profileImage;

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

    final imagePath = prefs.getString('profileImagePath');
    if (imagePath != null && await File(imagePath).exists()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      if (Platform.isAndroid) {
        PermissionStatus status;

        if (Platform.version.contains("13") ||
            Platform.version.contains("14")) {
          status = await Permission.photos.request(); // Android 13+
        } else {
          status = await Permission.storage.request(); // Below Android 13
        }

        if (status.isDenied || status.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Permission denied to access gallery."),
            ),
          );
          return;
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImagePath', pickedFile.path);
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No image selected.")));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clear saved user data

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ), // 👈 Replace with your login screen
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
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
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child:
                    _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _username,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode', style: theme.textTheme.bodyLarge),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
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
