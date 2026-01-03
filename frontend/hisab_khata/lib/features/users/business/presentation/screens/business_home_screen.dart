import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
import 'package:hisab_khata/shared/widgets/placeholder_page.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import '../../../../notification/presentation/screens/notification_screen.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    context.read<BusinessBloc>().add(const LoadBusinessDashboard());
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
        // Connected Customers
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
        await Navigator.pushNamed(context, '/business-profile-view');
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
                firstLabel: "Total Customers",
                firstValue: "${d.totalCustomers}",
                secondLabel: "Total Requests",
                secondValue: "${d.totalRequests}",
                icon: Icons.person_add_outlined,
              ),
            ),

            // Recently Added Customers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Recently Added Customers",
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
                        "No customers added yet",
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
                      debugPrint(
                        "Navigate to customer details: ${customer.id}",
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
        // 1 - Connections
        const PlaceholderPage(
          title: 'Connected Customers',
          icon: Icons.people_rounded,
          description: 'View and manage all your connected customers here.',
        ),
        // 2 - Analytics
        const PlaceholderPage(
          title: 'Analytics',
          icon: Icons.bar_chart_rounded,
          description: 'Track your sales patterns and business insights.',
        ),
        // 3 - History
        const PlaceholderPage(
          title: 'Transaction History',
          icon: Icons.history_rounded,
          description: 'View all your past transactions and received payments.',
        ),
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

        return const Scaffold(
          body: Center(child: Text("Something went wrong")),
        );
      },
    );
  }
}
