import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../emergency/emergency_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../setup/emergency_contacts/emergency_contacts_screen.dart';
import '../watch/connect_watch_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openEmergency(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyScreen(),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _openContacts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyContactsScreen(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  void _openWatch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ConnectWatchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 30),

              _buildEmergencyCard(context),

              const SizedBox(height: 24),

              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkNavy,
                    ),
              ),

              const SizedBox(height: 14),

              _buildQuickActions(context),

              const SizedBox(height: 28),

              Text(
                'Your Safety',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkNavy,
                    ),
              ),

              const SizedBox(height: 14),

              _buildSafetyStatus(),

              const SizedBox(height: 28),

              _buildEmergencyContactsCard(context),

              const SizedBox(height: 18),

              _buildWatchCard(context),

              const SizedBox(height: 18),

              _buildSettingsCard(context),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.cyanBlue,
                AppTheme.primaryBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RAPID REACH',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.darkNavy,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Your safety companion',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF66758C),
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () => _openSettings(context),
          icon: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightBlue,
              ),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: AppTheme.darkNavy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.cyanBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'ARE YOU IN AN EMERGENCY?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sos_rounded,
                color: AppTheme.primaryBlue,
                size: 58,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'SOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tap the SOS button when you need immediate help.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _openEmergency(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Activate Emergency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.location_on_rounded,
                title: 'Location',
                subtitle: 'Share location',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Location feature will be connected during integration.',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.contacts_rounded,
                title: 'Contacts',
                subtitle: 'Trusted people',
                onTap: () => _openContacts(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.watch_rounded,
                title: 'Watch',
                subtitle: 'Connect device',
                onTap: () => _openWatch(context),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'Manage app',
                onTap: () => _openSettings(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lightBlue,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryBlue,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.darkNavy,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF66758C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightBlue,
        ),
      ),
      child: Column(
        children: [
          _buildStatusRow(
            icon: Icons.location_on_rounded,
            title: 'Location',
            status: 'Ready',
          ),

          const Divider(height: 24),

          _buildStatusRow(
            icon: Icons.people_alt_rounded,
            title: 'Emergency Contacts',
            status: 'Configured',
          ),

          const Divider(height: 24),

          _buildStatusRow(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            status: 'Ready',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String status,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppTheme.lightBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.darkNavy,
            ),
          ),
        ),

        const Icon(
          Icons.check_circle_rounded,
          color: AppTheme.primaryBlue,
          size: 20,
        ),

        const SizedBox(width: 5),

        Text(
          status,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsCard(BuildContext context) {
    return InkWell(
      onTap: () => _openContacts(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.shield_rounded,
              color: AppTheme.primaryBlue,
              size: 30,
            ),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are protected',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkNavy,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Tap to manage your emergency contacts.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF66758C),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchCard(BuildContext context) {
    return InkWell(
      onTap: () => _openWatch(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lightBlue,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.watch_rounded,
              color: AppTheme.primaryBlue,
              size: 30,
            ),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect your smartwatch',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkNavy,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Connect a wearable device for emergency monitoring.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF66758C),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return InkWell(
      onTap: () => _openSettings(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lightBlue,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.settings_rounded,
              color: AppTheme.primaryBlue,
              size: 30,
            ),

            SizedBox(width: 14),

            Expanded(
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkNavy,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: const Color(0xFF8895A7),
      onTap: (index) {
        if (index == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location feature will be connected later.'),
            ),
          );
        }

        if (index == 2) {
          _openContacts(context);
        }

        if (index == 3) {
          _openProfile(context);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_rounded),
          label: 'Location',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_rounded),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}