import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/water_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/badge_controller.dart';
import '../models/user_settings.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../widgets/soft_card.dart';
import 'theme_selection_screen.dart';
import 'badges_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // Profil
          Text(
            'Profil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SoftCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'İsim',
                  subtitle: settings.userName ?? 'Belirtilmedi',
                  onTap: () => _showNameDialog(settings),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Kilo',
                  subtitle: '${settings.weight} kg',
                  onTap: () => _showWeightDialog(settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Hedefler
          Text(
            'Hedefler',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SoftCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.flag_outlined,
                  title: 'Günlük Hedef',
                  subtitle: '${settings.dailyGoal} ml',
                  onTap: () => _showGoalDialog(settings),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.local_drink_outlined,
                  title: 'Varsayılan Bardak',
                  subtitle: '${settings.defaultCupSize} ml',
                  onTap: () => _showCupSizeDialog(settings),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.calculate_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Önerilen Hedef'),
                  subtitle: Text(
                    '${UserSettings.calculateRecommendedGoal(settings.weight)} ml (kilonuza göre)',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      final recommended =
                          UserSettings.calculateRecommendedGoal(settings.weight);
                      ref
                          .read(userSettingsProvider.notifier)
                          .setDailyGoal(recommended);
                    },
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Bildirimler
          Text(
            'Bildirimler',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SoftCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Hatırlatmalar'),
                  subtitle: const Text('Su içme hatırlatmaları al'),
                  secondary: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(userSettingsProvider.notifier)
                        .setNotificationsEnabled(value);
                    if (value) {
                      _setupNotifications(settings);
                    } else {
                      ref.read(notificationServiceProvider).cancelAllNotifications();
                    }
                  },
                ),
                if (settings.notificationsEnabled) ...[
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.timer_outlined,
                    title: 'Hatırlatma Sıklığı',
                    subtitle: '${settings.notificationIntervalMinutes} dakika',
                    onTap: () => _showIntervalDialog(settings),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Akıllı Bildirimler'),
                    subtitle: const Text('Uzun süre su içilmezse hatırlat'),
                    secondary: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: AppColors.turquoise.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.turquoise,
                      ),
                    ),
                    value: settings.adaptiveNotifications,
                    onChanged: (value) {
                      ref.read(userSettingsProvider.notifier).updateSettings(
                            settings.copyWith(adaptiveNotifications: value),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Aktif Saatler',
                    subtitle:
                        '${settings.wakeUpHour.toString().padLeft(2, '0')}:00 - ${settings.sleepHour.toString().padLeft(2, '0')}:00',
                    onTap: () => _showActiveHoursDialog(settings),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Görünüm
          Text(
            'Görünüm',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SoftCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  title: 'Tema Modu',
                  subtitle: _getThemeName(settings.selectedTheme),
                  onTap: () => _showThemeDialog(settings),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Tema Koleksiyonu',
                  subtitle: _getThemeCollectionSubtitle(ref),
                  iconColor: AppColors.turquoise,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ThemeSelectionScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Ödüller
          Text(
            'Ödüller',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SoftCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.emoji_events_outlined,
                  title: 'Rozetler',
                  subtitle: _getBadgeSubtitle(ref),
                  iconColor: AppColors.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BadgesScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Veri
          Text(
            'Veri',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SoftCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.delete_outline,
                  title: 'Verileri Sil',
                  subtitle: 'Tüm su kayıtlarını sil',
                  iconColor: Colors.red,
                  onTap: () => _showDeleteDataDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          // Uygulama bilgisi
          Center(
            child: Column(
              children: [
                Text(
                  '💧 Hydration App',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sürüm 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sağlıklı yaşam için su içmeyi unutma!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
        ],
      ),
    );
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Açık';
      case 'dark':
        return 'Koyu';
      default:
        return 'Sistem';
    }
  }

  String _getThemeCollectionSubtitle(WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final stats = themeState.stats;
    if (stats.unlocked == stats.total) {
      return 'Tüm temalar açık! 🎉';
    }
    return '${stats.unlocked}/${stats.total} tema açık';
  }

  String _getBadgeSubtitle(WidgetRef ref) {
    final badgeState = ref.watch(badgeControllerProvider);
    final stats = badgeState.stats;
    if (stats.unlocked == stats.total) {
      return 'Tüm rozetler kazanıldı! 👑';
    }
    return '${stats.unlocked}/${stats.total} rozet kazanıldı';
  }

  void _setupNotifications(UserSettings settings) {
    ref.read(notificationServiceProvider).scheduleHydrationReminders(
          intervalMinutes: settings.notificationIntervalMinutes,
          wakeUpHour: settings.wakeUpHour,
          sleepHour: settings.sleepHour,
        );
  }

  void _showNameDialog(UserSettings settings) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İsminiz'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'İsminizi girin',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(userSettingsProvider.notifier)
                  .setUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(UserSettings settings) {
    int weight = settings.weight;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kilonuz'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$weight kg',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              Slider(
                value: weight.toDouble(),
                min: 30,
                max: 200,
                divisions: 170,
                onChanged: (value) {
                  setState(() => weight = value.round());
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userSettingsProvider.notifier).setWeight(weight);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(UserSettings settings) {
    int goal = settings.dailyGoal;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Günlük Hedef'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$goal ml',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${(goal / 1000).toStringAsFixed(1)} litre',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spacingM),
              Slider(
                value: goal.toDouble(),
                min: 1000,
                max: 5000,
                divisions: 40,
                onChanged: (value) {
                  setState(() => goal = (value / 100).round() * 100);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userSettingsProvider.notifier).setDailyGoal(goal);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showCupSizeDialog(UserSettings settings) {
    final sizes = [100, 150, 200, 250, 300, 330, 500];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılan Bardak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes.map((size) {
            return ListTile(
              title: Text('$size ml'),
              trailing: settings.defaultCupSize == size
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(userSettingsProvider.notifier)
                    .setDefaultCupSize(size);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showIntervalDialog(UserSettings settings) {
    final intervals = [30, 45, 60, 90, 120];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatma Sıklığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            return ListTile(
              title: Text('$interval dakika'),
              trailing: settings.notificationIntervalMinutes == interval
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref
                    .read(userSettingsProvider.notifier)
                    .setNotificationInterval(interval);
                _setupNotifications(
                    settings.copyWith(notificationIntervalMinutes: interval));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showActiveHoursDialog(UserSettings settings) {
    int wakeUp = settings.wakeUpHour;
    int sleep = settings.sleepHour;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktif Saatler'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uyanış'),
                  DropdownButton<int>(
                    value: wakeUp,
                    items: List.generate(24, (i) => i)
                        .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')}:00'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => wakeUp = value!);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uyku'),
                  DropdownButton<int>(
                    value: sleep,
                    items: List.generate(24, (i) => i)
                        .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')}:00'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => sleep = value!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userSettingsProvider.notifier).setWakeUpHour(wakeUp);
              ref.read(userSettingsProvider.notifier).setSleepHour(sleep);
              _setupNotifications(
                  settings.copyWith(wakeUpHour: wakeUp, sleepHour: sleep));
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(UserSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('Sistem'),
              trailing: settings.selectedTheme == 'system'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(userSettingsProvider.notifier).setTheme('system');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Açık'),
              trailing: settings.selectedTheme == 'light'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(userSettingsProvider.notifier).setTheme('light');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Koyu'),
              trailing: settings.selectedTheme == 'dark'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(userSettingsProvider.notifier).setTheme('dark');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Sil'),
        content: const Text(
          'Tüm su kayıtları ve istatistikler silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              ref.read(storageServiceProvider).clearAllData();
              ref.read(todayWaterEntriesProvider.notifier).refresh();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler silindi')),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

