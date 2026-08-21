import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/localization/localization_extension.dart';
import '../core/providers/settings_provider.dart';
import 'theme.dart';

class ShellScreen extends ConsumerWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    try {
      final location = GoRouterState.of(context).uri.toString();
      if (location == '/') return 0;
      if (location == '/queue-check') return 1;
      if (location == '/consistency') return 2;
      if (location == '/prayer-times') return 3;
      if (location == '/games') return 4;
      if (location == '/settings') return 5;
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(context);
    final activeTheme = ref.watch(effectiveThemeProvider);
    ref.watch(appLanguageProvider); // ensure rebuild on locale change

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
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: context.tr('nav_home'),
                  isSelected: currentIndex == 0,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.sports_esports_rounded,
                  label: context.tr('nav_queue'),
                  isSelected: currentIndex == 1,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/queue-check'),
                ),
                _NavItem(
                  icon: Icons.auto_graph_rounded,
                  label: context.tr('nav_heatmap'),
                  isSelected: currentIndex == 2,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/consistency'),
                ),
                _NavItem(
                  icon: Icons.schedule_rounded,
                  label: context.tr('nav_prayers'),
                  isSelected: currentIndex == 3,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/prayer-times'),
                ),
                _NavItem(
                  icon: Icons.videogame_asset_rounded,
                  label: context.tr('nav_profiles'),
                  isSelected: currentIndex == 4,
                  activeColor: activeTheme.primaryAccent,
                  onTap: () => context.go('/games'),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: context.tr('nav_settings'),
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
    final unselectedColor =
        Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          decoration: isSelected
              ? BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 21,
                color: isSelected ? activeColor : unselectedColor,
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : unselectedColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
