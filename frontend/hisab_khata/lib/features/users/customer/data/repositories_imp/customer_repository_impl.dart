import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_dashboard_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/entities/customer_profile_entity.dart';
import 'package:hisab_khata/features/users/customer/domain/repositories/customer_repository.dart';
import 'package:hisab_khata/features/users/customer/data/datasources/customer_remote_data_source.dart';
import 'package:hisab_khata/core/errors/exceptions.dart';

/// Implementation of CustomerRepository
/// Handles data operations and error handling
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, CustomerDashboardEntity>> getDashboard() async {
    try {
      final dashboard = await remoteDataSource.getDashboard();
      return Right(dashboard);
    } on ServerException catch (e) {
      return Left(e.exceptionMessage);
    } catch (e) {
      return Left('Failed to fetch dashboard: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, CustomerProfileEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(e.exceptionMessage);
    } catch (e) {
      return Left('Failed to fetch profile: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, CustomerProfileEntity>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
  }) async {
    try {
      File? profilePictureFile;
      if (profilePicturePath != null) {
        profilePictureFile = File(profilePicturePath);
      }

      final profile = await remoteDataSource.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePicture: profilePictureFile,
      );
      return Right(profile);
    } on ServerException catch (e) {
      return Left(e.exceptionMessage);
    } catch (e) {
      return Left('Failed to update profile: ${e.toString()}');
    }
  }
}
