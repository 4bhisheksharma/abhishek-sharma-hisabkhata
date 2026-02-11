import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
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
import '../../../../analytics/presentation/screens/business_analytics_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen>
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
    context.read<BusinessBloc>().add(const LoadBusinessDashboard());
  }

  void _loadProfileAndSetLanguage() {
    context.read<BusinessBloc>().add(const LoadBusinessProfile());
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
        // Connected Customers
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
          '/business-profile-view',
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

  Widget _buildHomeContent(BusinessDashboardLoaded state) {
    final d = state.dashboard;
    final recentCustomers = state.recentCustomers;

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
                title: "Add More Customers",
                firstLabel: AppLocalizations.of(context)!.totalCustomers,
                firstValue: "${d.totalCustomers}",
                secondLabel: AppLocalizations.of(context)!.totalRequests,
                secondValue: "${d.totalRequests}",
                icon: Icons.person_add_outlined,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.bulkAddConnection);
                },
              ),
            ),

            // Recently Added Customers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.recentlyAddedCustomers,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Customer List
            if (recentCustomers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.noCustomersAddedYet,
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
                itemCount: recentCustomers.length,
                itemBuilder: (context, index) {
                  final customer = recentCustomers[index];
                  return BusinessCustomerListItem(
                    businessName: customer.name,
                    phoneNumber: customer.contactInfo,
                    amount:
                        "Rs. ${customer.pendingDue.abs().toStringAsFixed(2)}",
                    profileImageUrl: ImageUtils.getFullImageUrl(
                      customer.profilePicture,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.connectedUserDetails,
                        arguments: ConnectedUserDetailsArgs(
                          relationshipId: customer.relationshipId,
                          isCustomerView: false,
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

  Widget _buildBodyContent(BusinessDashboardLoaded state) {
    return IndexedStack(
      index: _currentNavIndex,
      children: [
        // 0 - Home
        _buildHomeContent(state),
        // 1 - Connections (shows connected customers for businesses)
        const ConnectedUsersList(
          filterBusinesses: false, // Business sees customers
        ),
        // 2 - Connection Requests (Received + Sent)
        const ConnectionRequestsScreen(),
        // 3 - Analytics
        const BusinessAnalyticsScreen(),
        // 4 - Profile (handled via navigation)
        const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessBloc, BusinessState>(
      listener: (context, state) {
        if (state is BusinessError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        // Set language when profile is loaded
        if (state is BusinessProfileLoaded && !_hasLoadedLanguage) {
          final preferredLanguage = state.profile.preferredLanguage;
          if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
            final localeProvider = LocaleProvider.of(context);
            localeProvider?.changeLanguage(preferredLanguage);
            _hasLoadedLanguage = true;
          }
        }
      },
      builder: (context, state) {
        if (state is BusinessLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BusinessDashboardLoaded) {
          final d = state.dashboard;

          return SharedDashboard(
            userName: d.businessName,
            profileImageUrl: ImageUtils.getFullImageUrl(d.profilePicture),
            toGive: d.toGive,
            toTake: d.toTake,
            showLoyaltyPoints: false,
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
