import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisHeader extends StatelessWidget {
  final String analysisType;
  final String goldPrice;
  final DateTime startTime;

  const AnalysisHeader({
    super.key,
    required this.analysisType,
    required this.goldPrice,
    required this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryDark,
            AppTheme.secondaryDark.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAnalysisTypeSection(context),
          SizedBox(height: 2.h),
          _buildPriceAndTimeSection(context),
        ],
      ),
    );
  }

  Widget _buildAnalysisTypeSection(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.goldColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.goldColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: _getAnalysisIcon(),
              color: AppTheme.goldColor,
              size: 6.w,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نوع التحليل',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                _getArabicAnalysisType(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGreen.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'نشط',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndTimeSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            icon: 'attach_money',
            label: 'سعر الذهب',
            value: goldPrice,
            color: AppTheme.goldColor,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildInfoCard(
            context,
            icon: 'access_time',
            label: 'وقت البدء',
            value: _formatTime(startTime),
            color: AppTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.tradingDataSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getAnalysisIcon() {
    switch (analysisType.toLowerCase()) {
      case 'quick':
        return 'flash_on';
      case 'detailed':
        return 'analytics';
      case 'scalping':
        return 'speed';
      case 'swing':
        return 'trending_up';
      case 'forecast':
        return 'visibility';
      case 'reversal':
        return 'refresh';
      case 'nightmare':
        return 'psychology';
      default:
        return 'auto_awesome';
    }
  }

  String _getArabicAnalysisType() {
    switch (analysisType.toLowerCase()) {
      case 'quick':
        return 'تحليل سريع';
      case 'detailed':
        return 'تحليل مفصل';
      case 'scalping':
        return 'تحليل سكالبينغ';
      case 'swing':
        return 'تحليل متأرجح';
      case 'forecast':
        return 'تحليل توقعات';
      case 'reversal':
        return 'تحليل انعكاس';
      case 'nightmare':
        return 'تحليل نايتمير الكامل';
      default:
        return 'تحليل الذكاء الاصطناعي';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
