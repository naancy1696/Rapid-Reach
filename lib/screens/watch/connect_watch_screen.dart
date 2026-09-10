import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ConnectWatchScreen extends StatefulWidget {
  const ConnectWatchScreen({super.key});

  @override
  State<ConnectWatchScreen> createState() => _ConnectWatchScreenState();
}

class _ConnectWatchScreenState extends State<ConnectWatchScreen> {
  bool _searching = false;

  void _searchForWatch() {
    setState(() {
      _searching = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _searching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No smartwatch found. Watch connection will be available later.',
          ),
        ),
      );
    });
  }

  void _connectWatch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Watch connection will be enabled in a future version.',
        ),
      ),
    );
  }

  void _skipForNow() {
    Navigator.pop(context);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProgressIndicator(),

              const SizedBox(height: 40),

              Text(
                'Connect Your Smartwatch',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkNavy,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Connect RAPID REACH with your smartwatch '
                'to enable continuous emergency monitoring.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: const Color(0xFF66758C),
                ),
              ),

              const SizedBox(height: 45),

              _buildWatchIllustration(),

              const SizedBox(height: 40),

              _buildFeatureCard(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _searching ? null : _searchForWatch,
                  icon: _searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    _searching
                        ? 'Searching for Watch...'
                        : 'Search for Watch',
                    style: const TextStyle(
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

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _connectWatch,
                  icon: const Icon(Icons.bluetooth_connected_rounded),
                  label: const Text(
                    'Connect Watch',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextButton(
                onPressed: _skipForNow,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: AppTheme.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildInfoCard(),
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
            color: AppTheme.primaryBlue,
          ),
        ),

        _progressDot(active: true),
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

  Widget _buildWatchIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightBlue.withValues(alpha: 0.7),
          ),
        ),

        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.cyanBlue.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
        ),

        Container(
          width: 130,
          height: 150,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cyanBlue,
                AppTheme.primaryBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            Icons.watch_rounded,
            color: Colors.white,
            size: 75,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard() {
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
      child: const Column(
        children: [
          _FeatureRow(
            icon: Icons.monitor_heart_rounded,
            title: 'Health Monitoring',
            description:
                'Monitor health information from your watch.',
          ),
          SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.warning_rounded,
            title: 'Emergency Detection',
            description:
                'Help detect potential emergency situations.',
          ),
          SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.notifications_active_rounded,
            title: 'Instant Alerts',
            description:
                'Send emergency alerts when required.',
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
            Icons.info_outline_rounded,
            color: AppTheme.primaryBlue,
            size: 25,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Smartwatch integration will be connected '
              'during the next development phase. You can '
              'skip this step and continue using RAPID REACH.',
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppTheme.lightBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 23,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Color(0xFF66758C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}