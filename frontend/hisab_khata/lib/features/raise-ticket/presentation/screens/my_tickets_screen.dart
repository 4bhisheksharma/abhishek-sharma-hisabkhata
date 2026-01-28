import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/bloc/bloc.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/screens/create_ticket_screen.dart';
import 'package:hisab_khata/features/raise-ticket/presentation/screens/ticket_detail_screen.dart';
import 'package:intl/intl.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    context.read<TicketBloc>().add(const LoadMyTicketsEvent());
  }

  Future<void> _navigateToCreateTicket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTicketScreen()),
    );

    if (result == true && mounted) {
      _loadTickets();
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mySupportTickets),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTicket,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        // label: const Text('Create Ticket'),
      ),
      body: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTickets,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TicketsLoaded) {
            if (state.tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tickets yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first support ticket',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TicketBloc>().add(const RefreshTicketsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.tickets.length,
                itemBuilder: (context, index) {
                  final ticket = state.tickets[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketDetailScreen(ticketId: ticket.id),
                          ),
                        );
                        // Refresh tickets when coming back from detail screen
                        if (mounted) {
                          _loadTickets();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ticket.subject,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(
                                      ticket.priority,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _getPriorityColor(ticket.priority),
                                    ),
                                  ),
                                  child: Text(
                                    ticket.priorityDisplay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getPriorityColor(ticket.priority),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ticket.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ticket.categoryDisplay,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(ticket.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      ticket.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    ticket.statusDisplay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(ticket.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
