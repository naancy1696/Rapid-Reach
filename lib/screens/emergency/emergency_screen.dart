import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _emergencyActivated = false;

  void _callForHelp() {
    setState(() {
      _emergencyActivated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Emergency call will be connected during backend integration.',
        ),
      ),
    );
  }

  void _sendAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Emergency alert will be connected during backend integration.',
        ),
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Live location sharing will be connected during backend integration.',
        ),
      ),
    );
  }

  void _cancelEmergency() {
    setState(() {
      _emergencyActivated = false;
    });

    Navigator.pop(context);
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
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 35),

              _buildEmergencyCircle(),

              const SizedBox(height: 35),

              Text(
                _emergencyActivated
                    ? 'Emergency mode activated'
                    : 'Are you in an emergency?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.darkNavy,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _emergencyActivated
                    ? 'RAPID REACH is preparing your emergency response.'
                    : 'Choose an action below to get help quickly.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF66758C),
                ),
              ),

              const SizedBox(height: 35),

              _buildEmergencyAction(
                icon: Icons.phone_in_talk_rounded,
                title: 'CALL FOR HELP',
                description: 'Contact emergency services',
                onPressed: _callForHelp,
                filled: true,
              ),

              const SizedBox(height: 14),

              _buildEmergencyAction(
                icon: Icons.notifications_active_rounded,
                title: 'SEND ALERT',
                description: 'Notify your emergency contacts',
                onPressed: _sendAlert,
              ),

              const SizedBox(height: 14),

              _buildEmergencyAction(
                icon: Icons.location_on_rounded,
                title: 'SHARE LOCATION',
                description: 'Share your current location',
                onPressed: _shareLocation,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _cancelEmergency,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.darkNavy,
                    side: const BorderSide(
                      color: AppTheme.lightBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _buildSafetyInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: AppTheme.primaryBlue,
            size: 29,
          ),
        ),

        const SizedBox(width: 12),

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RAPID REACH',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkNavy,
              ),
            ),
            Text(
              'EMERGENCY RESPONSE',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencyCircle() {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
            blurRadius: 35,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 135,
          height: 135,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cyanBlue,
                AppTheme.primaryBlue,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: Colors.white,
            size: 70,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyAction({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _actionContent(
                icon: icon,
                title: title,
                description: description,
                light: true,
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.darkNavy,
                side: const BorderSide(
                  color: AppTheme.lightBlue,
                  width: 1.5,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _actionContent(
                icon: icon,
                title: title,
                description: description,
                light: false,
              ),
            ),
    );
  }

  Widget _actionContent({
    required IconData icon,
    required String title,
    required String description,
    required bool light,
  }) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: light
                ? Colors.white.withValues(alpha: 0.18)
                : AppTheme.lightBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: light ? Colors.white : AppTheme.primaryBlue,
            size: 24,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: light
                      ? Colors.white
                      : AppTheme.darkNavy,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: light
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF66758C),
                ),
              ),
            ],
          ),
        ),

        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 17,
          color: light
              ? Colors.white
              : AppTheme.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildSafetyInfo() {
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
              'In a real emergency, RAPID REACH will use '
              'your configured emergency contacts, location '
              'and available response services to help you '
              'get assistance quickly.',
              style: TextStyle(
                color: AppTheme.darkNavy,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}