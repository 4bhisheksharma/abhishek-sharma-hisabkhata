import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/get_customer_dashboard.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/get_customer_profile.dart';
import 'package:hisab_khata/features/users/customer/domain/usecases/update_customer_profile.dart';
import 'customer_event.dart';
import 'customer_state.dart';

/// BLoC for managing customer state
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomerDashboard getCustomerDashboard;
  final GetCustomerProfile getCustomerProfile;
  final UpdateCustomerProfile updateCustomerProfile;
  CustomerBloc({
    required this.getCustomerDashboard,
    required this.getCustomerProfile,
    required this.updateCustomerProfile,
  }) : super(const CustomerInitial()) {
    on<LoadCustomerDashboard>(_onLoadDashboard);
    on<LoadCustomerProfile>(_onLoadProfile);

    on<UpdateCustomerProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadDashboard(
    LoadCustomerDashboard event,

    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await getCustomerDashboard();

    result.fold(
      (error) => emit(CustomerError(error)),

      (dashboard) => emit(CustomerDashboardLoaded(dashboard)),
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
}
