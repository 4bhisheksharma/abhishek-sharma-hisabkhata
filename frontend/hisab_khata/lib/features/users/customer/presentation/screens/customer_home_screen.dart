import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
import 'package:hisab_khata/shared/widgets/placeholder_page.dart';
import 'package:hisab_khata/shared/widgets/connected_users_list.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import '../../../../notification/presentation/screens/notification_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    context.read<CustomerBloc>().add(const LoadCustomerDashboard());
  }

  void _onNavTap(int index) async {
    // Handle navigation based on index
    switch (index) {
      case 0:
        // Home
        setState(() {
          _currentNavIndex = 0;
        });
        break;
      case 1:
        // Connected Users/Businesses
        setState(() {
          _currentNavIndex = 1;
        });
        break;
      case 2:
        // Analytics
        setState(() {
          _currentNavIndex = 2;
        });
        break;
      case 3:
        // History
        setState(() {
          _currentNavIndex = 3;
        });
        break;
      case 4:
        // Profile
        await Navigator.pushNamed(context, '/customer-profile-view');
        // Check if widget is still mounted (user might have logged out)
        if (!mounted) return;
        // Reset to home when returning from profile
        setState(() {
          _currentNavIndex = 0;
        });
        // Reload dashboard
        _loadDashboard();
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
                      debugPrint(
                        "Navigate to business details: ${business.id}",
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
        // 2 - Analytics
        const PlaceholderPage(
          title: 'Analytics',
          icon: Icons.bar_chart_rounded,
          description: 'Track your spending patterns and financial insights.',
        ),
        // 3 - History
        PlaceholderPage(
          title: AppLocalizations.of(context)!.transactionHistory,
          icon: Icons.history_rounded,
          description: AppLocalizations.of(context)!.viewAllPastTransactions,
        ),
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
            onNotificationTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
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
