import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';

/// Hızlı su ekleme butonu
class WaterButton extends StatefulWidget {
  final int amount; // ml
  final VoidCallback onTap;
  final bool isSelected;
  final String? label;
  final IconData? icon;

  const WaterButton({
    super.key,
    required this.amount,
    required this.onTap,
    this.isSelected = false,
    this.label,
    this.icon,
  });

  @override
  State<WaterButton> createState() => _WaterButtonState();
}

class _WaterButtonState extends State<WaterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppTheme.animationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.primary,
                  size: 24,
                ),
              const SizedBox(height: 4),
              Text(
                widget.label ?? '${widget.amount} ml',
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Büyük su ekleme butonu (FAB tarzı)
class AddWaterFAB extends StatefulWidget {
  final VoidCallback onTap;
  final int defaultAmount;

  const AddWaterFAB({
    super.key,
    required this.onTap,
    this.defaultAmount = 250,
  });

  @override
  State<AddWaterFAB> createState() => _AddWaterFABState();
}

class _AddWaterFABState extends State<AddWaterFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _rippleController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: AppColors.waterGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _rippleController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ripple efekti
                if (_rippleController.isAnimating)
                  Transform.scale(
                    scale: 1 + _rippleController.value * 0.5,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 1 - _rippleController.value,
                          ),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                // İkon
                const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 36,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Özel miktar girişi için slider
class WaterSlider extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int divisions;
  final ValueChanged<int> onChanged;

  const WaterSlider({
    super.key,
    required this.value,
    this.min = 50,
    this.max = 1000,
    this.divisions = 19,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value ml',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.3),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 14,
              elevation: 4,
            ),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$min ml',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$max ml',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

