import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/get_customer_dashboard.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/get_customer_profile.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/update_customer_profile.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/get_recent_businesses.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';
import 'customer_event.dart';
import 'customer_state.dart';

/// BLoC for managing customer state
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomerDashboard getCustomerDashboard;
  final GetCustomerProfile getCustomerProfile;
  final UpdateCustomerProfile updateCustomerProfile;
  final GetRecentBusinesses getRecentBusinesses;

  CustomerBloc({
    required this.getCustomerDashboard,
    required this.getCustomerProfile,
    required this.updateCustomerProfile,
    required this.getRecentBusinesses,
  }) : super(const CustomerInitial()) {
    on<LoadCustomerDashboard>(_onLoadDashboard);
    on<LoadCustomerProfile>(_onLoadProfile);
    on<UpdateCustomerProfileEvent>(_onUpdateProfile);
    on<LoadRecentBusinesses>(_onLoadRecentBusinesses);
  }

  Future<void> _onLoadDashboard(
    LoadCustomerDashboard event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    
    // Load dashboard and recent businesses in parallel
    final dashboardResult = await getCustomerDashboard();
    final recentBusinessesResult = await getRecentBusinesses();
    
    List<RecentConnectionEntity> recentBusinesses = [];
    recentBusinessesResult.fold(
      (error) => {}, // Silently handle error, show empty list
      (businesses) => recentBusinesses = businesses,
    );

    dashboardResult.fold(
      (error) => emit(CustomerError(error)),
      (dashboard) => emit(CustomerDashboardLoaded(
        dashboard,
        recentBusinesses: recentBusinesses,
      )),
    );
  }

  Future<void> _onLoadProfile(
    LoadCustomerProfile event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await getCustomerProfile();

    result.fold(
      (error) => emit(CustomerError(error)),

      (profile) => emit(CustomerProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateCustomerProfileEvent event,

    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());

    final result = await updateCustomerProfile(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      profilePicturePath: event.profilePicturePath,
    );

    result.fold(
      (error) => emit(CustomerError(error)),
      (profile) =>
          emit(CustomerProfileUpdated(profile, 'Profile updated successfully')),
    );
  }

  Future<void> _onLoadRecentBusinesses(
    LoadRecentBusinesses event,
    Emitter<CustomerState> emit,
  ) async {
    // Get current state to preserve dashboard data
    final currentState = state;
    if (currentState is CustomerDashboardLoaded) {
      final result = await getRecentBusinesses(limit: event.limit);
      
      result.fold(
        (error) => emit(CustomerError(error)),
        (businesses) => emit(CustomerDashboardLoaded(
          currentState.dashboard,
          recentBusinesses: businesses,
        )),
      );
    }
  }
}
