import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../services/anthropic_service.dart';
import '../../services/gold_price_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/analysis_options_widget.dart';
import './widgets/image_preview_widget.dart';
import './widgets/upload_drop_zone_widget.dart';
import './widgets/upload_progress_widget.dart';

class ChartAnalysisUpload extends StatefulWidget {
  const ChartAnalysisUpload({super.key});

  @override
  State<ChartAnalysisUpload> createState() => _ChartAnalysisUploadState();
}

class _ChartAnalysisUploadState extends State<ChartAnalysisUpload>
    with TickerProviderStateMixin {
  // Image handling
  XFile? _selectedImage;
  String? _analysisQuestion;
  String _selectedAnalysisType = 'detailed';
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Services
  final ImagePicker _picker = ImagePicker();
  final AnthropicClient _anthropicClient =
      AnthropicClient(AnthropicService().dio);
  final GoldPriceService _goldPriceService = GoldPriceService.instance;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Gold price data
  double _currentGoldPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentGoldPrice();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  Future<void> _loadCurrentGoldPrice() async {
    try {
      final priceData = await _goldPriceService.refreshPrice();
      if (mounted) {
        setState(() {
          _currentGoldPrice = priceData['price'] as double;
        });
      }
    } catch (e) {
      debugPrint('Error loading gold price: $e');
      if (mounted) {
        setState(() {
          _currentGoldPrice = 1950.0; // Fallback price
        });
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showErrorSnackBar('يجب منح إذن الكاميرا لتحليل الشارت');
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        _showSuccessSnackBar('تم تحديد الصورة بنجاح');
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      _showErrorSnackBar('حدث خطأ أثناء فتح الكاميرا');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        // Validate file size (max 10MB)
        final file = kIsWeb ? null : File(image.path);
        final bytes =
            kIsWeb ? await image.readAsBytes() : await file!.readAsBytes();

        if (bytes.length > 10 * 1024 * 1024) {
          _showErrorSnackBar('حجم الصورة كبير جداً. الحد الأقصى 10 ميجا');
          return;
        }

        setState(() {
          _selectedImage = image;
        });
        _showSuccessSnackBar('تم اختيار الصورة بنجاح');
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
      _showErrorSnackBar('حدث خطأ أثناء اختيار الصورة');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              Text(
                'اختر مصدر الصورة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: AppTheme.accentGreen),
                title: const Text('التقاط صورة',
                    style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppTheme.goldColor),
                title: const Text('اختيار من المعرض',
                    style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startAnalysis() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('يجب اختيار صورة شارت أولاً');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate upload progress
      for (int i = 1; i <= 5; i++) {
        if (!mounted) return;
        setState(() {
          _uploadProgress = i / 5.0;
        });
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Read image file
      final Uint8List imageBytes = kIsWeb
          ? await _selectedImage!.readAsBytes()
          : await File(_selectedImage!.path).readAsBytes();

      // Prepare analysis prompt
      final String prompt = _buildAnalysisPrompt();

      // Call Anthropic API for multimodal analysis
      final completion = await _anthropicClient.createMultimodal(
        prompt: prompt,
        imageBytes: imageBytes,
        maxTokens: _getMaxTokensForAnalysisType(),
      );

      if (mounted) {
        // Navigate to analysis results with the response
        Navigator.pushNamed(
          context,
          AppRoutes.analysisResults,
          arguments: {
            'analysis': completion.text,
            'analysisType': _selectedAnalysisType,
            'goldPrice': _currentGoldPrice,
            'imageBytes': imageBytes,
            'imagePath': kIsWeb ? null : _selectedImage!.path,
          },
        );
      }
    } catch (e) {
      debugPrint('Analysis error: $e');
      if (mounted) {
        _showErrorSnackBar('فشل في تحليل الشارت. حاول مرة أخرى.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  String _buildAnalysisPrompt() {
    final basePrompt = '''
أنت خبير تحليل فني لمعدن الذهب. قم بتحليل شارت الذهب المرفق بالصورة باللغة العربية.

السعر الحالي للذهب: \$${_currentGoldPrice.toStringAsFixed(2)}
نوع التحليل المطلوب: $_selectedAnalysisType

${_analysisQuestion != null && _analysisQuestion!.isNotEmpty ? 'سؤال إضافي: $_analysisQuestion' : ''}

يرجى تقديم تحليل شامل يشمل:

1. 📈 **تحليل الاتجاه العام**
   - الاتجاه الحالي (صاعد/هابط/عرضي)
   - قوة الاتجاه ومدى استمراريته

2. 🎯 **المستويات المهمة**
   - مستويات الدعم الرئيسية
   - مستويات المقاومة الحاسمة
   - أهداف سعرية محتملة

3. 📊 **المؤشرات الفنية**
   - تحليل المتوسطات المتحركة
   - مؤشر القوة النسبية RSI
   - مؤشر الماكد MACD (إن وجد)

4. ⚡ **إشارات التداول**
   - نقاط دخول محتملة
   - نقاط خروج مقترحة
   - مستويات وقف الخسارة

5. 📅 **التوقعات قصيرة المدى**
   - توقعات 24-48 ساعة القادمة
   - السيناريو الأكثر احتمالاً
   - السيناريوهات البديلة

6. ⚠️ **إدارة المخاطر**
   - مستوى المخاطر الحالي (منخفض/متوسط/مرتفع)
   - عوامل الخطر المحتملة
   - نصائح إدارة رأس المال

7. 🎖️ **التوصية النهائية**
   - شراء/بيع/انتظار
   - مستوى الثقة (%)
   - الأسباب وراء التوصية

يرجى تقديم التحليل بشكل واضح ومنظم مع استخدام الرموز التعبيرية لتحسين القراءة.
''';

    return basePrompt;
  }

  int _getMaxTokensForAnalysisType() {
    switch (_selectedAnalysisType) {
      case 'comprehensive':
        return 4000;
      case 'detailed':
        return 2500;
      case 'quick':
        return 1500;
      default:
        return 2500;
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _analysisQuestion = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.warningRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: 'تحليل الشارت',
        centerTitle: true,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.textSecondary),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gold price header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldColor.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppTheme.goldColor,
                      size: 24.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سعر الذهب الحالي',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          Text(
                            '\$${_currentGoldPrice.toStringAsFixed(2)}',
                            style: AppTheme.tradingDataMedium.copyWith(
                              color: AppTheme.goldColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'مباشر',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.goldColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Upload section
              if (_selectedImage == null) ...[
                UploadDropZoneWidget(
                  onTap: _showImageSourceActionSheet,
                ),

                SizedBox(height: 2.h),

                // Guidelines
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.accentGreen,
                            size: 20.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'نصائح للحصول على أفضل تحليل',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      _buildGuideline('📸 استخدم صورة واضحة ومقروءة'),
                      _buildGuideline('📊 تأكد من ظهور المؤشرات الفنية'),
                      _buildGuideline('🔍 تجنب الصور المشوشة أو المقطوعة'),
                      _buildGuideline('📱 الحد الأقصى لحجم الصورة 10 ميجا'),
                    ],
                  ),
                ),
              ] else ...[
                // Image preview and analysis options
                ImagePreviewWidget(
                  image: _selectedImage!,
                  onRemove: _removeSelectedImage,
                ),

                SizedBox(height: 2.h),

                // Analysis options
                AnalysisOptionsWidget(
                  selectedType: _selectedAnalysisType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedAnalysisType = type;
                    });
                  },
                  question: _analysisQuestion,
                  onQuestionChanged: (question) {
                    setState(() {
                      _analysisQuestion = question;
                    });
                  },
                ),

                SizedBox(height: 3.h),

                // Upload progress or start button
                if (_isUploading) ...[
                  UploadProgressWidget(
                    progress: _uploadProgress,
                    onCancel: () {
                      setState(() {
                        _isUploading = false;
                        _uploadProgress = 0.0;
                      });
                    },
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _startAnalysis,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: AppTheme.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 20.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'بدء تحليل الشارت',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryDark,
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppTheme.accentGreen,
                size: 24.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'مساعدة تحليل الشارت',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'كيفية الحصول على أفضل تحليل:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildHelpItem('1. تأكد من وضوح الشارت والمؤشرات'),
                _buildHelpItem('2. اختر نوع التحليل المناسب'),
                _buildHelpItem('3. أضف أسئلة محددة (اختياري)'),
                _buildHelpItem('4. انتظر النتائج واطلع على التحليل'),
                SizedBox(height: 2.h),
                Text(
                  'أنواع التحليل:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 1.h),
                _buildHelpItem('• سريع: تحليل أساسي (2-3 دقائق)'),
                _buildHelpItem('• مفصل: تحليل شامل (5-8 دقائق)'),
                _buildHelpItem('• كامل: تحليل عميق (8-12 دقيقة)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'حسناً',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.accentGreen,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }
}
