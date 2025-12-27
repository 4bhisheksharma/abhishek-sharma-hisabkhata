import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/features/users/shared/presentation/dashboard.dart';
import 'package:hisab_khata/shared/widgets/dashboard/my_stats_card.dart';
import 'package:hisab_khata/shared/widgets/dashboard/business_customer_list_item.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';
import '../../../../request/presentation/screens/notification_screen.dart';

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
        await Navigator.pushNamed(context, '/customer-profile-view');
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
                        title: "Add More Business",
                        firstLabel: "Total Shops",
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
                        "Recently Added Business",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Business List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3, // Placeholder count
                      itemBuilder: (context, index) {
                        return BusinessCustomerListItem(
                          businessName: "Ram Dai Ko Pasal",
                          phoneNumber: "9878748574",
                          amount: "Rs. 15,220.5",
                          onTap: () {
                            // Navigate to business details
                            debugPrint("Business tapped: $index");
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // See More Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to full business list
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
