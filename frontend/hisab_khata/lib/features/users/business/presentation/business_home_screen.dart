import 'package:flutter/material.dart';
import 'package:hisab_khata/shared/utils/auth_utils.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Home')),
      body: Column(
        children: [
          Center(
            child: MyButton(
              text: "logout",
              onPressed: () => AuthUtils.handleLogout(context),
            ),

            //here will be something...
          ),
        ],
      ),
    );
  }
}
