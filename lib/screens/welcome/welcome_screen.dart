import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

import '../setup/quick_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: Stack(
          children: [
            // Soft background glow
            Positioned(
              top: -180,
              right: -120,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightBlue.withValues(alpha: 0.8),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 55),

                    if (screenWidth > 850)
                      _buildDesktopContent(context)
                    else
                      _buildMobileContent(context),

                    const SizedBox(height: 45),

                    _buildFeatureBar(),

                    const SizedBox(height: 30),

                    _buildSecurityFooter(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        // Logo
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.cyanBlue,
                AppTheme.primaryBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),

        const SizedBox(width: 14),

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RAPID REACH',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkNavy,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'AI POWERED. HUMAN FOCUSED.',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Language button
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.lightBlue,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.language,
                color: AppTheme.darkNavy,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'English',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkNavy,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.darkNavy,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESKTOP CONTENT
  // ============================================================

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _buildWelcomeText(context),
        ),

        const SizedBox(width: 35),

        Expanded(
          flex: 5,
          child: _buildShieldIllustration(),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE CONTENT
  // ============================================================

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      children: [
        _buildWelcomeText(context),

        const SizedBox(height: 40),

        _buildShieldIllustration(),
      ],
    );
  }

  // ============================================================
  // WELCOME TEXT
  // ============================================================

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'SMART  •  FAST  •  RELIABLE',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 44,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkNavy,
          ),
        ),

        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [
                AppTheme.primaryBlue,
                AppTheme.cyanBlue,
              ],
            ).createShader(bounds);
          },
          child: const Text(
            'RAPID REACH',
            style: TextStyle(
              fontSize: 48,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Your intelligent emergency\nresponse companion.',
          style: TextStyle(
            fontSize: 21,
            height: 1.5,
            color: Color(0xFF52627A),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 25),

        // Safety statement
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.verified_user_rounded,
              color: AppTheme.primaryBlue,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Always with you. Always ready to help.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkNavy,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 35),

        // Get Started button
        SizedBox(
          width: 420,
          height: 62,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryBlue,
                  AppTheme.cyanBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => const QuickSetupScreen(),
                  ),
                );
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 15),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SHIELD ILLUSTRATION
  // ============================================================

  Widget _buildShieldIllustration() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 390,
            height: 390,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightBlue.withValues(alpha: 0.7),
            ),
          ),

          // Outer ring
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.cyanBlue.withValues(alpha: 0.18),
                width: 2,
              ),
            ),
          ),

          // Inner ring
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                width: 2,
              ),
            ),
          ),

          // Main shield
          Container(
            width: 220,
            height: 250,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cyanBlue,
                  AppTheme.primaryBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(55),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 110,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURE BAR
  // ============================================================

  Widget _buildFeatureBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 35,
        runSpacing: 20,
        children: const [
          _FeatureItem(
            icon: Icons.notifications_active_rounded,
            title: 'Instant Alerts',
            subtitle: 'Notify trusted contacts',
          ),
          _FeatureItem(
            icon: Icons.smart_toy_rounded,
            title: 'AI Assistance',
            subtitle: 'Intelligent emergency support',
          ),
          _FeatureItem(
            icon: Icons.favorite_rounded,
            title: 'Health Monitoring',
            subtitle: 'Track vital signs',
          ),
          _FeatureItem(
            icon: Icons.location_on_rounded,
            title: 'Live Location',
            subtitle: 'Share your location',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY FOOTER
  // ============================================================

  Widget _buildSecurityFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_rounded,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Your safety is our priority. Your data is secure and private.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF52627A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FEATURE ITEM
// ============================================================

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 25,
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF66758C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}