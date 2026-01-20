import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Visual style options for routes
enum RouteStyle {
  /// Solid continuous line
  solid,
  
  /// Dashed line pattern
  dashed,
  
  /// Dotted line pattern
  dotted,
  
  /// Gradient from start to end color
  gradient,
  
  /// Animated flowing effect
  animated,
}

/// Configuration for route appearance and behavior.
/// 
/// Example:
/// ```dart
/// MapcnRoute(
///   points: [pointA, pointB, pointC],
///   config: RouteConfig(
///     color: Colors.blue,
///     width: 4,
///     style: RouteStyle.solid,
///   ),
/// )
/// ```
class RouteConfig {
  /// The color of the route line
  final Color color;
  
  /// Width of the route line in pixels
  final double width;
  
  /// Visual style of the route
  final RouteStyle style;
  
  /// Whether to show direction arrows along the route
  final bool showArrows;
  
  /// Spacing between arrows (in pixels)
  final double arrowSpacing;
  
  /// Whether to show start/end markers
  final bool showEndpoints;
  
  /// Color for the start marker
  final Color? startColor;
  
  /// Color for the end marker
  final Color? endColor;
  
  /// Whether to apply a glow effect
  final bool showGlow;
  
  /// Glow intensity (0.0 - 1.0)
  final double glowIntensity;
  
  /// Dash pattern for dashed routes [dash, gap, dash, gap...]
  final List<double>? dashPattern;
  
  /// Border/outline color (null = no border)
  final Color? borderColor;
  
  /// Border width
  final double borderWidth;
  
  /// Animation progress for animated routes (0.0 - 1.0)
  /// Set to 1.0 for fully visible, or animate this value
  final double? animationProgress;
  
  /// Whether route is interactive (can be tapped)
  final bool interactive;

  const RouteConfig({
    this.color = const Color(0xFF2196F3),
    this.width = 4.0,
    this.style = RouteStyle.solid,
    this.showArrows = false,
    this.arrowSpacing = 100.0,
    this.showEndpoints = true,
    this.startColor,
    this.endColor,
    this.showGlow = true,
    this.glowIntensity = 0.3,
    this.dashPattern,
    this.borderColor,
    this.borderWidth = 1.5,
    this.animationProgress,
    this.interactive = true,
  });
  
  /// Preset for navigation-style routes
  static const RouteConfig navigation = RouteConfig(
    color: Color(0xFF4285F4),
    width: 5.0,
    style: RouteStyle.solid,
    showArrows: true,
    arrowSpacing: 80,
    showGlow: true,
    glowIntensity: 0.4,
    borderColor: Color(0xFF1A73E8),
  );
  
  /// Preset for subtle/secondary routes
  static const RouteConfig subtle = RouteConfig(
    color: Color(0xFF9E9E9E),
    width: 3.0,
    style: RouteStyle.dashed,
    showArrows: false,
    showGlow: false,
    dashPattern: [8, 4],
  );
  
  /// Preset for walking/hiking routes
  static const RouteConfig walking = RouteConfig(
    color: Color(0xFF4CAF50),
    width: 4.0,
    style: RouteStyle.dotted,
    showArrows: false,
    showEndpoints: true,
    dashPattern: [2, 4],
  );
  
  /// Preset for animated/live tracking routes
  static const RouteConfig liveTracking = RouteConfig(
    color: Color(0xFF00E676),
    width: 4.0,
    style: RouteStyle.gradient,
    showArrows: true,
    arrowSpacing: 60,
    showGlow: true,
    glowIntensity: 0.5,
  );
  
  /// Creates a copy with modified values
  RouteConfig copyWith({
    Color? color,
    double? width,
    RouteStyle? style,
    bool? showArrows,
    double? arrowSpacing,
    bool? showEndpoints,
    Color? startColor,
    Color? endColor,
    bool? showGlow,
    double? glowIntensity,
    List<double>? dashPattern,
    Color? borderColor,
    double? borderWidth,
    double? animationProgress,
    bool? interactive,
  }) {
    return RouteConfig(
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
      showArrows: showArrows ?? this.showArrows,
      arrowSpacing: arrowSpacing ?? this.arrowSpacing,
      showEndpoints: showEndpoints ?? this.showEndpoints,
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
      showGlow: showGlow ?? this.showGlow,
      glowIntensity: glowIntensity ?? this.glowIntensity,
      dashPattern: dashPattern ?? this.dashPattern,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      animationProgress: animationProgress ?? this.animationProgress,
      interactive: interactive ?? this.interactive,
    );
  }
}

/// Represents a single route on the map
class MapcnRoute {
  /// Unique identifier for this route
  final String? id;
  
  /// List of points defining the route path
  final List<LatLng> points;
  
  /// Visual configuration for the route
  final RouteConfig config;
  
  /// Optional label for the route
  final String? label;
  
  /// Callback when route is tapped
  final VoidCallback? onTap;
  
  /// Custom metadata attached to this route
  final Map<String, dynamic>? metadata;

  const MapcnRoute({
    this.id,
    required this.points,
    this.config = const RouteConfig(),
    this.label,
    this.onTap,
    this.metadata,
  });
  
  /// Creates a simple route between two points
  factory MapcnRoute.simple({
    required LatLng start,
    required LatLng end,
    Color color = const Color(0xFF2196F3),
    double width = 4.0,
  }) {
    return MapcnRoute(
      points: [start, end],
      config: RouteConfig(color: color, width: width),
    );
  }
  
  /// Total distance of the route in kilometers
  double get distanceKm {
    if (points.length < 2) return 0;
    
    const distance = Distance();
    double total = 0;
    
    for (int i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Kilometer, points[i], points[i + 1]);
    }
    
    return total;
  }
  
  /// Total distance in meters
  double get distanceMeters => distanceKm * 1000;
  
  /// Total distance in miles
  double get distanceMiles => distanceKm * 0.621371;
  
  /// Formatted distance string (auto-selects unit)
  String get distanceFormatted {
    if (distanceKm < 1) {
      return '${distanceMeters.round()} m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }
  
  /// Estimated walking time (average 5 km/h)
  Duration get walkingTime => Duration(
    minutes: (distanceKm / 5 * 60).round(),
  );
  
  /// Estimated driving time (average 50 km/h)
  Duration get drivingTime => Duration(
    minutes: (distanceKm / 50 * 60).round(),
  );
  
  /// Estimated cycling time (average 15 km/h)
  Duration get cyclingTime => Duration(
    minutes: (distanceKm / 15 * 60).round(),
  );
  
  /// Get the bounding box that contains this route
  LatLngBounds get bounds => LatLngBounds.fromPoints(points);
  
  /// Get the center point of the route
  LatLng get center {
    if (points.isEmpty) return const LatLng(0, 0);
    if (points.length == 1) return points.first;
    
    double latSum = 0, lngSum = 0;
    for (final point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }
  
  /// Start point of the route
  LatLng? get startPoint => points.isNotEmpty ? points.first : null;
  
  /// End point of the route
  LatLng? get endPoint => points.isNotEmpty ? points.last : null;
}

/// Utilities for route calculations and operations
class RouteUtils {
  RouteUtils._();
  
  /// Calculate distance between two points in kilometers
  static double distanceBetween(LatLng a, LatLng b) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, a, b);
  }
  
  /// Calculate bearing (direction) from point A to point B in degrees
  static double bearingBetween(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - 
              math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }
  
  /// Get a point at a specific distance and bearing from a start point
  static LatLng pointAtDistanceAndBearing(
    LatLng start,
    double distanceKm,
    double bearingDegrees,
  ) {
    const earthRadius = 6371.0; // km
    
    final lat1 = start.latitude * math.pi / 180;
    final lng1 = start.longitude * math.pi / 180;
    final bearing = bearingDegrees * math.pi / 180;
    final angularDistance = distanceKm / earthRadius;
    
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angularDistance) +
      math.cos(lat1) * math.sin(angularDistance) * math.cos(bearing)
    );
    
    final lng2 = lng1 + math.atan2(
      math.sin(bearing) * math.sin(angularDistance) * math.cos(lat1),
      math.cos(angularDistance) - math.sin(lat1) * math.sin(lat2)
    );
    
    return LatLng(lat2 * 180 / math.pi, lng2 * 180 / math.pi);
  }
  
  /// Interpolate a point along a route at a given fraction (0.0 - 1.0)
  static LatLng interpolateAlongRoute(List<LatLng> points, double fraction) {
    if (points.isEmpty) return const LatLng(0, 0);
    if (points.length == 1) return points.first;
    if (fraction <= 0) return points.first;
    if (fraction >= 1) return points.last;
    
    // Calculate total distance
    double totalDistance = 0;
    final distances = <double>[];
    for (int i = 0; i < points.length - 1; i++) {
      final d = distanceBetween(points[i], points[i + 1]);
      distances.add(d);
      totalDistance += d;
    }
    
    // Find the segment
    final targetDistance = totalDistance * fraction;
    double accumulated = 0;
    
    for (int i = 0; i < distances.length; i++) {
      if (accumulated + distances[i] >= targetDistance) {
        // Interpolate within this segment
        final segmentFraction = (targetDistance - accumulated) / distances[i];
        final start = points[i];
        final end = points[i + 1];
        
        return LatLng(
          start.latitude + (end.latitude - start.latitude) * segmentFraction,
          start.longitude + (end.longitude - start.longitude) * segmentFraction,
        );
      }
      accumulated += distances[i];
    }
    
    return points.last;
  }
  
  /// Simplify a route by removing points that don't significantly affect the path
  /// Uses the Ramer-Douglas-Peucker algorithm
  static List<LatLng> simplifyRoute(List<LatLng> points, {double tolerance = 0.0001}) {
    if (points.length < 3) return points;
    
    return _rdpSimplify(points, tolerance);
  }
  
  static List<LatLng> _rdpSimplify(List<LatLng> points, double epsilon) {
    if (points.length < 3) return points;
    
    double maxDistance = 0;
    int maxIndex = 0;
    
    final first = points.first;
    final last = points.last;
    
    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], first, last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }
    
    if (maxDistance > epsilon) {
      final left = _rdpSimplify(points.sublist(0, maxIndex + 1), epsilon);
      final right = _rdpSimplify(points.sublist(maxIndex), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [first, last];
    }
  }
  
  static double _perpendicularDistance(LatLng point, LatLng lineStart, LatLng lineEnd) {
    final dx = lineEnd.longitude - lineStart.longitude;
    final dy = lineEnd.latitude - lineStart.latitude;
    
    if (dx == 0 && dy == 0) {
      return distanceBetween(point, lineStart);
    }
    
    final t = ((point.longitude - lineStart.longitude) * dx + 
               (point.latitude - lineStart.latitude) * dy) / (dx * dx + dy * dy);
    
    final nearestLng = lineStart.longitude + t * dx;
    final nearestLat = lineStart.latitude + t * dy;
    
    return distanceBetween(point, LatLng(nearestLat, nearestLng));
  }
  
  /// Check if a point is within a certain distance of a route
  static bool isPointNearRoute(LatLng point, List<LatLng> route, double maxDistanceKm) {
    for (int i = 0; i < route.length - 1; i++) {
      final distance = _perpendicularDistance(point, route[i], route[i + 1]);
      if (distance <= maxDistanceKm) return true;
    }
    return false;
  }
  
  /// Format a duration to a human-readable string
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } else {
      return '${duration.inMinutes} min';
    }
  }
}

/// Painter for route arrows
class RouteArrowPainter extends CustomPainter {
  final Color color;
  final double size;
  final double rotation;
  
  RouteArrowPainter({
    required this.color,
    this.size = 12,
    this.rotation = 0,
  });
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * math.pi / 180);
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = ui.Path()
      ..moveTo(0, -size / 2)
      ..lineTo(size / 2, size / 2)
      ..lineTo(0, size / 4)
      ..lineTo(-size / 2, size / 2)
      ..close();
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(RouteArrowPainter oldDelegate) =>
      color != oldDelegate.color ||
      size != oldDelegate.size ||
      rotation != oldDelegate.rotation;
}

/// Endpoint marker painter (for start/end of routes)
class RouteEndpointPainter extends CustomPainter {
  final Color color;
  final bool isStart;
  final double size;
  
  RouteEndpointPainter({
    required this.color,
    required this.isStart,
    this.size = 16,
  });
  
  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    
    // Outer circle (glow)
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, size * 0.8, glowPaint);
    
    // White background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, size * 0.6, bgPaint);
    
    // Colored ring
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, size * 0.5, ringPaint);
    
    // Inner icon
    if (isStart) {
      // Start: filled circle
      final innerPaint = Paint()..color = color;
      canvas.drawCircle(center, size * 0.25, innerPaint);
    } else {
      // End: flag or checkmark
      final flagPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final path = ui.Path()
        ..moveTo(center.dx - size * 0.15, center.dy - size * 0.3)
        ..lineTo(center.dx + size * 0.3, center.dy)
        ..lineTo(center.dx - size * 0.15, center.dy + size * 0.3)
        ..close();
      
      canvas.drawPath(path, flagPaint);
    }
  }
  
  @override
  bool shouldRepaint(RouteEndpointPainter oldDelegate) =>
      color != oldDelegate.color ||
      isStart != oldDelegate.isStart ||
      size != oldDelegate.size;
}
