import 'dart:async';

import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectedAddress {
  const SelectedAddress({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;

  LatLng get point => LatLng(latitude, longitude);
}

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key, this.initialSelection});

  final SelectedAddress? initialSelection;

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  static const _fallbackLocation = LatLng(30.0444, 31.2357);

  final _mapController = MapController();
  final _geocoding = Geocoding();
  late LatLng _selectedPoint;
  String? _address;
  String? _locationErrorKey;
  String? _addressErrorKey;
  bool _isLocating = false;
  bool _isResolvingAddress = false;
  bool _hasSelectedLocation = false;
  bool _mapReady = false;
  int _addressRequestId = 0;
  int _locationRequestId = 0;

  @override
  void initState() {
    super.initState();
    final initialSelection = widget.initialSelection;
    _selectedPoint = initialSelection?.point ?? _fallbackLocation;
    _address = initialSelection?.address;
    _hasSelectedLocation = initialSelection != null;
    if (initialSelection == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_locateCurrentUser());
        }
      });
    }
  }

  // Future<void> _locateCurrentUser() async {
  //   final requestId = ++_locationRequestId;
  //   setState(() {
  //     _isLocating = true;
  //     _locationErrorKey = null;
  //   });

  //   try {
  //     var permission = await Geolocator.checkPermission();
  //     if (!mounted || requestId != _locationRequestId) {
  //       return;
  //     }
  //     if (permission == LocationPermission.denied ||
  //         permission == LocationPermission.unableToDetermine) {
  //       permission = await Geolocator.requestPermission();
  //       if (!mounted || requestId != _locationRequestId) {
  //         return;
  //       }
  //     }
  //     if (permission == LocationPermission.denied) {
  //       _setLocationError('locationPermissionDenied', requestId);
  //       return;
  //     }
  //     if (permission == LocationPermission.deniedForever) {
  //       _setLocationError('locationPermissionPermanentlyDenied', requestId);
  //       return;
  //     }
  //     if (!await Geolocator.isLocationServiceEnabled()) {
  //       _setLocationError('locationServiceDisabled', requestId);
  //       return;
  //     }
  //     if (!mounted || requestId != _locationRequestId) {
  //       return;
  //     }

  //     final position = await Geolocator.getCurrentPosition(
  //       locationSettings: const LocationSettings(
  //         accuracy: LocationAccuracy.high,
  //         timeLimit: Duration(seconds: 20),
  //       ),
  //     );
  //     if (!mounted || requestId != _locationRequestId) {
  //       return;
  //     }

  //     final point = LatLng(position.latitude, position.longitude);
  //     setState(() {
  //       _selectedPoint = point;
  //       _hasSelectedLocation = true;
  //       _isLocating = false;
  //       _locationErrorKey = null;
  //     });
  //     if (_mapReady) {
  //       _mapController.move(point, 15);
  //     }
  //     await _resolveAddress(point);
  //   } on LocationServiceDisabledException {
  //     _setLocationError('locationServiceDisabled', requestId);
  //   } on PermissionDeniedException {
  //     _setLocationError('locationPermissionDenied', requestId);
  //   } on TimeoutException {
  //     _setLocationError('locationTimeout', requestId);
  //   } on PlatformException {
  //     _setLocationError('locationUnavailable', requestId);
  //   }
  // }

  Future<void> _locateCurrentUser() async {
    final requestId = ++_locationRequestId;

    setState(() {
      _isLocating = true;
      _locationErrorKey = null;
    });

    try {
      // 1. Check whether Location Services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        _setLocationError('locationServiceDisabled', requestId);
        return;
      }

      // 2. Check permission
      var permission = await Geolocator.checkPermission();

      // 3. Request permission if necessary
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 4. Handle denied
      if (permission == LocationPermission.denied) {
        _setLocationError('locationPermissionDenied', requestId);
        return;
      }

      // 5. Handle permanently denied
      if (permission == LocationPermission.deniedForever) {
        _setLocationError('locationPermissionPermanentlyDenied', requestId);

        await Geolocator.openAppSettings();
        return;
      }

      // 6. Get location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted || requestId != _locationRequestId) {
        return;
      }

      final point = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedPoint = point;
        _hasSelectedLocation = true;
        _isLocating = false;
        _locationErrorKey = null;
      });

      if (_mapReady) {
        _mapController.move(point, 15);
      }

      await _resolveAddress(point);
    } catch (e) {
      debugPrint('Location error: $e');
      _setLocationError('locationUnavailable', requestId);
    }
  }

  void _setLocationError(String key, int requestId) {
    if (!mounted || requestId != _locationRequestId) {
      return;
    }
    setState(() {
      _isLocating = false;
      _locationErrorKey = key;
    });
  }

  Future<void> _selectPoint(LatLng point) async {
    _locationRequestId++;
    setState(() {
      _selectedPoint = point;
      _hasSelectedLocation = true;
      _isLocating = false;
      _locationErrorKey = null;
      _address = null;
      _addressErrorKey = null;
      _isResolvingAddress = true;
    });
    await _resolveAddress(point);
  }

  Future<void> _resolveAddress(LatLng point) async {
    final requestId = ++_addressRequestId;
    if (mounted) {
      setState(() {
        _isResolvingAddress = true;
        _addressErrorKey = null;
      });
    }

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
        locale: context.locale,
      );
      if (!mounted || requestId != _addressRequestId) {
        return;
      }

      final parts = placemarks.isEmpty
          ? <String>[]
          : <String?>[
                  placemarks.first.name,
                  placemarks.first.street,
                  placemarks.first.subLocality,
                  placemarks.first.locality,
                  placemarks.first.subAdministrativeArea,
                  placemarks.first.administrativeArea,
                  placemarks.first.country,
                ]
                .whereType<String>()
                .map((part) => part.trim())
                .where((part) => part.isNotEmpty)
                .toSet()
                .toList();

      setState(() {
        _address = parts.isEmpty ? null : parts.join(', ');
        _addressErrorKey = parts.isEmpty ? 'addressLookupFailed' : null;
        _isResolvingAddress = false;
      });
    } on PlatformException {
      if (!mounted || requestId != _addressRequestId) {
        return;
      }
      setState(() {
        _address = null;
        _addressErrorKey = 'addressLookupFailed';
        _isResolvingAddress = false;
      });
    }
  }

  String _addressStatus(BuildContext context) {
    if (_isResolvingAddress) {
      return context.tr('addressResolving');
    }
    if (_address != null) {
      return _address!;
    }
    final errorKey = _addressErrorKey ?? _locationErrorKey;
    return context.tr(errorKey ?? 'locationUnavailable');
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        _hasSelectedLocation &&
        _address != null &&
        !_isResolvingAddress &&
        !_isLocating;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.tr('selectPharmacyAddress'),
          style: AppTextConstants.subheadingStyle(
            context,
          ).copyWith(fontSize: 20, color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.stroke),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('selectedAddress'),
                            style: AppTextConstants.bodyStyle(context).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _addressStatus(context),
                            style: AppTextConstants.bodyStyle(context).copyWith(
                              fontSize: 15,
                              color: _address == null
                                  ? AppColors.grey
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedPoint.latitude.toStringAsFixed(6)}, '
                            '${_selectedPoint.longitude.toStringAsFixed(6)}',
                            textDirection: .ltr,
                            style: AppTextConstants.bodyStyle(
                              context,
                            ).copyWith(fontSize: 12, color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_isLocating || _isResolvingAddress) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 15,
                      onMapReady: () {
                        _mapReady = true;
                        if (_hasSelectedLocation) {
                          _mapController.move(_selectedPoint, 15);
                        }
                      },
                      onTap: (_, point) => _selectPoint(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.dawak',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.location_pin,
                              size: 46,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            '© OpenStreetMap contributors',
                            onTap: () => launchUrl(
                              Uri.parse(
                                'https://www.openstreetmap.org/copyright',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'current-location',
                          tooltip: context.tr('useCurrentLocation'),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          onPressed: _isLocating ? null : _locateCurrentUser,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: canConfirm
                      ? () => Navigator.of(context).pop(
                          SelectedAddress(
                            latitude: _selectedPoint.latitude,
                            longitude: _selectedPoint.longitude,
                            address: _address!,
                          ),
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.stroke,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    context.tr('confirmLocation'),
                    style: AppTextConstants.subheadingStyle(
                      context,
                    ).copyWith(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
