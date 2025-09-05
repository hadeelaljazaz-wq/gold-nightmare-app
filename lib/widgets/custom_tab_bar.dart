import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_theme.dart';

enum CustomTabBarVariant {
  primary,
  secondary,
  minimal,
  pills,
  underline,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CustomTab> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final CustomTabBarVariant variant;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? indicatorWeight;
  final TabBarIndicatorSize? indicatorSize;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.variant = CustomTabBarVariant.primary,
    this.isScrollable = false,
    this.padding,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorWeight,
    this.indicatorSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: backgroundColor ?? _getBackgroundColor(isDark),
      padding: padding ?? _getPadding(),
      child: _buildTabBar(context, isDark),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    switch (variant) {
      case CustomTabBarVariant.primary:
        return _buildPrimaryTabBar(context, isDark);
      case CustomTabBarVariant.secondary:
        return _buildSecondaryTabBar(context, isDark);
      case CustomTabBarVariant.minimal:
        return _buildMinimalTabBar(context, isDark);
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context, isDark);
      case CustomTabBarVariant.underline:
        return _buildUnderlineTabBar(context, isDark);
    }
  }

  Widget _buildPrimaryTabBar(BuildContext context, bool isDark) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      tabs: tabs.map((tab) => _buildTab(tab, context)).toList(),
      isScrollable: isScrollable,
      labelColor: AppTheme.textPrimary,
      unselectedLabelColor: AppTheme.textTertiary,
      indicatorColor: indicatorColor ?? AppTheme.accentGreen,
      indicatorWeight: indicatorWeight ?? 3.0,
      indicatorSize: indicatorSize ?? TabBarIndicatorSize.label,
      labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
      unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Widget _buildSecondaryTabBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        tabs: tabs.map((tab) => _buildTab(tab, context)).toList(),
        isScrollable: isScrollable,
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: AppTheme.textSecondary,
        indicator: BoxDecoration(
          color: AppTheme.accentGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildMinimalTabBar(BuildContext context, bool isDark) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      tabs: tabs.map((tab) => _buildMinimalTab(tab, context)).toList(),
      isScrollable: isScrollable,
      labelColor: AppTheme.textPrimary,
      unselectedLabelColor: AppTheme.textTertiary,
      indicatorColor: Colors.transparent,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
      unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Widget _buildPillsTabBar(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = controller?.index == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                controller?.animateTo(index);
                onTap?.call(index);
              },
              child: AnimatedContainer(
                duration: AppTheme.fastAnimation,
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.accentGreen : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentGreen
                        : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? AppTheme.primaryDark
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      tab.text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppTheme.primaryDark
                                : AppTheme.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUnderlineTabBar(BuildContext context, bool isDark) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      tabs: tabs.map((tab) => _buildTab(tab, context)).toList(),
      isScrollable: isScrollable,
      labelColor: AppTheme.accentGreen,
      unselectedLabelColor: AppTheme.textSecondary,
      indicatorColor: AppTheme.accentGreen,
      indicatorWeight: 2.0,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
      dividerHeight: 1,
      dividerColor: AppTheme.borderColor.withValues(alpha: 0.3),
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
    );
  }

  Widget _buildTab(CustomTab tab, BuildContext context) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                tab.text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warningRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tab.badge!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalTab(CustomTab tab, BuildContext context) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          tab.text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    switch (variant) {
      case CustomTabBarVariant.primary:
      case CustomTabBarVariant.underline:
        return isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
      case CustomTabBarVariant.secondary:
      case CustomTabBarVariant.pills:
        return isDark ? AppTheme.secondaryDark : AppTheme.backgroundLight;
      case CustomTabBarVariant.minimal:
        return Colors.transparent;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (variant) {
      case CustomTabBarVariant.primary:
      case CustomTabBarVariant.underline:
        return const EdgeInsets.symmetric(horizontal: 16);
      case CustomTabBarVariant.secondary:
        return const EdgeInsets.all(4);
      case CustomTabBarVariant.pills:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case CustomTabBarVariant.minimal:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
    }
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomTabBarVariant.primary:
      case CustomTabBarVariant.underline:
        return const Size.fromHeight(48);
      case CustomTabBarVariant.secondary:
        return const Size.fromHeight(56);
      case CustomTabBarVariant.pills:
        return const Size.fromHeight(52);
      case CustomTabBarVariant.minimal:
        return const Size.fromHeight(40);
    }
  }
}

class CustomTab {
  final String text;
  final IconData? icon;
  final String? badge;
  final String? route;

  const CustomTab({
    required this.text,
    this.icon,
    this.badge,
    this.route,
  });
}

// Helper widget for TabBarView with custom tabs
class CustomTabBarView extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;
  final DragStartBehavior dragStartBehavior;
  final double? viewportFraction;

  const CustomTabBarView({
    super.key,
    required this.children,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.viewportFraction,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      viewportFraction: viewportFraction ?? 1.0,
      children: children,
    );
  }
}
