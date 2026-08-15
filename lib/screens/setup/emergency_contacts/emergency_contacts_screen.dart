import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../permissions/permissions_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final List<Map<String, String>> _contacts = [];

  static const String _contactsKey = 'emergency_contacts';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final savedContacts = prefs.getString(_contactsKey);

    if (savedContacts == null || savedContacts.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(savedContacts);

      if (decoded is List) {
        setState(() {
          _contacts.clear();

          for (final item in decoded) {
            if (item is Map) {
              _contacts.add({
                'name': item['name']?.toString() ?? '',
                'phone': item['phone']?.toString() ?? '',
              });
            }
          }
        });
      }
    } catch (_) {
      // Ignore invalid locally stored data.
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _contactsKey,
      jsonEncode(_contacts),
    );
  }

  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _contacts.add({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
    });

    await _saveContacts();

    _nameController.clear();
    _phoneController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Emergency contact added successfully.',
        ),
      ),
    );
  }

  Future<void> _removeContact(int index) async {
    setState(() {
      _contacts.removeAt(index);
    });

    await _saveContacts();
  }

  Future<void> _continueSetup() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can continue without adding emergency contacts. '
            'RAPID REACH can use trusted/favourite contacts later.',
          ),
        ),
      );
    }

    await _saveContacts();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PermissionsScreen(),
      ),
    );
  }

  void _skipForNow() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PermissionsScreen(),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(),

                const SizedBox(height: 32),

                Text(
                  'Your emergency contacts',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkNavy,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Add trusted people who should be contacted '
                  'when you need emergency assistance.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: const Color(0xFF66758C),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Contact name',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkNavy,
                  ),
                ),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter contact name',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the contact name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Phone number',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkNavy,
                  ),
                ),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _phoneController,
                  hintText: '+91  Enter phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the phone number';
                    }

                    final digits = value.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );

                    if (digits.length < 10) {
                      return 'Please enter a valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _addContact,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add Emergency Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                if (_contacts.isNotEmpty) ...[
                  Text(
                    'Added contacts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkNavy,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...List.generate(
                    _contacts.length,
                    (index) => _buildContactCard(index),
                  ),

                  const SizedBox(height: 12),
                ],

                _buildInfoCard(),

                const SizedBox(height: 32),

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
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Center(
                  child: TextButton(
                    onPressed: _skipForNow,
                    child: const Text(
                      'Skip for now',
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
                    'Your safety matters',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
            color: AppTheme.lightBlue,
          ),
        ),

        _progressDot(active: false),

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,

        prefixIcon: Icon(
          icon,
          color: AppTheme.primaryBlue,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.lightBlue,
            width: 1.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.primaryBlue,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(int index) {
    final contact = _contacts[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightBlue,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.primaryBlue,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkNavy,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  contact['phone'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF66758C),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => _removeContact(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
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
              'Your emergency contacts can be notified '
              'when RAPID REACH detects or receives an '
              'emergency request. If you do not add a '
              'contact now, trusted or favourite contacts '
              'can be used later when the emergency system '
              'is integrated.',
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