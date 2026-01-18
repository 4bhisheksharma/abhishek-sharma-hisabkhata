import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/core/di/dependency_injection.dart';
import 'package:hisab_khata/features/auth/presentation/screens/login_screen.dart';
import 'package:hisab_khata/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:hisab_khata/features/auth/presentation/screens/signup_screen.dart';
import 'package:hisab_khata/features/byapar_d-AI-bot/screens/chatbot_screen.dart';
import 'package:hisab_khata/features/request/presentation/screens/add_connection_screen.dart';
import 'package:hisab_khata/features/request/presentation/screens/bulk_add_connection_screen.dart';
import 'package:hisab_khata/features/static/welcome_screen.dart';
import 'package:hisab_khata/features/transaction/presentation/bloc/connected_user_details_bloc.dart';
import 'package:hisab_khata/features/transaction/presentation/bloc/connected_user_details_event.dart';
import 'package:hisab_khata/features/transaction/presentation/screens/connected_user_details_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/screens/business_home_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/screens/business_profile_edit_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/screens/business_profile_view_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/customer_home_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/customer_profile_edit_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/customer_profile_view_screen.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/screens/my_tickets_screen.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/screens/create_ticket_screen.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/screens/ticket_detail_screen.dart';
import 'package:hisab_khata/features/request/presentation/screens/connection_requests_screen.dart';
import 'package:hisab_khata/features/notification/presentation/screens/notification_screen.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

/// Arguments for connected user details page navigation
class ConnectedUserDetailsArgs {
  final int relationshipId;
  final bool isCustomerView;

  const ConnectedUserDetailsArgs({
    required this.relationshipId,
    required this.isCustomerView,
  });
}

class AppRouter {
  MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());

      case AppRoutes.otpVerification:
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: ""),
        );

      case AppRoutes.customerHome:
        return MaterialPageRoute(builder: (_) => CustomerHomeScreen());

      case AppRoutes.businessHome:
        return MaterialPageRoute(builder: (_) => BusinessHomeScreen());

      case AppRoutes.customerProfile:
        return MaterialPageRoute(
          builder: (_) => const CustomerProfileEditScreen(),
        );

      case AppRoutes.customerProfileView:
        return MaterialPageRoute(
          builder: (_) => const CustomerProfileViewScreen(),
        );

      case AppRoutes.businessProfile:
        return MaterialPageRoute(
          builder: (_) => const BusinessProfileEditScreen(),
        );

      case AppRoutes.businessProfileView:
        return MaterialPageRoute(
          builder: (_) => const BusinessProfileViewScreen(),
        );

      case AppRoutes.addConnection:
        return MaterialPageRoute(builder: (_) => const AddConnectionScreen());

      case AppRoutes.bulkAddConnection:
        return MaterialPageRoute(
          builder: (_) => const BulkAddConnectionScreen(),
        );

      case AppRoutes.connectedUserDetails:
        final args = settings.arguments as ConnectedUserDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ConnectedUserDetailsBloc>(
            create: (_) =>
                DependencyInjection().createConnectedUserDetailsBloc()
                  ..add(LoadConnectedUserDetails(args.relationshipId)),
            child: ConnectedUserDetailsPage(
              relationshipId: args.relationshipId,
              isCustomerView: args.isCustomerView,
            ),
          ),
        );

      case AppRoutes.myTickets:
        return MaterialPageRoute(builder: (_) => const MyTicketsScreen());

      case AppRoutes.createTicket:
        return MaterialPageRoute(builder: (_) => const CreateTicketScreen());

      case AppRoutes.ticketDetail:
        final ticketId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticketId: ticketId),
        );

      case AppRoutes.chatbot:
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());

      case AppRoutes.connectionRequests:
        return MaterialPageRoute(
          builder: (_) => const ConnectionRequestsScreen(),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                '${AppLocalizations.of(context)!.noRouteDefined} ${settings.name}',
              ),
            ),
          ),
        );
    }
  }
}
