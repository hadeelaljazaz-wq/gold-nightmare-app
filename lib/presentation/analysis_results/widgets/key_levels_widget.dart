import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KeyLevelsWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const KeyLevelsWidget({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entryPrice = (analysisData['entry_price'] as double?) ?? 0.0;
    final takeProfitLevels = (analysisData['take_profit'] as List?) ?? [];
    final stopLoss = (analysisData['stop_loss'] as double?) ?? 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'timeline',
                  color: AppTheme.goldColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'المستويات الرئيسية',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Entry Price
          if (entryPrice > 0) ...[
            _buildLevelItem(
              context,
              'نقطة الدخول',
              entryPrice,
              AppTheme.goldColor,
              Icons.login,
            ),
            SizedBox(height: 2.h),
          ],
          // Take Profit Levels
          if (takeProfitLevels.isNotEmpty) ...[
            Text(
              'أهداف الربح',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            ...takeProfitLevels.asMap().entries.map((entry) {
              final index = entry.key;
              final level = entry.value as double;
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: _buildLevelItem(
                  context,
                  'الهدف ${index + 1}',
                  level,
                  AppTheme.accentGreen,
                  Icons.flag,
                ),
              );
            }),
            SizedBox(height: 2.h),
          ],
          // Stop Loss
          if (stopLoss > 0) ...[
            _buildLevelItem(
              context,
              'وقف الخسارة',
              stopLoss,
              AppTheme.warningRed,
              Icons.block,
            ),
          ],
          SizedBox(height: 2.h),
          // Copy All Button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _copyAllLevels(context),
              icon: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.primaryDark,
                size: 18,
              ),
              label: Text(
                'نسخ جميع المستويات',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelItem(
    BuildContext context,
    String label,
    double price,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: () => _copyToClipboard(context, price),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: AppTheme.tradingDataMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _copyToClipboard(context, price),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.borderColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomIconWidget(
                  iconName: 'content_copy',
                  color: AppTheme.textTertiary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, double price) {
    Clipboard.setData(ClipboardData(text: price.toStringAsFixed(2)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ السعر: \$${price.toStringAsFixed(2)}'),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyAllLevels(BuildContext context) {
    final entryPrice = (analysisData['entry_price'] as double?) ?? 0.0;
    final takeProfitLevels = (analysisData['take_profit'] as List?) ?? [];
    final stopLoss = (analysisData['stop_loss'] as double?) ?? 0.0;

    String levelsText = 'المستويات الرئيسية:\n';

    if (entryPrice > 0) {
      levelsText += 'نقطة الدخول: \$${entryPrice.toStringAsFixed(2)}\n';
    }

    if (takeProfitLevels.isNotEmpty) {
      levelsText += 'أهداف الربح:\n';
      for (int i = 0; i < takeProfitLevels.length; i++) {
        final level = takeProfitLevels[i] as double;
        levelsText += 'الهدف ${i + 1}: \$${level.toStringAsFixed(2)}\n';
      }
    }

    if (stopLoss > 0) {
      levelsText += 'وقف الخسارة: \$${stopLoss.toStringAsFixed(2)}';
    }

    Clipboard.setData(ClipboardData(text: levelsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ جميع المستويات'),
        backgroundColor: AppTheme.accentGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
