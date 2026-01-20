import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapcn_flutter/src/mapcn_painter.dart';
import 'package:mapcn_flutter/src/mapcn_themes.dart';
import 'package:mapcn_flutter/src/mapcn_route.dart';

// Re-export for convenience
export 'package:mapcn_flutter/src/mapcn_painter.dart';
export 'package:mapcn_flutter/src/mapcn_themes.dart';
export 'package:mapcn_flutter/src/mapcn_route.dart';

/// A beautiful, customizable dark-themed map widget for Flutter.
/// 
/// Mapcn provides an elegant mapping solution with animated markers,
/// multiple built-in themes, and smooth camera animations.
/// 
/// ## Basic Usage
/// ```dart
/// Mapcn(
///   initialCenter: LatLng(51.5, -0.09),
///   initialZoom: 10,
///   style: MapcnStyle.midnight,
///   points: [LatLng(51.5, -0.09)],
/// )
/// ```
/// 
/// ## With Controller
/// ```dart
/// final controller = MapcnController(vsync: this);
/// 
/// Mapcn(
///   controller: controller,
///   initialCenter: LatLng(0, 0),
///   points: myPoints,
///   onPointTap: (point) => print('Tapped: $point'),
/// )
/// 
/// // Later: animate to location
/// controller.flyTo(LatLng(48.8566, 2.3522), zoom: 12);
/// ```
class Mapcn extends StatefulWidget {
  /// The initial center coordinates for the map.
  final LatLng initialCenter;
  
  /// The initial zoom level (1.0 - 18.0). Default is 3.0.
  final double initialZoom;
  
  /// The visual style/theme of the map tiles.
  final MapcnStyle style;
  
  /// List of points to display as animated markers on the map.
  final List<LatLng> points;
  
  /// The accent color used for markers and UI elements.
  final Color accentColor;
  
  /// Custom 5x4 color matrix for [MapcnStyle.custom].
  /// Use [MapcnThemes.createCustomTheme] to generate this easily.
  final List<double>? customMatrix;
  
  /// Optional controller for programmatic map control.
  final MapcnController? controller;
  
  /// Callback when a marker point is tapped.
  final Function(LatLng)? onPointTap;
  
  /// Configuration for marker appearance and animation.
  final MarkerConfig markerConfig;
  
  /// Whether to show the built-in glassmorphism tooltip on marker tap.
  /// Set to false if you want to handle taps entirely via [onPointTap].
  final bool showTooltip;
  
  /// Custom tooltip builder for complete control over marker popups.
  /// If provided, this overrides the default glassmorphism tooltip.
  final Widget Function(BuildContext context, LatLng point)? tooltipBuilder;
  
  /// Whether to show a loading indicator while tiles are loading.
  final bool showLoadingIndicator;
  
  /// Whether to show the OpenStreetMap attribution badge.
  final bool showAttribution;
  
  /// Minimum zoom level allowed (default: 2.0).
  final double minZoom;
  
  /// Maximum zoom level allowed (default: 18.0).
  final double maxZoom;
  
  /// Duration of the marker pulse animation cycle.
  final Duration pulseDuration;
  
  /// Callback when the map is ready and the controller can be used.
  final VoidCallback? onMapReady;
  
  /// Callback when the map camera moves.
  final Function(MapPosition position, bool hasGesture)? onCameraMove;
  
  /// List of routes to display on the map
  final List<MapcnRoute> routes;
  
  /// Callback when a route is tapped
  final Function(MapcnRoute route)? onRouteTap;
  
  /// Performance: Whether to use RepaintBoundary for markers
  final bool useRepaintBoundary;
  
  /// Performance: Whether to cache tile layers
  final bool enableTileCaching;
  
  /// Performance: Maximum number of tiles to keep in memory
  final int maxTileCache;

  const Mapcn({
    super.key,
    required this.initialCenter,
    this.initialZoom = 3.0,
    this.style = MapcnStyle.dark,
    this.points = const [],
    this.routes = const [],
    this.accentColor = const Color(0xFF00E676),
    this.customMatrix,
    this.controller,
    this.onPointTap,
    this.onRouteTap,
    this.markerConfig = const MarkerConfig(),
    this.showTooltip = true,
    this.tooltipBuilder,
    this.showLoadingIndicator = true,
    this.showAttribution = true,
    this.minZoom = 2.0,
    this.maxZoom = 18.0,
    this.pulseDuration = const Duration(seconds: 2),
    this.onMapReady,
    this.onCameraMove,
    this.useRepaintBoundary = true,
    this.enableTileCaching = true,
    this.maxTileCache = 100,
  });

  @override
  State<Mapcn> createState() => _MapcnState();
}

class _MapcnState extends State<Mapcn> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late MapController _internalMapController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    // Safe controller initialization with null check
    if (widget.controller != null) {
      _internalMapController = widget.controller!.mapController;
    } else {
      _internalMapController = MapController();
    }
    
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat();
  }

  @override
  void didUpdateWidget(Mapcn oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle controller changes safely
    if (widget.controller != oldWidget.controller) {
      if (widget.controller != null) {
        _internalMapController = widget.controller!.mapController;
      } else {
        _internalMapController = MapController();
      }
      // Force rebuild
      if (mounted) setState(() {});
    }
    
    // Update pulse duration if changed
    if (widget.pulseDuration != oldWidget.pulseDuration) {
      _pulseController.duration = widget.pulseDuration;
    }
  }
  
  void _onMapReady() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    widget.onMapReady?.call();
    
    // Notify controller that map is ready
    widget.controller?._notifyReady();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Only dispose internal controller if we created it
    if (widget.controller == null) {
      _internalMapController.dispose();
    }
    super.dispose();
  }

  void _handleTap(LatLng point) {
    // Execute callback first
    widget.onPointTap?.call(point);
    
    // Skip tooltip if disabled
    if (!widget.showTooltip) return;
    
    // Use custom builder if provided
    if (widget.tooltipBuilder != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black26,
        builder: (ctx) => widget.tooltipBuilder!(ctx, point),
      );
      return;
    }
    
    // Show enhanced Glassmorphism Tooltip
    _showGlassmorphismTooltip(point);
  }
  
  void _showGlassmorphismTooltip(LatLng point) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Accent dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "LOCATION",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${point.latitude.toStringAsFixed(4)}°",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "${point.longitude.toStringAsFixed(4)}°",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "TAP TO CLOSE",
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<double> _getMatrix() {
    if (widget.style == MapcnStyle.custom && widget.customMatrix != null) {
      // Validate custom matrix length
      if (widget.customMatrix!.length != 20) {
        debugPrint('Mapcn: customMatrix must have exactly 20 elements. Using default.');
        return MapcnThemes.mapcnDark;
      }
      return widget.customMatrix!;
    }
    
    return switch (widget.style) {
      MapcnStyle.dark => MapcnThemes.mapcnDark,
      MapcnStyle.midnight => MapcnThemes.midnight,
      MapcnStyle.dracula => MapcnThemes.dracula,
      MapcnStyle.emerald => MapcnThemes.emerald,
      MapcnStyle.silver => MapcnThemes.silver,
      MapcnStyle.sunset => MapcnThemes.sunset,
      MapcnStyle.ocean => MapcnThemes.ocean,
      MapcnStyle.sepia => MapcnThemes.sepia,
      MapcnStyle.highContrast => MapcnThemes.highContrast,
      MapcnStyle.normal => MapcnThemes.identity,
      _ => MapcnThemes.mapcnDark,
    };
  }
  
  Color _getBackgroundColor() {
    // Match background to theme for seamless appearance
    return switch (widget.style) {
      MapcnStyle.normal => Colors.white,
      MapcnStyle.sepia => const Color(0xFF2D2416),
      MapcnStyle.silver => const Color(0xFF1A1A1A),
      _ => Colors.black,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Map
        FlutterMap(
          mapController: _internalMapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom.clamp(widget.minZoom, widget.maxZoom),
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            backgroundColor: _getBackgroundColor(),
            onMapReady: _onMapReady,
            onPositionChanged: (camera, hasGesture) {
              widget.onCameraMove?.call(camera, hasGesture);
            },
          ),
          children: [
            // Themed Tile Layer with performance optimizations
            ColorFiltered(
              colorFilter: ColorFilter.matrix(_getMatrix()),
              child: TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mapcn',
                tileBuilder: _buildTile,
                keepBuffer: widget.enableTileCaching ? 5 : 2,
                panBuffer: widget.enableTileCaching ? 2 : 0,
                errorTileCallback: (tile, error, stackTrace) {
                  debugPrint('Mapcn: Tile load error: $error');
                },
              ),
            ),
            
            // Route Layer (drawn before markers so markers appear on top)
            if (widget.routes.isNotEmpty)
              ..._buildRouteLayers(),
            
            // Animated Marker Layer with performance optimization
            if (widget.points.isNotEmpty)
              widget.useRepaintBoundary
                ? RepaintBoundary(
                    child: MarkerLayer(
                      markers: widget.points.map((p) => _buildMarker(p)).toList(),
                    ),
                  )
                : MarkerLayer(
                    markers: widget.points.map((p) => _buildMarker(p)).toList(),
                  ),
              
            // Attribution (respects OSM license)
            if (widget.showAttribution)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '© OpenStreetMap',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        // Loading Indicator
        if (widget.showLoadingIndicator && _isLoading)
          Positioned(
            top: 12,
            right: 12,
            child: _buildLoadingIndicator(),
          ),
          
        // Error indicator
        if (_errorMessage != null)
          Positioned(
            bottom: 40,
            left: 12,
            right: 12,
            child: _buildErrorBanner(),
          ),
      ],
    );
  }
  
  Widget _buildTile(BuildContext context, Widget tileWidget, TileImage tile) {
    // Add fade-in animation for smoother tile loading
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: tileWidget,
    );
  }
  
  /// Build route layers for all configured routes
  List<Widget> _buildRouteLayers() {
    final layers = <Widget>[];
    
    for (final route in widget.routes) {
      if (route.points.length < 2) continue;
      
      // Get points to render (apply animation progress if set)
      final pointsToRender = route.config.animationProgress != null
          ? _getAnimatedRoutePoints(route.points, route.config.animationProgress!)
          : route.points;
      
      if (pointsToRender.length < 2) continue;
      
      // Border/outline layer (drawn first, behind main line)
      if (route.config.borderColor != null) {
        layers.add(
          PolylineLayer(
            polylines: [
              Polyline(
                points: pointsToRender,
                color: route.config.borderColor!,
                strokeWidth: route.config.width + (route.config.borderWidth * 2),
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),
        );
      }
      
      // Glow effect layer
      if (route.config.showGlow) {
        layers.add(
          PolylineLayer(
            polylines: [
              Polyline(
                points: pointsToRender,
                color: route.config.color.withValues(
                  alpha: route.config.glowIntensity * 0.3,
                ),
                strokeWidth: route.config.width + 8,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),
        );
      }
      
      // Main route line
      if (route.config.style == RouteStyle.dashed) {
        // Dashed line - create segments manually
        layers.add(
          PolylineLayer(
            polylines: _buildDashedPolylines(
              pointsToRender,
              route.config.color,
              route.config.width,
              route.config.dashPattern ?? [15.0, 8.0],
            ),
          ),
        );
      } else {
        // Solid or dotted line
        layers.add(
          PolylineLayer(
            polylines: [
              Polyline(
                points: pointsToRender,
                color: route.config.color,
                strokeWidth: route.config.width,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
                isDotted: route.config.style == RouteStyle.dotted,
              ),
            ],
          ),
        );
      }
      
      // Direction arrows
      if (route.config.showArrows && pointsToRender.length >= 2) {
        layers.add(
          MarkerLayer(
            markers: _buildRouteArrows(pointsToRender, route.config),
          ),
        );
      }
      
      // Start/End markers
      if (route.config.showEndpoints && route.points.length >= 2) {
        layers.add(
          MarkerLayer(
            markers: [
              _buildEndpointMarker(
                route.points.first,
                route.config.startColor ?? route.config.color,
                true,
              ),
              _buildEndpointMarker(
                route.points.last,
                route.config.endColor ?? route.config.color,
                false,
              ),
            ],
          ),
        );
      }
    }
    
    return layers;
  }
  
  /// Build dashed polylines by segmenting the route
  List<Polyline> _buildDashedPolylines(
    List<LatLng> points,
    Color color,
    double width,
    List<double> dashPattern,
  ) {
    final polylines = <Polyline>[];
    if (points.length < 2) return polylines;
    
    final dashLength = dashPattern.isNotEmpty ? dashPattern[0] : 15.0;
    final gapLength = dashPattern.length > 1 ? dashPattern[1] : 8.0;
    
    // Convert dash lengths to approximate degrees (very rough approximation)
    // At equator, 1 degree ≈ 111km, so we use a scale factor
    final scaleFactor = 0.0001; // Adjust based on zoom level approximation
    final dashDegrees = dashLength * scaleFactor;
    final gapDegrees = gapLength * scaleFactor;
    
    var isDrawing = true;
    var remainingLength = dashDegrees;
    var currentSegment = <LatLng>[];
    
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      
      final dx = end.longitude - start.longitude;
      final dy = end.latitude - start.latitude;
      final segmentLength = math.sqrt(dx * dx + dy * dy);
      
      if (segmentLength == 0) continue;
      
      final unitX = dx / segmentLength;
      final unitY = dy / segmentLength;
      
      var currentPos = 0.0;
      
      while (currentPos < segmentLength) {
        final stepLength = math.min(remainingLength, segmentLength - currentPos);
        
        final newPoint = LatLng(
          start.latitude + unitY * (currentPos + stepLength),
          start.longitude + unitX * (currentPos + stepLength),
        );
        
        if (isDrawing) {
          if (currentSegment.isEmpty) {
            currentSegment.add(LatLng(
              start.latitude + unitY * currentPos,
              start.longitude + unitX * currentPos,
            ));
          }
          currentSegment.add(newPoint);
        }
        
        currentPos += stepLength;
        remainingLength -= stepLength;
        
        if (remainingLength <= 0.0001) {
          // Switch between dash and gap
          if (isDrawing && currentSegment.length >= 2) {
            polylines.add(Polyline(
              points: List.from(currentSegment),
              color: color,
              strokeWidth: width,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ));
          }
          currentSegment.clear();
          isDrawing = !isDrawing;
          remainingLength = isDrawing ? dashDegrees : gapDegrees;
        }
      }
    }
    
    // Add any remaining segment
    if (isDrawing && currentSegment.length >= 2) {
      polylines.add(Polyline(
        points: currentSegment,
        color: color,
        strokeWidth: width,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ));
    }
    
    return polylines;
  }
  
  /// Get animated route points (partial route based on progress)
  List<LatLng> _getAnimatedRoutePoints(List<LatLng> points, double progress) {
    if (progress >= 1.0) return points;
    if (progress <= 0.0) return [];
    
    final result = <LatLng>[points.first];
    
    // Calculate total distance
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += RouteUtils.distanceBetween(points[i], points[i + 1]);
    }
    
    final targetDistance = totalDistance * progress;
    double accumulated = 0;
    
    for (int i = 0; i < points.length - 1; i++) {
      final segmentDistance = RouteUtils.distanceBetween(points[i], points[i + 1]);
      
      if (accumulated + segmentDistance >= targetDistance) {
        // Interpolate final point
        final segmentProgress = (targetDistance - accumulated) / segmentDistance;
        final start = points[i];
        final end = points[i + 1];
        
        result.add(LatLng(
          start.latitude + (end.latitude - start.latitude) * segmentProgress,
          start.longitude + (end.longitude - start.longitude) * segmentProgress,
        ));
        break;
      }
      
      accumulated += segmentDistance;
      result.add(points[i + 1]);
    }
    
    return result;
  }
  
  /// Build arrow markers along the route
  List<Marker> _buildRouteArrows(List<LatLng> points, RouteConfig config) {
    final arrows = <Marker>[];
    
    // Calculate positions along route for arrows
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += RouteUtils.distanceBetween(points[i], points[i + 1]);
    }
    
    // Spacing in km (approximate based on pixels)
    final spacingKm = (config.arrowSpacing / 1000) * 10;
    final numArrows = (totalDistance / spacingKm).floor();
    
    for (int a = 1; a <= numArrows; a++) {
      final fraction = a / (numArrows + 1);
      final point = RouteUtils.interpolateAlongRoute(points, fraction);
      
      // Calculate bearing for arrow rotation
      final nearbyFraction = (fraction + 0.01).clamp(0.0, 1.0);
      final nearbyPoint = RouteUtils.interpolateAlongRoute(points, nearbyFraction);
      final bearing = RouteUtils.bearingBetween(point, nearbyPoint);
      
      arrows.add(
        Marker(
          point: point,
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: RouteArrowPainter(
              color: Colors.white.withValues(alpha: 0.9),
              size: 10,
              rotation: bearing,
            ),
          ),
        ),
      );
    }
    
    return arrows;
  }
  
  /// Build endpoint marker (start or end)
  Marker _buildEndpointMarker(LatLng point, Color color, bool isStart) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: RouteEndpointPainter(
          color: color,
          isStart: isStart,
          size: 18,
        ),
      ),
    );
  }
  
  Marker _buildMarker(LatLng point) {
    final markerSize = (widget.markerConfig.pulseRadius + 20).clamp(60.0, 120.0);
    
    return Marker(
      point: point,
      width: markerSize,
      height: markerSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(point),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => CustomPaint(
            painter: MapcnGlowPainter(
              color: widget.accentColor,
              animationValue: _pulseController.value,
              config: widget.markerConfig,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.accentColor.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Controller for programmatic map manipulation with smooth animations.
/// 
/// ## Usage
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
///   late final MapcnController _controller;
///   
///   @override
///   void initState() {
///     super.initState();
///     _controller = MapcnController(vsync: this);
///   }
///   
///   void _goToParis() {
///     _controller.flyTo(
///       LatLng(48.8566, 2.3522),
///       zoom: 12,
///       duration: const Duration(seconds: 2),
///     );
///   }
/// }
/// ```
class MapcnController {
  late final MapController mapController;
  final TickerProvider vsync;
  
  bool _isReady = false;
  final List<VoidCallback> _pendingOperations = [];

  /// Creates a new MapcnController.
  /// 
  /// [vsync] is required for animations - typically pass `this` from a 
  /// State that uses [TickerProviderStateMixin].
  MapcnController({required this.vsync}) {
    mapController = MapController();
  }
  
  /// Whether the map is ready for programmatic control.
  bool get isReady => _isReady;
  
  /// The current camera state (center, zoom, rotation, etc.)
  MapCamera get camera => mapController.camera;
  
  /// The current center coordinates.
  LatLng get center => mapController.camera.center;
  
  /// The current zoom level.
  double get zoom => mapController.camera.zoom;
  
  void _notifyReady() {
    _isReady = true;
    // Execute any pending operations
    for (final op in _pendingOperations) {
      op();
    }
    _pendingOperations.clear();
  }
  
  /// Executes an operation immediately if ready, or queues it for later.
  void _executeWhenReady(VoidCallback operation) {
    if (_isReady) {
      operation();
    } else {
      _pendingOperations.add(operation);
    }
  }

  /// Animates the camera to a target location with smooth easing.
  /// 
  /// [target] - The destination coordinates
  /// [zoom] - Target zoom level (default: 5.0)
  /// [duration] - Animation duration (default: 1500ms)
  /// [curve] - Animation curve (default: easeInOutCubic)
  void flyTo(
    LatLng target, {
    double zoom = 5.0,
    Duration duration = const Duration(milliseconds: 1500),
    Curve curve = Curves.easeInOutCubic,
  }) {
    _executeWhenReady(() {
      _performAnimation(target, zoom, duration, curve);
    });
  }

  /// Fits all provided points on screen with padding.
  /// 
  /// [points] - List of coordinates to fit
  /// [padding] - Padding around the bounds (default: 50.0)
  /// [maxZoom] - Maximum zoom level to use (default: 16.0)
  void fitAllPoints(
    List<LatLng> points, {
    double padding = 50.0,
    double maxZoom = 16.0,
  }) {
    if (points.isEmpty) {
      debugPrint('Mapcn: fitAllPoints called with empty points list');
      return;
    }
    
    _executeWhenReady(() {
      try {
        final cameraFit = CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: EdgeInsets.all(padding),
          maxZoom: maxZoom,
        );
        final fittedCamera = cameraFit.fit(mapController.camera);
        _performAnimation(
          fittedCamera.center,
          fittedCamera.zoom,
          const Duration(milliseconds: 1500),
          Curves.easeInOutCubic,
        );
      } catch (e) {
        debugPrint('Mapcn: Error in fitAllPoints: $e');
      }
    });
  }

  /// Sequential animated tour through a list of locations.
  /// 
  /// [stops] - List of locations to visit
  /// [zoom] - Zoom level for each stop (default: 10.0)
  /// [stopDuration] - Time to pause at each location (default: 1500ms)
  /// [flyDuration] - Animation duration between stops (default: 2000ms)
  /// [onStopReached] - Callback when arriving at each stop
  Future<void> startTour(
    List<LatLng> stops, {
    double zoom = 10.0,
    Duration stopDuration = const Duration(milliseconds: 1500),
    Duration flyDuration = const Duration(milliseconds: 2000),
    Function(int index, LatLng stop)? onStopReached,
  }) async {
    if (stops.isEmpty) return;
    
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      flyTo(stop, zoom: zoom, duration: flyDuration);
      await Future.delayed(flyDuration + stopDuration);
      onStopReached?.call(i, stop);
    }
  }

  /// Zooms in or out by a relative amount with animation.
  /// 
  /// [delta] - Amount to change zoom (positive = zoom in, negative = zoom out)
  void zoomStep(double delta) {
    _executeWhenReady(() {
      final currentZoom = mapController.camera.zoom;
      final currentCenter = mapController.camera.center;
      _performAnimation(
        currentCenter,
        (currentZoom + delta).clamp(2.0, 18.0),
        const Duration(milliseconds: 400),
        Curves.easeOutCubic,
      );
    });
  }
  
  /// Zooms in by one level.
  void zoomIn() => zoomStep(1.0);
  
  /// Zooms out by one level.
  void zoomOut() => zoomStep(-1.0);
  
  /// Instantly moves the camera without animation.
  /// 
  /// Use this for immediate repositioning. For smooth transitions, use [flyTo].
  void jumpTo(LatLng target, {double? zoom}) {
    _executeWhenReady(() {
      mapController.move(target, zoom ?? mapController.camera.zoom);
    });
  }
  
  /// Rotates the map to a specific angle with animation.
  /// 
  /// [degrees] - Target rotation in degrees
  void rotateTo(double degrees, {Duration duration = const Duration(milliseconds: 500)}) {
    _executeWhenReady(() {
      final controller = AnimationController(vsync: vsync, duration: duration);
      final tween = Tween<double>(
        begin: mapController.camera.rotation,
        end: degrees,
      );
      final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
      
      controller.addListener(() {
        mapController.rotate(tween.evaluate(animation));
      });
      
      controller.forward().then((_) => controller.dispose());
    });
  }
  
  /// Resets rotation to north-up (0 degrees).
  void resetRotation() => rotateTo(0);

  void _performAnimation(LatLng target, double zoom, Duration duration, Curve curve) {
    try {
      final latTween = Tween<double>(
        begin: mapController.camera.center.latitude,
        end: target.latitude,
      );
      final lngTween = Tween<double>(
        begin: mapController.camera.center.longitude,
        end: target.longitude,
      );
      final zoomTween = Tween<double>(
        begin: mapController.camera.zoom,
        end: zoom,
      );

      final controller = AnimationController(vsync: vsync, duration: duration);
      final animation = CurvedAnimation(parent: controller, curve: curve);

      controller.addListener(() {
        try {
          mapController.move(
            LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
            zoomTween.evaluate(animation),
          );
        } catch (e) {
          debugPrint('Mapcn: Animation frame error: $e');
        }
      });

      controller.forward().then((_) => controller.dispose());
    } catch (e) {
      debugPrint('Mapcn: Animation setup error: $e');
    }
  }
  
  /// Disposes internal resources. Call this when done with the controller.
  void dispose() {
    _pendingOperations.clear();
    // MapController is disposed by FlutterMap
  }
}

/// Available map visual styles/themes.
enum MapcnStyle {
  /// Pure black & silver - optimized for dark mode and AMOLED
  dark,
  
  /// Deep midnight blue - elegant and professional
  midnight,
  
  /// Grayscale silver - minimal and clean
  silver,
  
  /// Purple/dark Dracula theme - developer-friendly
  dracula,
  
  /// Deep forest green - nature-inspired
  emerald,
  
  /// Warm sunset tones - cozy and inviting
  sunset,
  
  /// Deep blue ocean - calm and serene
  ocean,
  
  /// Vintage sepia - classic and timeless
  sepia,
  
  /// Maximum contrast - accessibility-focused
  highContrast,
  
  /// Normal OpenStreetMap appearance (no filter)
  normal,
  
  /// Use a custom color matrix via [Mapcn.customMatrix]
  custom,
}