import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CustomBottomBarVariant {
  main,
  trading,
  analysis,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final CustomBottomBarVariant variant;
  final bool showLabels;
  final double? elevation;
  final Color? backgroundColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.main,
    this.showLabels = true,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? _getBackgroundColor(isDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: elevation ?? 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: _getHeight(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(BuildContext context) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;

      return Expanded(
        child: _buildNavigationItem(
          context: context,
          item: item,
          isSelected: isSelected,
          onTap: () => _handleTap(context, index, item.route),
        ),
      );
    }).toList();
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required _NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.fastAnimation,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.accentGreen.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppTheme.fastAnimation,
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected && variant == CustomBottomBarVariant.trading
                    ? AppTheme.accentGreen.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: _getItemColor(isSelected, isDark),
                size: _getIconSize(),
              ),
            ),
            if (showLabels && item.label.isNotEmpty) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppTheme.fastAnimation,
                style: theme.textTheme.labelSmall!.copyWith(
                  color: _getItemColor(isSelected, isDark),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: _getLabelSize(),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (isSelected && variant == CustomBottomBarVariant.trading) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_NavigationItem> _getNavigationItems() {
    switch (variant) {
      case CustomBottomBarVariant.main:
        return [
          _NavigationItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/main-dashboard',
          ),
          _NavigationItem(
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics,
            label: 'Analysis',
            route: '/analysis-type-selection',
          ),
          _NavigationItem(
            icon: Icons.trending_up_outlined,
            selectedIcon: Icons.trending_up,
            label: 'Results',
            route: '/analysis-results',
          ),
          _NavigationItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
            route: '/settings',
          ),
        ];

      case CustomBottomBarVariant.trading:
        return [
          _NavigationItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            route: '/main-dashboard',
          ),
          _NavigationItem(
            icon: Icons.show_chart_outlined,
            selectedIcon: Icons.show_chart,
            label: 'Charts',
            route: '/charts',
          ),
          _NavigationItem(
            icon: Icons.psychology_outlined,
            selectedIcon: Icons.psychology,
            label: 'AI Analysis',
            route: '/ai-analysis-processing',
          ),
          _NavigationItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: 'Portfolio',
            route: '/portfolio',
          ),
          _NavigationItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            route: '/profile',
          ),
        ];

      case CustomBottomBarVariant.analysis:
        return [
          _NavigationItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            route: '/main-dashboard',
          ),
          _NavigationItem(
            icon: Icons.auto_awesome_outlined,
            selectedIcon: Icons.auto_awesome,
            label: 'AI Tools',
            route: '/analysis-type-selection',
          ),
          _NavigationItem(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            label: 'History',
            route: '/analysis-results',
          ),
        ];

      case CustomBottomBarVariant.minimal:
        return [
          _NavigationItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: '',
            route: '/main-dashboard',
          ),
          _NavigationItem(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search,
            label: '',
            route: '/search',
          ),
          _NavigationItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: '',
            route: '/profile',
          ),
        ];
    }
  }

  Color _getItemColor(bool isSelected, bool isDark) {
    if (isSelected) {
      return AppTheme.accentGreen;
    }
    return isDark ? AppTheme.textTertiary : AppTheme.textSecondaryLight;
  }

  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.analysis:
        return isDark ? AppTheme.secondaryDark : AppTheme.primaryLight;
      case CustomBottomBarVariant.trading:
        return isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
      case CustomBottomBarVariant.minimal:
        return isDark
            ? AppTheme.secondaryDark.withValues(alpha: 0.95)
            : AppTheme.primaryLight.withValues(alpha: 0.95);
    }
  }

  double _getHeight() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.analysis:
        return showLabels ? 70 : 60;
      case CustomBottomBarVariant.trading:
        return showLabels ? 75 : 65;
      case CustomBottomBarVariant.minimal:
        return 60;
    }
  }

  double _getIconSize() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.analysis:
        return 24;
      case CustomBottomBarVariant.trading:
        return 26;
      case CustomBottomBarVariant.minimal:
        return 22;
    }
  }

  double _getLabelSize() {
    switch (variant) {
      case CustomBottomBarVariant.main:
      case CustomBottomBarVariant.analysis:
        return 11;
      case CustomBottomBarVariant.trading:
        return 10;
      case CustomBottomBarVariant.minimal:
        return 10;
    }
  }

  void _handleTap(BuildContext context, int index, String route) {
    onTap(index);

    // Navigate to the corresponding route
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
