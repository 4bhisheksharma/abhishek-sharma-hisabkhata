class ApiEndpoints {
  // Auth endpoints
  static const String login = "login/";
  static const String register = "register/";
  static const String otpVerification = "verify-otp/";
  static const String resendOtp = "resend-otp/";
  static const String refreshToken = "token/refresh/";
  static const String changePassword = "change-password/";

  // Customer endpoints
  static const String customerDashboard = "customer/dashboard/";
  static const String customerProfile = "customer/profile/";
  static const String recentBusinesses = "customer/recent-businesses/";

  // Business endpoints
  static const String businessDashboard = "business/dashboard/";
  static const String businessProfile = "business/profile/";
  static const String recentCustomers = "business/recent-customers/";

  // Connection Request endpoints
  static const String searchUsers = "request/connections/search-users/";
  static const String sendRequest = "request/connections/send-request/";
  static const String bulkSendRequest =
      "request/connections/bulk-send-request/";
  static const String bulkUpdateStatus =
      "request/connections/bulk-update-status/";
  static const String sentRequests = "request/connections/sent/";
  static const String receivedRequests = "request/connections/received/";
  static const String pendingReceivedRequests =
      "request/connections/pending-received/";
  static const String connectedUsers = "request/connections/connected/";
  static String updateRequestStatus(int id) =>
      "request/connections/$id/update-status/";

  // Notification endpoints
  static const String allNotifications = "notifications/";
  static const String unreadNotifications = "notifications/unread/";
  static const String unreadCount = "notifications/unread-count/";
  static String markNotificationAsRead(int id) =>
      "notifications/$id/mark-read/";
  static const String markAllNotificationsAsRead =
      "notifications/mark-all-read/";
  static String deleteNotification(int id) => "notifications/$id/delete/";
  static const String deleteAllReadNotifications =
      "notifications/delete-all-read/";
}
