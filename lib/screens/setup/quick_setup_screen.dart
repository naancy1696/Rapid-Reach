import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/setup_storage.dart';
import 'emergency_contacts/emergency_contacts_screen.dart';

class QuickSetupScreen extends StatefulWidget {
  const QuickSetupScreen({super.key});

  @override
  State<QuickSetupScreen> createState() => _QuickSetupScreenState();
}

class _QuickSetupScreenState extends State<QuickSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continueSetup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // Save the user's basic details locally.
    await SetupStorage.saveUserDetails(
      name: name,
      phone: phone,
    );

    if (!mounted) return;

    // Move to emergency contacts.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyContactsScreen(),
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
            padding: const EdgeInsets.fromLTRB(
              24,
              8,
              24,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressIndicator(),

                const SizedBox(height: 32),

                Text(
                  'Let’s get you protected',
                  style: theme.textTheme.headlineMedium,
                ),

                const SizedBox(height: 12),

                Text(
                  'Set up a few details so RAPID REACH can '
                  'respond quickly when you need help.',
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 36),

                Text(
                  'Your name',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter your name',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your name';
                    }

                    if (value.trim().length < 2) {
                      return 'Please enter a valid name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Phone number',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
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
                      return 'Please enter your phone number';
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

                const SizedBox(height: 36),

                _buildInfoCard(),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _continueSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
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

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Your safety matters',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
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
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 200),
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
                color: AppTheme.primaryBlue
                    .withValues(alpha: 0.25),
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
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.lightBlue,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
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
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppTheme.primaryBlue,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'These details help RAPID REACH '
              'identify you and prepare your '
              'emergency response.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppTheme.darkNavy,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}