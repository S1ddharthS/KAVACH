import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Data model for a single emergency contact.
class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;
  final Color? avatarColor;
  final IconData? icon;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
    this.avatarColor,
    this.icon,
  });

  /// First letter of name for avatar.
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}

/// A polished emergency contact tile.
///
/// Usage:
/// ```dart
/// ContactTile(
///   contact: EmergencyContact(
///     name: 'Priya Sharma',
///     phone: '+91 98765 43210',
///     relationship: 'Sister',
///   ),
///   onCall: () { /* dial */ },
///   onMessage: () { /* sms */ },
/// )
/// ```
class ContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onTap;
  final bool isTopContact;

  const ContactTile({
    super.key,
    required this.contact,
    this.onCall,
    this.onMessage,
    this.onTap,
    this.isTopContact = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = contact.avatarColor ?? KavachColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: KavachSizes.paddingM,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: KavachColors.surfaceCard,
          borderRadius: BorderRadius.circular(KavachSizes.radiusLarge),
          border: Border.all(
            color: isTopContact
                ? KavachColors.primary.withOpacity(0.55)
                : KavachColors.divider,
            width: isTopContact ? 1.5 : 1,
          ),
          boxShadow: isTopContact
              ? [
                  BoxShadow(
                    color: KavachColors.primaryGlow,
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KavachSizes.paddingM,
            vertical: KavachSizes.paddingS,
          ),
          child: Row(
            children: [
              // ── Avatar ────────────────────────────────
              _Avatar(
                initial: contact.initial,
                color: avatarColor,
                icon: contact.icon,
              ),

              const SizedBox(width: 14),

              // ── Name + phone ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contact.name,
                          style: KavachTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isTopContact) ...[
                          const SizedBox(width: 6),
                          _Badge(label: 'PRIMARY'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.phone,
                      style: KavachTextStyles.caption,
                    ),
                    const SizedBox(height: 3),
                    _RelationshipChip(label: contact.relationship),
                  ],
                ),
              ),

              // ── Quick actions ─────────────────────────
              _ActionButton(
                icon: Icons.phone_rounded,
                color: KavachColors.safe,
                onTap: onCall,
                tooltip: 'Call',
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.message_rounded,
                color: KavachColors.accent,
                onTap: onMessage,
                tooltip: 'Message',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Internal sub-widgets ──────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initial;
  final Color color;
  final IconData? icon;

  const _Avatar({
    required this.initial,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.4)],
          radius: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 22, color: Colors.white)
            : Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: KavachColors.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: KavachColors.primary.withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: KavachColors.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  final String label;
  const _RelationshipChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: KavachColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: KavachColors.accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
