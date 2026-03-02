import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

/// Screen where the business owner can pick/update their shop location on a map.
class BusinessLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const BusinessLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<BusinessLocationPickerScreen> createState() =>
      _BusinessLocationPickerScreenState();
}

class _BusinessLocationPickerScreenState
    extends State<BusinessLocationPickerScreen> {
  late final MapController _mapController;
  late final TextEditingController _addressController;

  // Default to Itahari, Nepal if no initial location
  late LatLng _selectedLocation;
  bool _hasSelected = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _addressController = TextEditingController(
      text: widget.initialAddress ?? '',
    );

    _selectedLocation = LatLng(
      widget.initialLatitude ?? 26.6648,
      widget.initialLongitude ?? 87.2783,
    );
    _hasSelected = widget.initialLatitude != null;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _hasSelected = true;
    });
  }

  void _saveLocation() {
    if (!_hasSelected) {
      MySnackbar.showError(
        context,
        'Please tap on the map to select a location',
      );
      return;
    }

    context.read<BusinessBloc>().add(
      UpdateBusinessLocationEvent(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusinessBloc, BusinessState>(
      listener: (context, state) {
        if (state is BusinessProfileUpdated) {
          MySnackbar.showSuccess(context, state.message);
          Navigator.pop(context);
        } else if (state is BusinessError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          title: const Text(
            'Set Shop Location',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Address input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Enter shop address (optional)',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Info bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.lightBlue,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppTheme.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hasSelected
                          ? 'Location: ${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}'
                          : 'Tap on the map to pin your shop location',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: widget.initialLatitude != null ? 16.0 : 14.0,
                  onTap: _onTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.hisabkhata.app',
                  ),
                  if (_hasSelected)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Save button
            BlocBuilder<BusinessBloc, BusinessState>(
              builder: (context, state) {
                final isLoading = state is BusinessLoading;
                return Container(
                  padding: const EdgeInsets.all(16),
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _saveLocation,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 20),
                        label: Text(
                          isLoading ? 'Saving...' : 'Save Location',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
