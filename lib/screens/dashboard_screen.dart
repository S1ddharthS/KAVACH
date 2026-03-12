import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/sos_button.dart';
import '../widgets/contact_tile.dart';

/// The main dashboard screen of KAVACH.
///
/// Features:
/// • Hero SOS long-press button
/// • Quick feature navigation grid
/// • Emergency contacts horizontal list
/// • Bottom navigation bar
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Sample contacts — replace with real data source
  static const List<EmergencyContact> _contacts = [
    EmergencyContact(
      name: 'Priya Sharma',
      phone: '+91 98765 43210',
      relationship: 'Sister',
      avatarColor: KavachColors.primary,
    ),
    EmergencyContact(
      name: 'Anika Gupta',
      phone: '+91 87654 32109',
      relationship: 'Friend',
      avatarColor: KavachColors.accent,
    ),
    EmergencyContact(
      name: 'Mom',
      phone: '+91 76543 21098',
      relationship: 'Mother',
      avatarColor: KavachColors.safe,
    ),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break; // already on dashboard
      case 1:
        Navigator.pushNamed(context, KavachRoutes.map);
        break;
      case 2:
        Navigator.pushNamed(context, KavachRoutes.safeWalk);
        break;
      case 3:
        Navigator.pushNamed(context, KavachRoutes.fakeCall);
        break;
      case 4:
        Navigator.pushNamed(context, KavachRoutes.community);
        break;
    }
  }

  void _onSosActivated() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '🚨 SOS Alert Sent to Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: KavachColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KavachColors.background,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: KavachColors.bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ─────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── SOS Section ──────────────────────────
              SliverToBoxAdapter(child: _buildSosSection()),

              // ── Quick Access Grid ─────────────────────
              SliverToBoxAdapter(child: _buildQuickAccess()),

              // ── Contacts Header ───────────────────────
              SliverToBoxAdapter(child: _buildSectionHeader(
                'Emergency Contacts',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Manage',
                    style: TextStyle(
                      color: KavachColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),

              // ── Contact Tiles ─────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ContactTile(
                    contact: _contacts[index],
                    isTopContact: index == 0,
                    onCall: () => _showSnack('📞 Calling ${_contacts[index].name}…'),
                    onMessage: () => _showSnack('💬 Messaging ${_contacts[index].name}…'),
                  ),
                  childCount: _contacts.length,
                ),
              ),

              // ── Status Card ───────────────────────────
              SliverToBoxAdapter(child: _buildStatusCard()),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KavachSizes.paddingL, KavachSizes.paddingL,
        KavachSizes.paddingL, 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                KavachStrings.appName,
                style: KavachTextStyles.headline1.copyWith(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [KavachColors.primary, KavachColors.accent],
                    ).createShader(
                      const Rect.fromLTWH(0, 0, 120, 40),
                    ),
                ),
              ),
              Text(
                KavachStrings.dashboardGreeting,
                style: KavachTextStyles.subtitle,
              ),
            ],
          ),
          Row(
            children: [
              _HeaderIconBtn(
                icon: Icons.notifications_outlined,
                badge: true,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _HeaderIconBtn(
                icon: Icons.person_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KavachSizes.paddingXL),
      child: Column(
        children: [
          SosButton(onActivated: _onSosActivated),
          const SizedBox(height: 12),
          Text(
            'Press & Hold to Send Emergency Alert',
            style: KavachTextStyles.caption.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KavachSizes.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Quick Access'),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickCard(
                icon: Icons.map_rounded,
                label: KavachStrings.navMap,
                color: KavachColors.accent,
                onTap: () => Navigator.pushNamed(context, KavachRoutes.map),
              ),
              _QuickCard(
                icon: Icons.directions_walk_rounded,
                label: KavachStrings.navSafeWalk,
                color: KavachColors.safe,
                onTap: () => Navigator.pushNamed(context, KavachRoutes.safeWalk),
              ),
              _QuickCard(
                icon: Icons.phone_callback_rounded,
                label: KavachStrings.navFakeCall,
                color: KavachColors.warning,
                onTap: () => Navigator.pushNamed(context, KavachRoutes.fakeCall),
              ),
              _QuickCard(
                icon: Icons.flag_rounded,
                label: KavachStrings.navReport,
                color: KavachColors.primary,
                onTap: () => Navigator.pushNamed(context, KavachRoutes.report),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KavachSizes.paddingM,
        vertical: KavachSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: KavachTextStyles.headline2.copyWith(fontSize: 18)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(KavachSizes.paddingM),
      padding: const EdgeInsets.all(KavachSizes.paddingM),
      decoration: BoxDecoration(
        color: KavachColors.safe.withOpacity(0.08),
        borderRadius: BorderRadius.circular(KavachSizes.radiusLarge),
        border: Border.all(
          color: KavachColors.safe.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KavachColors.safe.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: KavachColors.safe,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are Protected',
                  style: KavachTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: KavachColors.safe,
                  ),
                ),
                Text(
                  'KAVACH is actively monitoring your safety.',
                  style: KavachTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.circle,
            size: 10,
            color: KavachColors.safe,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: KavachColors.surface,
        border: Border(
          top: BorderSide(
            color: KavachColors.divider,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: KavachColors.primary,
        unselectedItemColor: KavachColors.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk_outlined),
            activeIcon: Icon(Icons.directions_walk_rounded),
            label: 'Safe Walk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_callback_outlined),
            activeIcon: Icon(Icons.phone_callback_rounded),
            label: 'Fake Call',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group_rounded),
            label: 'Community',
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: KavachColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Local sub-widgets ─────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: KavachColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KavachColors.divider),
            ),
            child: Icon(icon, color: KavachColors.textPrimary, size: 22),
          ),
          if (badge)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: KavachColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(KavachSizes.radiusMedium),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: KavachTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
