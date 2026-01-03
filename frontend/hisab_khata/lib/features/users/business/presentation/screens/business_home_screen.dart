import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
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
        // Home - already here, just update state
        setState(() {
          _currentNavIndex = 0;
        });
        break;
      case 1:
        // Analytics/Reports
        debugPrint("Navigate to Analytics");
        setState(() {
          _currentNavIndex = index;
        });
        break;
      case 2:
        // Transactions
        debugPrint("Navigate to Transactions");
        setState(() {
          _currentNavIndex = index;
        });
        break;
      case 3:
        // Layers/Categories
        debugPrint("Navigate to Categories");
        setState(() {
          _currentNavIndex = index;
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
            body: RefreshIndicator(
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3, // Placeholder count
                      itemBuilder: (context, index) {
                        return BusinessCustomerListItem(
                          businessName: "Customer ${index + 1}",
                          phoneNumber: "+1234567890",
                          amount: "${1000.0 * (index + 1)}",
                          onTap: () {
                            debugPrint("Navigate to customer details");
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text("Something went wrong")),
        );
      },
    );
  }
}
