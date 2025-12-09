import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/badge_controller.dart';
import '../models/badge_model.dart';
import '../services/badge_service.dart';
import '../widgets/badge_card.dart';
import '../widgets/progress_ring.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeState = ref.watch(badgeControllerProvider);
    final badges = badgeState.badges;
    final stats = badgeState.stats;
    final nextBadge = badgeState.nextBadge;
    final progressToNext = badgeState.progressToNext;
    final daysUntilNext = badgeState.daysUntilNext;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rozetler'),
      ),
      body: CustomScrollView(
        slivers: [
          // İlerleme kartı
          SliverToBoxAdapter(
            child: _buildProgressCard(context, stats),
          ),
          // Sonraki rozet
          if (nextBadge != null)
            SliverToBoxAdapter(
              child: _buildNextBadgeCard(
                context,
                nextBadge,
                progressToNext,
                daysUntilNext,
              ),
            ),
          // Açıklama
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Su içme serilerini koruyarak rozetler kazan!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Rozet grid'i
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final badge = badges[index];
                  return BadgeCard(
                    badge: badge,
                    onTap: () => _showBadgeDetail(context, badge),
                  );
                },
                childCount: badges.length,
              ),
            ),
          ),
          // Bilgi kartı
          SliverToBoxAdapter(
            child: _buildInfoCard(context),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, BadgeStats stats) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final completionText = stats.unlocked == stats.total
        ? 'Tüm rozetleri kazandın! 👑'
        : '${stats.total - stats.unlocked} rozet kaldı';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.15),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: stats.completionPercentage,
            size: 90,
            strokeWidth: 10,
            progressColor: primaryColor,
            showPercentage: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stats.unlocked}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
                Text(
                  '/ ${stats.total}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rozet Koleksiyonu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  completionText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 8),
                // Mini ilerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.completionPercentage / 100,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextBadgeCard(
    BuildContext context,
    Badge nextBadge,
    double progress,
    int daysLeft,
  ) {
    final color = _getBadgeColor(nextBadge.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Rozet preview
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                nextBadge.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sonraki Hedef',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  nextBadge.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysLeft > 0 ? '$daysLeft gün kaldı' : 'Bugün açılabilir!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          // Mini ilerleme
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 4,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text(
                  '${progress.round()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Rozet Seviyeleri',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLevelRow(context, '🌱', 'Taze Başlangıç', '3 günlük seri'),
          _buildLevelRow(context, '🎵', 'Ritmini Buldun', '7 günlük seri'),
          _buildLevelRow(context, '💎', 'Hidrasyon Ustası', '14 günlük seri'),
          _buildLevelRow(context, '🏅', 'Ayın Su Kahramanı', '30 günlük seri'),
          _buildLevelRow(context, '👑', 'Efsanevi Hidrasyon', '100 günlük seri'),
        ],
      ),
    );
  }

  Widget _buildLevelRow(
    BuildContext context,
    String emoji,
    String name,
    String requirement,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  requirement,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Badge badge) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailModal(badge: badge),
    );
  }

  Color _getBadgeColor(String badgeId) {
    switch (badgeId) {
      case 'fresh_start':
        return const Color(0xFF66BB6A);
      case 'found_rhythm':
        return const Color(0xFF42A5F5);
      case 'hydration_master':
        return const Color(0xFF7E57C2);
      case 'monthly_hero':
        return const Color(0xFFFF9800);
      case 'legendary_hydration':
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF5DADE2);
    }
  }
}

