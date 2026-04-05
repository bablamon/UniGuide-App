import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const CheckEmailScreen({super.key, required this.email});

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen> {
  int _seconds = 900; // 15 min countdown
  int _resendCooldown = 0;
  Timer? _timer;
  Timer? _resendTimer;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _timeLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _resending) return;
    setState(() => _resending = true);
    final error = await ref.read(authServiceProvider).sendMagicLink(widget.email);
    setState(() { _resending = false; _resendCooldown = 60; _seconds = 900; });
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New magic link sent!')),
      );
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_resendCooldown > 0) {
          setState(() => _resendCooldown--);
        } else {
          _resendTimer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _seconds / 900;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: const Icon(Icons.mark_email_read_rounded, size: 32, color: AppTheme.accent),
              ),
              const SizedBox(height: 20),

              Text('Check your inbox', style: AppText.h2),
              const SizedBox(height: 8),
              const Text('We sent a magic link to', style: AppText.bodySmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.email,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap the link in that email to sign in.\nNo password needed.',
                textAlign: TextAlign.center,
                style: AppText.bodySmall,
              ),
              const SizedBox(height: 28),

              // Timer card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.timer_outlined, size: 18, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Link expires in', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            Text('For your security', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        Text(_timeLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.accent)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.bgSurface,
                        color: AppTheme.accent,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final Uri gmailUri = Uri.parse('googlegmail://');
                    final Uri mailtoUri = Uri.parse('mailto:');

                    if (await canLaunchUrl(gmailUri)) {
                      await launchUrl(gmailUri);
                    } else if (await canLaunchUrl(mailtoUri)) {
                      await launchUrl(mailtoUri);
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open email app'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const Spacer(),

              // Resend / change email links
              _resending
                  ? const CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2)
                  : TextButton(
                      onPressed: _resendCooldown > 0 ? null : _resend,
                      child: Text(
                        _resendCooldown > 0
                            ? 'Resend in ${_resendCooldown}s'
                            : "Didn't receive it? Resend link",
                      ),
                    ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Wrong email? Change email', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
