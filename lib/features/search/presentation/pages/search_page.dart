import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

/// Simple API config
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    } else {
      return 'http://10.0.2.2:8080/api/v1';
    }
  }
}

/// Modelo de Veterinaria
class Vet {
  final int id;
  final String nombre;
  final double lat;
  final double lng;

  final String? codigoActividad;
  final String? nombreActividad;
  final String? tipoVial;
  final String? nombreVial;
  final String? numeroExterior;
  final String? codigoPostal;
  final String? municipio;
  final String? localidad;
  final String? telefono;
  final String? correo;
  final String? tipoAsent;
  final String? nombAsent;
  final String? entidad;

  Vet({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
    this.codigoActividad,
    this.nombreActividad,
    this.tipoVial,
    this.nombreVial,
    this.numeroExterior,
    this.codigoPostal,
    this.municipio,
    this.localidad,
    this.telefono,
    this.correo,
    this.tipoAsent,
    this.nombAsent,
    this.entidad,
  });

  factory Vet.fromJson(Map<String, dynamic> j) => Vet(
    id: j['id'] is int ? j['id'] : int.parse('${j['id']}'),
    nombre: (j['nombre'] ?? 'Veterinaria').toString(),
    lat: (j['latitud'] as num).toDouble(),
    lng: (j['longitud'] as num).toDouble(),
    codigoActividad: _s(j['codigo_actividad']),
    nombreActividad: _s(j['nombre_actividad']),
    tipoVial: _s(j['tipo_vial']),
    nombreVial: _s(j['nombre_vial']),
    numeroExterior: _s(j['numero_exterior']),
    codigoPostal: _s(j['codigo_postal']),
    municipio: _s(j['municipio']),
    localidad: _s(j['localidad']),
    telefono: _s(j['telefono']),
    correo: _s(j['correo']),
    tipoAsent: _s(j['tipo_asent']),
    nombAsent: _s(j['nomb_asent']),
    entidad: _s(j['entidad']),
  );

  static String? _s(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  String get direccionCompleta {
    final partes = <String>[];

    if (tipoVial != null && nombreVial != null) {
      partes.add('$tipoVial $nombreVial');
    } else if (nombreVial != null) {
      partes.add(nombreVial!);
    }

    if (numeroExterior != null) {
      partes.add('#$numeroExterior');
    }

    if (nombAsent != null) {
      partes.add(nombAsent!);
    }

    if (municipio != null) {
      partes.add(municipio!);
    }

    if (codigoPostal != null) {
      partes.add('CP $codigoPostal');
    }

    return partes.isEmpty ? 'Sin dirección' : partes.join(', ');
  }
}

/// Página de búsqueda con CLUSTERING
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MapController _mapController = MapController();
  final List<Vet> _allVets = [];

  late final Dio _dio;

  bool _isLoading = false;
  bool _isFirstLoad = true;
  String _statusMessage = 'Iniciando...';
  int _loadedCount = 0;
  double _currentZoom = 12.0;

  Timer? _debounceTimer;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _statusMessage = 'Listo para cargar';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _loadVeterinarias();
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _loadVeterinarias() async {
    _cancelToken?.cancel('Nueva búsqueda');
    _cancelToken = CancelToken();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _statusMessage = _isFirstLoad ? 'Cargando mapa...' : 'Actualizando...';
      });
    }

    try {
      final cam = _mapController.camera;
      final bounds = cam.visibleBounds;
      final zoom = cam.zoom;
      _currentZoom = zoom;

      // Límites adaptativos
      int limit;
      if (zoom < 9) {
        limit = 500;
      } else if (zoom < 11) {
        limit = 1000;
      } else if (zoom < 13) {
        limit = 2000;
      } else {
        limit = 3000;
      }

      final bbox =
          '${bounds.south},${bounds.west},${bounds.north},${bounds.east}';

      debugPrint('🔄 Cargando: zoom=$zoom, limit=$limit');

      final resp = await _dio.get(
        '/veterinarias',
        queryParameters: {'bbox': bbox, 'limit': limit},
        cancelToken: _cancelToken,
      );

      final data = (resp.data as List).cast<Map<String, dynamic>>();
      final vets = data.map((j) => Vet.fromJson(j)).toList();

      if (!mounted) return;

      setState(() {
        _allVets.clear();
        _allVets.addAll(vets);
        _isLoading = false;
        _isFirstLoad = false;
        _loadedCount = vets.length;
        _statusMessage = '$_loadedCount veterinarias';
      });

      debugPrint('✅ Cargadas $_loadedCount veterinarias');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
        _statusMessage = 'Error al cargar';
      });

      debugPrint('❌ Error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message ?? "Desconocido"}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
        _statusMessage = 'Error inesperado';
      });

      debugPrint('❌ Error: $e');
    }
  }

  void _onMapEvent(MapEvent event) {
    if (_isLoading) return;

    if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
      _debounceTimer?.cancel();

      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted && !_isLoading) {
          _loadVeterinarias();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Veterinarias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadVeterinarias,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(20.6736, -103.344),
              initialZoom: 12,
              minZoom: 3,
              maxZoom: 18,
              onMapEvent: _onMapEvent,
              interactionOptions: InteractionOptions(
                flags: _isLoading ? InteractiveFlag.none : InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: kIsWeb
                    ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.buscadog.app',
              ),

              // ✅ CLUSTERING LAYER (SIN popupOptions)
              if (_allVets.isNotEmpty)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 80,
                    size: const Size(50, 50),

                    // ✅ Markers con tap directo a bottom sheet
                    markers: _allVets
                        .map(
                          (v) => Marker(
                            point: LatLng(v.lat, v.lng),
                            width: 40,
                            height: 40,
                            child: _vetPin(v),
                          ),
                        )
                        .toList(),

                    // ✅ Builder de clusters
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${markers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },

                    // ✅ Polígonos invisibles
                    polygonOptions: const PolygonOptions(
                      borderColor: Colors.transparent,
                      color: Colors.transparent,
                      borderStrokeWidth: 0,
                    ),
                  ),
                ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            GestureDetector(
              onTap: () {},
              child: Container(
                color: _isFirstLoad
                    ? Colors.white.withOpacity(0.95)
                    : Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          _isFirstLoad
                              ? 'Preparando el mapa...'
                              : 'Cargando datos...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Status bar
          if (!_isLoading && !_isFirstLoad)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: IgnorePointer(
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.teal),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$_loadedCount veterinarias · Zoom ${_currentZoom.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _vetPin(Vet v) {
    return GestureDetector(
      onTap: () {
        if (!_isLoading) {
          _showBottomCardMobile(v);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.teal,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
      ),
    );
  }

  void _showBottomCardMobile(Vet v) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ListView(
            controller: controller,
            children: [
              Text(
                v.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (v.direccionCompleta != 'Sin dirección')
                _infoRow(Icons.place_outlined, v.direccionCompleta),

              if (v.telefono != null)
                _infoRow(Icons.call_outlined, v.telefono!),

              if (v.correo != null) _infoRow(Icons.mail_outlined, v.correo!),

              if (v.nombreActividad != null)
                _infoRow(Icons.business_outlined, v.nombreActividad!),

              const SizedBox(height: 16),

              Text(
                'Lat: ${v.lat.toStringAsFixed(5)} · Lng: ${v.lng.toStringAsFixed(5)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
