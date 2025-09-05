import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisProgressIndicator extends StatefulWidget {
  final String currentStage;
  final double progress;
  final List<String> stages;
  final int currentStageIndex;

  const AnalysisProgressIndicator({
    super.key,
    required this.currentStage,
    required this.progress,
    required this.stages,
    required this.currentStageIndex,
  });

  @override
  State<AnalysisProgressIndicator> createState() =>
      _AnalysisProgressIndicatorState();
}

class _AnalysisProgressIndicatorState extends State<AnalysisProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  @override
  void didUpdateWidget(AnalysisProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildProgressHeader(),
          SizedBox(height: 3.h),
          _buildProgressBar(),
          SizedBox(height: 3.h),
          _buildStagesList(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentGreen,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'psychology',
                    color: AppTheme.accentGreen,
                    size: 6.w,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تحليل الذكاء الاصطناعي',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                widget.currentStage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Text(
          '${(widget.progress * 100).toInt()}%',
          style: AppTheme.tradingDataMedium.copyWith(
            color: AppTheme.accentGreen,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 1.h,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: 1.h,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width:
                    (widget.progress * _progressAnimation.value) * 100.w * 0.82,
                height: 1.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentGreen,
                      AppTheme.goldColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStagesList() {
    return Column(
      children: widget.stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isCompleted = index < widget.currentStageIndex;
        final isCurrent = index == widget.currentStageIndex;
        final isUpcoming = index > widget.currentStageIndex;

        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Row(
            children: [
              _buildStageIcon(isCompleted, isCurrent, isUpcoming),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  stage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCompleted || isCurrent
                            ? AppTheme.textPrimary
                            : AppTheme.textTertiary,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
              if (isCompleted)
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.accentGreen,
                  size: 5.w,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStageIcon(bool isCompleted, bool isCurrent, bool isUpcoming) {
    if (isCompleted) {
      return Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: AppTheme.accentGreen,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'check',
            color: AppTheme.primaryDark,
            size: 3.w,
          ),
        ),
      );
    } else if (isCurrent) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * 0.8 + 0.2,
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.goldColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      );
    }
  }
}
