import '../../domain/repositories/transaction_repository.dart';

class FavoriteBusinessModel extends FavoriteBusiness {
  const FavoriteBusinessModel({
    required super.favoriteId,
    required super.businessId,
    required super.businessName,
    super.businessProfilePicture,
    required super.createdAt,
  });

  factory FavoriteBusinessModel.fromJson(Map<String, dynamic> json) {
    return FavoriteBusinessModel(
      favoriteId: json['favorite_id'] as int,
      businessId: json['business_id'] as int,
      businessName: json['business_name'] as String,
      businessProfilePicture: json['business_profile_picture'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorite_id': favoriteId,
      'business_id': businessId,
      'business_name': businessName,
      'business_profile_picture': businessProfilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert entity to model
  factory FavoriteBusinessModel.fromEntity(FavoriteBusiness entity) {
    return FavoriteBusinessModel(
      favoriteId: entity.favoriteId,
      businessId: entity.businessId,
      businessName: entity.businessName,
      businessProfilePicture: entity.businessProfilePicture,
      createdAt: entity.createdAt,
    );
  }
}
