import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Sakin dalga animasyonu widget'ı
class WaveAnimation extends StatefulWidget {
  final double fillPercentage; // 0.0 - 1.0
  final double height;
  final double width;
  final Color? waveColor;
  final Color? backgroundColor;
  final bool animate;

  const WaveAnimation({
    super.key,
    required this.fillPercentage,
    this.height = 300,
    this.width = 200,
    this.waveColor,
    this.backgroundColor,
    this.animate = true,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.fillPercentage,
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _waveController.repeat();
    }
    _fillController.forward();
  }

  @override
  void didUpdateWidget(WaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.fillPercentage != widget.fillPercentage) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.fillPercentage,
      ).animate(CurvedAnimation(
        parent: _fillController,
        curve: Curves.easeOutCubic,
      ));
      _fillController.forward(from: 0);
    }

    if (widget.animate && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!widget.animate && _waveController.isAnimating) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = widget.waveColor ?? AppColors.water;
    final bgColor = widget.backgroundColor ?? AppColors.waterLight;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.width / 2),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.width / 2),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([_waveController, _fillAnimation]),
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  waveProgress: _waveController.value,
                  fillPercentage: _fillAnimation.value,
                  waveColor: waveColor,
                ),
                size: Size(widget.width, widget.height),
              );
            },
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveProgress;
  final double fillPercentage;
  final Color waveColor;

  WavePainter({
    required this.waveProgress,
    required this.fillPercentage,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillHeight = size.height * (1 - fillPercentage);

    // Birinci dalga (ana dalga)
    final wave1Paint = Paint()
      ..color = waveColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final wave1Path = Path();
    wave1Path.moveTo(0, size.height);
    wave1Path.lineTo(0, fillHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = fillHeight +
          math.sin((x / size.width * 2 * math.pi) + (waveProgress * 2 * math.pi)) * 8;
      wave1Path.lineTo(x, y);
    }

    wave1Path.lineTo(size.width, size.height);
    wave1Path.close();

    canvas.drawPath(wave1Path, wave1Paint);

    // İkinci dalga (arka plan dalgası)
    final wave2Paint = Paint()
      ..color = waveColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final wave2Path = Path();
    wave2Path.moveTo(0, size.height);
    wave2Path.lineTo(0, fillHeight + 5);

    for (double x = 0; x <= size.width; x++) {
      final y = fillHeight +
          5 +
          math.sin((x / size.width * 2 * math.pi) + (waveProgress * 2 * math.pi) + math.pi) * 6;
      wave2Path.lineTo(x, y);
    }

    wave2Path.lineTo(size.width, size.height);
    wave2Path.close();

    canvas.drawPath(wave2Path, wave2Paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.waveProgress != waveProgress ||
        oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.waveColor != waveColor;
  }
}

/// Su bardağı şeklinde dalga animasyonu
class WaterGlassWidget extends StatelessWidget {
  final double fillPercentage;
  final double size;
  final VoidCallback? onTap;

  const WaterGlassWidget({
    super.key,
    required this.fillPercentage,
    this.size = 200,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size * 1.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.15),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.12),
          child: Stack(
            children: [
              // Arka plan
              Container(
                color: Colors.white.withValues(alpha: 0.3),
              ),
              // Dalga animasyonu
              Positioned.fill(
                child: WaveAnimation(
                  fillPercentage: fillPercentage,
                  waveColor: AppColors.water,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

