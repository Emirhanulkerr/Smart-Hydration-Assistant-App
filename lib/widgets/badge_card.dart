import 'package:flutter/material.dart' hide Badge;
import '../models/badge_model.dart';

/// Rozet kartı - Soft, pastel tasarım
class BadgeCard extends StatefulWidget {
  final Badge badge;
  final VoidCallback? onTap;
  final bool showShimmer;

  const BadgeCard({
    super.key,
    required this.badge,
    this.onTap,
    this.showShimmer = true,
  });

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.badge.unlocked && widget.showShimmer) {
      _shimmerController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BadgeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.badge.unlocked && widget.showShimmer && !_shimmerController.isAnimating) {
      _shimmerController.repeat(reverse: true);
    } else if (!widget.badge.unlocked && _shimmerController.isAnimating) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getBadgeColor() {
    if (!widget.badge.unlocked) return Colors.grey.shade300;

    switch (widget.badge.id) {
      case 'fresh_start':
        return const Color(0xFF81C784); // Yeşil
      case 'found_rhythm':
        return const Color(0xFF64B5F6); // Mavi
      case 'hydration_master':
        return const Color(0xFF9575CD); // Mor
      case 'monthly_hero':
        return const Color(0xFFFFB74D); // Turuncu
      case 'legendary_hydration':
        return const Color(0xFFFFD54F); // Altın
      default:
        return const Color(0xFF90CAF9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.badge.unlocked;
    final badgeColor = _getBadgeColor();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        badgeColor.withValues(alpha: 0.15),
                        badgeColor.withValues(alpha: 0.08),
                      ],
                    )
                  : null,
              color: isUnlocked ? null : Colors.grey.shade100,
              border: Border.all(
                color: isUnlocked
                    ? badgeColor.withValues(
                        alpha: 0.4 + _shimmerAnimation.value * 0.3,
                      )
                    : Colors.grey.shade200,
                width: isUnlocked ? 2 : 1,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: badgeColor.withValues(
                          alpha: 0.15 + _shimmerAnimation.value * 0.15,
                        ),
                        blurRadius: 12 + _shimmerAnimation.value * 8,
                        spreadRadius: _shimmerAnimation.value * 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rozet emoji
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? badgeColor.withValues(alpha: 0.2)
                        : Colors.grey.shade200,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: badgeColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.badge.emoji,
                      style: TextStyle(
                        fontSize: 32,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Başlık
                Text(
                  widget.badge.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? badgeColor : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Streak bilgisi
                Text(
                  isUnlocked
                      ? '${widget.badge.streakRequired} gün ✓'
                      : '${widget.badge.streakRequired} gün',
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnlocked
                        ? badgeColor.withValues(alpha: 0.8)
                        : Colors.grey.shade400,
                  ),
                ),
                // Kilit ikonu
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.grey.shade400,
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

/// Rozet detay modal'ı
class BadgeDetailModal extends StatefulWidget {
  final Badge badge;

  const BadgeDetailModal({super.key, required this.badge});

  @override
  State<BadgeDetailModal> createState() => _BadgeDetailModalState();
}

class _BadgeDetailModalState extends State<BadgeDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    if (widget.badge.unlocked) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBadgeColor() {
    if (!widget.badge.unlocked) return Colors.grey;

    switch (widget.badge.id) {
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

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.badge.unlocked;
    final badgeColor = _getBadgeColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      badgeColor,
                      badgeColor.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: isUnlocked ? null : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rozet
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.grey.shade100,
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: 0.2 + _shimmerAnimation.value * 0.2,
                                ),
                                blurRadius: 16 + _shimmerAnimation.value * 8,
                                spreadRadius: _shimmerAnimation.value * 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.badge.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Başlık
              Text(
                widget.badge.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.white : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Açıklama
              Text(
                widget.badge.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isUnlocked
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Streak bilgisi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.badge.streakRequired} günlük seri gerekli',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Açılma tarihi
              if (isUnlocked && widget.badge.unlockedAt != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Açılma: ${_formatDate(widget.badge.unlockedAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
              // Tebrik mesajı
              if (isUnlocked) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.badge.congratsMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Kapat butonu
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnlocked ? Colors.white : badgeColor,
                  foregroundColor: isUnlocked ? badgeColor : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Tamam'),
              ),
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

/// Rozet açıldı popup'ı (soft animasyonlu)
class BadgeUnlockedPopup extends StatefulWidget {
  final Badge badge;
  final VoidCallback? onDismiss;

  const BadgeUnlockedPopup({
    super.key,
    required this.badge,
    this.onDismiss,
  });

  @override
  State<BadgeUnlockedPopup> createState() => _BadgeUnlockedPopupState();
}

class _BadgeUnlockedPopupState extends State<BadgeUnlockedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // 4 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBadgeColor() {
    switch (widget.badge.id) {
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

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [badgeColor, badgeColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    widget.badge.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Yeni Rozet! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.badge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

