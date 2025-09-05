import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/analysis_type_card.dart';
import './widgets/header_widget.dart';
import './widgets/subscription_tier_widget.dart';

class AnalysisTypeSelection extends StatefulWidget {
  const AnalysisTypeSelection({super.key});

  @override
  State<AnalysisTypeSelection> createState() => _AnalysisTypeSelectionState();
}

class _AnalysisTypeSelectionState extends State<AnalysisTypeSelection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Mock user data
  final String currentTier = 'Basic';
  final int remainingAnalyses = 35;
  final int totalAnalyses = 50;

  // Mock analysis types data
  final List<Map<String, dynamic>> analysisTypes = [
    {
      "id": "quick",
      "title": "تحليل سريع",
      "titleEn": "Quick Analysis",
      "description": "تحليل فوري للذهب مع توصيات BUY/SELL وأهداف الربح",
      "descriptionEn":
          "Instant gold analysis with BUY/SELL recommendations and profit targets",
      "estimatedTime": "1-2 دقيقة",
      "estimatedTimeEn": "1-2 minutes",
      "iconName": "flash_on",
      "isPremium": false,
      "isAvailable": true,
      "usageCount": 12,
      "maxUsage": 20,
      "accuracyRate": 0.87,
      "route": "/ai-analysis-processing"
    },
    {
      "id": "detailed",
      "title": "تحليل مفصل",
      "titleEn": "Detailed Analysis",
      "description": "تحليل شامل مع مستويات الدعم والمقاومة وتوقعات السوق",
      "descriptionEn":
          "Comprehensive analysis with support/resistance levels and market forecasts",
      "estimatedTime": "5-10 دقائق",
      "estimatedTimeEn": "5-10 minutes",
      "iconName": "analytics",
      "isPremium": false,
      "isAvailable": true,
      "usageCount": 8,
      "maxUsage": 15,
      "accuracyRate": 0.92,
      "route": "/ai-analysis-processing"
    },
    {
      "id": "scalping",
      "title": "تحليل السكالبينغ",
      "titleEn": "Scalping Analysis",
      "description": "تحليل للتداول السريع على الإطار الزمني 1-15 دقيقة",
      "descriptionEn": "Analysis for quick trading on 1-15 minute timeframes",
      "estimatedTime": "2-3 دقائق",
      "estimatedTimeEn": "2-3 minutes",
      "iconName": "speed",
      "isPremium": true,
      "isAvailable": false,
      "usageCount": 5,
      "maxUsage": 5,
      "accuracyRate": 0.89,
      "route": "/ai-analysis-processing"
    },
    {
      "id": "swing",
      "title": "تحليل التداول المتأرجح",
      "titleEn": "Swing Trading",
      "description": "تحليل للصفقات متوسطة المدى مع استراتيجيات متقدمة",
      "descriptionEn":
          "Analysis for medium-term trades with advanced strategies",
      "estimatedTime": "7-12 دقيقة",
      "estimatedTimeEn": "7-12 minutes",
      "iconName": "trending_up",
      "isPremium": true,
      "isAvailable": true,
      "usageCount": 3,
      "maxUsage": 10,
      "accuracyRate": 0.94,
      "route": "/ai-analysis-processing"
    },
    {
      "id": "forecast",
      "title": "توقعات السوق",
      "titleEn": "Market Forecast",
      "description": "توقعات مستقبلية لحركة الذهب مع تحليل الاتجاهات",
      "descriptionEn":
          "Future predictions for gold movement with trend analysis",
      "estimatedTime": "8-15 دقيقة",
      "estimatedTimeEn": "8-15 minutes",
      "iconName": "visibility",
      "isPremium": true,
      "isAvailable": true,
      "usageCount": 2,
      "maxUsage": 8,
      "accuracyRate": 0.91,
      "route": "/ai-analysis-processing"
    },
    {
      "id": "reversal",
      "title": "كشف الانعكاسات",
      "titleEn": "Reversal Detection",
      "description": "تحديد نقاط الانعكاس المحتملة في اتجاه السعر",
      "descriptionEn": "Identify potential reversal points in price direction",
      "estimatedTime": "6-10 دقائق",
      "estimatedTimeEn": "6-10 minutes",
      "iconName": "swap_horiz",
      "isPremium": true,
      "isAvailable": true,
      "usageCount": 1,
      "maxUsage": 6,
      "accuracyRate": 0.88,
      "route": "/ai-analysis-processing"
    },
    {
      "id": "nightmare",
      "title": "التحليل الكامل - Nightmare",
      "titleEn": "Nightmare Full Analysis",
      "description": "التحليل الأكثر تفصيلاً مع جميع المؤشرات والاستراتيجيات",
      "descriptionEn":
          "Most detailed analysis with all indicators and strategies",
      "estimatedTime": "15-25 دقيقة",
      "estimatedTimeEn": "15-25 minutes",
      "iconName": "psychology",
      "isPremium": true,
      "isAvailable": true,
      "usageCount": 0,
      "maxUsage": 3,
      "accuracyRate": 0.96,
      "route": "/ai-analysis-processing"
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.95),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100.h),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        HeaderWidget(
          onClose: _handleClose,
          remainingAnalyses: remainingAnalyses,
        ),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: 2.h),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final analysis = analysisTypes[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      curve: Curves.easeOutBack,
                      child: AnalysisTypeCard(
                        title: analysis["title"] as String,
                        description: analysis["description"] as String,
                        estimatedTime: analysis["estimatedTime"] as String,
                        iconName: analysis["iconName"] as String,
                        isPremium: analysis["isPremium"] as bool,
                        isAvailable: analysis["isAvailable"] as bool,
                        usageCount: analysis["usageCount"] as int,
                        maxUsage: analysis["maxUsage"] as int,
                        accuracyRate: analysis["accuracyRate"] as double,
                        onTap: () => _handleAnalysisSelection(analysis),
                        onLongPress: () => _showAnalysisDetails(analysis),
                      ),
                    );
                  },
                  childCount: analysisTypes.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 2.h),
              ),
              SliverToBoxAdapter(
                child: SubscriptionTierWidget(
                  currentTier: currentTier,
                  remainingAnalyses: remainingAnalyses,
                  totalAnalyses: totalAnalyses,
                  onUpgrade: _handleUpgrade,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 4.h),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleClose() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _handleAnalysisSelection(Map<String, dynamic> analysis) {
    if (!(analysis["isAvailable"] as bool)) {
      _showLimitReachedDialog();
      return;
    }

    if ((analysis["isPremium"] as bool) && currentTier == 'Basic') {
      _showPremiumRequiredDialog();
      return;
    }

    if (remainingAnalyses <= 0) {
      _showNoAnalysesLeftDialog();
      return;
    }

    // Navigate to analysis processing with selected type
    Navigator.pushNamed(
      context,
      analysis["route"] as String,
      arguments: {
        'analysisType': analysis["id"],
        'analysisTitle': analysis["title"],
      },
    );
  }

  void _showAnalysisDetails(Map<String, dynamic> analysis) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: analysis["iconName"] as String,
                  color: AppTheme.accentGreen,
                  size: 8.w,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    analysis["title"] as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildDetailRow('Accuracy Rate',
                '${((analysis["accuracyRate"] as double) * 100).toInt()}%'),
            _buildDetailRow('Usage This Month',
                '${analysis["usageCount"]}/${analysis["maxUsage"]}'),
            _buildDetailRow(
                'Estimated Time', analysis["estimatedTime"] as String),
            _buildDetailRow('Premium Required',
                (analysis["isPremium"] as bool) ? 'Yes' : 'No'),
            SizedBox(height: 3.h),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              analysis["description"] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.warningRed,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Limit Reached',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Text(
          'You have reached the usage limit for this analysis type. Please wait 2 hours and 15 minutes before using it again.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPremiumRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.goldColor,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Premium Required',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Text(
          'This analysis type requires a Premium subscription. Upgrade now to access advanced AI analysis features.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleUpgrade();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: AppTheme.primaryDark,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showNoAnalysesLeftDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.warningRed,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'No Analyses Left',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Text(
          'You have used all your monthly analyses. Upgrade to Premium for more analyses or wait until next month.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleUpgrade();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: AppTheme.primaryDark,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade() {
    // Navigate to subscription/upgrade screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirecting to upgrade options...'),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // In a real app, this would navigate to subscription screen
    // Navigator.pushNamed(context, '/subscription');
  }
}
