import 'user_entity.dart';
import 'tokens_entity.dart';

class LoginResultEntity {
  final UserEntity user;
  final TokensEntity tokens;

  LoginResultEntity({required this.user, required this.tokens});
}
