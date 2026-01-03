import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/core/di/dependency_injection.dart';
import 'package:hisab_khata/features/auth/presentation/screens/login_screen.dart';
import 'package:hisab_khata/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:hisab_khata/features/auth/presentation/screens/signup_screen.dart';
import 'package:hisab_khata/features/request/presentation/screens/add_connection_screen.dart';
import 'package:hisab_khata/features/static/welcome_screen.dart';
import 'package:hisab_khata/features/transaction/presentation/bloc/connected_user_details_bloc.dart';
import 'package:hisab_khata/features/transaction/presentation/bloc/connected_user_details_event.dart';
import 'package:hisab_khata/features/transaction/presentation/pages/connected_user_details_page.dart';
import 'package:hisab_khata/features/users/business/presentation/screens/business_home_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/screens/business_profile_edit_screen.dart';
import 'package:hisab_khata/features/users/business/presentation/screens/business_profile_view_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/customer_home_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/customer_profile_edit_screen.dart';
import 'package:hisab_khata/features/users/customer/presentation/screens/customer_profile_view_screen.dart';

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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
