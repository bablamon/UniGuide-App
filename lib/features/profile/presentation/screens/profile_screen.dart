import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:math';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/data/auth_service.dart';

const _photoKey = 'profile_photo_path';

final _questionCountProvider = FutureProvider<int>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return 0;
  final data = await Supabase.instance.client
      .from('questions')
      .select('id')
      .eq('author_uid', uid);
  return data.length;
});

final _answerCountProvider = FutureProvider<int>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return 0;
  final data = await Supabase.instance.client
      .from('answers')
      .select('id')
      .eq('author_uid', uid);
  return data.length;
});

final _bookmarkCountProvider = FutureProvider<int>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return 0;
  final data = await Supabase.instance.client
      .from('bookmarks')
      .select('id')
      .eq('user_id', uid);
  return data.length;
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String? _localPhotoPath;
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _loadLocalPhoto();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_photoKey);
    if (path != null && File(path).existsSync()) {
      setState(() => _localPhotoPath = path);
    }
  }

  Future<void> _pickPhoto() async {
    final source = await _showSourcePicker();
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoKey, picked.path);
    setState(() => _localPhotoPath = picked.path);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')));
    }
  }

  Future<ImageSource?> _showSourcePicker() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Set profile photo',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 20),
            _SourceOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take a photo',
                onTap: () => Navigator.pop(context, ImageSource.camera)),
            const SizedBox(height: 10),
            _SourceOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from gallery',
                onTap: () => Navigator.pop(context, ImageSource.gallery)),
            const SizedBox(height: 10),
            if (_localPhotoPath != null)
              _SourceOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove photo',
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove(_photoKey);
                    setState(() => _localPhotoPath = null);
                    if (mounted) Navigator.pop(context);
                  }),
            const SizedBox(height: 10),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final questionCount = ref.watch(_questionCountProvider);
    final answerCount = ref.watch(_answerCountProvider);
    final bookmarkCount = ref.watch(_bookmarkCountProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: uid != null
              ? Supabase.instance.client
                  .from('users')
                  .stream(primaryKey: ['id'])
                  .eq('id', uid)
              : Stream.value(<Map<String, dynamic>>[]),
          builder: (context, snap) {
            final data =
                snap.data?.isNotEmpty == true ? snap.data!.first : null;
            final displayTag = data?['display_tag'] ?? 'Student';
            final year = data?['year'];
            final branch = data?['branch'] ?? '';
            final email =
                Supabase.instance.client.auth.currentUser?.email ?? '';
            final initial = branch.isNotEmpty ? branch[0] : 'S';

            return SingleChildScrollView(
              child: Column(children: [
                // Hero header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1C1C1C)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: Stack(children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: AppTheme.accent,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color:
                                              Colors.white.withValues(alpha: 0.2),
                                          width: 2)),
                                  child: _localPhotoPath != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.file(
                                              File(_localPhotoPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Center(
                                                      child: Text(initial,
                                                          style: const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight.w800,
                                                              color: Colors
                                                                  .white)))))
                                      : Center(
                                          child: Text(initial,
                                              style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white))),
                                ),
                                Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: AppTheme.accent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF1C1C1C)
                                                    : const Color(0xFF1A1A1A),
                                                width: 2)),
                                        child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 10,
                                            color: Colors.white))),
                              ]),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(displayTag,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                  const SizedBox(height: 3),
                                  Text(email,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF666666)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ])),
                            GestureDetector(
                                onTap: _pickPhoto,
                                child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.edit_rounded,
                                        size: 16,
                                        color: Color(0xFF888888)))),
                          ]),
                          const SizedBox(height: 20),

                          // Stats
                          Row(children: [
                            _HeroStat(
                                label: 'QUESTIONS',
                                value: questionCount.when(
                                    data: (v) => '$v',
                                    loading: () => '...',
                                    error: (_, __) => '0')),
                            _divider(),
                            _HeroStat(
                                label: 'ANSWERS',
                                value: answerCount.when(
                                    data: (v) => '$v',
                                    loading: () => '...',
                                    error: (_, __) => '0')),
                            _divider(),
                            _HeroStat(
                                label: 'BOOKMARKS',
                                value: bookmarkCount.when(
                                    data: (v) => '$v',
                                    loading: () => '...',
                                    error: (_, __) => '0')),
                          ]),
                        ]),
                  ),
                ),

                const SizedBox(height: 16),

                // Info cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.school_rounded,
                            label: 'Year',
                            value: year != null ? 'Year $year' : 'Not set',
                            iconColor: AppTheme.accent,
                            iconBg: AppTheme.accentLight,
                            isDark: isDark,
                            cs: cs)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _InfoCard(
                            icon: Icons.account_tree_rounded,
                            label: 'Branch',
                            value:
                                branch.isNotEmpty ? branch : 'Not set',
                            iconColor: AppTheme.green,
                            iconBg: AppTheme.greenLight,
                            isDark: isDark,
                            cs: cs)),
                  ]),
                ),

                const SizedBox(height: 16),

                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('SETTINGS',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface.withValues(alpha: 0.4),
                                letterSpacing: 0.8)))),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: [
                    _SettingsTile(
                        icon: Icons.forum_rounded,
                        iconColor: AppTheme.green,
                        iconBg: AppTheme.greenLight,
                        label: 'My questions',
                        subtitle: 'Questions you\'ve asked',
                        onTap: () => context.push('/profile/my-questions'),
                        isDark: isDark,
                        cs: cs),
                    _SettingsTile(
                        icon: Icons.bookmark_border_rounded,
                        iconColor: const Color(0xFF185FA5),
                        iconBg: const Color(0xFFE0EEFF),
                        label: 'Saved articles',
                        subtitle: 'Your bookmarked guides',
                        onTap: () => context.push('/profile/bookmarks'),
                        isDark: isDark,
                        cs: cs),
                    _SettingsTile(
                        icon: Icons.school_rounded,
                        iconColor: AppTheme.accent,
                        iconBg: AppTheme.accentLight,
                        label: 'Update year & branch',
                        subtitle: year != null && branch.isNotEmpty
                            ? 'Year $year · $branch'
                            : 'Not set yet',
                        onTap: () => context.push('/onboarding'),
                        isDark: isDark,
                        cs: cs),

                    // Dark mode toggle
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : AppTheme.border,
                              width: 0.5)),
                      child: Row(children: [
                        Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFFDF0D8),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.amber
                                    : const Color(0xFF854F0B))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Dark mode',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface)),
                              Text(
                                  isDark
                                      ? 'Currently dark'
                                      : 'Currently light',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          cs.onSurface.withValues(alpha: 0.5))),
                            ])),
                        CupertinoSwitch(
                            value: isDark,
                            activeTrackColor: AppTheme.accent,
                            onChanged: (_) =>
                                ref.read(themeProvider.notifier).toggle()),
                      ]),
                    ),
                  ]),
                ),

                const SizedBox(height: 6),

                // Sign out
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: GestureDetector(
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A1A1A)
                              : const Color(0xFFFCEBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFF09595)
                                  .withValues(alpha: 0.4),
                              width: 0.5)),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                size: 16, color: Color(0xFFE24B4A)),
                            SizedBox(width: 8),
                            Text('Sign out',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE24B4A))),
                          ]),
                    ),
                  ),
                ),

                // Floating quote
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                  child: AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        sin(_floatController.value * 2 * pi) * 3,
                        _floatAnimation.value,
                      ),
                      child: child,
                    ),
                    child: Column(children: [
                      Text(
                        '"anonymity?\nwe got you."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                          height: 1.15,
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
                          color: cs.onSurface.withValues(alpha: 0.35),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _divider() => Container(
      width: 0.5,
      height: 32,
      color: Colors.white.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 16));
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceOption(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: const Color(0xFFE0DDD8), width: 0.5)),
        child: Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: AppTheme.accent)),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
        ]),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label, value;
  const _HeroStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
                letterSpacing: 0.5)),
      ]));
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value;
  final bool isDark;
  final ColorScheme cs;
  const _InfoCard(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.label,
      required this.value,
      required this.isDark,
      required this.cs});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.border,
                width: 0.5)),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgSurfaceDark : iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.5))),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
              ])),
        ]),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final ColorScheme cs;
  const _SettingsTile(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.label,
      required this.subtitle,
      required this.onTap,
      required this.isDark,
      required this.cs});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.border,
                  width: 0.5)),
          child: Row(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: isDark ? AppTheme.bgSurfaceDark : iconBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: iconColor)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.5))),
                ])),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurface.withValues(alpha: 0.3)),
          ]),
        ),
      );
}
