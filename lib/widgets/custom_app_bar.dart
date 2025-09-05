import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum CustomAppBarVariant {
  main,
  analysis,
  settings,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.main,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildTitle(context),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      centerTitle: centerTitle,
      elevation: elevation ?? _getElevation(),
      backgroundColor: backgroundColor ?? _getBackgroundColor(isDark),
      foregroundColor: foregroundColor ?? _getForegroundColor(isDark),
      surfaceTintColor: Colors.transparent,
      shadowColor: _getShadowColor(isDark),
      systemOverlayStyle: _getSystemOverlayStyle(isDark),
      bottom: bottom,
      automaticallyImplyLeading: false,
      titleSpacing: _getTitleSpacing(),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.main:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              color: AppTheme.goldColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        );

      case CustomAppBarVariant.analysis:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'AI Analysis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        );

      case CustomAppBarVariant.settings:
        return Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        );

      case CustomAppBarVariant.minimal:
        return Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        );
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
        iconSize: 20,
        padding: const EdgeInsets.all(12),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final defaultActions = <Widget>[];

    switch (variant) {
      case CustomAppBarVariant.main:
        defaultActions.addAll([
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ]);
        break;

      case CustomAppBarVariant.analysis:
        defaultActions.addAll([
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareAnalysis(context),
            tooltip: 'Share Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _saveAnalysis(context),
            tooltip: 'Save Analysis',
          ),
        ]);
        break;

      case CustomAppBarVariant.settings:
        defaultActions.addAll([
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
            tooltip: 'Help',
          ),
        ]);
        break;

      case CustomAppBarVariant.minimal:
        // No default actions for minimal variant
        break;
    }

    if (actions != null) {
      defaultActions.addAll(actions!);
    }

    return defaultActions.isNotEmpty ? defaultActions : null;
  }

  double _getElevation() {
    switch (variant) {
      case CustomAppBarVariant.main:
        return 0;
      case CustomAppBarVariant.analysis:
        return 2;
      case CustomAppBarVariant.settings:
        return 0;
      case CustomAppBarVariant.minimal:
        return 0;
    }
  }

  Color _getBackgroundColor(bool isDark) {
    if (isDark) {
      switch (variant) {
        case CustomAppBarVariant.main:
          return AppTheme.primaryDark;
        case CustomAppBarVariant.analysis:
          return AppTheme.secondaryDark;
        case CustomAppBarVariant.settings:
          return AppTheme.primaryDark;
        case CustomAppBarVariant.minimal:
          return Colors.transparent;
      }
    } else {
      return AppTheme.primaryLight;
    }
  }

  Color _getForegroundColor(bool isDark) {
    return isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
  }

  Color _getShadowColor(bool isDark) {
    return isDark
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(bool isDark) {
    return isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          );
  }

  double _getTitleSpacing() {
    switch (variant) {
      case CustomAppBarVariant.main:
        return 0;
      case CustomAppBarVariant.analysis:
        return 16;
      case CustomAppBarVariant.settings:
        return 16;
      case CustomAppBarVariant.minimal:
        return 16;
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('No new notifications'),
          ],
        ),
      ),
    );
  }

  void _shareAnalysis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analysis shared successfully')),
    );
  }

  void _saveAnalysis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analysis saved successfully')),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: const Text('Help'),
        content: const Text('Help information will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
