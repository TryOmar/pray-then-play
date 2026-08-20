import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/settings_provider.dart';
import 'theme.dart';

class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    if (location == '/queue-check') return 1;
    if (location == '/consistency') return 2;
    if (location == '/prayer-times') return 3;
    if (location == '/games') return 4;
    if (location == '/settings') return 5;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    final activeTheme = ref.watch(effectiveThemeProvider);

    return Scaffold(
      backgroundColor: activeTheme.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: activeTheme.surface,
          border: Border(
            top: BorderSide(
              color: activeTheme.surfaceHighlight.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: activeTheme.primaryAccent.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.sports_esports_rounded,
                  label: 'Queue',
                  isSelected: currentIndex == 1,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/queue-check'),
                ),
                _NavItem(
                  icon: Icons.auto_graph_rounded,
                  label: 'Consistency',
                  isSelected: currentIndex == 2,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/consistency'),
                ),
                _NavItem(
                  icon: Icons.schedule_rounded,
                  label: 'Prayer',
                  isSelected: currentIndex == 3,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/prayer-times'),
                ),
                _NavItem(
                  icon: Icons.videogame_asset_rounded,
                  label: 'Games',
                  isSelected: currentIndex == 4,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/games'),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentIndex == 5,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/settings'),
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
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: activeColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : unselectedColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
