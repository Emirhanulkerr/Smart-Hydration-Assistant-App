import 'package:flutter/material.dart';
import '../models/health_tip.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';

/// Sağlık önerisi kartı - Yumuşak, sakinleştirici tasarım
class HealthTipCard extends StatefulWidget {
  final HealthTip tip;
  final VoidCallback? onDismiss;
  final bool showDismiss;

  const HealthTipCard({
    super.key,
    required this.tip,
    this.onDismiss,
    this.showDismiss = false,
  });

  @override
  State<HealthTipCard> createState() => _HealthTipCardState();
}

class _HealthTipCardState extends State<HealthTipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.tip.level) {
      case HealthTipLevel.celebration:
        return AppColors.successLight;
      case HealthTipLevel.encouraging:
        return AppColors.turquoiseLight;
      case HealthTipLevel.calm:
        return AppColors.mintLight;
      case HealthTipLevel.reminder:
        return AppColors.beigeLight;
    }
  }

  Color _getAccentColor() {
    switch (widget.tip.level) {
      case HealthTipLevel.celebration:
        return AppColors.success;
      case HealthTipLevel.encouraging:
        return AppColors.turquoise;
      case HealthTipLevel.calm:
        return AppColors.primary;
      case HealthTipLevel.reminder:
        return AppColors.primaryDark;
    }
  }

  IconData _getIcon() {
    switch (widget.tip.type) {
      case HealthTipType.hydration:
        return Icons.water_drop;
      case HealthTipType.streak:
        return Icons.local_fire_department;
      case HealthTipType.progress:
        return Icons.trending_up;
      case HealthTipType.morning:
        return Icons.wb_sunny;
      case HealthTipType.evening:
        return Icons.nights_stay;
      case HealthTipType.achievement:
        return Icons.emoji_events;
      case HealthTipType.general:
        return Icons.lightbulb;
      case HealthTipType.reminder:
        return Icons.notifications_active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? _getAccentColor().withValues(alpha: 0.15)
        : _getBackgroundColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: _getAccentColor().withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji veya İkon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getAccentColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: widget.tip.emoji != null
                    ? Text(
                        widget.tip.emoji!,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Icon(
                        _getIcon(),
                        color: _getAccentColor(),
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            // Mesaj
            Expanded(
              child: Text(
                widget.tip.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1.4,
                    ),
              ),
            ),
            // Dismiss butonu
            if (widget.showDismiss && widget.onDismiss != null)
              IconButton(
                onPressed: widget.onDismiss,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mini sağlık önerisi (snackbar gibi)
class MiniHealthTip extends StatelessWidget {
  final HealthTip tip;

  const MiniHealthTip({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tip.emoji != null)
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingS),
              child: Text(tip.emoji!, style: const TextStyle(fontSize: 16)),
            ),
          Flexible(
            child: Text(
              tip.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

