import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/analysis_header.dart';
import './widgets/analysis_progress_indicator.dart';
import './widgets/animated_gold_chart.dart';
import './widgets/cancel_analysis_button.dart';
import './widgets/time_remaining_widget.dart';

class AiAnalysisProcessing extends StatefulWidget {
  const AiAnalysisProcessing({super.key});

  @override
  State<AiAnalysisProcessing> createState() => _AiAnalysisProcessingState();
}

class _AiAnalysisProcessingState extends State<AiAnalysisProcessing>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  Timer? _progressTimer;
  Timer? _hapticTimer;

  int _currentStageIndex = 0;
  double _progress = 0.0;
  int _remainingSeconds = 75;
  final int _totalSeconds = 75;
  bool _canCancel = true;
  bool _isProcessing = true;

  final List<String> _analysisStages = [
    'جلب بيانات السوق',
    'تحليل الأنماط',
    'توليد الرؤى',
    'تنسيق النتائج',
  ];

  // Mock analysis data
  final Map<String, dynamic> _analysisData = {
    'type': 'Detailed',
    'goldPrice': '\$2,045.30',
    'startTime': DateTime.now(),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnalysisProcess();
    _setupHapticFeedback();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.elasticOut,
    ));

    _backgroundController.repeat(reverse: true);
    _contentController.forward();
  }

  void _startAnalysisProcess() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;

      setState(() {
        _remainingSeconds = (_totalSeconds * (1 - _progress)).round();

        if (_remainingSeconds <= 65) _canCancel = false;

        _progress += 0.02;

        if (_progress >= 0.25 && _currentStageIndex == 0) {
          _currentStageIndex = 1;
        } else if (_progress >= 0.50 && _currentStageIndex == 1) {
          _currentStageIndex = 2;
        } else if (_progress >= 0.80 && _currentStageIndex == 2) {
          _currentStageIndex = 3;
        }

        if (_progress >= 1.0) {
          _progress = 1.0;
          _remainingSeconds = 0;
          _isProcessing = false;
          timer.cancel();
          _completeAnalysis();
        }
      });
    });
  }

  void _setupHapticFeedback() {
    _hapticTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted || !_isProcessing) {
        timer.cancel();
        return;
      }
      HapticFeedback.lightImpact();
    });
  }

  void _completeAnalysis() {
    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/analysis-results');
      }
    });
  }

  void _cancelAnalysis() {
    _progressTimer?.cancel();
    _hapticTimer?.cancel();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/analysis-type-selection',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    _progressTimer?.cancel();
    _hapticTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primaryDark.withValues(
                      alpha: 0.8 + 0.2 * _backgroundAnimation.value,
                    ),
                    AppTheme.secondaryDark.withValues(
                      alpha: 0.3 + 0.1 * _backgroundAnimation.value,
                    ),
                  ],
                ),
              ),
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: _contentAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _contentAnimation.value,
                      child: Opacity(
                        opacity: _contentAnimation.value,
                        child: _buildContent(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            AnalysisHeader(
              analysisType: _analysisData['type'] as String,
              goldPrice: _analysisData['goldPrice'] as String,
              startTime: _analysisData['startTime'] as DateTime,
            ),
            SizedBox(height: 4.h),
            AnimatedGoldChart(progress: _progress),
            SizedBox(height: 4.h),
            AnalysisProgressIndicator(
              currentStage: _analysisStages[_currentStageIndex],
              progress: _progress,
              stages: _analysisStages,
              currentStageIndex: _currentStageIndex,
            ),
            SizedBox(height: 4.h),
            TimeRemainingWidget(
              remainingSeconds: _remainingSeconds,
              totalSeconds: _totalSeconds,
            ),
            SizedBox(height: 4.h),
            CancelAnalysisButton(
              isVisible: _canCancel && _isProcessing,
              onCancel: _cancelAnalysis,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
