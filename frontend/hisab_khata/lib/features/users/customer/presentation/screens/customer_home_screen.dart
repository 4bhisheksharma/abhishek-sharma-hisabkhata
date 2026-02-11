import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
import 'package:hisab_khata/features/request/presentation/screens/connection_requests_screen.dart';
import 'package:hisab_khata/shared/widgets/connected_users_list.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:hisab_khata/shared/providers/locale_provider.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/config/route/app_router.dart';
import '../../../../notification/presentation/screens/notification_screen.dart';
import '../../../../analytics/presentation/screens/customer_analytics_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with WidgetsBindingObserver {
  int _currentNavIndex = 0;
  bool _hasLoadedLanguage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboard();
    _loadProfileAndSetLanguage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload dashboard when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadDashboard();
    }
  }

  void _loadDashboard() {
    context.read<CustomerBloc>().add(const LoadCustomerDashboard());
  }

  void _loadProfileAndSetLanguage() {
    context.read<CustomerBloc>().add(const LoadCustomerProfile());
  }

  void _onNavTap(int index) async {
    // Handle navigation based on index
    switch (index) {
      case 0:
        // Home
        setState(() {
          _currentNavIndex = 0;
        });
        _loadDashboard();
        break;
      case 1:
        // Connected Users/Businesses
        setState(() {
          _currentNavIndex = 1;
        });
        break;
      case 2:
        // Connection Placeholder
        setState(() {
          _currentNavIndex = 2;
        });
        break;
      case 3:
        // Analytics
        setState(() {
          _currentNavIndex = 3;
        });
        break;
      case 4:
        // Profile
        final result = await Navigator.pushNamed(
          context,
          '/customer-profile-view',
        );
        // Check if widget is still mounted (user might have logged out)
        if (!mounted) return;
        // If a specific tab index was returned, navigate to it
        if (result != null && result is int) {
          setState(() {
            _currentNavIndex = result;
          });
          // Always reload dashboard to ensure we have the data
          _loadDashboard();
        } else {
          // Reset to home when returning from profile
          setState(() {
            _currentNavIndex = 0;
          });
          // Reload dashboard
          _loadDashboard();
        }
        break;
    }
  }

  Widget _buildHomeContent(CustomerDashboardLoaded state) {
    final d = state.dashboard;
    final recentBusinesses = state.recentBusinesses;

    return RefreshIndicator(
      onRefresh: () async {
        _loadDashboard();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: MyStatCard(
                title: "Add More Business",
                firstLabel: AppLocalizations.of(context)!.totalShops,
                firstValue: "${d.totalShops}",
                secondLabel: "Pending Requests",
                secondValue: "${d.pendingRequests}",
                icon: Icons.add_business_outlined,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.bulkAddConnection);
                },
              ),
            ),

            // Recently Added Business Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.recentlyAddedBusiness,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Business List
            if (recentBusinesses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        Icons.store_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.noBusinessesAddedYet,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentBusinesses.length,
                itemBuilder: (context, index) {
                  final business = recentBusinesses[index];
                  return BusinessCustomerListItem(
                    businessName: business.name,
                    phoneNumber: business.contactInfo,
                    amount:
                        "Rs. ${business.pendingDue.abs().toStringAsFixed(2)}",
                    profileImageUrl: ImageUtils.getFullImageUrl(
                      business.profilePicture,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.connectedUserDetails,
                        arguments: ConnectedUserDetailsArgs(
                          relationshipId: business.relationshipId,
                          isCustomerView: true,
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(CustomerDashboardLoaded state) {
    return IndexedStack(
      index: _currentNavIndex,
      children: [
        // 0 - Home
        _buildHomeContent(state),
        // 1 - Connections (shows connected businesses for customers)
        const ConnectedUsersList(
          filterBusinesses: true, // Customer sees businesses
        ),
        // 2 - Connection Requests (Received + Sent)
        const ConnectionRequestsScreen(),
        // 3 - Analytics
        const CustomerAnalyticsScreen(),
        // 4 - Profile (handled via navigation)
        const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        // Set language when profile is loaded
        if (state is CustomerProfileLoaded && !_hasLoadedLanguage) {
          final preferredLanguage = state.profile.preferredLanguage;
          if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
            final localeProvider = LocaleProvider.of(context);
            localeProvider?.changeLanguage(preferredLanguage);
            _hasLoadedLanguage = true;
          }
        }
      },
      builder: (context, state) {
        if (state is CustomerLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CustomerDashboardLoaded) {
          final d = state.dashboard;

          return SharedDashboard(
            userName: d.fullName,
            profileImageUrl: ImageUtils.getFullImageUrl(d.profilePicture),
            toGive: d.toGive,
            toTake: d.toTake,
            loyaltyPoints: d.loyaltyPoints.toDouble(),
            showLoyaltyPoints: true,
            currentNavIndex: _currentNavIndex,
            onNavTap: _onNavTap,
            onNotificationTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
              // If a tab index was returned, navigate to it
              if (result != null && result is int && mounted) {
                setState(() {
                  _currentNavIndex = result;
                });
              }
            },
            body: _buildBodyContent(state),
          );
        }

        return Scaffold(
          body: Center(
            child: Text(AppLocalizations.of(context)!.somethingWentWrong),
          ),
        );
      },
    );
  }
}
