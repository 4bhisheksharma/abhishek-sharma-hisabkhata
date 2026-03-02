import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/nearby_businesses_map_screen.dart';
import 'package:hisab_khata/shared/utils/auth_utils.dart';
import 'package:hisab_khata/shared/widgets/profile/profile_picture_avatar.dart';
import 'package:hisab_khata/shared/widgets/my_bottom_nav_bar.dart';
import 'package:hisab_khata/shared/widgets/language_switcher.dart';
import 'package:hisab_khata/shared/widgets/dialogs/change_password_dialog.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';

class CustomerProfileViewScreen extends StatefulWidget {
  const CustomerProfileViewScreen({super.key});

  @override
  State<CustomerProfileViewScreen> createState() =>
      _CustomerProfileViewScreenState();
}

class _CustomerProfileViewScreenState extends State<CustomerProfileViewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomerProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const ProfileViewShimmer();
          }

          if (state is CustomerProfileLoaded ||
              state is CustomerProfileUpdated) {
            final profile = state is CustomerProfileLoaded
                ? state.profile
                : (state as CustomerProfileUpdated).profile;

            // Save profile picture to shared preferences
            SharedPreferences.getInstance().then((prefs) {
              if (profile.profilePicture != null) {
                prefs.setString('profile_picture', profile.profilePicture!);
              }
            });

            return CustomScrollView(
              slivers: [
                // Modern gradient header with profile (matching business style)
                SliverToBoxAdapter(
                  child: _buildProfileHeader(context, profile),
                ),

                // Menu sections
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Account ──
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.editProfile ==
                                'Edit Profile'
                            ? 'Account'
                            : 'खाता',
                      ),
                      _buildMenuCard(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF4A90E2),
                            iconBgColor: const Color(0xFFE3F2FD),
                            title: AppLocalizations.of(context)!.editProfile,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/customer-profile',
                            ),
                          ),
                          _divider(),
                          _buildMenuItem(
                            icon: Icons.security_outlined,
                            iconColor: const Color(0xFF00D9B5),
                            iconBgColor: const Color(0xFFE0F7F4),
                            title: AppLocalizations.of(context)!.security,
                            subtitle: 'Change password',
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const ChangePasswordDialog(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Location ──
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.editProfile ==
                                'Edit Profile'
                            ? 'Location'
                            : 'स्थान',
                      ),
                      _buildMenuCard(
                        children: [
                          _buildMenuItem(
                            icon: Icons.map_outlined,
                            iconColor: const Color(0xFFE53935),
                            iconBgColor: const Color(0xFFFFEBEE),
                            title: 'Businesses Near Me',
                            subtitle: 'View businesses on map',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NearbyBusinessesMapScreen(),
                                ),
                              );
                              if (mounted) {
                                context.read<CustomerBloc>().add(
                                  const LoadCustomerProfile(),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── App ──
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.editProfile ==
                                'Edit Profile'
                            ? 'App'
                            : 'एप',
                      ),
                      _buildMenuCard(
                        children: [
                          _buildMenuItem(
                            icon: Icons.language_outlined,
                            iconColor: const Color(0xFF2196F3),
                            iconBgColor: const Color(0xFFE3F2FD),
                            title: AppLocalizations.of(context)!.language,
                            trailing: LanguageSwitcher(
                              initialLanguage:
                                  profile.preferredLanguage ?? 'en',
                              onLanguageChanged: (language) {
                                context.read<CustomerBloc>().add(
                                  UpdateCustomerProfileEvent(
                                    preferredLanguage: language,
                                  ),
                                );
                              },
                            ),
                            onTap: () {},
                          ),
                          _divider(),
                          _buildMenuItem(
                            icon: Icons.people_outline,
                            iconColor: const Color(0xFF9C27B0),
                            iconBgColor: const Color(0xFFF3E5F5),
                            title: AppLocalizations.of(context)!.switchToHybrid,
                            onTap: () => debugPrint("Switch to Hybrid tapped"),
                          ),
                          _divider(),
                          _buildMenuItem(
                            icon: Icons.smart_toy_outlined,
                            iconColor: const Color(0xFF6200EA),
                            iconBgColor: const Color(0xFFEDE7F6),
                            title: 'Talk to Byapar d-AI',
                            subtitle: 'AI assistant',
                            onTap: () =>
                                Navigator.pushNamed(context, '/chatbot'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Support ──
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.editProfile ==
                                'Edit Profile'
                            ? 'Support'
                            : 'सहयोग',
                      ),
                      _buildMenuCard(
                        children: [
                          _buildMenuItem(
                            icon: Icons.support_agent_outlined,
                            iconColor: const Color(0xFFFF9800),
                            iconBgColor: const Color(0xFFFFF3E0),
                            title: AppLocalizations.of(context)!.raiseATicket,
                            onTap: () =>
                                Navigator.pushNamed(context, '/my-tickets'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Logout ──
                      _buildLogoutButton(context),

                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text(AppLocalizations.of(context)!.unableToLoadProfile),
          );
        },
      ),
      bottomNavigationBar: MyBottomNavBar(
        currentIndex: 4,
        onTap: (index) => _handleNavTap(context, index),
      ),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────
  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDark,
            AppTheme.primaryBlue,
            AppTheme.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    AppLocalizations.of(context)!.profile,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () => debugPrint("Notifications tapped"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Profile picture with ring
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: ProfilePictureAvatar(
                profilePicture: profile.profilePicture,
                placeholderIcon: Icons.person,
              ),
            ),

            const SizedBox(height: 14),

            // User name
            Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 2),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─── Menu Card Container ──────────────────────────────────────────
  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  // ─── Single Menu Item (inside a card) ─────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Colors.grey[400],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 72,
      color: Colors.grey[200],
    );
  }

  // ─── Logout Button ────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => AuthUtils.handleLogout(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red[400], size: 20),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.logout,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 4) return;
    Navigator.pop(context, index);
  }
}
