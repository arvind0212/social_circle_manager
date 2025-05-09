import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  String? _fullName;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;
  String _initials = '';
  List<Map<String, dynamic>> _userAttributes = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      _email = currentUser.email;

      final profileResponse = await Supabase.instance.client
          .from('user_profiles')
          .select('full_name, avatar_url')
          .eq('id', currentUser.id)
          .maybeSingle();

      // Fetch user attributes (preferences/constraints)
      final attributesResponse = await Supabase.instance.client
          .from('user_attributes')
          .select('attribute_type, description, source')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          if (profileResponse != null) {
            _fullName = profileResponse['full_name'] as String?;
            _avatarUrl = profileResponse['avatar_url'] as String?;
          }
          _userAttributes = List<Map<String, dynamic>>.from(attributesResponse);
          _updateInitials();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to fetch profile data: ${e.toString()}'),
          )
        );
      }
    }
  }
  
  void _updateInitials() {
    if (_fullName != null && _fullName!.isNotEmpty) {
      _initials = _fullName!
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s[0].toUpperCase())
          .take(2)
          .join();
    } else if (_email != null && _email!.isNotEmpty) {
      _initials = _email![0].toUpperCase();
    } else {
      _initials = '';
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? pic = await _picker.pickImage(source: ImageSource.gallery);
    if (pic != null) {
      _goEdit(pickedImageFile: File(pic.path));
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

  void _goEdit({File? pickedImageFile}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialFullName: _fullName,
          initialAvatarUrl: _avatarUrl,
          pickedImageFile: pickedImageFile,
        ),
      ),
    ).then((_) => _fetchProfileData());
  }

  void _goCalendar() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CalendarIntegrationScreen()),
  );

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => ShadDialog.alert(
        title: const Text('Delete Account'),
        description: const Text('Are you sure? This will permanently delete your account and all associated data. This action cannot be undone.'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              setState(() => _isLoading = true);
              try {
                await Supabase.instance.client.rpc('delete_current_user');
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  ShadToaster.of(context).show(
                    ShadToast(
                      title: const Text('Account Deleted'),
                      description: const Text('Your account has been successfully deleted.'),
                    )
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('Error Deleting Account'),
                      description: Text(e.toString()),
                    )
                  );
                }
              }
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
            onPressed: () async {
              Navigator.pop(context);
              if (!mounted) return;
              setState(() => _isLoading = true);
              try {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                   ShadToaster.of(context).show(
                    ShadToast(
                      title: const Text('Logged Out'),
                      description: const Text('You have been successfully logged out.'),
                    )
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              } catch (e) {
                 if (mounted) {
                  setState(() => _isLoading = false);
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('Error Logging Out'),
                      description: Text(e.toString()),
                    )
                  );
                }
              }
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

    if (_isLoading && _fullName == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

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
              Container(color: theme.colorScheme.background),
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
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => ShadAvatar(
                                      '',
                                      placeholder: Text(
                                        _initials,
                                        style: theme.textTheme.h2.copyWith(color: theme.colorScheme.primaryForeground),
                                      ),
                                      backgroundColor: theme.colorScheme.primary,
                                    ),
                                  )
                                : ShadAvatar(
                                    '',
                                    placeholder: Text(
                                      _initials,
                                      style: theme.textTheme.h2.copyWith(color: theme.colorScheme.primaryForeground),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _fullName ?? 'User Name', 
                        style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        _email ?? 'user.email@example.com', 
                        style: theme.textTheme.muted.copyWith(color: theme.colorScheme.mutedForeground)
                      ),
                    ),
                    // User Preferences & Constraints
                    const SizedBox(height: 12),
                    if (_userAttributes.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _userAttributes.map((attr) {
                            final isPref = attr['attribute_type'] == 'preference';
                            final color = isPref
                                ? ThemeProvider.accentPeach
                                : ThemeProvider.secondaryPurple;
                            final icon = isPref
                                ? Icons.favorite
                                : Icons.schedule;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Tooltip(
                                message: '${attr['attribute_type'] != null && attr['attribute_type'].toString().isNotEmpty ? attr['attribute_type'].toString()[0].toUpperCase() + attr['attribute_type'].toString().substring(1) : ''} (${attr['source']})',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(icon, color: color, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        attr['description'] ?? '',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (_userAttributes.isEmpty)
                      Center(
                        child: Text(
                          'No preferences set yet',
                          style: theme.textTheme.muted.copyWith(color: theme.colorScheme.mutedForeground),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ShadCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_outlined, color: ThemeProvider.successGreen),
                            title: const Text('Edit Profile'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _goEdit(),
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