import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnimatedGoldChart extends StatefulWidget {
  final double progress;

  const AnimatedGoldChart({
    super.key,
    required this.progress,
  });

  @override
  State<AnimatedGoldChart> createState() => _AnimatedGoldChartState();
}

class _AnimatedGoldChartState extends State<AnimatedGoldChart>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;
  late Animation<double> _waveAnimation;
  late Animation<double> _particleAnimation;

  final List<DataPoint> _dataPoints = [];
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _generateDataPoints();
    _generateParticles();

    _waveController.repeat();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _generateDataPoints() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _dataPoints.add(DataPoint(
        x: i * 2.0,
        y: 50 + random.nextDouble() * 30,
        opacity: random.nextDouble() * 0.8 + 0.2,
      ));
    }
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: random.nextDouble() * 100.w,
        y: random.nextDouble() * 30.h,
        size: random.nextDouble() * 4 + 2,
        speed: random.nextDouble() * 2 + 1,
        opacity: random.nextDouble() * 0.6 + 0.2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            _buildBackgroundGrid(),
            _buildAnimatedChart(),
            _buildFloatingParticles(),
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGrid() {
    return CustomPaint(
      size: Size(85.w, 30.h),
      painter: GridPainter(),
    );
  }

  Widget _buildAnimatedChart() {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _particleAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(85.w, 30.h),
          painter: ChartPainter(
            dataPoints: _dataPoints,
            progress: widget.progress,
            waveOffset: _waveAnimation.value,
            animationProgress: _particleAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(85.w, 30.h),
          painter: ParticlePainter(
            particles: _particles,
            animationProgress: _particleAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      top: 2.h,
      left: 4.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.goldColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'trending_up',
              color: AppTheme.goldColor,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'XAUUSD',
              style: AppTheme.tradingDataSmall.copyWith(
                color: AppTheme.goldColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataPoint {
  final double x;
  final double y;
  final double opacity;

  DataPoint({
    required this.x,
    required this.y,
    required this.opacity,
  });
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    // Draw horizontal lines
    for (int i = 0; i <= 6; i++) {
      final y = (size.height / 6) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical lines
    for (int i = 0; i <= 8; i++) {
      final x = (size.width / 8) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChartPainter extends CustomPainter {
  final List<DataPoint> dataPoints;
  final double progress;
  final double waveOffset;
  final double animationProgress;

  ChartPainter({
    required this.dataPoints,
    required this.progress,
    required this.waveOffset,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.accentGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppTheme.accentGreen.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.accentGreen.withValues(alpha: 0.3),
          AppTheme.accentGreen.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    bool isFirst = true;

    final visiblePoints = (dataPoints.length * progress).round();

    for (int i = 0; i < visiblePoints && i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final x = (point.x / 100) * size.width;
      final baseY = (point.y / 100) * size.height;

      // Add wave effect
      final waveY = baseY + math.sin(waveOffset + i * 0.2) * 5;

      if (isFirst) {
        path.moveTo(x, waveY);
        fillPath.moveTo(x, waveY);
        isFirst = false;
      } else {
        path.lineTo(x, waveY);
        fillPath.lineTo(x, waveY);
      }
    }

    // Complete fill path
    if (visiblePoints > 0) {
      final lastX = (dataPoints[visiblePoints - 1].x / 100) * size.width;
      fillPath.lineTo(lastX, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
    }

    // Draw glow effect
    canvas.drawPath(path, glowPaint);

    // Draw fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw main line
    canvas.drawPath(path, linePaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = AppTheme.goldColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < visiblePoints && i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final x = (point.x / 100) * size.width;
      final baseY = (point.y / 100) * size.height;
      final waveY = baseY + math.sin(waveOffset + i * 0.2) * 5;

      final opacity = point.opacity * animationProgress;
      pointPaint.color = AppTheme.goldColor.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(x, waveY),
        2 + math.sin(animationProgress * 2 * math.pi + i) * 1,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationProgress;

  ParticlePainter({
    required this.particles,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = particle.x + math.sin(animationProgress * 2 * math.pi) * 20;
      final y = particle.y + math.cos(animationProgress * 2 * math.pi) * 10;

      final opacity = particle.opacity *
          (0.5 + 0.5 * math.sin(animationProgress * 2 * math.pi));

      paint.color = AppTheme.goldColor.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (0.8 + 0.2 * math.sin(animationProgress * 4 * math.pi)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
