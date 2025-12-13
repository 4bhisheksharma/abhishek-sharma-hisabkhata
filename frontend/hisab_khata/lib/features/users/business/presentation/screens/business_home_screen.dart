import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';

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
              debugPrint("Notification tapped!");
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
                        title: "Add Customer",
                        firstLabel: "Total Customers",
                        firstValue: "${d.totalCustomers}",
                        secondLabel: "Pending Requests",
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

                    // Customer List (Placeholder data - replace with actual data when available)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3, // Placeholder count
                      itemBuilder: (context, index) {
                        return BusinessCustomerListItem(
                          businessName: "Ram Dai",
                          phoneNumber: "9845474454",
                          amount: "Rs. 15,220.5",
                          onTap: () {
                            // Navigate to customer details
                            debugPrint("Customer tapped: $index");
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // See More Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to full customer list
                          debugPrint("See more customers");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "See More",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
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
