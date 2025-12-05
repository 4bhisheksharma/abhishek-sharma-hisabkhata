import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/shared/utils/auth_utils.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomerDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              //ya baki chha profile ma route garna TODO:
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthUtils.handleLogout(context),
          ),
        ],
      ),

      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerDashboardLoaded) {
            final d = state.dashboard;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerBloc>().add(const LoadCustomerDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION: CUSTOMER BASIC INFO
                    Text("CUSTOMER INFO", style: debugHeader()),
                    debugBox("""
Name: ${d.fullName}
Customer ID: ${d.customerId}
Profile Pic: ${d.profilePicture ?? "No image"}
"""),

                    // SECTION: FINANCIAL SUMMARY
                    Text("FINANCIAL SUMMARY", style: debugHeader()),
                    debugBox("""
To Give: Rs ${d.toGive}
To Take: Rs ${d.toTake}
"""),

                    // SECTION: STATS
                    Text("STATISTICS", style: debugHeader()),
                    debugBox("""
Total Shops: ${d.totalShops}
Pending Requests: ${d.pendingRequests}
"""),

                    // SECTION: LOYALTY
                    Text("LOYALTY POINTS", style: debugHeader()),
                    debugBox("${d.loyaltyPoints} points"),

                    // SECTION: TRANSACTIONS
                    Text("RECENT TRANSACTIONS", style: debugHeader()),
                    d.recentTransactions.isEmpty
                        ? debugBox("No recent transactions")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: d.recentTransactions.length,
                            itemBuilder: (context, index) {
                              return debugBox(
                                "Transaction ${index + 1}: ${d.recentTransactions[index]}",
                              );
                            },
                          ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text("Something went wrong"));
        },
      ),
    );
  }

  TextStyle debugHeader() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );
  }

  Widget debugBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade300,
      child: Text(text.trim(), style: const TextStyle(fontSize: 14)),
    );
  }
}
