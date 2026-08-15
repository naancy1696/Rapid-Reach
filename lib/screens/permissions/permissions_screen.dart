import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationEnabled = false;
  bool _contactsEnabled = false;
  bool _phoneEnabled = false;
  bool _callLogsEnabled = false;
  bool _bluetoothEnabled = false;
  bool _notificationsEnabled = false;
  bool _activityEnabled = false;

  void _continueSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? AppTheme.primaryBlue
              : AppTheme.lightBlue,
          width: enabled ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkNavy,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF66758C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: enabled,
            activeThumbColor: AppTheme.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressIndicator(),

              const SizedBox(height: 32),

              Text(
                'Set up permissions',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 12),

              Text(
                'Allow RAPID REACH to access the features '
                'needed to respond quickly during an emergency.',
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 30),

              // LOCATION
              _buildPermissionCard(
                icon: Icons.location_on_rounded,
                title: 'Location',
                description:
                    'Share your current location with emergency '
                    'contacts when help is needed.',
                enabled: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
              ),

              // CONTACTS
              _buildPermissionCard(
                icon: Icons.contacts_rounded,
                title: 'Contacts',
                description:
                    'Access your contacts so you can select '
                    'trusted people for emergency assistance.',
                enabled: _contactsEnabled,
                onChanged: (value) {
                  setState(() {
                    _contactsEnabled = value;
                  });
                },
              ),

              // PHONE
              _buildPermissionCard(
                icon: Icons.phone_rounded,
                title: 'Phone',
                description:
                    'Allow RAPID REACH to initiate emergency '
                    'phone calls when assistance is required.',
                enabled: _phoneEnabled,
                onChanged: (value) {
                  setState(() {
                    _phoneEnabled = value;
                  });
                },
              ),

              // CALL LOGS
              _buildPermissionCard(
                icon: Icons.call_rounded,
                title: 'Call Logs',
                description:
                    'Allow access to call information needed '
                    'for emergency communication and call status.',
                enabled: _callLogsEnabled,
                onChanged: (value) {
                  setState(() {
                    _callLogsEnabled = value;
                  });
                },
              ),

              // BLUETOOTH
              _buildPermissionCard(
                icon: Icons.bluetooth_rounded,
                title: 'Bluetooth',
                description:
                    'Allow RAPID REACH to communicate with '
                    'a connected smartwatch or wearable device.',
                enabled: _bluetoothEnabled,
                onChanged: (value) {
                  setState(() {
                    _bluetoothEnabled = value;
                  });
                },
              ),

              // NOTIFICATIONS
              _buildPermissionCard(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                description:
                    'Receive important emergency alerts and '
                    'status updates from RAPID REACH.',
                enabled: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),

              // ACTIVITY RECOGNITION
              _buildPermissionCard(
                icon: Icons.directions_run_rounded,
                title: 'Activity Recognition',
                description:
                    'Allow RAPID REACH to detect activity patterns '
                    'that may help identify emergency situations.',
                enabled: _activityEnabled,
                onChanged: (value) {
                  setState(() {
                    _activityEnabled = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _buildInfoCard(),

              const SizedBox(height: 32),

              // CONTINUE
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continueSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // SKIP
              Center(
                child: TextButton(
                  onPressed: _continueSetup,
                  child: const Text(
                    'Set up permissions later',
                    style: TextStyle(
                      color: AppTheme.darkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'You can change these permissions later.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _progressDot(active: true),

        Expanded(
          child: Container(
            height: 3,
            color: AppTheme.primaryBlue,
          ),
        ),

        _progressDot(active: true),

        Expanded(
          child: Container(
            height: 3,
            color: AppTheme.primaryBlue,
          ),
        ),

        _progressDot(active: true),

        Expanded(
          child: Container(
            height: 3,
            color: AppTheme.lightBlue,
          ),
        ),

        _progressDot(active: false),
      ],
    );
  }

  Widget _progressDot({
    required bool active,
  }) {
    return Container(
      width: active ? 14 : 10,
      height: active ? 14 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppTheme.primaryBlue
            : AppTheme.lightBlue,
        border: active
            ? null
            : Border.all(
                color: AppTheme.primaryBlue.withValues(
                  alpha: 0.25,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
            Icons.shield_outlined,
            color: AppTheme.primaryBlue,
            size: 26,
          ),

          SizedBox(width: 14),

          Expanded(
            child: Text(
              'RAPID REACH only uses these permissions '
              'to provide emergency assistance. You can '
              'change them at any time.',
              style: TextStyle(
                color: AppTheme.darkNavy,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}