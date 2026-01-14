import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/constants/routes.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import '../../../../config/storage/storage_service.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/widgets/my_button.dart';
import '../../../../shared/widgets/my_snackbar.dart';
import '../../../../shared/widgets/my_text_field.dart';
import '../../../../core/utils/validators/validators.dart';

class AddConnectionScreen extends StatefulWidget {
  const AddConnectionScreen({super.key});

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await StorageService.getUserData();
    setState(() {
      _userRole = user?.roles.isNotEmpty == true ? user!.roles.first : '';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    if (_userRole.toLowerCase() == 'business') {
      return 'Add Customer';
    } else if (_userRole.toLowerCase() == 'customer') {
      return 'Add Business';
    }
    return 'Add Connection';
  }

  String get _buttonText {
    if (_userRole.toLowerCase() == 'business') {
      return 'Add Customer';
    } else if (_userRole.toLowerCase() == 'customer') {
      return 'Add Business';
    }
    return 'Add Connection';
  }

  void _handleAddConnection() {
    if (_formKey.currentState!.validate()) {
      context.read<ConnectionRequestBloc>().add(
        SendConnectionRequestEvent(receiverEmail: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionRequestBloc, ConnectionRequestState>(
      listener: (context, state) {
        if (state is ConnectionRequestSentSuccess) {
          MySnackbar.showSuccess(context, state.message);
          Navigator.of(context).pop();
        } else if (state is ConnectionRequestError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryBlue,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _appBarTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add, color: Colors.white),
              tooltip: 'Add Multiple Connections',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.bulkAddConnection);
              },
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Email Field
                  MyTextField(
                    controller: _emailController,
                    label: AppLocalizations.of(context)!.email,
                    hintText: AppLocalizations.of(context)!.emailExample,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.enterAnEmail;
                      }
                      if (!Validators.isValidEmail(value.trim())) {
                        return AppLocalizations.of(context)!.enterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Note Field
                  MyTextField(
                    controller: _noteController,
                    label: AppLocalizations.of(context)!.note,
                    hintText: AppLocalizations.of(context)!.messageHint,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 40),
                  // Add Connection Button
                  BlocBuilder<ConnectionRequestBloc, ConnectionRequestState>(
                    builder: (context, state) {
                      return Center(
                        child: MyButton(
                          text: _buttonText,
                          onPressed: _handleAddConnection,
                          isLoading: state is ConnectionRequestLoading,
                          width: 200,
                          height: 50,
                          borderRadius: 25,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
