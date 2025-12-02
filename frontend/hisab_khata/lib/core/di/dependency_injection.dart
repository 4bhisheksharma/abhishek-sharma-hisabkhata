import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories_imp/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Dependency Injection Container
/// Manages creation and lifecycle of app dependencies
class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  // HTTP Client
  late final http.Client _httpClient;

  // Data Sources
  late final AuthRemoteDataSource _authRemoteDataSource;

  // Repositories
  late final AuthRepository _authRepository;

  // Use Cases
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final VerifyOtpUseCase _verifyOtpUseCase;
  late final ResendOtpUseCase _resendOtpUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  // BLoCs
  late final AuthBloc _authBloc;

  /// Initialize all dependencies
  void init() {
    // HTTP Client
    _httpClient = http.Client();

    // Data Sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(client: _httpClient);

    // Repositories
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
    );

    // Use Cases
    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);
    _verifyOtpUseCase = VerifyOtpUseCase(_authRepository);
    _resendOtpUseCase = ResendOtpUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _checkAuthStatusUseCase = CheckAuthStatusUseCase(_authRepository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);

    // BLoCs
    _authBloc = AuthBloc(
      loginUseCase: _loginUseCase,
      registerUseCase: _registerUseCase,
      verifyOtpUseCase: _verifyOtpUseCase,
      resendOtpUseCase: _resendOtpUseCase,
      logoutUseCase: _logoutUseCase,
      checkAuthStatusUseCase: _checkAuthStatusUseCase,
      getCurrentUserUseCase: _getCurrentUserUseCase,
    );
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
    _authBloc.close();
  }

  // Getters
  AuthBloc get authBloc => _authBloc;
  AuthRepository get authRepository => _authRepository;
}
