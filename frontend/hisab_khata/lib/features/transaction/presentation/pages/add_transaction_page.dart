import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/connected_user_details_bloc.dart';
import '../bloc/connected_user_details_event.dart';
import '../bloc/connected_user_details_state.dart';
import '../../domain/entities/transaction.dart';

/// Full-screen page for adding a transaction (for business users)
class AddTransactionPage extends StatefulWidget {
  final int relationshipId;
  final String customerName;

  const AddTransactionPage({
    super.key,
    required this.relationshipId,
    required this.customerName,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _itemTitleController = TextEditingController();
  final _messageController = TextEditingController();

  DateTime? _selectedDate;
  bool _isAutoDate = true;

  @override
  void dispose() {
    _amountController.dispose();
    _itemTitleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isAutoDate = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final itemTitle = _itemTitleController.text.trim();
      final message = _messageController.text.trim();

      // Combine item title and message for description
      String? description;
      if (itemTitle.isNotEmpty && message.isNotEmpty) {
        description = '$itemTitle: $message';
      } else if (itemTitle.isNotEmpty) {
        description = itemTitle;
      } else if (message.isNotEmpty) {
        description = message;
      }

      context.read<ConnectedUserDetailsBloc>().add(
        CreateTransaction(
          relationshipId: widget.relationshipId,
          amount: amount,
          type: TransactionType.purchase,
          description: description,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocListener<ConnectedUserDetailsBloc, ConnectedUserDetailsState>(
      listener: (context, state) {
        if (state is ConnectedUserDetailsLoaded) {
          // Transaction created successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (state is ConnectedUserDetailsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Add Transaction',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                // TODO: Notifications
              },
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date field
                        _buildLabel('Date'),
                        _buildDateField(),
                        const SizedBox(height: 24),

                        // Amount field
                        _buildLabel('Amount'),
                        _buildAmountField(),
                        const SizedBox(height: 24),

                        // Item Title field
                        _buildLabel('Item Title'),
                        _buildItemTitleField(),
                        const SizedBox(height: 24),

                        // Message field
                        _buildMessageField(),
                      ],
                    ),
                  ),
                ),

                // Bottom action bar
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _isAutoDate
                    ? 'Auto'
                    : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixText: 'Rs. ',
        prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        hintText: '0.00',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        final amount = double.tryParse(value.replaceAll(',', ''));
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildItemTitleField() {
    return TextFormField(
      controller: _itemTitleController,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'e.g., Rice, Dal, Groceries',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter item title';
        }
        return null;
      },
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _messageController,
        maxLines: 4,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Enter Message',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<ConnectedUserDetailsBloc, ConnectedUserDetailsState>(
      builder: (context, state) {
        final isLoading = state is ConnectedUserDetailsTransactionCreating;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Camera button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      // TODO: Camera functionality
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Mic button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.mic_outlined, color: Colors.grey.shade600),
                    onPressed: () {
                      // TODO: Voice input
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Add button
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
