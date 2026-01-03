import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/get_business_dashboard.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/get_business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/update_business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/get_recent_customers.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';
import 'business_event.dart';
import 'business_state.dart';

/// BLoC for managing business state
class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetBusinessDashboard getBusinessDashboard;
  final GetBusinessProfile getBusinessProfile;
  final UpdateBusinessProfile updateBusinessProfile;
  final GetRecentCustomers getRecentCustomers;

  BusinessBloc({
    required this.getBusinessDashboard,
    required this.getBusinessProfile,
    required this.updateBusinessProfile,
    required this.getRecentCustomers,
  }) : super(const BusinessInitial()) {
    on<LoadBusinessDashboard>(_onLoadDashboard);
    on<LoadBusinessProfile>(_onLoadProfile);
    on<UpdateBusinessProfileEvent>(_onUpdateProfile);
    on<LoadRecentCustomers>(_onLoadRecentCustomers);
  }

  Future<void> _onLoadDashboard(
    LoadBusinessDashboard event,
    Emitter<BusinessState> emit,
  ) async {
    emit(const BusinessLoading());

    // Load dashboard and recent customers in parallel
    final dashboardResult = await getBusinessDashboard();
    final recentCustomersResult = await getRecentCustomers();

    List<RecentConnectionEntity> recentCustomers = [];
    recentCustomersResult.fold(
      (error) => {}, // Silently handle error, show empty list
      (customers) => recentCustomers = customers,
    );

    dashboardResult.fold(
      (error) => emit(BusinessError(error)),
      (dashboard) => emit(
        BusinessDashboardLoaded(dashboard, recentCustomers: recentCustomers),
      ),
    );
  }

  Future<void> _onLoadProfile(
    LoadBusinessProfile event,
    Emitter<BusinessState> emit,
  ) async {
    emit(const BusinessLoading());
    final result = await getBusinessProfile();

    result.fold(
      (error) => emit(BusinessError(error)),
      (profile) => emit(BusinessProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateBusinessProfileEvent event,
    Emitter<BusinessState> emit,
  ) async {
    emit(const BusinessLoading());

    final result = await updateBusinessProfile(
      businessName: event.businessName,
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      profilePicturePath: event.profilePicturePath,
    );

    result.fold(
      (error) => emit(BusinessError(error)),
      (profile) =>
          emit(BusinessProfileUpdated(profile, 'Profile updated successfully')),
    );
  }

  Future<void> _onLoadRecentCustomers(
    LoadRecentCustomers event,
    Emitter<BusinessState> emit,
  ) async {
    // Get current state to preserve dashboard data
    final currentState = state;
    if (currentState is BusinessDashboardLoaded) {
      final result = await getRecentCustomers(limit: event.limit);

      result.fold(
        (error) => emit(BusinessError(error)),
        (customers) => emit(
          BusinessDashboardLoaded(
            currentState.dashboard,
            recentCustomers: customers,
          ),
        ),
      );
    }
  }
}
