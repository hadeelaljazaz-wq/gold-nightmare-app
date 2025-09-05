import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/gold_price_service.dart';
import './widgets/analysis_history_widget.dart';
import './widgets/chart_analysis_widget.dart';
import './widgets/price_alerts_widget.dart';
import './widgets/price_header_widget.dart';
import './widgets/quick_analysis_cards_widget.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  StreamSubscription<Map<String, dynamic>>? _priceSubscription;

  // Real-time price data from service
  double _currentPrice = 2045.67;
  double _priceChange = 12.45;
  double _priceChangePercent = 0.61;
  bool _isConnected = true;
  String _lastUpdate = "منذ 5 ثوان";

  // Mock analysis history data
  final List<Map<String, dynamic>> _analysisHistory = [
    {
      "id": 1,
      "type": "تحليل سريع",
      "recommendation": "BUY",
      "confidence": 85.0,
      "timestamp": "اليوم 14:30",
      "entry_price": 2043.20,
      "take_profit": 2055.80,
      "stop_loss": 2038.50,
      "gold_price": 2043.20,
      "result":
          "إشارة شراء قوية مع كسر مستوى المقاومة عند 2042. الهدف الأول 2055 والثاني 2065.",
    },
    {
      "id": 2,
      "type": "تحليل مفصل",
      "recommendation": "SELL",
      "confidence": 72.0,
      "timestamp": "أمس 16:45",
      "entry_price": 2048.90,
      "take_profit": 2035.20,
      "stop_loss": 2053.40,
      "gold_price": 2048.90,
      "result": "إشارة بيع متوسطة القوة مع تشبع شرائي على المؤشرات الفنية.",
    },
    {
      "id": 3,
      "type": "سكالبينج",
      "recommendation": "BUY",
      "confidence": 68.0,
      "timestamp": "أمس 11:20",
      "entry_price": 2041.15,
      "take_profit": 2044.80,
      "stop_loss": 2039.90,
      "gold_price": 2041.15,
      "result": "فرصة سكالبينج سريعة مع دعم قوي عند 2040.",
    },
  ];

  // Mock price alerts data
  final List<Map<String, dynamic>> _priceAlerts = [
    {
      "id": 1,
      "type": "مقاومة",
      "target_price": 2050.00,
      "condition": "above",
      "is_active": true,
    },
    {
      "id": 2,
      "type": "دعم",
      "target_price": 2035.00,
      "condition": "below",
      "is_active": true,
    },
    {
      "id": 3,
      "type": "هدف ربح",
      "target_price": 2060.00,
      "condition": "above",
      "is_active": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });

    // Initialize gold price service
    GoldPriceService.instance.initialize();
    _startListeningToPriceUpdates();
  }

  void _startListeningToPriceUpdates() {
    // Listen to real-time price updates
    _priceSubscription =
        GoldPriceService.instance.priceStream.listen((priceData) {
      if (mounted) {
        setState(() {
          _currentPrice = priceData['price'] ?? 2045.67;
          _priceChange = priceData['change'] ?? 0.0;
          _priceChangePercent = priceData['changePercent'] ?? 0.0;
          _isConnected = priceData['isConnected'] ?? false;
          _lastUpdate = priceData['lastUpdate'] ?? 'غير متصل';
        });
      }
    });

    // Initialize with current data
    final currentData = GoldPriceService.instance.currentPriceData;
    setState(() {
      _currentPrice = currentData['price'] ?? 2045.67;
      _priceChange = currentData['change'] ?? 0.0;
      _priceChangePercent = currentData['changePercent'] ?? 0.0;
      _isConnected = currentData['isConnected'] ?? false;
      _lastUpdate = currentData['lastUpdate'] ?? 'غير متصل';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceSubscription?.cancel();
    GoldPriceService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Column(
        children: [
          // Price Header - Always visible
          PriceHeaderWidget(
            currentPrice: _currentPrice,
            priceChange: _priceChange,
            priceChangePercent: _priceChangePercent,
            lastUpdate: _lastUpdate,
            isConnected: _isConnected,
          ),

          // Tab Bar
          Container(
            color: AppTheme.primaryDark,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard),
                  text: 'الرئيسية',
                ),
                Tab(
                  icon: Icon(Icons.analytics),
                  text: 'التحليل',
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: 'السجل',
                ),
                Tab(
                  icon: Icon(Icons.person),
                  text: 'الملف الشخصي',
                ),
              ],
              labelColor: AppTheme.accentGreen,
              unselectedLabelColor: AppTheme.textTertiary,
              indicatorColor: AppTheme.accentGreen,
              indicatorWeight: 3.0,
              labelStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
              unselectedLabelStyle:
                  AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 11.sp,
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildAnalysisTab(),
                _buildHistoryTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button - Only visible on Dashboard tab
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAnalysisTypeSelection,
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: AppTheme.primaryDark,
              icon: CustomIconWidget(
                iconName: 'auto_awesome',
                color: AppTheme.primaryDark,
                size: 24,
              ),
              label: Text(
                'تحليل جديد',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          // Quick Analysis Cards
          QuickAnalysisCardsWidget(
            onQuickAnalysis: () => _navigateToAnalysis('quick'),
            onDetailedAnalysis: () => _navigateToAnalysis('detailed'),
            onScalpingMode: () => _navigateToAnalysis('scalping'),
          ),

          SizedBox(height: 3.h),

          // Price Alerts Section
          PriceAlertsWidget(
            alerts: _priceAlerts,
            onToggleAlert: _toggleAlert,
            onAddAlert: _showAddAlertDialog,
          ),

          SizedBox(height: 3.h),

          // Recent Analysis Preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخر التحليلات',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _tabController.animateTo(2); // Navigate to History tab
                  },
                  child: Text(
                    'عرض الكل',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentGreen,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Recent Analysis Cards (Limited to 2)
          Container(
            height: 35.h,
            child: AnalysisHistoryWidget(
              analyses: _analysisHistory.take(2).toList(),
              onShare: _shareAnalysis,
              onDelete: _deleteAnalysis,
              onRefresh: _refreshData,
            ),
          ),

          SizedBox(height: 10.h), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          // AI Chat Button
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 3.h),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
              icon: CustomIconWidget(
                iconName: 'smart_toy',
                color: AppTheme.primaryDark,
                size: 24,
              ),
              label: Text(
                'محادثة مع الذكاء الاصطناعي',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: AppTheme.primaryDark,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Chart Analysis Widget
          const ChartAnalysisWidget(),

          SizedBox(height: 3.h),

          // Quick Analysis Cards
          QuickAnalysisCardsWidget(
            onQuickAnalysis: () => _navigateToAnalysis('quick'),
            onDetailedAnalysis: () => _navigateToAnalysis('detailed'),
            onScalpingMode: () => _navigateToAnalysis('scalping'),
          ),

          SizedBox(height: 3.h),

          // Analysis Tools Header
          Text(
            'أدوات التحليل المتقدمة',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 2.h),

          // Analysis Options
          _buildAnalysisOption('تحليل سريع', 'نتائج فورية خلال ثوان',
              'flash_on', AppTheme.accentGreen),
          _buildAnalysisOption('تحليل مفصل', 'تحليل شامل ومعمق', 'analytics',
              AppTheme.goldColor),
          _buildAnalysisOption('سكالبينج', 'للتداول السريع 1-15 دقيقة', 'speed',
              AppTheme.warningRed),
          _buildAnalysisOption('سوينغ', 'للتداول متوسط المدى', 'trending_up',
              AppTheme.accentGreen),
          _buildAnalysisOption(
              'توقعات', 'تنبؤات مستقبلية', 'visibility', AppTheme.goldColor),
          _buildAnalysisOption('انعكاس', 'نقاط الانعكاس المحتملة', 'refresh',
              AppTheme.warningRed),
          _buildAnalysisOption('تحليل الكابوس الكامل', 'التحليل الأشمل والأدق',
              'psychology', AppTheme.goldColor),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return AnalysisHistoryWidget(
      analyses: _analysisHistory,
      onShare: _shareAnalysis,
      onDelete: _deleteAnalysis,
      onRefresh: _refreshData,
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Profile Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.1),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.accentGreen,
                    size: 48,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'متداول محترف',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'عضوية VIP',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.goldColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Usage Statistics
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات الاستخدام',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                          'التحليلات المتبقية', '42', AppTheme.accentGreen),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildStatCard(
                          'التحليلات المستخدمة', '8', AppTheme.goldColor),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                          'معدل النجاح', '87%', AppTheme.accentGreen),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildStatCard(
                          'التنبيهات النشطة', '3', AppTheme.warningRed),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Settings Options
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  'الإعدادات',
                  'تخصيص التطبيق والإشعارات',
                  'settings',
                  () {},
                ),
                Divider(color: AppTheme.borderColor.withValues(alpha: 0.3)),
                _buildSettingsTile(
                  'الدعم الفني',
                  'تواصل مع فريق الدعم',
                  'support',
                  () {},
                ),
                Divider(color: AppTheme.borderColor.withValues(alpha: 0.3)),
                _buildSettingsTile(
                  'حول التطبيق',
                  'معلومات النسخة والترخيص',
                  'info',
                  () {},
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Social Media Contact Section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تواصل معنا',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 2.h),

                // Admin Contact
                _buildContactTile(
                  'ADMIN',
                  'للتواصل مع الإدارة',
                  'https://t.me/Odai_xau',
                  AppTheme.accentGreen,
                ),

                SizedBox(height: 1.h),

                // Recommendations Channel
                _buildContactTile(
                  'قناة التوصيات',
                  'احصل على أحدث التوصيات والتحليلات',
                  'https://t.me/odai_xau_usd',
                  AppTheme.goldColor,
                ),

                SizedBox(height: 1.h),

                // Discussion Group
                _buildContactTile(
                  'مجموعة المناقشات',
                  'شارك الآراء والنقاشات مع المتداولين',
                  'https://t.me/odai_xauusdt',
                  AppTheme.warningRed,
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.tradingDataLarge.copyWith(
              color: color,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      String title, String subtitle, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.accentGreen,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          color: AppTheme.textPrimary,
          fontSize: 14.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
          fontSize: 12.sp,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.textTertiary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactTile(
      String title, String subtitle, String url, Color color) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(
                iconName: 'send',
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'open_in_new',
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        HapticFeedback.lightImpact();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح الرابط: $url'),
            backgroundColor: AppTheme.warningRed,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في فتح الرابط'),
          backgroundColor: AppTheme.warningRed,
        ),
      );
    }
  }

  void _navigateToAnalysis(String type) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/analysis-type-selection');
  }

  void _showAnalysisTypeSelection() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
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
            SizedBox(height: 3.h),
            Text(
              'اختر نوع التحليل',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 3.h),
            _buildAnalysisOption('تحليل سريع', 'نتائج فورية خلال ثوان',
                'flash_on', AppTheme.accentGreen),
            _buildAnalysisOption('تحليل مفصل', 'تحليل شامل ومعمق', 'analytics',
                AppTheme.goldColor),
            _buildAnalysisOption('سكالبينج', 'للتداول السريع 1-15 دقيقة',
                'speed', AppTheme.warningRed),
            _buildAnalysisOption('سوينغ', 'للتداول متوسط المدى', 'trending_up',
                AppTheme.accentGreen),
            _buildAnalysisOption(
                'توقعات', 'تنبؤات مستقبلية', 'visibility', AppTheme.goldColor),
            _buildAnalysisOption('انعكاس', 'نقاط الانعكاس المحتملة', 'refresh',
                AppTheme.warningRed),
            _buildAnalysisOption('تحليل الكابوس الكامل',
                'التحليل الأشمل والأدق', 'psychology', AppTheme.goldColor),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisOption(
      String title, String subtitle, String iconName, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12.sp,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.textTertiary,
          size: 20,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/ai-analysis-processing');
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppTheme.surfaceColor,
      ),
    );
  }

  void _shareAnalysis(int index) {
    HapticFeedback.lightImpact();
    final analysis = _analysisHistory[index];
    // Share functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم مشاركة التحليل: ${analysis['type']}'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  void _deleteAnalysis(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _analysisHistory.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف التحليل'),
        backgroundColor: AppTheme.warningRed,
      ),
    );
  }

  void _refreshData() async {
    HapticFeedback.lightImpact();

    // Refresh real gold price data
    await GoldPriceService.instance.refreshPrice();

    // Update last update text immediately
    setState(() {
      _lastUpdate = "الآن";
    });
  }

  void _toggleAlert(int index, bool isActive) {
    HapticFeedback.selectionClick();
    setState(() {
      _priceAlerts[index]['is_active'] = isActive;
    });
  }

  void _showAddAlertDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'إضافة تنبيه جديد',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'سيتم إضافة هذه الميزة قريباً',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
