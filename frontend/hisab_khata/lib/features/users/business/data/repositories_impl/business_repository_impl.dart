import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_dashboard.dart';
import 'package:hisab_khata/features/users/business/domain/entities/business_profile.dart';
import 'package:hisab_khata/features/users/business/domain/repositories/business_repository.dart';
import 'package:hisab_khata/features/users/business/data/datasources/business_remote_data_source.dart';
import 'package:hisab_khata/features/users/shared/domain/entities/recent_connection_entity.dart';
import 'package:hisab_khata/core/errors/exceptions.dart';

/// Implementation of BusinessRepository
/// Handles data operations and error handling
class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, BusinessDashboard>> getDashboard() async {
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
  Future<Either<String, BusinessProfile>> getProfile() async {
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
  Future<Either<String, BusinessProfile>> updateProfile({
    String? businessName,
    String? fullName,
    String? phoneNumber,
    String? profilePicturePath,
    String? preferredLanguage,
  }) async {
    try {
      File? profilePictureFile;
      if (profilePicturePath != null) {
        profilePictureFile = File(profilePicturePath);
      }

      final profile = await remoteDataSource.updateProfile(
        businessName: businessName,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePicture: profilePictureFile,
        preferredLanguage: preferredLanguage,
      );
      return Right(profile);
    } on ServerException catch (e) {
      return Left(e.exceptionMessage);
    } catch (e) {
      return Left('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<RecentConnectionEntity>>> getRecentCustomers({
    int limit = 10,
  }) async {
    try {
      final customers = await remoteDataSource.getRecentCustomers(limit: limit);
      return Right(customers);
    } on ServerException catch (e) {
      return Left(e.exceptionMessage);
    } catch (e) {
      return Left('Failed to fetch recent customers: ${e.toString()}');
    }
  }
}
