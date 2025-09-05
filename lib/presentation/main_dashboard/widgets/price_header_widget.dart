import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PriceHeaderWidget extends StatefulWidget {
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final String lastUpdate;
  final bool isConnected;

  const PriceHeaderWidget({
    super.key,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.lastUpdate,
    required this.isConnected,
  });

  @override
  State<PriceHeaderWidget> createState() => _PriceHeaderWidgetState();
}

class _PriceHeaderWidgetState extends State<PriceHeaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double _previousPrice = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _previousPrice = widget.currentPrice;
  }

  @override
  void didUpdateWidget(PriceHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPrice != widget.currentPrice) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      _previousPrice = oldWidget.currentPrice;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.priceChange >= 0;
    final Color changeColor =
        isPositive ? AppTheme.accentGreen : AppTheme.warningRed;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Connection Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isConnected
                            ? AppTheme.accentGreen
                            : AppTheme.warningRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      widget.isConnected ? 'متصل' : 'غير متصل',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: widget.isConnected
                            ? AppTheme.accentGreen
                            : AppTheme.warningRed,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  'XAUUSD',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.goldColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Price Display
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$',
                        style: AppTheme.tradingDataLarge.copyWith(
                          fontSize: 16.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        widget.currentPrice.toStringAsFixed(2),
                        style: AppTheme.tradingDataLarge.copyWith(
                          fontSize: 24.sp,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 0.5.h),

            // Price Change
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: changeColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: isPositive ? 'trending_up' : 'trending_down',
                    color: changeColor,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${isPositive ? '+' : ''}${widget.priceChange.toStringAsFixed(2)}',
                    style: AppTheme.tradingDataMedium.copyWith(
                      fontSize: 14.sp,
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '(${isPositive ? '+' : ''}${widget.priceChangePercent.toStringAsFixed(2)}%)',
                    style: AppTheme.tradingDataMedium.copyWith(
                      fontSize: 12.sp,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 1.h),

            // Last Update
            Text(
              'آخر تحديث: ${widget.lastUpdate}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
