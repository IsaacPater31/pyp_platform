import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ClientLocationView extends StatefulWidget {
  const ClientLocationView({super.key});

  @override
  State<ClientLocationView> createState() => _ClientLocationViewState();
}

class _ClientLocationViewState extends State<ClientLocationView> {
  final MapController _mapController = MapController();
  late final TileLayer _tileLayer;
  latlong.LatLng _currentCenter = const latlong.LatLng(10.3910, -75.4794);
  String? _selectedAddress;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tileLayer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      tileProvider: CancellableNetworkTileProvider(), // Versión 3.1.0
      userAgentPackageName: 'com.example.your_app',
      maxZoom: 19,
    );
    _updateAddressFromCenter(); // Carga la dirección inicial
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _updateAddressFromCenter() async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_currentCenter.latitude}&lon=${_currentCenter.longitude}&zoom=18&addressdetails=1',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.your_app',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedAddress = data['display_name'] ?? 'Dirección no disponible';
        });
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Error al obtener dirección: ${e.toString()}';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor activa el GPS')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permisos requeridos'),
            content: const Text('Por favor habilita los permisos de ubicación en ajustes'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Abrir ajustes'),
              ),
            ],
          ),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentCenter = latlong.LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentCenter, _mapController.camera.zoom);
        await _updateAddressFromCenter();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentCenter,
          initialZoom: 16,
          interactionOptions: const InteractionOptions(
            flags: ~InteractiveFlag.rotate,
          ),
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              setState(() => _currentCenter = position.center!);
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 800), () {
                if (mounted) _updateAddressFromCenter();
              });
            }
          },
        ),
        children: [
          _tileLayer,
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: _currentCenter,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedAddress ?? 'Cargando dirección...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Mi ubicación'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, _currentCenter),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}