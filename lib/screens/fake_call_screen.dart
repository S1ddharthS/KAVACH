import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Simulated incoming call screen.
///
/// Shows a realistic-looking incoming call UI. Call it via:
/// ```dart
/// Navigator.pushNamed(context, KavachRoutes.fakeCall);
/// // or with arguments:
/// Navigator.pushNamed(
///   context,
///   KavachRoutes.fakeCall,
///   arguments: FakeCallArgs(callerName: 'Mom', callerPhone: '+91 76543 21098'),
/// );
/// ```
class FakeCallArgs {
  final String callerName;
  final String callerPhone;
  final String? callerInitial;

  const FakeCallArgs({
    this.callerName = 'Mom',
    this.callerPhone = '+91 76543 21098',
    this.callerInitial,
  });
}

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with TickerProviderStateMixin {
  // States: ringing → connected → ended
  _CallState _state = _CallState.ringing;
  int _seconds = 0;
  Timer? _callTimer;

  // Ripple animation for ringing
  late final AnimationController _rippleCtrl;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;

  // Slide-up animation for action buttons
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideOffset;

  // Mic / speaker toggles
  bool _micMuted = false;
  bool _speakerOn = true;
  bool _onHold = false;

  @override
  void initState() {
    super.initState();

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _rippleScale = Tween<double>(begin: 0.8, end: 1.5)
        .animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    _rippleOpacity = Tween<double>(begin: 0.6, end: 0.0)
        .animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideOffset =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );

    _slideCtrl.forward();

    // Vibrate to simulate incoming call
    _startVibration();
  }

  Future<void> _startVibration() async {
    HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted && _state == _CallState.ringing) {
      HapticFeedback.vibrate();
    }
  }

  void _acceptCall() {
    HapticFeedback.mediumImpact();
    _rippleCtrl.stop();
    setState(() => _state = _CallState.connected);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _declineCall() {
    HapticFeedback.heavyImpact();
    setState(() => _state = _CallState.ended);
    _callTimer?.cancel();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _endCall() {
    HapticFeedback.heavyImpact();
    _callTimer?.cancel();
    setState(() => _state = _CallState.ended);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  String get _formattedTime {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _slideCtrl.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as FakeCallArgs?;
    final callerName   = args?.callerName   ?? 'Mom';
    final callerPhone  = args?.callerPhone  ?? '+91 76543 21098';
    final callerInitial = (args?.callerInitial ?? callerName)[0].toUpperCase();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: KavachColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF12003A), Color(0xFF0D0D1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────
                _buildTopBar(),

                const Spacer(flex: 2),

                // ── Caller info ──────────────────────────
                _buildCallerInfo(callerName, callerPhone, callerInitial),

                const Spacer(flex: 1),

                // ── Status / timer ───────────────────────
                _buildCallStatus(),

                const Spacer(flex: 2),

                // ── In-call controls (when connected) ────
                if (_state == _CallState.connected)
                  SlideTransition(
                    position: _slideOffset,
                    child: _buildInCallControls(),
                  ),

                const Spacer(flex: 1),

                // ── Answer / decline row ─────────────────
                SlideTransition(
                  position: _slideOffset,
                  child: _buildCallActions(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KavachSizes.paddingL,
        vertical: KavachSizes.paddingM,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: KavachColors.textSecondary,
              size: 30,
            ),
          ),
          const Spacer(),
          Text(
            _state == _CallState.ringing
                ? 'KAVACH  •  Fake Call'
                : 'KAVACH  •  In Call',
            style: KavachTextStyles.caption.copyWith(letterSpacing: 1),
          ),
          const Spacer(),
          const SizedBox(width: 30),
        ],
      ),
    );
  }

  Widget _buildCallerInfo(
      String name, String phone, String initial) {
    return Column(
      children: [
        // Avatar with ripple rings
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple rings (only while ringing)
              if (_state == _CallState.ringing)
                AnimatedBuilder(
                  animation: _rippleCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _rippleOpacity.value,
                    child: Transform.scale(
                      scale: _rippleScale.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: KavachColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Avatar circle
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFF4A3AB0)],
                    radius: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KavachColors.accent.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text(name, style: KavachTextStyles.headline1),
        const SizedBox(height: 6),
        Text(
          phone,
          style: KavachTextStyles.subtitle.copyWith(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildCallStatus() {
    String statusText;
    Color statusColor;

    switch (_state) {
      case _CallState.ringing:
        statusText = 'Incoming Call…';
        statusColor = KavachColors.accent;
        break;
      case _CallState.connected:
        statusText = _formattedTime;
        statusColor = KavachColors.safe;
        break;
      case _CallState.ended:
        statusText = 'Call Ended';
        statusColor = KavachColors.textSecondary;
        break;
    }

    return AnimatedSwitcher(
      duration: KavachDurations.normal,
      child: Column(
        key: ValueKey(_state),
        children: [
          if (_state == _CallState.ringing)
            const _PulsingDots(),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: KavachTextStyles.body.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          if (_state == _CallState.connected && _onHold)
            Text(
              'ON HOLD',
              style: KavachTextStyles.caption.copyWith(
                color: KavachColors.warning,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInCallControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KavachSizes.paddingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CallControl(
            icon: _micMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: _micMuted ? 'Unmute' : 'Mute',
            active: _micMuted,
            onTap: () => setState(() => _micMuted = !_micMuted),
          ),
          _CallControl(
            icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            label: 'Speaker',
            active: _speakerOn,
            onTap: () => setState(() => _speakerOn = !_speakerOn),
          ),
          _CallControl(
            icon: _onHold
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            label: _onHold ? 'Resume' : 'Hold',
            active: _onHold,
            activeColor: KavachColors.warning,
            onTap: () => setState(() => _onHold = !_onHold),
          ),
          _CallControl(
            icon: Icons.dialpad_rounded,
            label: 'Keypad',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCallActions() {
    if (_state == _CallState.connected || _state == _CallState.ended) {
      // Show only end-call button
      return Center(
        child: _state == _CallState.ended
            ? const SizedBox.shrink()
            : _BigCallBtn(
                icon: Icons.call_end_rounded,
                color: KavachColors.danger,
                label: 'End',
                onTap: _endCall,
              ),
      );
    }

    // Ringing state — accept or decline
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KavachSizes.paddingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              _BigCallBtn(
                icon: Icons.call_end_rounded,
                color: KavachColors.danger,
                label: 'Decline',
                onTap: _declineCall,
              ),
            ],
          ),
          Column(
            children: [
              _BigCallBtn(
                icon: Icons.call_rounded,
                color: KavachColors.safe,
                label: 'Accept',
                onTap: _acceptCall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum _CallState { ringing, connected, ended }

// ── Local sub-widgets ─────────────────────────────────────────────────────────

class _BigCallBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _BigCallBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: KavachTextStyles.caption.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? activeColor;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = active
        ? (activeColor ?? KavachColors.primary)
        : KavachColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: KavachDurations.fast,
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active
                  ? effectiveColor.withOpacity(0.18)
                  : KavachColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active
                    ? effectiveColor.withOpacity(0.4)
                    : KavachColors.divider,
                width: 1,
              ),
            ),
            child: Icon(icon, color: effectiveColor, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: KavachTextStyles.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final value = ((_anim.value + delay) % 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: KavachColors.accent.withOpacity(0.3 + value * 0.7),
            ),
          );
        }),
      ),
    );
  }
}
