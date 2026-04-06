import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/connectivity_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/wiki') || location.startsWith('/home')) return 0;
    if (location.startsWith('/qa')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          if (!isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? const Color(0xFF2A1F00) : const Color(0xFFFFF3E0),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 16,
                        color: isDark ? Colors.orange.shade300 : Colors.orange.shade800),
                    const SizedBox(width: 10),
                    Text(
                      'You\'re offline. Some features may not work.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.orange.shade300 : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.border,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Wiki',
                  active: currentIndex == 0,
                  onTap: () => context.go('/wiki'),
                ),
                _NavItem(
                  icon: Icons.forum_rounded,
                  label: 'Q&A',
                  active: currentIndex == 1,
                  onTap: () => context.go('/qa'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  active: currentIndex == 2,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppTheme.textHintDark : AppTheme.textHint;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? AppTheme.accent : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppTheme.accent : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
