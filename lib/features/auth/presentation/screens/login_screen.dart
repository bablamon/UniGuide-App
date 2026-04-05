import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_service.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }
  static const _lastSentKey = 'lastMagicLinkSent';
  static const _cooldownSeconds = 60;

  @override
  void dispose() {
    _floatController.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<bool> _canSend() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSentMs = prefs.getInt(_lastSentKey);
    if (lastSentMs == null) return true;
    final diff = DateTime.now().millisecondsSinceEpoch - lastSentMs;
    return diff > (_cooldownSeconds * 1000);
  }

  Future<int> _secondsRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSentMs = prefs.getInt(_lastSentKey);
    if (lastSentMs == null) return 0;
    final elapsed = (DateTime.now().millisecondsSinceEpoch - lastSentMs) ~/ 1000;
    return (_cooldownSeconds - elapsed).clamp(0, _cooldownSeconds);
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _canSend()) {
      final secs = await _secondsRemaining();
      _showSnack('Please wait $secs seconds before requesting another link.');
      return;
    }
    setState(() => _loading = true);
    final error = await ref.read(authServiceProvider).sendMagicLink(_emailCtrl.text);
    if (error == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSentKey, DateTime.now().millisecondsSinceEpoch);
    }
    setState(() { _loading = false; });
    if (!mounted) return;
    if (error != null) {
      _showSnack(error);
    } else {
      context.push('/check-email', extra: _emailCtrl.text.trim().toLowerCase());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    final error = await ref.read(authServiceProvider).signInWithGoogle();
    setState(() => _googleLoading = false);
    if (!mounted) return;
    if (error != null) _showSnack(error);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final secondaryTextColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final bannerBg = isDark ? AppTheme.accent.withValues(alpha: 0.10) : AppTheme.accentLight;
    final bannerBorderColor = AppTheme.accent.withValues(alpha: isDark ? 0.18 : 0.30);
    final bannerTextColor = isDark ? AppTheme.accent : AppTheme.accentDark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Logo — floating animation
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        sin(_floatController.value * 2 * pi) * 3,
                        _floatAnimation.value,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.bgSurfaceDark : AppTheme.bgDark,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.layers_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 24),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primaryTextColor),
                    children: const [
                      TextSpan(text: 'Welcome to\n'),
                      TextSpan(text: 'UniGuide', style: TextStyle(color: AppTheme.accent)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your campus, simplified.\nConnect, correct, stay informed.',
                  textAlign: TextAlign.center,
                  style: AppText.bodySmall.copyWith(color: secondaryTextColor),
                ),
                const SizedBox(height: 40),

                // Email field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('EMAIL ADDRESS', style: AppText.label.copyWith(color: secondaryTextColor)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _send(),
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    final reg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!reg.hasMatch(v.trim())) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Info banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: bannerBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bannerBorderColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 15, color: bannerTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "We'll send a magic link — no password needed.",
                          style: TextStyle(fontSize: 12, color: bannerTextColor, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Magic link button
                _loading
                    ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
                    : ElevatedButton(onPressed: _send, child: const Text('Send magic link')),

                const SizedBox(height: 20),

                // OR divider
                Row(
                  children: [
                    Expanded(child: Divider(color: secondaryTextColor.withValues(alpha: 0.3), thickness: 0.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                    ),
                    Expanded(child: Divider(color: secondaryTextColor.withValues(alpha: 0.3), thickness: 0.5)),
                  ],
                ),

                const SizedBox(height: 20),

                // Google sign-in button
                _googleLoading
                    ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(color: AppTheme.accent)))
                    : OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: Image.asset('assets/images/google_logo.png', height: 20, width: 20,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 22)),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: BorderSide(color: secondaryTextColor.withValues(alpha: 0.3)),
                          foregroundColor: primaryTextColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                const SizedBox(height: 72),

                // Gen Z quote
                Column(
                  children: [
                    Text(
                      '"anonymity?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: primaryTextColor,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'we got you."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: primaryTextColor,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '— no tracking. no judgment. just you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                Text(
                  'By continuing you agree to our Terms of Service & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textHintDark : AppTheme.textHint,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Made by Atharva Deshmukh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppTheme.textHintDark : AppTheme.textHint,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
