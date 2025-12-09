import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/water_controller.dart';
import '../models/daily_stats.dart';
import '../models/health_tip.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../widgets/achievement_grid.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_widget.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsState = ref.watch(achievementsControllerProvider);
    final streakStatus = ref.watch(streakStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarımlar'),
      ),
      body: achievementsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Genel İlerleme
                SliverToBoxAdapter(
                  child: _buildProgressSection(context, achievementsState, streakStatus, isDark),
                ),
                // Streak Kartı
                SliverToBoxAdapter(
                  child: StreakCard(status: streakStatus),
                ),
                // Son 7 günün ilerleme göstergesi
                if (streakStatus.recentProgress.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                      ),
                      child: WeeklyProgressIndicator(
                        progress: streakStatus.recentProgress,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spacingM),
                ),
                // Kategorilere göre başarımlar
                ..._buildAchievementCategories(context, ref, isDark),
                // Alt boşluk
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spacingXL),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    AchievementsState state,
    StreakStatus streakStatus,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppColors.calmGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
      ),
      child: Row(
        children: [
          // İlerleme halkası
          ProgressRing(
            progress: state.stats.completionPercentage,
            size: 100,
            strokeWidth: 10,
            progressColor: AppColors.success,
            showPercentage: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.stats.unlocked}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
                Text(
                  '/ ${state.stats.total}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          // İstatistikler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Başarım İlerlemesi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                _buildStatRow(
                  context,
                  '🔓 Kilidi Açık',
                  '${state.stats.unlocked}',
                  AppColors.success,
                ),
                _buildStatRow(
                  context,
                  '🔒 Kilitli',
                  '${state.stats.total - state.stats.unlocked}',
                  isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                _buildStatRow(
                  context,
                  '🔥 En İyi Seri',
                  '${streakStatus.bestStreak} gün',
                  AppColors.turquoise,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievementCategories(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final controller = ref.read(achievementsControllerProvider.notifier);
    final categories = controller.getAchievementsByCategory();

    return categories.entries.expand((entry) {
      final categoryName = entry.key;
      final achievements = entry.value;

      if (achievements.isEmpty) return <Widget>[];

      // Kilidi açıkları önce göster
      achievements.sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return 0;
      });

      final unlockedCount = achievements.where((a) => a.isUnlocked).length;

      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingM,
              AppTheme.spacingM,
              AppTheme.spacingM,
              AppTheme.spacingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '$unlockedCount / ${achievements.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return AchievementCard(
                achievement: achievements[index],
                isCompact: false,
              );
            },
            childCount: achievements.length,
          ),
        ),
      ];
    }).toList();
  }
}

/// Başarım detay sayfası
class AchievementDetailScreen extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailScreen({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarım Detayı'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Büyük emoji
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.success.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 56,
                      color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              // Başlık
              Text(
                achievement.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? null
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              // Açıklama
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingL),
              // Durum
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.successLight
                      : (isDark ? AppColors.surfaceDark : AppColors.beigeLight),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.lock_outline,
                      color: isUnlocked ? AppColors.success : Colors.grey,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      isUnlocked
                          ? 'Kilidi Açıldı!'
                          : 'Henüz Açılmadı',
                      style: TextStyle(
                        color: isUnlocked ? AppColors.success : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Açılma tarihi
              if (isUnlocked && achievement.unlockedAt != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Açılma tarihi: ${_formatDate(achievement.unlockedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

