import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/shared/utils/auth_utils.dart';
import 'package:hisab_khata/shared/widgets/dashboard/profile_menu_item.dart';
import 'package:hisab_khata/shared/widgets/profile/profile_picture_avatar.dart';
import 'package:hisab_khata/shared/widgets/my_bottom_nav_bar.dart';
import 'package:hisab_khata/shared/widgets/language_switcher.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

class BusinessProfileViewScreen extends StatefulWidget {
  const BusinessProfileViewScreen({super.key});

  @override
  State<BusinessProfileViewScreen> createState() =>
      _BusinessProfileViewScreenState();
}

class _BusinessProfileViewScreenState extends State<BusinessProfileViewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(const LoadBusinessProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              debugPrint("Notifications tapped");
            },
          ),
        ],
      ),
      body: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          if (state is BusinessLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BusinessProfileLoaded ||
              state is BusinessProfileUpdated) {
            final profile = state is BusinessProfileLoaded
                ? state.profile
                : (state as BusinessProfileUpdated).profile;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: const BoxDecoration(color: Color(0xFFE8F5F3)),
                    child: Column(
                      children: [
                        // Profile Picture
                        ProfilePictureAvatar(
                          profilePicture: profile.profilePicture,
                          placeholderIcon: Icons.business,
                        ),
                        const SizedBox(height: 16),
                        // Business Name
                        Text(
                          profile.businessName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Verification Badge
                        if (profile.isVerified)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.blue[600],
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.verifiedBusiness,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Menu Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.business_outlined,
                          iconColor: const Color(0xFF4A90E2),
                          iconBgColor: const Color(0xFFE3F2FD),
                          title: AppLocalizations.of(context)!.editProfile,
                          onTap: () {
                            Navigator.pushNamed(context, '/business-profile');
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.security_outlined,
                          iconColor: const Color(0xFF00D9B5),
                          iconBgColor: const Color(0xFFE0F7F4),
                          title: AppLocalizations.of(context)!.security,
                          onTap: () {
                            debugPrint("Security tapped");
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.language_outlined,
                          iconColor: const Color(0xFF2196F3),
                          iconBgColor: const Color(0xFFE3F2FD),
                          title: AppLocalizations.of(context)!.language,
                          trailing: LanguageSwitcher(
                            initialLanguage: profile.preferredLanguage ?? 'en',
                            onLanguageChanged: (language) {
                              context.read<BusinessBloc>().add(
                                UpdateBusinessProfileEvent(
                                  preferredLanguage: language,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            // Language switcher handles its own tap
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.people_outline,
                          iconColor: const Color(0xFF9C27B0),
                          iconBgColor: const Color(0xFFF3E5F5),
                          title: AppLocalizations.of(context)!.switchToHybrid,
                          onTap: () {
                            debugPrint("Switch to Hybrid tapped");
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.support_agent_outlined,
                          iconColor: const Color(0xFFFF9800),
                          iconBgColor: const Color(0xFFFFF3E0),
                          title: AppLocalizations.of(context)!.raiseATicket,
                          onTap: () {
                            debugPrint("Raise a ticket tapped");
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          iconColor: const Color(0xFFF44336),
                          iconBgColor: const Color(0xFFFFEBEE),
                          title: AppLocalizations.of(context)!.logout,
                          onTap: () {
                            AuthUtils.handleLogout(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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

  void _handleNavTap(BuildContext context, int index) {
    if (index == 4) return; // Already on profile
    // Pop back to home and let it handle the navigation
    Navigator.pop(context);
  }
}
