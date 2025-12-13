import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/get_business_dashboard.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/get_business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/usecases/update_business_profile.dart';
import 'business_event.dart';
import 'business_state.dart';

/// BLoC for managing business state
class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetBusinessDashboard getBusinessDashboard;
  final GetBusinessProfile getBusinessProfile;
  final UpdateBusinessProfile updateBusinessProfile;

  BusinessBloc({
    required this.getBusinessDashboard,
    required this.getBusinessProfile,
    required this.updateBusinessProfile,
  }) : super(const BusinessInitial()) {
    on<LoadBusinessDashboard>(_onLoadDashboard);
    on<LoadBusinessProfile>(_onLoadProfile);
    on<UpdateBusinessProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadDashboard(
    LoadBusinessDashboard event,
    Emitter<BusinessState> emit,
  ) async {
    emit(const BusinessLoading());
    final result = await getBusinessDashboard();

    result.fold(
      (error) => emit(BusinessError(error)),
      (dashboard) => emit(BusinessDashboardLoaded(dashboard)),
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
}
