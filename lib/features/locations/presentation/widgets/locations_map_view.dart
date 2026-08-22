import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyber_vpn/app/di.dart';
import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:cyber_vpn/core/widgets/ping_bar.dart';
import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';
import 'package:cyber_vpn/features/locations/presentation/country_centroids.dart';
import 'package:cyber_vpn/features/session/data/direct_location_store.dart';
import 'package:cyber_vpn/features/session/presentation/bloc/session_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

/// Interactive locations map: clustered pins, fly-to, ping pulse, connect arc.
class LocationsMapView extends StatefulWidget {
  const LocationsMapView({
    super.key,
    required this.locations,
    required this.rttMs,
    required this.favoriteIds,
    required this.selectedId,
    required this.onSelect,
    required this.onToggleFavorite,
  });

  final List<VpnLocation> locations;
  final Map<int, int?> rttMs;
  final List<int> favoriteIds;
  final int? selectedId;
  final void Function(VpnLocation) onSelect;
  final void Function(int) onToggleFavorite;

  @override
  State<LocationsMapView> createState() => _LocationsMapViewState();
}

class _LocationsMapViewState extends State<LocationsMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _pulse;
  late final AnimationController _arc;
  late final AnimationController _entrance;
  VpnLocation? _preview;
  bool _mapReady = false;
  int? _fittedForCount;
  /// Cached Direct location (prefs); filled once on first app open.
  LatLng? _youFromIp;
  bool _loadingYou = false;

  List<VpnLocation> get _mappable =>
      widget.locations.where((l) => l.hasCoordinates).toList();

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _arc = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _loadYouFromCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final phase = context.read<SessionBloc>().state.phase;
      _syncArc(phase);
      _ensureYouCachedIfNeeded(phase);
    });
  }

  @override
  void didUpdateWidget(covariant LocationsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      final selected = _locationById(widget.selectedId);
      if (selected != null && selected.hasCoordinates && _mapReady) {
        _flyTo(LatLng(selected.lat!, selected.lng!));
      }
    }
    if (oldWidget.locations.length != widget.locations.length) {
      _fittedForCount = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitIfNeeded());
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _arc.dispose();
    _entrance.dispose();
    _mapController.dispose();
    super.dispose();
  }

  VpnLocation? _locationById(int? id) {
    if (id == null) return null;
    for (final l in widget.locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  void _flyTo(LatLng target) {
    _mapController.move(target, math.max(_mapController.camera.zoom, 4.5));
  }

  void _fitIfNeeded() {
    if (!_mapReady || !mounted) return;
    final points = _mappable
        .map((l) => LatLng(l.lat!, l.lng!))
        .toList(growable: false);
    if (points.isEmpty || _fittedForCount == points.length) return;
    _fittedForCount = points.length;
    if (points.length == 1) {
      _mapController.move(points.first, 4);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
  }

  void _onMarkerTap(VpnLocation loc) {
    setState(() => _preview = loc);
    if (loc.hasCoordinates) {
      _flyTo(LatLng(loc.lat!, loc.lng!));
    }
  }

  void _loadYouFromCache() {
    final cached = getIt<DirectLocationStore>().read();
    if (cached == null) return;
    _youFromIp = LatLng(cached.lat, cached.lng);
  }

  void _syncArc(SessionPhase phase) {
    final active =
        phase == SessionPhase.connecting || phase == SessionPhase.protected;
    if (active) {
      if (!_arc.isAnimating) _arc.repeat();
    } else {
      _arc
        ..stop()
        ..value = 0;
    }
  }

  /// Uses prefs cache; only hits ipwho.is if never captured and VPN is Direct.
  Future<void> _ensureYouCachedIfNeeded(SessionPhase phase) async {
    if (_youFromIp != null || _loadingYou) return;
    final isDirect =
        phase != SessionPhase.protected && phase != SessionPhase.connecting;
    _loadingYou = true;
    try {
      final point = await getIt<DirectLocationStore>().ensureCaptured(
        isDirect: isDirect,
      );
      if (!mounted || point == null) return;
      setState(() => _youFromIp = LatLng(point.lat, point.lng));
    } finally {
      _loadingYou = false;
    }
  }

  LatLng? _youPoint() {
    if (_youFromIp != null) return _youFromIp;
    final code =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    return countryCentroid(code);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final mappable = _mappable;
    final selected = _locationById(widget.selectedId);

    if (mappable.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No mapped servers yet. Sync the catalog or use List view.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.secondary,
                ),
          ),
        ),
      );
    }

    final markers = _buildMarkers(scheme, mappable, selected);

    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (p, n) => p.phase != n.phase,
      listener: (context, session) {
        _syncArc(session.phase);
        _ensureYouCachedIfNeeded(session.phase);
      },
      child: BlocBuilder<SessionBloc, SessionState>(
        buildWhen: (p, n) => p.phase != n.phase,
        builder: (context, session) {
          final you = _youPoint();
          final dest = selected?.hasCoordinates == true
              ? LatLng(selected!.lat!, selected.lng!)
              : null;
          final showArc = (session.phase == SessionPhase.connecting ||
                  session.phase == SessionPhase.protected) &&
              you != null &&
              dest != null;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(20, 10),
                  initialZoom: 1.8,
                  minZoom: 1.2,
                  maxZoom: 12,
                  backgroundColor: dark
                      ? const Color(0xFF0B0D12)
                      : const Color(0xFFE8EEF5),
                  onMapReady: () {
                    _mapReady = true;
                    _fitIfNeeded();
                    final sel = _locationById(widget.selectedId);
                    if (sel != null && sel.hasCoordinates) {
                      _flyTo(LatLng(sel.lat!, sel.lng!));
                    }
                  },
                  onTap: (_, _) => setState(() => _preview = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: dark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.cybervpn.cyber_vpn',
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 48,
                      size: const Size(40, 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      maxZoom: 12,
                      markers: markers,
                      builder: (context, clusterMarkers) {
                        return Container(
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surface,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${clusterMarkers.length}',
                            style: TextStyle(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (showArc)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _arc,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ConnectArcPainter(
                            map: _mapController.camera,
                            from: you,
                            to: dest,
                            progress: _arc.value,
                            color: scheme.primary,
                            protected:
                                session.phase == SessionPhase.protected,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_preview != null)
                        _LocationPreviewSheet(
                          location: _preview!,
                          rttMs: widget.rttMs,
                          favorite: widget.favoriteIds.contains(_preview!.id),
                          selected: widget.selectedId == _preview!.id,
                          onSelect: () {
                            final loc = _preview!;
                            setState(() => _preview = null);
                            widget.onSelect(loc);
                          },
                          onToggleFavorite: () =>
                              widget.onToggleFavorite(_preview!.id),
                          onDismiss: () => setState(() => _preview = null),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Map data © CARTO · GeoIP approximate',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.45),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildMarkers(
    ColorScheme scheme,
    List<VpnLocation> mappable,
    VpnLocation? selected,
  ) {
    // Slight jitter when multiple protocols share the same GeoIP point.
    final seen = <String, int>{};
    final markers = <Marker>[];

    final sorted = List<VpnLocation>.from(mappable)
      ..sort((a, b) => (a.lng ?? 0).compareTo(b.lng ?? 0));

    for (var i = 0; i < sorted.length; i++) {
      final loc = sorted[i];
      final key =
          '${loc.lat!.toStringAsFixed(3)},${loc.lng!.toStringAsFixed(3)}';
      final n = seen[key] ?? 0;
      seen[key] = n + 1;
      final point = LatLng(
        loc.lat! + n * 0.018,
        loc.lng! + n * 0.018,
      );
      final isSelected = selected?.id == loc.id;
      final probed = widget.rttMs.containsKey(loc.id);
      final color = latencyColorForPing(
        scheme,
        widget.rttMs[loc.id],
        loading: !probed,
      );
      final stagger = (i / math.max(sorted.length, 1)).clamp(0.0, 1.0);

      markers.add(
        Marker(
          point: point,
          width: isSelected ? 44 : 32,
          height: isSelected ? 44 : 32,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entrance,
              curve: Interval(
                stagger * 0.55,
                math.min(1.0, stagger * 0.55 + 0.45),
                curve: Curves.easeOut,
              ),
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.4, end: 1).animate(
                CurvedAnimation(
                  parent: _entrance,
                  curve: Interval(
                    stagger * 0.55,
                    math.min(1.0, stagger * 0.55 + 0.45),
                    curve: Curves.easeOutBack,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () => _onMarkerTap(loc),
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final pulse =
                        isSelected ? 1.0 + _pulse.value * 0.18 : 1.0;
                    return Transform.scale(scale: pulse, child: child);
                  },
                  child: _MapPin(
                    color: color,
                    selected: isSelected,
                    flagUrl: loc.flagUrl,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.color,
    required this.selected,
    required this.flagUrl,
  });

  final Color color;
  final bool selected;
  final String flagUrl;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 36.0 : 26.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: selected ? 2.5 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: selected ? 12 : 6,
            spreadRadius: selected ? 1 : 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: flagUrl.isEmpty
          ? Icon(Icons.place_rounded, size: size * 0.55, color: Colors.white)
          : CachedNetworkImage(
              imageUrl: flagUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Icon(
                Icons.place_rounded,
                size: size * 0.55,
                color: Colors.white,
              ),
            ),
    );
  }
}

class _LocationPreviewSheet extends StatelessWidget {
  const _LocationPreviewSheet({
    required this.location,
    required this.rttMs,
    required this.favorite,
    required this.selected,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onDismiss,
  });

  final VpnLocation location;
  final Map<int, int?> rttMs;
  final bool favorite;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final probed = rttMs.containsKey(location.id);

    return Material(
      elevation: 6,
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            if (location.flagUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: location.flagUrl,
                  width: 40,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.listSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  PingBar(
                    milliseconds: rttMs[location.id],
                    loading: !probed,
                    variant: PingBarVariant.badge,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: favorite ? 'Unfavorite' : 'Favorite',
              onPressed: onToggleFavorite,
              icon: Icon(
                favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: favorite ? scheme.primary : scheme.secondary,
              ),
            ),
            FilledButton(
              onPressed: onSelect,
              child: Text(selected ? 'Selected' : 'Select'),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectArcPainter extends CustomPainter {
  _ConnectArcPainter({
    required this.map,
    required this.from,
    required this.to,
    required this.progress,
    required this.color,
    required this.protected,
  });

  final MapCamera map;
  final LatLng from;
  final LatLng to;
  final double progress;
  final Color color;
  final bool protected;

  @override
  void paint(Canvas canvas, Size size) {
    final a = map.latLngToScreenOffset(from);
    final b = map.latLngToScreenOffset(to);
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - 80);

    final path = ui.Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final drawLen = metric.length * (0.15 + 0.85 * progress);

    final extract = metric.extractPath(0, drawLen);
    final glow = Paint()
      ..color = color.withValues(alpha: protected ? 0.35 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final stroke = Paint()
      ..color = color.withValues(alpha: protected ? 0.95 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(extract, glow);
    _drawDashed(canvas, extract, stroke);

    final endpoint = Paint()..color = color;
    canvas.drawCircle(a, 4, endpoint);
    canvas.drawCircle(b, 5, endpoint);
  }

  void _drawDashed(Canvas canvas, ui.Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 10.0;
      const gap = 6.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.protected != protected ||
        oldDelegate.map.zoom != map.zoom ||
        oldDelegate.map.center != map.center;
  }
}
