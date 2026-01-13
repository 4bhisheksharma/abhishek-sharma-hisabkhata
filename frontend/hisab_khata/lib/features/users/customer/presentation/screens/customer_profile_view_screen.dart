import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/shared/utils/auth_utils.dart';
import 'package:hisab_khata/shared/widgets/dashboard/profile_menu_item.dart';
import 'package:hisab_khata/shared/widgets/profile/profile_picture_avatar.dart';
import 'package:hisab_khata/shared/widgets/my_bottom_nav_bar.dart';
import 'package:hisab_khata/shared/widgets/language_switcher.dart';

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
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
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
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerProfileLoaded ||
              state is CustomerProfileUpdated) {
            final profile = state is CustomerProfileLoaded
                ? state.profile
                : (state as CustomerProfileUpdated).profile;

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
                          placeholderIcon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
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
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF4A90E2),
                          iconBgColor: const Color(0xFFE3F2FD),
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.pushNamed(context, '/customer-profile');
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.security_outlined,
                          iconColor: const Color(0xFF00D9B5),
                          iconBgColor: const Color(0xFFE0F7F4),
                          title: 'Security',
                          onTap: () {
                            debugPrint("Security tapped");
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.language_outlined,
                          iconColor: const Color(0xFF2196F3),
                          iconBgColor: const Color(0xFFE3F2FD),
                          title: 'Language',
                          trailing: LanguageSwitcher(
                            initialLanguage: profile.preferredLanguage ?? 'en',
                            onLanguageChanged: (language) {
                              context.read<CustomerBloc>().add(
                                UpdateCustomerProfileEvent(
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
                          title: 'Switch To Hybrid',
                          onTap: () {
                            debugPrint("Switch to Hybrid tapped");
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.support_agent_outlined,
                          iconColor: const Color(0xFFFF9800),
                          iconBgColor: const Color(0xFFFFF3E0),
                          title: 'Raise A Ticket',
                          onTap: () {
                            debugPrint("Raise a ticket tapped");
                          },
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          iconColor: const Color(0xFFF44336),
                          iconBgColor: const Color(0xFFFFEBEE),
                          title: 'Logout',
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

          return const Center(child: Text("Unable to load profile"));
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
