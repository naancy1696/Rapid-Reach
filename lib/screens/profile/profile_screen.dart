import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/setup_storage.dart';
import '../setup/emergency_contacts/emergency_contacts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'RAPID REACH User';
  String _phoneNumber = 'Not available';
  int _emergencyContactsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final name = await SetupStorage.getUserName();
    final phone = await SetupStorage.getUserPhone();
    final contacts = await SetupStorage.getEmergencyContacts();

    if (!mounted) return;

    setState(() {
      _name = name?.trim().isNotEmpty == true
          ? name!.trim()
          : 'RAPID REACH User';

      _phoneNumber = phone?.trim().isNotEmpty == true
          ? phone!.trim()
          : 'Not available';

      _emergencyContactsCount = contacts.length;
      _loading = false;
    });
  }

  Future<void> _openEmergencyContacts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyContactsScreen(),
      ),
    );

    // Refresh the profile after returning from
    // the Emergency Contacts screen.
    _loadUserDetails();
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
          'My Profile',
          style: TextStyle(
            color: AppTheme.darkNavy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      _name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.darkNavy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _phoneNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF66758C),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildSectionTitle('Personal Information'),

                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.person_outline_rounded,
                      title: 'Name',
                      value: _name,
                    ),

                    const SizedBox(height: 12),

                    _buildInfoCard(
                      icon: Icons.phone_rounded,
                      title: 'Phone Number',
                      value: _phoneNumber,
                    ),

                    const SizedBox(height: 28),

                    _buildSectionTitle('Safety Information'),

                    const SizedBox(height: 12),

                    InkWell(
                      onTap: _openEmergencyContacts,
                      borderRadius: BorderRadius.circular(18),
                      child: _buildNavigationCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Emergency Contacts',
                        subtitle: _emergencyContactsCount == 0
                            ? 'No contacts added yet'
                            : '$_emergencyContactsCount '
                                '${_emergencyContactsCount == 1 ? 'contact' : 'contacts'} added',
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildNavigationCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Health Information',
                      subtitle: 'Add health details later',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.darkNavy,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.lightBlue,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
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
                    fontSize: 13,
                    color: Color(0xFF66758C),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.lightBlue,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
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

                const SizedBox(height: 5),

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

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}