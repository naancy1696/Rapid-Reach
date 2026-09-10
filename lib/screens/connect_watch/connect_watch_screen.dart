import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ConnectWatchScreen extends StatefulWidget {
  const ConnectWatchScreen({super.key});

  @override
  State<ConnectWatchScreen> createState() => _ConnectWatchScreenState();
}

class _ConnectWatchScreenState extends State<ConnectWatchScreen> {
  bool _searching = false;
  bool _connected = false;

  Future<void> _searchForWatch() async {
    setState(() {
      _searching = true;
    });

    // UI-only for Breakpoint 1.
    // Actual Bluetooth/watch communication will be integrated later.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _searching = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Watch search completed. Watch integration will be added later.',
        ),
      ),
    );
  }

  void _connectWatch() {
    setState(() {
      _connected = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Watch connected successfully.'),
      ),
    );
  }

  void _skipForNow() {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProgressIndicator(),

              const SizedBox(height: 40),

              Text(
                'Connect Your Smartwatch',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkNavy,
                    ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Connect RAPID REACH with your smartwatch '
                'to enable continuous emergency monitoring.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF66758C),
                ),
              ),

              const SizedBox(height: 40),

              _buildWatchIllustration(),

              const SizedBox(height: 40),

              if (_connected)
                _buildConnectedCard()
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _searching ? null : _searchForWatch,
                    icon: _searching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.bluetooth_searching_rounded,
                          ),
                    label: Text(
                      _searching
                          ? 'Searching for Watch...'
                          : 'Search for Watch',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.primaryBlue.withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
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
                  child: OutlinedButton.icon(
                    onPressed: _connectWatch,
                    icon: const Icon(
                      Icons.watch_rounded,
                    ),
                    label: const Text(
                      'Connect Watch',
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
              ],

              const SizedBox(height: 20),

              TextButton(
                onPressed: _skipForNow,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: AppTheme.darkNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

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

  Widget _progressDot({required bool active}) {
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
          width: 270,
          height: 270,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightBlue.withValues(alpha: 0.7),
          ),
        ),

        Container(
          width: 220,
          height: 220,
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
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.lightBlue,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.18),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _connected
                    ? Icons.bluetooth_connected_rounded
                    : Icons.watch_rounded,
                color: AppTheme.primaryBlue,
                size: 60,
              ),
              const SizedBox(height: 12),
              Text(
                _connected ? 'CONNECTED' : 'WATCH',
                style: const TextStyle(
                  color: AppTheme.darkNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppTheme.primaryBlue,
            size: 30,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Your smartwatch is connected to RAPID REACH.',
              style: TextStyle(
                color: AppTheme.darkNavy,
                fontWeight: FontWeight.w700,
              ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.lightBlue,
        ),
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
              'A connected smartwatch can later be used '
              'for continuous emergency monitoring and '
              'activity-related alerts.',
              style: TextStyle(
                color: Color(0xFF52627A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}