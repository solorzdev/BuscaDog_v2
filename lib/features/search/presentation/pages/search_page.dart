import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // Campos extra
  final String? telefono;
  final String? correo;
  final String? municipio;
  final String? localidad;
  final String? codigoPostal;
  final String? via; // calle + número
  final String? colonia; // tipo_asent + nomb_asent
  final String? direccion; // dirección completa

  Vet({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
    this.telefono,
    this.correo,
    this.municipio,
    this.localidad,
    this.codigoPostal,
    this.via,
    this.colonia,
    this.direccion,
  });

  factory Vet.fromJson(Map<String, dynamic> j) => Vet(
    id: j['id'] is int ? j['id'] : int.parse('${j['id']}'),
    nombre: (j['nombre'] ?? 'Veterinaria').toString(),
    lat: (j['latitud'] as num).toDouble(),
    lng: (j['longitud'] as num).toDouble(),
    telefono: _s(j['telefono']),
    correo: _s(j['correo']),
    municipio: _s(j['municipio']),
    localidad: _s(j['localidad']),
    codigoPostal: _s(j['codigo_postal']),
    via: _s(j['via']),
    colonia: _s(j['colonia']),
    direccion: _s(j['direccion']),
  );

  static String? _s(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }
}

class AggPoint {
  final double lat;
  final double lng;
  final int count;
  AggPoint({required this.lat, required this.lng, required this.count});

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
  final Map<int, OverlayEntry> _hoverEntries = {};

  // HTTP (Android emulador → 10.0.2.2; físico → IP de tu PC)
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

          // -------- CLUSTER VISUAL --------
          MarkerClusterLayerWidget(
            key: ValueKey('cluster-${_reqSeq}-${_markers.length}'),
            options: MarkerClusterLayerOptions(
              markers: _markers,
              maxClusterRadius: 60,
              size: const Size(42, 42),
              builder: (context, markers) {
                final count = markers.length;
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00796B), Color(0xFF48A999)],
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
    return MouseRegion(
      onEnter: kIsWeb ? (_) => _showHoverInfoWeb(v) : null,
      onExit: kIsWeb ? (_) => _hideHoverInfoWeb(v) : null,
      child: GestureDetector(
        onTap: kIsWeb ? null : () => _showBottomCardMobile(v),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
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
          child: const Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ======================
  // Mini-modal móvil y tooltip web
  // ======================
  void _showBottomCardMobile(Vet v) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.local_hospital, color: Color(0xFF00796B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    v.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (v.direccion != null)
              _infoRow(Icons.place_outlined, v.direccion!),
            if (v.via != null || v.colonia != null)
              _infoRow(
                Icons.map_outlined,
                [
                  if (v.via != null) v.via!,
                  if (v.colonia != null) v.colonia!,
                ].join(' • '),
              ),
            if (v.telefono != null) _infoRow(Icons.call_outlined, v.telefono!),
            if (v.correo != null) _infoRow(Icons.mail_outlined, v.correo!),
            if (v.municipio != null ||
                v.localidad != null ||
                v.codigoPostal != null)
              _infoRow(
                Icons.location_city_outlined,
                [
                  if (v.localidad != null) v.localidad!,
                  if (v.municipio != null) v.municipio!,
                  if (v.codigoPostal != null) 'CP ${v.codigoPostal!}',
                ].join(' • '),
              ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${v.lat.toStringAsFixed(5)} · Lng: ${v.lng.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void _showHoverInfoWeb(Vet v) {
    if (_hoverEntries.containsKey(v.id)) return;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 90, // sobre la barra inferior
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  if (v.direccion != null)
                    _infoRow(Icons.place_outlined, v.direccion!),
                  if (v.telefono != null || v.correo != null)
                    _infoRow(
                      Icons.contact_phone_outlined,
                      [
                        if (v.telefono != null) v.telefono!,
                        if (v.correo != null) v.correo!,
                      ].join(' • '),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    _hoverEntries[v.id] = entry;
  }

  void _hideHoverInfoWeb(Vet v) {
    _hoverEntries.remove(v.id)?.remove();
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00796B)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
