import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
import 'package:hisab_khata/features/request/presentation/screens/connection_requests_screen.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/shared/widgets/connected_users_list.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import 'package:hisab_khata/shared/providers/locale_provider.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/core/route/app_router.dart';
import '../../../../notification/presentation/screens/notification_screen.dart';
import '../../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../../notification/presentation/bloc/notification_event.dart';
import '../../../../notification/presentation/bloc/notification_state.dart';
import '../../../../analytics/presentation/screens/customer_analytics_screen.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';

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
    context.read<NotificationBloc>().add(const GetUnreadCountEvent());
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
        // Reload connected users since this BLoC is shared with other tabs
        context.read<ConnectionRequestBloc>().add(
          const GetConnectedUsersEvent(),
        );
        break;
      case 2:
        // Connection Requests
        setState(() {
          _currentNavIndex = 2;
        });
        // Reload connection requests since this BLoC is shared with other tabs
        context.read<ConnectionRequestBloc>().add(
          const FetchAllConnectionRequestsEvent(),
        );
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
              padding: EdgeInsets.all(Responsive.w(context, 16)),
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
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
              ),
              child: Text(
                AppLocalizations.of(context)!.recentlyAddedBusiness,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: Responsive.sp(context, 18),
                ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),

            // Business List
            if (recentBusinesses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: Responsive.h(context, 20)),
                      Icon(
                        Icons.store_outlined,
                        size: Responsive.sp(context, 48),
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: Responsive.h(context, 8)),
                      Text(
                        AppLocalizations.of(context)!.noBusinessesAddedYet,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: Responsive.sp(context, 14),
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 20)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 16),
                ),
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
          return const DashboardShimmer();
        }

        if (state is CustomerDashboardLoaded) {
          final d = state.dashboard;

          return BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notifState) {
              final hasUnread =
                  notifState is UnreadCountLoaded && notifState.count > 0;
              return SharedDashboard(
                userName: d.fullName,
                profileImageUrl: ImageUtils.getFullImageUrl(d.profilePicture),
                toGive: d.toGive,
                toTake: d.toTake,
                loyaltyPoints: d.loyaltyPoints.toDouble(),
                showLoyaltyPoints: true,
                currentNavIndex: _currentNavIndex,
                onNavTap: _onNavTap,
                hasUnreadNotifications: hasUnread,
                onNotificationTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                  // Refresh unread count after returning from notifications
                  if (mounted) {
                    context.read<NotificationBloc>().add(
                      const GetUnreadCountEvent(),
                    );
                  }
                  // If a tab index was returned, navigate to it
                  if (result != null && result is int && mounted) {
                    setState(() {
                      _currentNavIndex = result;
                    });
                  }
                },
                body: _buildBodyContent(state),
              );
            },
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
