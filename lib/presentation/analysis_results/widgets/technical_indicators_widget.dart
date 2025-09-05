import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TechnicalIndicatorsWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const TechnicalIndicatorsWidget({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicators =
        (analysisData['technical_indicators'] as Map<String, dynamic>?) ?? {};

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'show_chart',
                    color: AppTheme.goldColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'المؤشرات الفنية',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Indicators Horizontal List
          SizedBox(
            height: 20.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              children: [
                _buildIndicatorCard(
                  context,
                  'RSI',
                  (indicators['rsi'] as double?) ?? 65.0,
                  'مؤشر القوة النسبية',
                  _getRSISignal(indicators['rsi'] as double? ?? 65.0),
                ),
                _buildIndicatorCard(
                  context,
                  'MACD',
                  (indicators['macd'] as double?) ?? 0.5,
                  'تقارب وتباعد المتوسطات',
                  _getMACDSignal(indicators['macd'] as double? ?? 0.5),
                ),
                _buildIndicatorCard(
                  context,
                  'MA20',
                  (indicators['ma20'] as double?) ?? 2650.0,
                  'المتوسط المتحرك 20',
                  _getMASignal(indicators['ma20'] as double? ?? 2650.0),
                ),
                _buildIndicatorCard(
                  context,
                  'MA50',
                  (indicators['ma50'] as double?) ?? 2640.0,
                  'المتوسط المتحرك 50',
                  _getMASignal(indicators['ma50'] as double? ?? 2640.0),
                ),
                _buildIndicatorCard(
                  context,
                  'Stochastic',
                  (indicators['stochastic'] as double?) ?? 75.0,
                  'مؤشر العشوائية',
                  _getStochasticSignal(
                      indicators['stochastic'] as double? ?? 75.0),
                ),
                _buildIndicatorCard(
                  context,
                  'Bollinger',
                  (indicators['bollinger_position'] as double?) ?? 0.7,
                  'نطاقات بولينجر',
                  _getBollingerSignal(
                      indicators['bollinger_position'] as double? ?? 0.7),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Overall Signal Summary
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'analytics',
                      color: AppTheme.accentGreen,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'ملخص الإشارات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildSignalSummary(context, indicators),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(
    BuildContext context,
    String name,
    double value,
    String description,
    Map<String, dynamic> signal,
  ) {
    final theme = Theme.of(context);
    final signalColor = signal['color'] as Color;
    final signalText = signal['text'] as String;
    final signalIcon = signal['icon'] as IconData;

    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: signalColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: signalColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  signalIcon,
                  color: signalColor,
                  size: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Value
          Text(
            _formatIndicatorValue(name, value),
            style: AppTheme.tradingDataMedium.copyWith(
              color: signalColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          // Description
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Signal
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: signalColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              signalText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: signalColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalSummary(
      BuildContext context, Map<String, dynamic> indicators) {
    final theme = Theme.of(context);

    // Calculate overall signal
    int bullishSignals = 0;
    int bearishSignals = 0;
    int neutralSignals = 0;

    final rsiSignal = _getRSISignal(indicators['rsi'] as double? ?? 65.0);
    final macdSignal = _getMACDSignal(indicators['macd'] as double? ?? 0.5);
    final ma20Signal = _getMASignal(indicators['ma20'] as double? ?? 2650.0);
    final ma50Signal = _getMASignal(indicators['ma50'] as double? ?? 2640.0);
    final stochasticSignal =
        _getStochasticSignal(indicators['stochastic'] as double? ?? 75.0);
    final bollingerSignal =
        _getBollingerSignal(indicators['bollinger_position'] as double? ?? 0.7);

    final signals = [
      rsiSignal,
      macdSignal,
      ma20Signal,
      ma50Signal,
      stochasticSignal,
      bollingerSignal
    ];

    for (final signal in signals) {
      final signalType = signal['type'] as String;
      if (signalType == 'bullish') {
        bullishSignals++;
      } else if (signalType == 'bearish') {
        bearishSignals++;
      } else {
        neutralSignals++;
      }
    }

    final totalSignals = signals.length;
    final bullishPercentage = (bullishSignals / totalSignals * 100).round();
    final bearishPercentage = (bearishSignals / totalSignals * 100).round();
    final neutralPercentage = (neutralSignals / totalSignals * 100).round();

    String overallSignal;
    Color overallColor;
    IconData overallIcon;

    if (bullishSignals > bearishSignals) {
      overallSignal = 'صاعد';
      overallColor = AppTheme.accentGreen;
      overallIcon = Icons.trending_up;
    } else if (bearishSignals > bullishSignals) {
      overallSignal = 'هابط';
      overallColor = AppTheme.warningRed;
      overallIcon = Icons.trending_down;
    } else {
      overallSignal = 'محايد';
      overallColor = AppTheme.goldColor;
      overallIcon = Icons.remove;
    }

    return Column(
      children: [
        // Overall Signal
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: overallColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                overallIcon,
                color: overallColor,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'الاتجاه العام: $overallSignal',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: overallColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // Signal Distribution
        Row(
          children: [
            Expanded(
              child: _buildSignalPercentage(
                context,
                'صاعد',
                bullishPercentage,
                AppTheme.accentGreen,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildSignalPercentage(
                context,
                'هابط',
                bearishPercentage,
                AppTheme.warningRed,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildSignalPercentage(
                context,
                'محايد',
                neutralPercentage,
                AppTheme.goldColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignalPercentage(
    BuildContext context,
    String label,
    int percentage,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatIndicatorValue(String name, double value) {
    switch (name) {
      case 'RSI':
      case 'Stochastic':
        return value.toStringAsFixed(1);
      case 'MACD':
        return value.toStringAsFixed(3);
      case 'MA20':
      case 'MA50':
        return '\$${value.toStringAsFixed(2)}';
      case 'Bollinger':
        return '${(value * 100).toStringAsFixed(0)}%';
      default:
        return value.toStringAsFixed(2);
    }
  }

  Map<String, dynamic> _getRSISignal(double rsi) {
    if (rsi > 70) {
      return {
        'type': 'bearish',
        'text': 'ذروة شراء',
        'color': AppTheme.warningRed,
        'icon': Icons.trending_down,
      };
    } else if (rsi < 30) {
      return {
        'type': 'bullish',
        'text': 'ذروة بيع',
        'color': AppTheme.accentGreen,
        'icon': Icons.trending_up,
      };
    } else {
      return {
        'type': 'neutral',
        'text': 'محايد',
        'color': AppTheme.goldColor,
        'icon': Icons.remove,
      };
    }
  }

  Map<String, dynamic> _getMACDSignal(double macd) {
    if (macd > 0) {
      return {
        'type': 'bullish',
        'text': 'صاعد',
        'color': AppTheme.accentGreen,
        'icon': Icons.trending_up,
      };
    } else if (macd < 0) {
      return {
        'type': 'bearish',
        'text': 'هابط',
        'color': AppTheme.warningRed,
        'icon': Icons.trending_down,
      };
    } else {
      return {
        'type': 'neutral',
        'text': 'محايد',
        'color': AppTheme.goldColor,
        'icon': Icons.remove,
      };
    }
  }

  Map<String, dynamic> _getMASignal(double ma) {
    // Assuming current price is around 2660 for demo
    final currentPrice = 2660.0;
    if (currentPrice > ma) {
      return {
        'type': 'bullish',
        'text': 'فوق المتوسط',
        'color': AppTheme.accentGreen,
        'icon': Icons.trending_up,
      };
    } else if (currentPrice < ma) {
      return {
        'type': 'bearish',
        'text': 'تحت المتوسط',
        'color': AppTheme.warningRed,
        'icon': Icons.trending_down,
      };
    } else {
      return {
        'type': 'neutral',
        'text': 'عند المتوسط',
        'color': AppTheme.goldColor,
        'icon': Icons.remove,
      };
    }
  }

  Map<String, dynamic> _getStochasticSignal(double stochastic) {
    if (stochastic > 80) {
      return {
        'type': 'bearish',
        'text': 'ذروة شراء',
        'color': AppTheme.warningRed,
        'icon': Icons.trending_down,
      };
    } else if (stochastic < 20) {
      return {
        'type': 'bullish',
        'text': 'ذروة بيع',
        'color': AppTheme.accentGreen,
        'icon': Icons.trending_up,
      };
    } else {
      return {
        'type': 'neutral',
        'text': 'محايد',
        'color': AppTheme.goldColor,
        'icon': Icons.remove,
      };
    }
  }

  Map<String, dynamic> _getBollingerSignal(double position) {
    if (position > 0.8) {
      return {
        'type': 'bearish',
        'text': 'النطاق العلوي',
        'color': AppTheme.warningRed,
        'icon': Icons.trending_down,
      };
    } else if (position < 0.2) {
      return {
        'type': 'bullish',
        'text': 'النطاق السفلي',
        'color': AppTheme.accentGreen,
        'icon': Icons.trending_up,
      };
    } else {
      return {
        'type': 'neutral',
        'text': 'الوسط',
        'color': AppTheme.goldColor,
        'icon': Icons.remove,
      };
    }
  }
}
