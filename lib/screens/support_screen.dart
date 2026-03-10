// path: lib/screens/support_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/spacing.dart';

class SupportScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const SupportScreen({super.key, this.onBack});

  static const _backgroundColor = Color(0xFF0B0B0B);
  static const _surfaceColor = Color(0xFF1A1A1A);
  static const _primaryOrange = Color(0xFFFF7A00);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF888888);

  static const String _phoneNumber = '+56963567384';
  static const String _displayPhone = '+56 9 6356 7384';

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.screenPadding),
                  child: _buildSupportCard(),
                ),
              ),
            ),
            _buildCallButton(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, size: 28),
        color: _textPrimary,
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: const Text(
        'Soporte',
        style: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xxl + AppSpacing.lg,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Support icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _primaryOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: _primaryOrange,
              size: 40,
            ),
          ),
          SizedBox(height: AppSpacing.xl),

          // Company name
          const Text(
            'ELECTRICAUTOMATICCHILE',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Phone number
          const Text(
            _displayPhone,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Availability text
          const Text(
            'Disponible de 09:00 a 18:00',
            style: TextStyle(color: _textSecondary, fontSize: 14),
          ),
          SizedBox(height: AppSpacing.sm),
          const Text(
            'Lunes a Viernes',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _makePhoneCall,
          icon: const Icon(Icons.phone, size: 22),
          label: const Text(
            'Llamar ahora',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
