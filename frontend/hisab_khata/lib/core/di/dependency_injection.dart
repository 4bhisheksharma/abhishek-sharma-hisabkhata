import 'package:hisab_khata/features/notification/domain/usecases/get_all_notifications_usecase.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/transaction/data/datasources/transaction_remote_data_source.dart';
import '../../features/transaction/data/repositories_imp/transaction_repository_impl.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/presentation/bloc/connected_user_details_bloc.dart';
import '../../features/auth/data/repositories_imp/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/users/customer/data/datasources/customer_remote_data_source.dart';
import '../../features/users/customer/data/repositories_imp/customer_repository_impl.dart';
import '../../features/users/customer/domain/repositories/customer_repository.dart';
import '../../features/users/customer/domain/usecases/get_customer_dashboard.dart';
import '../../features/users/customer/domain/usecases/get_customer_profile.dart';
import '../../features/users/customer/domain/usecases/update_customer_profile.dart';
import '../../features/users/customer/domain/usecases/get_recent_businesses.dart';
import '../../features/users/customer/presentation/bloc/customer_bloc.dart';
import '../../features/users/business/data/datasources/business_remote_data_source.dart';
import '../../features/users/business/data/repositories_impl/business_repository_impl.dart';
import '../../features/users/business/domain/repositories/business_repository.dart';
import '../../features/users/business/domain/usecases/get_business_dashboard.dart';
import '../../features/users/business/domain/usecases/get_business_profile.dart';
import '../../features/users/business/domain/usecases/update_business_profile.dart';
import '../../features/users/business/domain/usecases/get_recent_customers.dart';
import '../../features/users/business/presentation/bloc/business_bloc.dart';
import '../../features/request/data/datasource/connection_request_remote_data_source.dart';
import '../../features/request/data/repository_imp/connection_request_repository_impl.dart';
import '../../features/request/domain/repositories/connection_request_repository.dart';
import '../../features/request/domain/usecases/search_users_usecase.dart';
import '../../features/request/domain/usecases/fetch_paginated_users_usecase.dart';
import '../../features/request/domain/usecases/send_bulk_connection_request_usecase.dart';
import '../../features/request/domain/usecases/send_connection_request_usecase.dart';
import '../../features/request/domain/usecases/get_sent_requests_usecase.dart';
import '../../features/request/domain/usecases/get_received_requests_usecase.dart';
import '../../features/request/domain/usecases/get_pending_received_requests_usecase.dart';
import '../../features/request/domain/usecases/get_connected_users_usecase.dart';
import '../../features/request/domain/usecases/update_request_status_usecase.dart';
import '../../features/request/domain/usecases/delete_connection_usecase.dart';
import '../../features/request/presentation/bloc/connection_request_bloc.dart';
import '../../features/request/data/datasource/notification_remote_data_source.dart';
import '../../features/notification/data/repository_imp/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_unread_notifications_usecase.dart';
import '../../features/request/domain/usecases/get_unread_count_usecase.dart';
import '../../features/notification/domain/usecases/mark_notification_as_read_usecase.dart';
import '../../features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../features/notification/domain/usecases/delete_notification_usecase.dart';
import '../../features/notification/domain/usecases/delete_all_read_notifications_usecase.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/raise-ticket/data/datasources/ticket_remote_data_source.dart';
import '../../features/raise-ticket/data/repositories_imp/ticket_repository_impl.dart';
import '../../features/raise-ticket/domain/repositories/ticket_repository.dart';
import '../../features/raise-ticket/domain/usecases/create_ticket_usecase.dart';
import '../../features/raise-ticket/domain/usecases/get_my_tickets_usecase.dart';
import '../../features/raise-ticket/domain/usecases/get_ticket_by_id_usecase.dart';
import '../../features/raise-ticket/presentation/bloc/bloc.dart';
import '../../features/analytics/data/datasources/analytics_remote_data_source.dart';
import '../../features/analytics/data/repositories_imp/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/analytics_usecases.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';

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
  late final CustomerRemoteDataSource _customerRemoteDataSource;
  late final BusinessRemoteDataSource _businessRemoteDataSource;
  late final ConnectionRequestRemoteDataSource
  _connectionRequestRemoteDataSource;
  late final NotificationRemoteDataSource _notificationRemoteDataSource;
  late final TransactionRemoteDataSource _transactionRemoteDataSource;
  late final TicketRemoteDataSource _ticketRemoteDataSource;
  late final AnalyticsRemoteDataSource _analyticsRemoteDataSource;

  // Repositories
  late final AuthRepository _authRepository;
  late final CustomerRepository _customerRepository;
  late final BusinessRepository _businessRepository;
  late final ConnectionRequestRepository _connectionRequestRepository;
  late final NotificationRepository _notificationRepository;
  late final TransactionRepository _transactionRepository;
  late final TicketRepository _ticketRepository;
  late final AnalyticsRepository _analyticsRepository;

  // Use Cases - Auth
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final VerifyOtpUseCase _verifyOtpUseCase;
  late final ResendOtpUseCase _resendOtpUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final ChangePasswordUseCase _changePasswordUseCase;

  // Use Cases - Customer
  late final GetCustomerDashboard _getCustomerDashboard;
  late final GetCustomerProfile _getCustomerProfile;
  late final UpdateCustomerProfile _updateCustomerProfile;
  late final GetRecentBusinesses _getRecentBusinesses;

  // Use Cases - Business
  late final GetBusinessDashboard _getBusinessDashboard;
  late final GetBusinessProfile _getBusinessProfile;
  late final UpdateBusinessProfile _updateBusinessProfile;
  late final GetRecentCustomers _getRecentCustomers;

  // Use Cases - Connection Request
  late final SearchUsersUseCase _searchUsersUseCase;
  late final FetchPaginatedUsersUseCase _fetchPaginatedUsersUseCase;
  late final SendConnectionRequestUseCase _sendConnectionRequestUseCase;
  late final SendBulkConnectionRequestUseCase _sendBulkConnectionRequestUseCase;
  late final GetSentRequestsUseCase _getSentRequestsUseCase;
  late final GetReceivedRequestsUseCase _getReceivedRequestsUseCase;
  late final GetPendingReceivedRequestsUseCase
  _getPendingReceivedRequestsUseCase;
  late final GetConnectedUsersUseCase _getConnectedUsersUseCase;
  late final UpdateRequestStatusUseCase _updateRequestStatusUseCase;
  late final DeleteConnectionUseCase _deleteConnectionUseCase;

  // Use Cases - Notification
  late final GetAllNotificationsUseCase _getAllNotificationsUseCase;
  late final GetUnreadNotificationsUseCase _getUnreadNotificationsUseCase;
  late final GetUnreadCountUseCase _getUnreadCountUseCase;
  late final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  late final MarkAllNotificationsAsReadUseCase
  _markAllNotificationsAsReadUseCase;
  late final DeleteNotificationUseCase _deleteNotificationUseCase;
  late final DeleteAllReadNotificationsUseCase
  _deleteAllReadNotificationsUseCase;

  // Use Cases - Ticket
  late final CreateTicketUseCase _createTicketUseCase;
  late final GetMyTicketsUseCase _getMyTicketsUseCase;
  late final GetTicketByIdUseCase _getTicketByIdUseCase;

  // Use Cases - Analytics
  late final GetPaidVsToPay _getPaidVsToPay;
  late final GetMonthlyTransactionTrend _getMonthlyTransactionTrend;
  late final GetFavoriteCustomers _getFavoriteCustomers;
  late final GetFavoriteBusinesses _getFavoriteBusinesses;
  late final GetTotalTransactions _getTotalTransactions;
  late final GetTotalAmount _getTotalAmount;
  late final GetMonthlySpendingLimit _getMonthlySpendingLimit;
  late final SetMonthlyLimit _setMonthlyLimit;

  // BLoCs
  late final AuthBloc _authBloc;
  late final CustomerBloc _customerBloc;
  late final BusinessBloc _businessBloc;
  late final ConnectionRequestBloc _connectionRequestBloc;
  late final NotificationBloc _notificationBloc;
  late final TicketBloc _ticketBloc;
  late final AnalyticsBloc _analyticsBloc;

  bool _isInitialized = false;

  /// Check if DI is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize all dependencies
  void init() {
    if (_isInitialized) return; // Prevent double initialization
    _isInitialized = true;

    // HTTP Client
    _httpClient = http.Client();

    // Data Sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(client: _httpClient);
    _customerRemoteDataSource = CustomerRemoteDataSourceImpl(
      client: _httpClient,
    );
    _businessRemoteDataSource = BusinessRemoteDataSourceImpl(
      client: _httpClient,
    );
    _connectionRequestRemoteDataSource = ConnectionRequestRemoteDataSourceImpl(
      client: _httpClient,
    );
    _notificationRemoteDataSource = NotificationRemoteDataSourceImpl(
      client: _httpClient,
    );
    _transactionRemoteDataSource = TransactionRemoteDataSource(
      client: _httpClient,
    );
    _ticketRemoteDataSource = TicketRemoteDataSourceImpl(client: _httpClient);
    _analyticsRemoteDataSource = AnalyticsRemoteDataSource(client: _httpClient);

    // Repositories
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
    );
    _customerRepository = CustomerRepositoryImpl(
      remoteDataSource: _customerRemoteDataSource,
    );
    _businessRepository = BusinessRepositoryImpl(
      remoteDataSource: _businessRemoteDataSource,
    );
    _connectionRequestRepository = ConnectionRequestRepositoryImpl(
      remoteDataSource: _connectionRequestRemoteDataSource,
    );
    _notificationRepository = NotificationRepositoryImpl(
      remoteDataSource: _notificationRemoteDataSource,
    );
    _transactionRepository = TransactionRepositoryImpl(
      remoteDataSource: _transactionRemoteDataSource,
    );
    _ticketRepository = TicketRepositoryImpl(
      remoteDataSource: _ticketRemoteDataSource,
    );
    _analyticsRepository = AnalyticsRepositoryImpl(
      remoteDataSource: _analyticsRemoteDataSource,
    );

    // Use Cases - Auth
    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);
    _verifyOtpUseCase = VerifyOtpUseCase(_authRepository);
    _resendOtpUseCase = ResendOtpUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _checkAuthStatusUseCase = CheckAuthStatusUseCase(_authRepository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
    _changePasswordUseCase = ChangePasswordUseCase(_authRepository);

    // Use Cases - Customer
    _getCustomerDashboard = GetCustomerDashboard(_customerRepository);
    _getCustomerProfile = GetCustomerProfile(_customerRepository);
    _updateCustomerProfile = UpdateCustomerProfile(_customerRepository);
    _getRecentBusinesses = GetRecentBusinesses(_customerRepository);

    // Use Cases - Business
    _getBusinessDashboard = GetBusinessDashboard(_businessRepository);
    _getBusinessProfile = GetBusinessProfile(_businessRepository);
    _updateBusinessProfile = UpdateBusinessProfile(_businessRepository);
    _getRecentCustomers = GetRecentCustomers(_businessRepository);

    // Use Cases - Connection Request
    _searchUsersUseCase = SearchUsersUseCase(_connectionRequestRepository);
    _fetchPaginatedUsersUseCase = FetchPaginatedUsersUseCase(
      _connectionRequestRepository,
    );
    _sendConnectionRequestUseCase = SendConnectionRequestUseCase(
      _connectionRequestRepository,
    );
    _sendBulkConnectionRequestUseCase = SendBulkConnectionRequestUseCase(
      _connectionRequestRepository,
    );
    _getSentRequestsUseCase = GetSentRequestsUseCase(
      _connectionRequestRepository,
    );
    _getReceivedRequestsUseCase = GetReceivedRequestsUseCase(
      _connectionRequestRepository,
    );
    _getPendingReceivedRequestsUseCase = GetPendingReceivedRequestsUseCase(
      _connectionRequestRepository,
    );
    _getConnectedUsersUseCase = GetConnectedUsersUseCase(
      _connectionRequestRepository,
    );
    _updateRequestStatusUseCase = UpdateRequestStatusUseCase(
      _connectionRequestRepository,
    );
    _deleteConnectionUseCase = DeleteConnectionUseCase(
      _connectionRequestRepository,
    );

    // Use Cases - Notification
    _getAllNotificationsUseCase = GetAllNotificationsUseCase(
      _notificationRepository,
    );
    _getUnreadNotificationsUseCase = GetUnreadNotificationsUseCase(
      _notificationRepository,
    );
    _getUnreadCountUseCase = GetUnreadCountUseCase(_notificationRepository);
    _markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(
      _notificationRepository,
    );
    _markAllNotificationsAsReadUseCase = MarkAllNotificationsAsReadUseCase(
      _notificationRepository,
    );
    _deleteNotificationUseCase = DeleteNotificationUseCase(
      _notificationRepository,
    );
    _deleteAllReadNotificationsUseCase = DeleteAllReadNotificationsUseCase(
      _notificationRepository,
    );

    // Use Cases - Ticket
    _createTicketUseCase = CreateTicketUseCase(_ticketRepository);
    _getMyTicketsUseCase = GetMyTicketsUseCase(_ticketRepository);
    _getTicketByIdUseCase = GetTicketByIdUseCase(_ticketRepository);

    // Use Cases - Analytics
    _getPaidVsToPay = GetPaidVsToPay(_analyticsRepository);
    _getMonthlyTransactionTrend = GetMonthlyTransactionTrend(
      _analyticsRepository,
    );
    _getFavoriteCustomers = GetFavoriteCustomers(_analyticsRepository);
    _getFavoriteBusinesses = GetFavoriteBusinesses(_analyticsRepository);
    _getTotalTransactions = GetTotalTransactions(_analyticsRepository);
    _getTotalAmount = GetTotalAmount(_analyticsRepository);
    _getMonthlySpendingLimit = GetMonthlySpendingLimit(_analyticsRepository);
    _setMonthlyLimit = SetMonthlyLimit(_analyticsRepository);

    // BLoCs
    _authBloc = AuthBloc(
      loginUseCase: _loginUseCase,
      registerUseCase: _registerUseCase,
      verifyOtpUseCase: _verifyOtpUseCase,
      resendOtpUseCase: _resendOtpUseCase,
      logoutUseCase: _logoutUseCase,
      checkAuthStatusUseCase: _checkAuthStatusUseCase,
      getCurrentUserUseCase: _getCurrentUserUseCase,
      changePasswordUseCase: _changePasswordUseCase,
    );
    _customerBloc = CustomerBloc(
      getCustomerDashboard: _getCustomerDashboard,
      getCustomerProfile: _getCustomerProfile,
      updateCustomerProfile: _updateCustomerProfile,
      getRecentBusinesses: _getRecentBusinesses,
    );
    _businessBloc = BusinessBloc(
      getBusinessDashboard: _getBusinessDashboard,
      getBusinessProfile: _getBusinessProfile,
      updateBusinessProfile: _updateBusinessProfile,
      getRecentCustomers: _getRecentCustomers,
    );
    _connectionRequestBloc = ConnectionRequestBloc(
      searchUsersUseCase: _searchUsersUseCase,
      fetchPaginatedUsersUseCase: _fetchPaginatedUsersUseCase,
      sendConnectionRequestUseCase: _sendConnectionRequestUseCase,
      sendBulkConnectionRequestUseCase: _sendBulkConnectionRequestUseCase,
      getSentRequestsUseCase: _getSentRequestsUseCase,
      getReceivedRequestsUseCase: _getReceivedRequestsUseCase,
      getPendingReceivedRequestsUseCase: _getPendingReceivedRequestsUseCase,
      getConnectedUsersUseCase: _getConnectedUsersUseCase,
      updateRequestStatusUseCase: _updateRequestStatusUseCase,
      deleteConnectionUseCase: _deleteConnectionUseCase,
    );
    _notificationBloc = NotificationBloc(
      getAllNotificationsUseCase: _getAllNotificationsUseCase,
      getUnreadNotificationsUseCase: _getUnreadNotificationsUseCase,
      getUnreadCountUseCase: _getUnreadCountUseCase,
      markNotificationAsReadUseCase: _markNotificationAsReadUseCase,
      markAllNotificationsAsReadUseCase: _markAllNotificationsAsReadUseCase,
      deleteNotificationUseCase: _deleteNotificationUseCase,
      deleteAllReadNotificationsUseCase: _deleteAllReadNotificationsUseCase,
    );
    _ticketBloc = TicketBloc(
      createTicketUseCase: _createTicketUseCase,
      getMyTicketsUseCase: _getMyTicketsUseCase,
      getTicketByIdUseCase: _getTicketByIdUseCase,
    );
    _analyticsBloc = AnalyticsBloc(
      getPaidVsToPay: _getPaidVsToPay,
      getMonthlyTransactionTrend: _getMonthlyTransactionTrend,
      getFavoriteCustomers: _getFavoriteCustomers,
      getFavoriteBusinesses: _getFavoriteBusinesses,
      getTotalTransactions: _getTotalTransactions,
      getTotalAmount: _getTotalAmount,
      getMonthlySpendingLimit: _getMonthlySpendingLimit,
      setMonthlyLimit: _setMonthlyLimit,
    );
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
    _authBloc.close();
    _customerBloc.close();
    _businessBloc.close();
    _connectionRequestBloc.close();
    _notificationBloc.close();
    _ticketBloc.close();
    _analyticsBloc.close();
  }

  // Getters
  AuthBloc get authBloc => _authBloc;
  CustomerBloc get customerBloc => _customerBloc;
  BusinessBloc get businessBloc => _businessBloc;
  ConnectionRequestBloc get connectionRequestBloc => _connectionRequestBloc;
  NotificationBloc get notificationBloc => _notificationBloc;
  TicketBloc get ticketBloc => _ticketBloc;
  AnalyticsBloc get analyticsBloc => _analyticsBloc;
  AuthRepository get authRepository => _authRepository;
  CustomerRepository get customerRepository => _customerRepository;
  BusinessRepository get businessRepository => _businessRepository;
  ConnectionRequestRepository get connectionRequestRepository =>
      _connectionRequestRepository;
  NotificationRepository get notificationRepository => _notificationRepository;
  TransactionRepository get transactionRepository => _transactionRepository;

  /// Create a new ConnectedUserDetailsBloc instance
  ConnectedUserDetailsBloc createConnectedUserDetailsBloc() {
    return ConnectedUserDetailsBloc(repository: _transactionRepository);
  }
}
