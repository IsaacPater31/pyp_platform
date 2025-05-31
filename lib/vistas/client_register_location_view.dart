import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ClientRegisterLocationView extends StatefulWidget {
  final Function(latlong.LatLng, String) onLocationSelected;

  const ClientRegisterLocationView({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<ClientRegisterLocationView> createState() => _ClientRegisterLocationViewState();
}

class _ClientRegisterLocationViewState extends State<ClientRegisterLocationView> {
  late final MapController _mapController;
  final TextEditingController _addressDetailController = TextEditingController();
  latlong.LatLng _currentCenter = const latlong.LatLng(4.6097, -74.0817);
  String? _selectedAddress;
  bool _isLoading = true;
  bool _mapReady = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    _addressDetailController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      setState(() => _isLoading = true);
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = latlong.LatLng(position.latitude, position.longitude);
        _mapReady = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveToCurrentLocation();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error obteniendo ubicación: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _moveToCurrentLocation() {
    if (_mapReady) {
      _mapController.move(_currentCenter, 16);
      _updateAddressFromCoordinates();
    }
  }

  Future<void> _updateAddressFromCoordinates() async {
    try {
      final places = await placemarkFromCoordinates(
        _currentCenter.latitude,
        _currentCenter.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        setState(() {
          _selectedAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.country
          ].where((part) => part?.isNotEmpty ?? false).join(', ');
        });
      }
    } catch (e) {
      print('Error obteniendo dirección: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu ubicación'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentCenter,
                    initialZoom: 16,
                    onPositionChanged: (position, _) {
                      setState(() => _currentCenter = position.center!);
                      _debounceTimer?.cancel();
                      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                        _updateAddressFromCoordinates();
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentCenter,
                          child: GestureDetector(
                            onTap: _initLocation,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          // Botón de ubicación — estilo iOS y visible arriba
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location),
                color: Colors.black87,
                onPressed: () {
                  _initLocation().then((_) {
                    if (_mapReady) {
                      _mapController.move(_currentCenter, 16);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedAddress ?? 'Mueve el mapa para ajustar tu ubicación',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressDetailController,
            decoration: const InputDecoration(
              labelText: 'Detalles adicionales (ej: Casa 2, Piso 3)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final fullAddress = '${_selectedAddress ?? "Ubicación seleccionada"} ${_addressDetailController.text}';
              widget.onLocationSelected(_currentCenter, fullAddress);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF1F2937),
            ),
            child: const Text(
              'CONFIRMAR UBICACIÓN',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}