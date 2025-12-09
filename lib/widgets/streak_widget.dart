import 'package:flutter/material.dart';
import '../models/health_tip.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';

/// Streak göstergesi - Yumuşak animasyonlu
class StreakPill extends StatefulWidget {
  final int streak;
  final bool isAtRisk;
  final int forgivenessDays;
  final VoidCallback? onTap;

  const StreakPill({
    super.key,
    required this.streak,
    this.isAtRisk = false,
    this.forgivenessDays = 0,
    this.onTap,
  });

  @override
  State<StreakPill> createState() => _StreakPillState();
}

class _StreakPillState extends State<StreakPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.streak > 0) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streak > 0 && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (widget.streak == 0 && _glowController.isAnimating) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getColor() {
    if (widget.isAtRisk) {
      return AppColors.warning;
    }
    if (widget.streak >= 30) {
      return AppColors.success;
    } else if (widget.streak >= 7) {
      return AppColors.turquoise;
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.streak == 0) {
      return const SizedBox.shrink();
    }

    final color = _getColor();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3 + _glowAnimation.value * 0.2),
                  blurRadius: 8 + _glowAnimation.value * 4,
                  spreadRadius: _glowAnimation.value * 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '${widget.streak}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.forgivenessDays > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '💝 ${widget.forgivenessDays}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Genişletilmiş streak kartı
class StreakCard extends StatelessWidget {
  final StreakStatus status;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          gradient: status.currentStreak > 0
              ? AppColors.achievementGradient
              : null,
          color: status.currentStreak == 0
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: status.currentStreak > 0
                  ? AppColors.turquoise.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mevcut seri
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mevcut Seri',
                      style: TextStyle(
                        color: status.currentStreak > 0
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Text(
                          '${status.currentStreak}',
                          style: TextStyle(
                            color: status.currentStreak > 0
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' gün',
                          style: TextStyle(
                            color: status.currentStreak > 0
                                ? Colors.white.withValues(alpha: 0.8)
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // En iyi seri
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'En İyi',
                      style: TextStyle(
                        color: status.currentStreak > 0
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 4),
                        Text(
                          '${status.bestStreak}',
                          style: TextStyle(
                            color: status.currentStreak > 0
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Affetme günleri
            if (status.forgivenessDaysLeft > 0) ...[
              const SizedBox(height: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💝', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      '${status.forgivenessDaysLeft} affetme hakkı',
                      style: TextStyle(
                        color: status.currentStreak > 0
                            ? Colors.white
                            : AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Risk uyarısı
            if (status.isAtRisk) ...[
              const SizedBox(height: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Seri risk altında! Bugün %70 hedefine ulaş.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Son 7 günün ilerleme göstergesi
class WeeklyProgressIndicator extends StatelessWidget {
  final List<double> progress; // Son 7 günün ilerleme yüzdeleri

  const WeeklyProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final today = DateTime.now().weekday; // 1 = Pazartesi

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          // Son 7 günü hesapla
          final dayOffset = 6 - index;
          final isToday = dayOffset == 0;
          final dayProgress = index < progress.length ? progress[index] : 0.0;
          final dayIndex = (today - 7 + index) % 7;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekDays[dayIndex],
                style: TextStyle(
                  fontSize: 10,
                  color: isToday
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              _DayIndicator(
                progress: dayProgress,
                isToday: isToday,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final double progress;
  final bool isToday;

  const _DayIndicator({
    required this.progress,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final color = progress >= 70
        ? AppColors.success
        : progress >= 50
            ? AppColors.warning
            : AppColors.primary.withValues(alpha: 0.3);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: progress >= 70 ? color : Colors.transparent,
        border: Border.all(
          color: isToday ? AppColors.primary : color,
          width: isToday ? 2 : 1.5,
        ),
      ),
      child: Center(
        child: progress >= 70
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '${progress.round()}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
      ),
    );
  }
}

