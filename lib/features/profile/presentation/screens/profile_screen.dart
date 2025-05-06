import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'calendar_integration_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final XFile? pic = await _picker.pickImage(source: ImageSource.gallery);
    if (pic != null) {
      setState(() => _avatarFile = File(pic.path));
      // TODO: upload avatar to backend
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadButton(
              leading: const Icon(Icons.photo_library_outlined),
              onPressed: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
              child: const Text('Pick from gallery'),
            ),
            ShadButton.ghost(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _goEdit() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
  );

  void _goCalendar() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CalendarIntegrationScreen()),
  );

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => ShadDialog.alert(
        title: const Text('Delete Account'),
        description: const Text('This action cannot be undone. Continue?'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () {
              Navigator.pop(context);
              // TODO: perform account deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => ShadDialog.alert(
        title: const Text('Log out'),
        description: const Text('Are you sure you want to log out?'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.ghost(
            onPressed: () {
              Navigator.pop(context);
              // TODO: perform logout
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    const name = 'Taylor Smith';
    const email = 'taylor.smith@example.com';
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final statusBarHeight = MediaQuery.of(context).viewPadding.top;
          final width = constraints.maxWidth;
          final hPadding = width < 600 ? 12.0 : 20.0;
          return Stack(
            children: [
              // Base background color
              Container(color: theme.colorScheme.background),
              // Subtle decorative circle
              Positioned(
                top: -screenHeight * 0.1,
                right: -screenHeight * 0.1,
                child: Container(
                  width: screenHeight * 0.4,
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeProvider.successGreen.withOpacity(0.05),
                  ),
                ),
              ),
              // Header row
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPadding, statusBarHeight + 16, hPadding, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeProvider.successGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: ThemeProvider.successGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.foreground,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              // Main content below header
              Positioned.fill(
                top: statusBarHeight + 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _avatarFile != null
                              ? Image.file(_avatarFile!, fit: BoxFit.cover)
                              : ShadAvatar(
                                  'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
                                  placeholder: Text(
                                    initials,
                                    style: theme.textTheme.h2.copyWith(color: Colors.white),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(email, style: TextStyle(color: theme.colorScheme.mutedForeground)),
                    ),
                    const SizedBox(height: 24),
                    ShadCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_outlined, color: ThemeProvider.successGreen),
                            title: const Text('Edit Profile'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _goEdit,
                          ),
                          Divider(height: 1, indent: 56, endIndent: 16, color: theme.colorScheme.border),
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined, color: ThemeProvider.successGreen),
                            title: const Text('Calendar Integration'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _goCalendar,
                          ),
                          Divider(height: 1, indent: 56, endIndent: 16, color: theme.colorScheme.border),
                          ListTile(
                            leading: const Icon(Icons.contacts_outlined, color: ThemeProvider.successGreen),
                            title: const Text('Contact Sync'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 24),
                    ShadButton.destructive(onPressed: _confirmDelete, child: const Text('Delete Account'))
                      .animate().fadeIn(duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: 12),
                    ShadButton.ghost(onPressed: _confirmLogout, child: const Text('Log out'))
                      .animate().fadeIn(duration: 500.ms, delay: 300.ms),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 