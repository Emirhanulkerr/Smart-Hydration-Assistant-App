import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/water_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../utils/motivational_messages.dart';
import '../widgets/wave_animation.dart';
import '../widgets/progress_ring.dart';
import '../widgets/water_button.dart';
import '../widgets/soft_card.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/streak_widget.dart';
import '../widgets/achievement_grid.dart';
import 'add_water_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showCelebration = false;
  String _motivationalMessage = '';

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _motivationalMessage = MotivationalMessages.getGreetingByTime();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _showAddWaterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddWaterDialog(),
    );
  }

  void _addQuickWater(int amount) async {
    final wasGoalReached = ref.read(goalReachedProvider);
    await ref.read(todayWaterEntriesProvider.notifier).addWaterEntry(amount);

    // Mesajı güncelle
    setState(() {
      _motivationalMessage = MotivationalMessages.getRandomWaterAddedMessage();
    });

    // Hedefe yeni ulaşıldıysa kutlama göster
    final isGoalReached = ref.read(goalReachedProvider);
    if (!wasGoalReached && isGoalReached) {
      _showCelebrationEffect();
    }

    // Yeni açılan başarımları kontrol et
    _checkNewAchievements();

    // Snackbar göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_motivationalMessage),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCelebrationEffect() {
    setState(() {
      _showCelebration = true;
      _motivationalMessage = MotivationalMessages.getRandomGoalReachedMessage();
    });
    _celebrationController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _showCelebration = false;
        });
      }
    });
  }

  void _checkNewAchievements() {
    final achievementsState = ref.read(achievementsControllerProvider);
    if (achievementsState.recentlyUnlocked.isNotEmpty) {
      // İlk açılan başarımı göster
      final achievement = achievementsState.recentlyUnlocked.first;
      showDialog(
        context: context,
        builder: (context) =>
            AchievementUnlockedDialog(achievement: achievement),
      ).then((_) {
        ref
            .read(achievementsControllerProvider.notifier)
            .clearRecentlyUnlocked();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final progress = ref.watch(todayProgressProvider);
    final totalToday = ref.watch(todayTotalWaterProvider);
    final entries = ref.watch(todayWaterEntriesProvider);
    final streakStatus = ref.watch(streakStatusProvider);
    final healthTip = ref.watch(currentHealthTipProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Arka plan dekoratif şekiller
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.turquoiseLight.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Ana içerik
            CustomScrollView(
              slivers: [
                // Üst başlık
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Karşılama mesajı ve streak
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.userName != null &&
                                            settings.userName!.isNotEmpty
                                        ? 'Merhaba, ${settings.userName}! 👋'
                                        : 'Merhaba! 👋',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    MotivationalMessages.getGreetingByTime()
                                            .split('!')
                                            .first +
                                        '!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondaryLight,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            // Streak göstergesi
                            StreakPill(
                              streak: streakStatus.currentStreak,
                              isAtRisk: streakStatus.isAtRisk,
                              forgivenessDays: streakStatus.forgivenessDaysLeft,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Sağlık önerisi kartı
                SliverToBoxAdapter(child: HealthTipCard(tip: healthTip)),
                // Ana ilerleme göstergesi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingL,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Kutlama efekti
                          if (_showCelebration)
                            AnimatedBuilder(
                              animation: _celebrationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1 + _celebrationController.value * 0.3,
                                  child: Opacity(
                                    opacity: 1 - _celebrationController.value,
                                    child: Container(
                                      width: 250,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.success,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // İlerleme halkası
                          ProgressRing(
                            progress: progress,
                            size: 220,
                            strokeWidth: 16,
                            progressColor: progress >= 100
                                ? AppColors.success
                                : progress >= 70
                                ? AppColors.turquoise
                                : AppColors.primary,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Su animasyonu
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: WaveAnimation(
                                    fillPercentage: (progress / 100).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    waveColor: AppColors.water,
                                    backgroundColor: AppColors.waterLight,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingS),
                                Text(
                                  '$totalToday',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '/ ${settings.dailyGoal} ml',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // İlerleme mesajı
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                      ),
                      child: Text(
                        MotivationalMessages.getProgressMessage(progress),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: progress >= 100
                                  ? AppColors.success
                                  : progress >= 70
                                  ? AppColors.turquoise
                                  : AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Hızlı ekleme butonları
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Hızlı Ekle',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              WaterButton(
                                amount: 100,
                                icon: Icons.local_cafe,
                                onTap: () => _addQuickWater(100),
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              WaterButton(
                                amount: 200,
                                icon: Icons.coffee,
                                onTap: () => _addQuickWater(200),
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              WaterButton(
                                amount: 250,
                                icon: Icons.local_drink,
                                label: '1 Bardak',
                                onTap: () => _addQuickWater(250),
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              WaterButton(
                                amount: 330,
                                icon: Icons.sports_bar,
                                onTap: () => _addQuickWater(330),
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              WaterButton(
                                amount: 500,
                                icon: Icons.water_drop,
                                label: '1 Şişe',
                                onTap: () => _addQuickWater(500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bugünkü girdiler başlık
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bugün',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${entries.length} kayıt',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                // Girdi listesi
                if (entries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXL),
                      child: Column(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Henüz su eklemedin',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            'İlk yudumunu eklemek için aşağıdaki butona tıkla',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                        ),
                        child: WaterEntryCard(
                          amount: entry.amount,
                          time: entry.timestamp,
                          note: entry.note,
                          onDelete: () {
                            ref
                                .read(todayWaterEntriesProvider.notifier)
                                .deleteWaterEntry(entry.id);
                          },
                        ),
                      );
                    }, childCount: entries.length),
                  ),
                // Alt boşluk (FAB için)
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: AddWaterFAB(
        onTap: _showAddWaterDialog,
        defaultAmount: settings.defaultCupSize,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
