import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class UploadDropZoneWidget extends StatefulWidget {
  final VoidCallback onTap;

  const UploadDropZoneWidget({
    super.key,
    required this.onTap,
  });

  @override
  State<UploadDropZoneWidget> createState() => _UploadDropZoneWidgetState();
}

class _UploadDropZoneWidgetState extends State<UploadDropZoneWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered ? 1.02 : _pulseAnimation.value,
              child: AnimatedContainer(
                duration: AppTheme.fastAnimation,
                height: 40.h,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppTheme.surfaceColor.withAlpha(204)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? AppTheme.accentGreen.withAlpha(153)
                        : AppTheme.borderColor.withAlpha(128),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Upload icon with background
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withAlpha(26),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentGreen.withAlpha(77),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 8.w,
                        color: AppTheme.accentGreen,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Main text
                    Text(
                      'اختر صورة الشارت للتحليل',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    SizedBox(height: 1.h),

                    // Subtitle
                    Text(
                      'اضغط لاختيار صورة من المعرض أو التقاط صورة جديدة',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),

                    SizedBox(height: 3.h),

                    // Action buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.camera_alt,
                          label: 'كاميرا',
                          color: AppTheme.accentGreen,
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          height: 30,
                          width: 1,
                          color: AppTheme.borderColor,
                        ),
                        SizedBox(width: 4.w),
                        _buildActionButton(
                          icon: Icons.photo_library,
                          label: 'معرض',
                          color: AppTheme.goldColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // File format info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'JPG, PNG, WebP • حتى 10 ميجا',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withAlpha(77),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 6.w,
            color: color,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}