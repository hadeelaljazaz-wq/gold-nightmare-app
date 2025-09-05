import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/app_export.dart';
import '../../../services/fixed_claude_ai_manager.dart';
import '../../../services/gold_price_service.dart';

class ChartAnalysisWidget extends StatefulWidget {
  const ChartAnalysisWidget({super.key});

  @override
  State<ChartAnalysisWidget> createState() => _ChartAnalysisWidgetState();
}

class _ChartAnalysisWidgetState extends State<ChartAnalysisWidget> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysisResult;
  final FixedClaudeAIManager _aiManager = FixedClaudeAIManager.instance;

  @override
  void initState() {
    super.initState();
    _aiManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'analytics',
                  color: AppTheme.accentGreen,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحليل الشارت بالذكاء الاصطناعي',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      'ارفع صورة الشارت للحصول على تحليل متقدم',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Image Upload Section
          if (_selectedImage == null) _buildImageUploadSection(),
          if (_selectedImage != null) _buildSelectedImageSection(),

          if (_selectedImage != null) SizedBox(height: 3.h),

          // Analysis Result Section
          if (_analysisResult != null) _buildAnalysisResultSection(),

          // Action Buttons
          if (_selectedImage != null && !_isAnalyzing) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'cloud_upload',
            color: AppTheme.textSecondary,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'اختر صورة الشارت',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'PNG, JPG, GIF حتى 10MB',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showImageSourceDialog(),
                  icon: CustomIconWidget(
                    iconName: 'photo_library',
                    color: AppTheme.primaryDark,
                    size: 20,
                  ),
                  label: Text(
                    'اختيار صورة',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    foregroundColor: AppTheme.primaryDark,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImageSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Image preview
          Container(
            height: 30.h,
            width: double.infinity,
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Image info and actions
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صورة الشارت محملة',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        'جاهز للتحليل بالذكاء الاصطناعي',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _analysisResult = null;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: AppTheme.warningRed,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: AppTheme.accentGreen,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'نتائج التحليل',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.accentGreen,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            constraints: BoxConstraints(maxHeight: 40.h),
            child: SingleChildScrollView(
              child: Text(
                _analysisResult!,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 13.sp,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : () => _analyzeChart(),
                icon: _isAnalyzing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppTheme.primaryDark),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'auto_awesome',
                        color: AppTheme.primaryDark,
                        size: 20,
                      ),
                label: Text(
                  _isAnalyzing ? 'جاري التحليل...' : 'تحليل الشارت',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: AppTheme.primaryDark,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_analysisResult != null) ...[
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareAnalysis(),
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: AppTheme.accentGreen,
                    size: 18,
                  ),
                  label: Text(
                    'مشاركة النتائج',
                    style: TextStyle(
                      color: AppTheme.accentGreen,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.accentGreen),
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _saveAnalysis(),
                  icon: CustomIconWidget(
                    iconName: 'bookmark',
                    color: AppTheme.goldColor,
                    size: 18,
                  ),
                  label: Text(
                    'حفظ التحليل',
                    style: TextStyle(
                      color: AppTheme.goldColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.goldColor),
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showImageSourceDialog() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
              'اختر مصدر الصورة',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'photo_library',
                  color: AppTheme.accentGreen,
                  size: 24,
                ),
              ),
              title: Text(
                'معرض الصور',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                'اختر من الصور المحفوظة',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.goldColor,
                  size: 24,
                ),
              ),
              title: Text(
                'الكاميرا',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                'التقط صورة جديدة',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _aiManager.selectImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _analysisResult = null; // Clear previous analysis
        });
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الصورة: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        _showErrorSnackBar('يرجى السماح بالوصول للكاميرا');
        return;
      }

      final image = await _aiManager.captureImageFromCamera();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _analysisResult = null; // Clear previous analysis
        });
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في التقاط الصورة: ${e.toString()}');
    }
  }

  Future<void> _analyzeChart() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      // Get current gold price
      final currentPriceData = GoldPriceService.instance.currentPriceData;
      final goldPrice = GoldPrice(
        price: currentPriceData['price'] ?? 2045.67,
        change_24h: currentPriceData['change'] ?? 0.0,
        changePercentage: currentPriceData['changePercent'] ?? 0.0,
        low_24h: currentPriceData['price'] != null
            ? currentPriceData['price'] * 0.95
            : 1950.0,
        high_24h: currentPriceData['price'] != null
            ? currentPriceData['price'] * 1.05
            : 2150.0,
        timestamp: DateTime.now(),
        source: 'Live Market Data',
      );

      // Perform AI analysis
      final result = await _aiManager.analyzeGold(
        prompt:
            'قم بتحليل هذا الشارت بشكل مفصل وأعطني نقاط الدخول والخروج والمستويات المهمة',
        goldPrice: goldPrice,
        imageFile: _selectedImage,
        analysisType: AnalysisType.DETAILED,
      );

      setState(() {
        _analysisResult = result;
      });

      _showSuccessSnackBar('تم التحليل بنجاح!');
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في التحليل: ${e.toString()}');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _shareAnalysis() {
    if (_analysisResult == null) return;

    // Implement share functionality
    HapticFeedback.lightImpact();
    _showSuccessSnackBar('سيتم إضافة ميزة المشاركة قريباً');
  }

  void _saveAnalysis() {
    if (_analysisResult == null) return;

    // Implement save functionality
    HapticFeedback.lightImpact();
    _showSuccessSnackBar('سيتم إضافة ميزة الحفظ قريباً');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.warningRed,
      ),
    );
  }
}
