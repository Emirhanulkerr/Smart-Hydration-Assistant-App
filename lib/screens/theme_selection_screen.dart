import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/theme_controller.dart';
import '../models/app_theme_model.dart';
import '../services/theme_unlock_service.dart';
import '../widgets/theme_card.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final themes = themeState.themes;
    final selectedThemeId = themeState.selectedThemeId;
    final stats = themeState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temalar'),
      ),
      body: CustomScrollView(
        slivers: [
          // İlerleme kartı
          SliverToBoxAdapter(
            child: _buildProgressCard(context, stats),
          ),
          // Açıklama
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Tüm temalar ücretsiz! İstediğin temayı seç.',
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
          // Tema grid'i
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final theme = themes[index];
                  return ThemeCard(
                    theme: theme,
                    isSelected: theme.id == selectedThemeId,
                    onTap: theme.unlocked
                        ? () => _selectTheme(context, ref, theme)
                        : null,
                  );
                },
                childCount: themes.length,
              ),
            ),
          ),
          // Tema bilgisi
          SliverToBoxAdapter(
            child: _buildThemeInfo(context),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ThemeStats stats) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // İlerleme göstergesi
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: stats.completionPercentage / 100,
                  strokeWidth: 8,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
                Text(
                  '${stats.unlocked}/${stats.total}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
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
                  'Tema Koleksiyonu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tüm temalar ücretsiz! 🎨',
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

  Widget _buildThemeInfo(BuildContext context) {
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
              const Icon(Icons.palette_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tema Koleksiyonu',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeRow(context, '💧', 'Sakin Mavi', 'Varsayılan huzurlu tema'),
          _buildThemeRow(context, '🌊', 'Deniz Sessizliği', 'Turkuaz tonları'),
          _buildThemeRow(context, '🌲', 'Orman Sabahı', 'Doğal yeşil tonları'),
          _buildThemeRow(context, '☁️', 'Gökyüzü Blues', 'Açık mavi tonları'),
        ],
      ),
    );
  }

  Widget _buildThemeRow(
    BuildContext context,
    String emoji,
    String name,
    String description,
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
                  description,
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
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  void _selectTheme(BuildContext context, WidgetRef ref, AppThemeModel theme) {
    ref.read(themeControllerProvider.notifier).selectTheme(theme.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${theme.emoji} ${theme.name} teması uygulandı!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

