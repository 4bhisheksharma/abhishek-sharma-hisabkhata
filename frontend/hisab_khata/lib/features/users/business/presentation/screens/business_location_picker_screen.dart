import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

/// Screen where the business owner can pick/update their shop location on a map.
/// Includes search, tap-to-pin, and locate-me functionality.
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Default to Itahari, Nepal if no initial location
  late LatLng _selectedLocation;
  bool _hasSelected = false;
  bool _isSearching = false;
  bool _isLocating = false;
  List<_SearchResult> _searchResults = [];

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
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _hasSelected = true;
      _searchResults = [];
    });
    _searchFocus.unfocus();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'HisabKhataApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((item) {
            return _SearchResult(
              displayName: item['display_name'] as String,
              lat: double.parse(item['lat'] as String),
              lon: double.parse(item['lon'] as String),
            );
          }).toList();
        });
      }
    } catch (_) {
      // Silently fail search
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(_SearchResult result) {
    final point = LatLng(result.lat, result.lon);
    setState(() {
      _selectedLocation = point;
      _hasSelected = true;
      _searchResults = [];
      _searchController.text = result.displayName;
      _addressController.text = result.displayName;
    });
    _searchFocus.unfocus();
    _mapController.move(point, 16.0);
  }

  Future<void> _locateMe() async {
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          MySnackbar.showError(context, 'Location services are disabled');
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            MySnackbar.showError(context, 'Location permission denied');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          MySnackbar.showError(
            context,
            'Location permissions are permanently denied',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = point;
        _hasSelected = true;
      });
      _mapController.move(point, 16.0);
    } catch (e) {
      if (mounted) {
        MySnackbar.showError(context, 'Failed to get current location');
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
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
            // Search field
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: _searchLocation,
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.primaryBlue,
                  ),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        )
                      : null,
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Search results dropdown
            if (_searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.location_on,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      title: Text(
                        result.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () => _selectSearchResult(result),
                    );
                  },
                ),
              ),

            // Address input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
              child: Stack(
                children: [
                  FlutterMap(
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

                  // Locate me FAB
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      heroTag: 'locate_me',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: _isLocating ? null : _locateMe,
                      child: _isLocating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: AppTheme.primaryBlue,
                            ),
                    ),
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

/// Simple model for search results from Nominatim
class _SearchResult {
  final String displayName;
  final double lat;
  final double lon;

  _SearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}
