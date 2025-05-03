import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: ThemeProvider.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to settings
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            
            ..._buildMenuSection('Account', [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  // Navigate to edit profile
                },
              ),
              _MenuItem(
                icon: Icons.calendar_today_outlined,
                title: 'Calendar Integration',
                onTap: () {
                  // Navigate to calendar settings
                },
              ),
              _MenuItem(
                icon: Icons.contacts_outlined,
                title: 'Contact Sync',
                onTap: () {
                  // Navigate to contacts settings
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            ..._buildMenuSection('Preferences', [
              _MenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              _MenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                trailing: ShadSwitch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // Toggle theme
                  },
                ),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            ..._buildMenuSection('Help & Support', [
              _MenuItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  // Navigate to help
                },
              ),
              _MenuItem(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                onTap: () {
                  // Navigate to feedback
                },
              ),
              _MenuItem(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                onTap: () {
                  // Navigate to bug report
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            ShadButton.destructive(
              onPressed: () {
                // Logout confirmation
                showDialog(
                  context: context,
                  builder: (context) => ShadDialog.alert(
                    title: const Text('Log out'),
                    description: const Text('Are you sure you want to log out?'),
                    actions: [
                      ShadButton.ghost(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ShadButton.destructive(
                        onPressed: () {
                          // Perform logout
                          Navigator.pop(context);
                        },
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Log out'),
            ).animate().fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey,
              backgroundImage: null, // Add user image when available
              child: Text(
                'TS',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Taylor Smith',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'taylor.smith@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Circles', '4'),
                _buildDivider(),
                _buildStatItem('Events', '12'),
                _buildDivider(),
                _buildStatItem('Joined', 'Mar 2023'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey.shade300,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuSection(String title, List<_MenuItem> items) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
      ShadCard(
        child: Column(
          children: List.generate(
            items.length,
            (index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: ThemeProvider.primaryBlue,
                    ),
                    title: Text(item.title),
                    trailing: item.trailing ?? (item.onTap != null ? const Icon(Icons.chevron_right) : null),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: Colors.grey.shade200,
                    ),
                ],
              );
            },
          ),
        ),
      ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
    ];
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Function()? onTap;
  final Widget? trailing;

  _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });
} 