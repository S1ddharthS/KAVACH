import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// A big, animated SOS button.
///
/// Usage:
/// ```dart
/// SosButton(
///   onActivated: () { /* trigger SOS logic */ },
/// )
/// ```
class SosButton extends StatefulWidget {
  /// Called when the user completes a long-press to confirm SOS.
  final VoidCallback? onActivated;

  /// Duration the user must hold before SOS fires (default 2 s).
  final Duration holdDuration;

  const SosButton({
    super.key,
    this.onActivated,
    this.holdDuration = const Duration(seconds: 2),
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with TickerProviderStateMixin {
  // Continuous glow-pulse animation
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Hold-progress animation
  late final AnimationController _holdCtrl;
  late final Animation<double> _holdProgress;

  bool _isHolding = false;
  bool _activated = false;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: KavachDurations.sosPulse,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    _holdCtrl = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _holdProgress = CurvedAnimation(
      parent: _holdCtrl,
      curve: Curves.easeInOut,
    );

    _holdCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onActivated();
      }
    });
  }

  void _onActivated() {
    if (_activated) return;
    _activated = true;
    HapticFeedback.heavyImpact();
    widget.onActivated?.call();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _activated = false);
        _holdCtrl.reset();
      }
    });
  }

  void _startHold() {
    if (_activated) return;
    HapticFeedback.mediumImpact();
    setState(() => _isHolding = true);
    _holdCtrl.forward(from: 0);
  }

  void _cancelHold() {
    if (_activated) return;
    setState(() => _isHolding = false);
    _holdCtrl.reverse();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _holdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = KavachSizes.sosBtnSize;

    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: SizedBox(
        width: size + 60,
        height: size + 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Outer glow ring ──────────────────────
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Transform.scale(
                scale: _pulseScale.value,
                child: Container(
                  width: size + 48,
                  height: size + 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KavachColors.primary
                        .withOpacity(_pulseOpacity.value),
                  ),
                ),
              ),
            ),

            // ── Mid glow ring ────────────────────────
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Transform.scale(
                scale: 1.0 + (_pulseScale.value - 1.0) * 0.5,
                child: Container(
                  width: size + 24,
                  height: size + 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KavachColors.primary
                        .withOpacity(_pulseOpacity.value * 0.6),
                  ),
                ),
              ),
            ),

            // ── Hold progress ring ────────────────────
            AnimatedBuilder(
              animation: _holdProgress,
              builder: (context, _) {
                return SizedBox(
                  width: size + 16,
                  height: size + 16,
                  child: CircularProgressIndicator(
                    value: _holdProgress.value,
                    strokeWidth: 5,
                    backgroundColor: KavachColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _activated
                          ? KavachColors.safe
                          : KavachColors.primary,
                    ),
                  ),
                );
              },
            ),

            // ── Main button body ──────────────────────
            AnimatedScale(
              scale: _isHolding ? 0.94 : 1.0,
              duration: KavachDurations.fast,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: KavachColors.sosGradient,
                    center: Alignment(-0.3, -0.4),
                    radius: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KavachColors.primary.withOpacity(0.55),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: KavachColors.danger.withOpacity(0.25),
                      blurRadius: 60,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 42,
                      color: KavachColors.textPrimary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _activated
                          ? KavachStrings.sosSending
                          : KavachStrings.sosHold,
                      style: KavachTextStyles.sosLabel.copyWith(
                        fontSize: _activated ? 13 : 22,
                        letterSpacing: _activated ? 1.5 : 3,
                      ),
                    ),
                    if (!_activated) ...[
                      const SizedBox(height: 4),
                      Text(
                        '2 SECONDS',
                        style: KavachTextStyles.sosSubLabel,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
