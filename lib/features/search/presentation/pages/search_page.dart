import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _mapController = MapController();
  final _markers = <Marker>[];
  final _debounce = const Duration(milliseconds: 400);
  Timer? _bboxTimer;

  @override
  void initState() {
    super.initState();
    // Crea caché de tiles
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPoisForView());
  }

  @override
  void dispose() {
    _bboxTimer?.cancel();
    super.dispose();
  }

  void _onMapMoved() {
    _bboxTimer?.cancel();
    _bboxTimer = Timer(_debounce, _loadPoisForView);
  }

  Future<void> _loadPoisForView() async {
    final bounds = _mapController.camera.visibleBounds;

    // TODO: conecta aquí tu API de lugares/mascotas por bbox.
    // Datos de ejemplo:
    final demoPoints = [
      (LatLng(20.6736, -103.344), 'veterinaria'),
      (LatLng(20.6748, -103.349), 'hotel'),
      (LatLng(20.6715, -103.340), 'parque'),
      (LatLng(20.6795, -103.350), 'tienda'),
    ];

    final visibles = demoPoints
        .where((e) => bounds.contains(e.$1))
        .map(
          (e) => Marker(
            point: e.$1,
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: _buildMarker(e.$2),
          ),
        )
        .toList();

    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..addAll(visibles);
    });
  }

  Widget _buildMarker(String tipo) {
    IconData icon;
    switch (tipo) {
      case 'veterinaria':
        icon = Icons.local_hospital;
        break;
      case 'hotel':
        icon = Icons.hotel;
        break;
      case 'parque':
        icon = Icons.park;
        break;
      case 'tienda':
        icon = Icons.storefront;
        break;
      default:
        icon = Icons.pets;
    }

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(6),
      child: Icon(icon, size: 24, color: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(20.6736, -103.344),
          initialZoom: 12,
          minZoom: 3,
          maxZoom: 19,
          onMapEvent: (evt) {
            if (evt is MapEventMoveEnd ||
                evt is MapEventRotateEnd ||
                evt is MapEventFlingAnimationEnd) {
              _onMapMoved();
            }
          },
        ),
        children: [
          // Capa base (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.buscadog.app',
            maxZoom: 19,
          ),

          // Capa de clustering
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 60,
              size: const Size(42, 42),
              markers: _markers,
              builder: (context, markers) {
                final count = markers.length;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              onClusterTap: (cluster) {
                final zoom = _mapController.camera.zoom + 2;
                _mapController.move(cluster.bounds.center, zoom);
              },
              onMarkerTap: (marker) {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => ListTile(
                    title: const Text('Detalle del lugar'),
                    subtitle: Text(
                      'Lat: ${marker.point.latitude.toStringAsFixed(5)}, '
                      'Lng: ${marker.point.longitude.toStringAsFixed(5)}',
                    ),
                    trailing: const Icon(Icons.info_outline),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPoisForView,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
