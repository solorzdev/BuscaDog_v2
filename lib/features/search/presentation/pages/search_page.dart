import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

/// ======================
/// Modelos
/// ======================
class Vet {
  final int id;
  final String nombre;
  final double lat;
  final double lng;

  Vet({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
  });

  /// Detalle: tu endpoint devuelve { id, nombre, latitud, longitud, ... }
  factory Vet.fromJson(Map<String, dynamic> j) => Vet(
    id: j['id'] is int ? j['id'] : int.parse('${j['id']}'),
    nombre: (j['nombre'] ?? 'Veterinaria').toString(),
    lat: (j['latitud'] as num).toDouble(),
    lng: (j['longitud'] as num).toDouble(),
  );
}

class AggPoint {
  final double lat;
  final double lng;
  final int count;
  AggPoint({required this.lat, required this.lng, required this.count});

  /// Agregados: tu endpoint devuelve { lat, lng, count }
  factory AggPoint.fromJson(Map<String, dynamic> j) => AggPoint(
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    count: (j['count'] as num).toInt(),
  );
}

/// ======================
/// Página de búsqueda
/// ======================
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Mapa
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  // HTTP (Android emulador → 10.0.2.2)
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api/v1'));
  CancelToken? _cancel;
  int _reqSeq = 0;

  // Control
  Timer? _bboxTimer;

  // Config
  static const double _zoomThreshold = 11.0; // cambia de agregados a detalle
  static const int _debounceMs = 400;
  static const int _detailLimit = 800;
  static const int _aggLimit = 1200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPoisForView());
  }

  @override
  void dispose() {
    _bboxTimer?.cancel();
    _cancel?.cancel();
    super.dispose();
  }

  // ======================
  // Carga por vista (BBOX)
  // ======================
  Future<void> _loadPoisForView() async {
    final int seq = ++_reqSeq;

    // Cancela request anterior
    _cancel?.cancel('newer request');
    _cancel = CancelToken();

    final cam = _mapController.camera;
    final LatLngBounds bounds = cam.visibleBounds;
    final double zoom = cam.zoom;

    // Padding del BBOX para evitar bordes vacíos al mover
    final double latPad = (bounds.north - bounds.south) * 0.08;
    final double lngPad = (bounds.east - bounds.west) * 0.08;
    final double s = bounds.south - latPad;
    final double w = bounds.west - lngPad;
    final double n = bounds.north + latPad;
    final double e = bounds.east + lngPad;

    try {
      Response resp;

      if (zoom < _zoomThreshold) {
        // ---- Agregados (clusters lógicos desde backend)
        final int precision = _precisionFor(zoom);
        resp = await _dio.get(
          '/veterinarias/agg',
          queryParameters: {
            's': s,
            'w': w,
            'n': n,
            'e': e,
            'precision': precision,
            'limit': _aggLimit,
          },
          cancelToken: _cancel,
        );

        final data = (resp.data as List).cast<Map<String, dynamic>>();
        final agg = data.map((j) => AggPoint.fromJson(j)).toList();

        final ms = <Marker>[
          for (final a in agg)
            Marker(
              point: LatLng(a.lat, a.lng),
              width: 44,
              height: 44,
              child: _bubble(a.count > 999 ? '999+' : '${a.count}'),
            ),
        ];

        if (!mounted || seq != _reqSeq) return;
        setState(() {
          _markers
            ..clear()
            ..addAll(ms);
        });
        debugPrint('AGG -> puntos: ${ms.length}, zoom=$zoom');
      } else {
        // ---- Detalle real
        final String bboxStr = '$s,$w,$n,$e';
        resp = await _dio.get(
          '/veterinarias',
          queryParameters: {'bbox': bboxStr, 'limit': _detailLimit},
          cancelToken: _cancel,
        );

        final data = (resp.data as List).cast<Map<String, dynamic>>();
        final vets = data.map((j) => Vet.fromJson(j)).toList();

        final ms = <Marker>[
          for (final v in vets)
            Marker(
              point: LatLng(v.lat, v.lng),
              width: 44,
              height: 44,
              child: _vetPin(v),
            ),
        ];

        if (!mounted || seq != _reqSeq) return;
        setState(() {
          _markers
            ..clear()
            ..addAll(ms);
        });
        debugPrint('DETALLE -> puntos: ${ms.length}, zoom=$zoom');
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) return;
      debugPrint('Error al cargar POIs: $e');
    }
  }

  int _precisionFor(double zoom) {
    // 0..6: menor zoom => menos precisión (más agregación)
    if (zoom < 5) return 1;
    if (zoom < 8) return 2;
    if (zoom < 11) return 3;
    if (zoom < 13) return 4;
    if (zoom < 15) return 5;
    return 6;
  }

  void _onMapMoved() {
    _bboxTimer?.cancel();
    _bboxTimer = Timer(
      const Duration(milliseconds: _debounceMs),
      _loadPoisForView,
    );
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(20.6736, -103.344),
          initialZoom: 14, // fuerza entrar en modo detalle al abrir
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
          // Capa base OSM
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.buscadog.app',
            maxZoom: 19,
          ),

          // -------- PRUEBA RÁPIDA SIN CLUSTER (descomenta para test) --------
          // MarkerLayer(markers: _markers),

          // -------- CLUSTER VISUAL --------
          MarkerClusterLayerWidget(
            key: ValueKey(
              'cluster-${_reqSeq}-${_markers.length}',
            ), // 👈 fuerza rebuild
            options: MarkerClusterLayerOptions(
              markers: _markers,
              maxClusterRadius: 60,
              size: const Size(42, 42),
              builder: (context, markers) {
                final count = markers.length;
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00796B),
                        Color(0xFF48A999),
                      ], // tonos teal con degradado
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black38,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
              onClusterTap: (cluster) {
                final zoom = _mapController.camera.zoom + 2;
                _mapController.move(cluster.bounds.center, zoom);
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

  // ======================
  // Widgets de marker
  // ======================
  Widget _bubble(String text) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _vetPin(Vet v) {
    return GestureDetector(
      onTap: () {
        debugPrint('Veterinaria tocada: ${v.nombre}');
        showModalBottomSheet(
          context: context,
          builder: (_) => ListTile(
            title: Text(
              v.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Lat: ${v.lat.toStringAsFixed(5)},  Lng: ${v.lng.toStringAsFixed(5)}',
            ),
            trailing: const Icon(Icons.local_hospital, color: Colors.teal),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF009688),
              Color(0xFF4DB6AC),
            ], // tonos teal con brillo
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
      ),
    );
  }
}
