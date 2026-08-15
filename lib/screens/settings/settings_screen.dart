import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../permissions/permissions_screen.dart';
import '../watch/connect_watch_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppTheme.darkNavy,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppTheme.darkNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 28),

              const Text(
                'Emergency & Safety',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkNavy,
                ),
              ),

              const SizedBox(height: 12),

              _buildSettingTile(
                context: context,
                icon: Icons.people_alt_rounded,
                title: 'Emergency Contacts',
                subtitle: 'Manage your trusted contacts',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Emergency contact management',
                  );
                },
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.security_rounded,
                title: 'Permissions',
                subtitle: 'Manage app permissions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PermissionsScreen(),
                    ),
                  );
                },
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.watch_rounded,
                title: 'Connected Watch',
                subtitle: 'Manage smartwatch connection',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectWatchScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'App Preferences',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkNavy,
                ),
              ),

              const SizedBox(height: 12),

              _buildSettingTile(
                context: context,
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                subtitle: 'Emergency alerts and updates',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Notification settings',
                  );
                },
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Language selection',
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Privacy & Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkNavy,
                ),
              ),

              const SizedBox(height: 12),

              _buildSettingTile(
                context: context,
                icon: Icons.lock_rounded,
                title: 'Privacy & Security',
                subtitle: 'Manage your data and privacy',
                onTap: () {
                  _showComingSoon(
                    context,
                    'Privacy and security settings',
                  );
                },
              ),

              _buildSettingTile(
                context: context,
                icon: Icons.info_outline_rounded,
                title: 'About RAPID REACH',
                subtitle: 'Application information',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),

              const SizedBox(height: 30),

              _buildSecurityCard(),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'RAPID REACH',
                  style: TextStyle(
                    color: AppTheme.primaryBlue.withValues(
                      alpha: 0.8,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Center(
                child: Text(
                  'AI POWERED. HUMAN FOCUSED.',
                  style: TextStyle(
                    color: Color(0xFF7A899E),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.cyanBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(
              alpha: 0.2,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.settings_rounded,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Customize your RAPID REACH experience.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.lightBlue,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppTheme.lightBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkNavy,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF66758C),
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Color(0xFF8A98AA),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_rounded,
            color: AppTheme.primaryBlue,
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Your safety and privacy are important to us. '
              'RAPID REACH uses your information only to '
              'support emergency response features.',
              style: TextStyle(
                color: AppTheme.darkNavy,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'RAPID REACH',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.darkNavy,
            ),
          ),
          content: const Text(
            'RAPID REACH is a next-generation emergency '
            'response system designed to provide fast, '
            'intelligent and reliable emergency assistance.',
            style: TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}