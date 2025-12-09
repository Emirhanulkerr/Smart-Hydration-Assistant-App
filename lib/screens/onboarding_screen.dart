import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/water_controller.dart';
import '../models/user_settings.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../widgets/wave_animation.dart';
import 'main_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Kullanıcı verileri
  String _userName = '';
  int _weight = 70;
  int _dailyGoal = 2000;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AppTheme.animationMedium,
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final settings = UserSettings(
      userName: _userName.isNotEmpty ? _userName : null,
      weight: _weight,
      dailyGoal: _dailyGoal,
      onboardingCompleted: true,
    );
    
    await ref.read(userSettingsProvider.notifier).updateSettings(settings);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // İlerleme göstergesi
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Sayfa içeriği
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Sayfa 1: Hoş geldin
                  _OnboardingPage(
                    title: 'Hoş Geldin! 💧',
                    description:
                        'Su içme alışkanlığı kazanmak için doğru yerdesin. Sağlıklı bir yaşam için düzenli su tüketimi çok önemli.',
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: WaveAnimation(
                        fillPercentage: 0.6,
                        waveColor: AppColors.water,
                        backgroundColor: AppColors.waterLight,
                      ),
                    ),
                  ),
                  // Sayfa 2: İsim
                  _OnboardingPage(
                    title: 'Seni Tanıyalım 👋',
                    description: 'Sana nasıl hitap etmemizi istersin?',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL,
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _userName = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'İsminizi girin',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  // Sayfa 3: Kilo
                  _OnboardingPage(
                    title: 'Kilonuz 📊',
                    description:
                        'Kilonuza göre günlük su hedefinizi hesaplayalım.',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_weight kg',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingL,
                          ),
                          child: Slider(
                            value: _weight.toDouble(),
                            min: 30,
                            max: 150,
                            divisions: 120,
                            onChanged: (value) {
                              setState(() {
                                _weight = value.round();
                                _dailyGoal =
                                    UserSettings.calculateRecommendedGoal(_weight);
                              });
                            },
                          ),
                        ),
                        Text(
                          'Önerilen hedef: $_dailyGoal ml',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.success,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Sayfa 4: Hedef
                  _OnboardingPage(
                    title: 'Günlük Hedefin 🎯',
                    description:
                        'Günlük su hedefinizi ayarlayın. İstediğiniz zaman değiştirebilirsiniz.',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_dailyGoal ml',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${(_dailyGoal / 1000).toStringAsFixed(1)} litre',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingL,
                          ),
                          child: Slider(
                            value: _dailyGoal.toDouble(),
                            min: 1000,
                            max: 5000,
                            divisions: 40,
                            onChanged: (value) {
                              setState(() {
                                _dailyGoal = (value / 100).round() * 100;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppColors.mintLight,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.turquoiseDark,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              Text(
                                'Yaklaşık ${(_dailyGoal / 250).round()} bardak su',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Butonlar
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  // Geri butonu
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: AppTheme.animationMedium,
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: const Text('Geri'),
                    )
                  else
                    const SizedBox(width: 80),
                  const Spacer(),
                  // İleri butonu
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXL,
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                    child: Text(
                      _currentPage == 3 ? 'Başla' : 'İleri',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          child,
        ],
      ),
    );
  }
}

