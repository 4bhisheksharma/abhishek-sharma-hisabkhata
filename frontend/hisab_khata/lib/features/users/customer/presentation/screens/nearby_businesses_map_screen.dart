import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/core/di/dependency_injection.dart';
import 'package:hisab_khata/features/users/customer/data/models/nearby_business_model.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_bloc.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_event.dart';
import 'package:hisab_khata/features/request/presentation/bloc/connection_request_state.dart';
import 'package:hisab_khata/features/transaction/presentation/bloc/connected_user_details_event.dart';
import 'package:hisab_khata/features/transaction/presentation/screens/connected_user_details_screen.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

/// Full-screen map showing nearby businesses.
/// Tapping a marker shows a bottom sheet:
///   - connected → navigate to ConnectedUserDetailsPage
///   - pending → show "Request pending" info
///   - not connected → send connection request
class NearbyBusinessesMapScreen extends StatefulWidget {
  const NearbyBusinessesMapScreen({super.key});

  @override
  State<NearbyBusinessesMapScreen> createState() =>
      _NearbyBusinessesMapScreenState();
}

class _NearbyBusinessesMapScreenState extends State<NearbyBusinessesMapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadNearbyBusinesses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Businesses Near Me',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CustomerBloc>().add(
                      const LoadNearbyBusinesses(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NearbyBusinessesLoaded) {
            final businesses = state.businesses;
            if (businesses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No businesses with location found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Center on first business
            final center = LatLng(
              businesses.first.latitude,
              businesses.first.longitude,
            );

            return FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 13.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hisabkhata.app',
                ),
                MarkerLayer(
                  markers: businesses.map((biz) {
                    return Marker(
                      point: LatLng(biz.latitude, biz.longitude),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _showBusinessSheet(context, biz),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.store,
                              color: biz.isConnected
                                  ? AppTheme.primaryBlue
                                  : biz.connectionStatus == 'pending'
                                  ? Colors.orange
                                  : Colors.grey[700],
                              size: 34,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }

          // Default
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showBusinessSheet(BuildContext context, NearbyBusinessModel biz) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Business info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.12,
                    ),
                    backgroundImage: biz.profilePicture != null
                        ? NetworkImage(biz.profilePicture!)
                        : null,
                    child: biz.profilePicture == null
                        ? const Icon(Icons.store, color: AppTheme.primaryBlue)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                biz.businessName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (biz.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                size: 18,
                                color: AppTheme.primaryBlue,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          biz.address ?? biz.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Connection status chip
              _buildStatusChip(biz),

              const SizedBox(height: 16),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: _buildActionButton(context, sheetCtx, biz),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(NearbyBusinessModel biz) {
    if (biz.isConnected) {
      return Chip(
        avatar: const Icon(Icons.link, size: 16, color: Colors.white),
        label: const Text(
          'Connected',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else if (biz.connectionStatus == 'pending') {
      return Chip(
        avatar: const Icon(
          Icons.hourglass_empty,
          size: 16,
          color: Colors.white,
        ),
        label: const Text(
          'Request Pending',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: Colors.orange,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    return Chip(
      avatar: Icon(
        Icons.person_add_outlined,
        size: 16,
        color: Colors.grey[700],
      ),
      label: Text(
        'Not Connected',
        style: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
      backgroundColor: Colors.grey[200],
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    BuildContext sheetCtx,
    NearbyBusinessModel biz,
  ) {
    if (biz.isConnected && biz.relationshipId != null) {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(sheetCtx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) =>
                        DependencyInjection().createConnectedUserDetailsBloc()
                          ..add(LoadConnectedUserDetails(biz.relationshipId!)),
                  ),
                  BlocProvider.value(
                    value: context.read<ConnectionRequestBloc>(),
                  ),
                ],
                child: ConnectedUserDetailsPage(
                  relationshipId: biz.relationshipId!,
                  isCustomerView: true,
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.visibility, size: 18),
        label: const Text(
          'View Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
      );
    } else if (biz.connectionStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty, size: 18),
        label: const Text(
          'Request Pending',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.orange[200],
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
      );
    } else {
      return BlocListener<ConnectionRequestBloc, ConnectionRequestState>(
        listener: (context, state) {
          if (state is ConnectionRequestSentSuccess) {
            MySnackbar.showSuccess(context, 'Connection request sent!');
            Navigator.pop(sheetCtx);
            // Reload businesses to refresh status
            context.read<CustomerBloc>().add(const LoadNearbyBusinesses());
          } else if (state is ConnectionRequestError) {
            MySnackbar.showError(context, state.message);
          }
        },
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<ConnectionRequestBloc>().add(
              SendConnectionRequestEvent(receiverId: biz.userId),
            );
          },
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text(
            'Send Connection Request',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
        ),
      );
    }
  }
}
