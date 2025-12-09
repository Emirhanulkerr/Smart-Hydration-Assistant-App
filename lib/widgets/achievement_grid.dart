import 'package:flutter/material.dart';
import '../models/daily_stats.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';

/// Başarım kartı - Yumuşak, sakinleştirici tasarım
class AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final bool isCompact;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.achievement.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = widget.achievement.isUnlocked;

    if (widget.isCompact) {
      return _buildCompact(isDark, isUnlocked);
    }

    return _buildFull(isDark, isUnlocked);
  }

  Widget _buildCompact(bool isDark, bool isUnlocked) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: isUnlocked
                  ? Border.all(
                      color: AppColors.success.withValues(
                        alpha: 0.3 + _glowAnimation.value * 0.3,
                      ),
                      width: 2,
                    )
                  : null,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(
                          alpha: 0.1 + _glowAnimation.value * 0.1,
                        ),
                        blurRadius: 12 + _glowAnimation.value * 8,
                        spreadRadius: _glowAnimation.value * 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.achievement.icon,
                      style: TextStyle(
                        fontSize: 28,
                        color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                // Başlık
                Text(
                  widget.achievement.title.replaceAll(RegExp(r'[^\w\s]'), '').trim(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isUnlocked
                            ? null
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Kilit ikonu
                if (!isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingXS),
                    child: Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFull(bool isDark, bool isUnlocked) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: AppTheme.spacingXS,
            ),
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: isUnlocked
                  ? Border.all(
                      color: AppColors.success.withValues(
                        alpha: 0.3 + _glowAnimation.value * 0.3,
                      ),
                      width: 2,
                    )
                  : null,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(
                          alpha: 0.1 + _glowAnimation.value * 0.1,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      widget.achievement.icon,
                      style: TextStyle(
                        fontSize: 28,
                        color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.achievement.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isUnlocked
                                  ? null
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.achievement.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUnlocked
                                  ? (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight)
                                  : Colors.grey.withValues(alpha: 0.7),
                            ),
                      ),
                      if (isUnlocked && widget.achievement.unlockedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.achievement.unlockedAt!),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Durum ikonu
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.lock_outline,
                  color: isUnlocked
                      ? AppColors.success
                      : Colors.grey.withValues(alpha: 0.3),
                  size: 24,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

/// Başarım grid'i
class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final bool showLocked;
  final int crossAxisCount;

  const AchievementGrid({
    super.key,
    required this.achievements,
    this.showLocked = true,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = showLocked
        ? achievements
        : achievements.where((a) => a.isUnlocked).toList();

    // Kilidi açıkları önce göster
    filtered.sort((a, b) {
      if (a.isUnlocked && !b.isUnlocked) return -1;
      if (!a.isUnlocked && b.isUnlocked) return 1;
      return 0;
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacingS,
        mainAxisSpacing: AppTheme.spacingS,
        childAspectRatio: 0.85,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return AchievementCard(
          achievement: filtered[index],
          isCompact: true,
        );
      },
    );
  }
}

/// Yeni açılan başarım kutlama dialog'u
class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
  });

  @override
  State<AchievementUnlockedDialog> createState() => _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            gradient: AppColors.achievementGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Yeni Başarım!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.achievement.icon,
                      style: const TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      widget.achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      widget.achievement.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingM,
                  ),
                ),
                child: const Text('Harika!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

