import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/water_controller.dart';
import '../models/daily_stats.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../widgets/soft_card.dart';
import '../widgets/progress_ring.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedPeriod = 0; // 0: Hafta, 1: Ay

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final range = _selectedPeriod == 0
        ? DateRange.lastWeek()
        : DateRange.lastMonth();
    final stats = ref.watch(statsProvider(range));
    final streak = ref.watch(currentStreakProvider);
    final settings = ref.watch(userSettingsProvider);

    // İstatistik hesaplamaları
    final totalAmount = stats.fold(0, (sum, s) => sum + s.totalAmount);
    final avgAmount = stats.isNotEmpty ? totalAmount ~/ stats.length : 0;
    final daysWithGoal = stats.where((s) => s.goalReached).length;
    final completionRate = stats.isNotEmpty
        ? (daysWithGoal / stats.length * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        actions: [
          // Periyot seçici
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingM),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Hafta')),
                ButtonSegment(value: 1, label: Text('Ay')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Özet kartları
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Toplam',
                    value: '${(totalAmount / 1000).toStringAsFixed(1)} L',
                    icon: Icons.water_drop,
                    iconColor: AppColors.water,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    title: 'Ortalama',
                    value: '$avgAmount ml',
                    subtitle: 'günlük',
                    icon: Icons.analytics,
                    iconColor: AppColors.turquoise,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Başarı Oranı',
                    value: '%$completionRate',
                    icon: Icons.emoji_events,
                    iconColor: AppColors.success,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    title: 'Seri',
                    value: '$streak gün',
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Grafik
            Text(
              _selectedPeriod == 0 ? 'Haftalık Tüketim' : 'Aylık Tüketim',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            SoftCard(
              child: SizedBox(
                height: 200,
                child: stats.isEmpty
                    ? Center(
                        child: Text(
                          'Henüz veri yok',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (settings.dailyGoal * 1.2).toDouble(),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: AppColors.surfaceDark,
                              tooltipRoundedRadius: AppTheme.radiusSmall,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final stat = stats[groupIndex];
                                return BarTooltipItem(
                                  '${stat.totalAmount} ml',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= stats.length) {
                                    return const SizedBox();
                                  }
                                  final stat = stats[value.toInt()];
                                  final text = _selectedPeriod == 0
                                      ? DateFormat('E', 'tr').format(stat.date)
                                      : stat.date.day.toString();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${(value / 1000).toStringAsFixed(1)}L',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: settings.dailyGoal / 4,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: isDark
                                    ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                                    : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: stats.asMap().entries.map((entry) {
                            final stat = entry.value;
                            final isGoalReached = stat.goalReached;
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: stat.totalAmount.toDouble(),
                                  color: isGoalReached
                                      ? AppColors.success
                                      : AppColors.primary,
                                  width: _selectedPeriod == 0 ? 20 : 8,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: settings.dailyGoal.toDouble(),
                                color: AppColors.success.withValues(alpha: 0.5),
                                strokeWidth: 2,
                                dashArray: [5, 5],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10,
                                  ),
                                  labelResolver: (line) => 'Hedef',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            // Başarılar bölümü
            Text(
              'Başarılar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Consumer(
              builder: (context, ref, child) {
                final achievements = ref.watch(achievementsProvider);
                final unlockedCount =
                    achievements.where((a) => a.isUnlocked).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İlerleme göstergesi
                    Row(
                      children: [
                        Expanded(
                          child: MiniProgressIndicator(
                            progress:
                                (unlockedCount / achievements.length * 100),
                            height: 8,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          '$unlockedCount/${achievements.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // Başarı kartları
                    ...achievements.map((achievement) {
                      return AchievementCard(
                        title: achievement.title,
                        description: achievement.description,
                        icon: achievement.icon,
                        isUnlocked: achievement.isUnlocked,
                        unlockedAt: achievement.unlockedAt,
                      );
                    }),
                  ],
                );
              },
            ),
            // Alt boşluk
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }
}

/// Haftalık özet widget'ı (Home screen için)
class WeeklySummaryWidget extends ConsumerWidget {
  const WeeklySummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider(DateRange.lastWeek()));
    final settings = ref.watch(userSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu Hafta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = DateTime.now().subtract(Duration(days: 6 - index));
              final dayStat = stats.firstWhere(
                (s) =>
                    s.date.year == date.year &&
                    s.date.month == date.month &&
                    s.date.day == date.day,
                orElse: () => DailyStats.empty(date, settings.dailyGoal),
              );

              final dayName = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'][date.weekday - 1];
              final isToday = date.day == DateTime.now().day;

              return Column(
                children: [
                  Text(
                    dayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isToday ? FontWeight.bold : null,
                          color: isToday
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dayStat.goalReached
                          ? AppColors.success
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                      border: Border.all(
                        color: dayStat.goalReached
                            ? AppColors.success
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: dayStat.goalReached
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              '${dayStat.progressPercentage.round()}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

