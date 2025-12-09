import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/water_controller.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';
import '../widgets/water_button.dart';
import '../utils/motivational_messages.dart';

class AddWaterDialog extends ConsumerStatefulWidget {
  const AddWaterDialog({super.key});

  @override
  ConsumerState<AddWaterDialog> createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends ConsumerState<AddWaterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _selectedAmount = 250;
  int? _customAmount;
  bool _showCustomInput = false;
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<int> quickAmounts = [100, 150, 200, 250, 300, 330, 500, 750, 1000];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    // Varsayılan bardak boyutunu kullan
    final settings = ref.read(userSettingsProvider);
    _selectedAmount = settings.defaultCupSize;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _showCustomInput = false;
    });
  }

  void _addWater() async {
    final amount = _showCustomInput
        ? (_customAmount ?? _selectedAmount)
        : _selectedAmount;

    if (amount <= 0) return;

    final wasGoalReached = ref.read(goalReachedProvider);

    await ref.read(todayWaterEntriesProvider.notifier).addWaterEntry(
          amount,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
        );

    if (mounted) {
      Navigator.of(context).pop();

      // Motivasyon mesajı göster
      final isGoalReached = ref.read(goalReachedProvider);
      final message = !wasGoalReached && isGoalReached
          ? MotivationalMessages.getRandomGoalReachedMessage()
          : MotivationalMessages.getRandomWaterAddedMessage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, screenHeight * 0.5 * _slideAnimation.value),
          child: child,
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppTheme.spacingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Başlık
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Su Ekle 💧',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // Seçili miktar göstergesi
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                gradient: AppColors.calmGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.water_drop,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    _showCustomInput
                        ? '${_customAmount ?? 0} ml'
                        : '$_selectedAmount ml',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Hızlı seçim butonları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                alignment: WrapAlignment.center,
                children: quickAmounts.map((amount) {
                  return WaterButton(
                    amount: amount,
                    isSelected: !_showCustomInput && _selectedAmount == amount,
                    onTap: () => _selectAmount(amount),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            // Özel miktar butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCustomInput = !_showCustomInput;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: _showCustomInput
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _showCustomInput
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 18,
                        color: _showCustomInput
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        'Özel Miktar Gir',
                        style: TextStyle(
                          color: _showCustomInput
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Özel miktar girişi
            if (_showCustomInput) ...[
              const SizedBox(height: AppTheme.spacingM),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: WaterSlider(
                  value: _customAmount ?? 250,
                  min: 50,
                  max: 1500,
                  divisions: 29,
                  onChanged: (value) {
                    setState(() {
                      _customAmount = value;
                    });
                  },
                ),
              ),
            ],
            // Not ekleme
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Not ekle (isteğe bağlı)',
                  prefixIcon: Icon(
                    Icons.note_add_outlined,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                maxLength: 50,
              ),
            ),
            // Ekle butonu
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM,
                0,
                AppTheme.spacingM,
                AppTheme.spacingL,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addWater,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  ),
                  child: const Text(
                    'Su Ekle',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            // Güvenli alan
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

