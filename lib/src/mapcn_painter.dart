import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Configuration for marker appearance and animation.
/// 
/// Use this to customize how markers look and animate on the map.
/// 
/// Example:
/// ```dart
/// MarkerConfig(
///   coreRadius: 8,
///   pulseRadius: 40,
///   glowIntensity: 0.5,
///   style: MarkerStyle.pulse,
/// )
/// ```
class MarkerConfig {
  /// Radius of the solid center dot
  final double coreRadius;
  
  /// Maximum radius of the pulsing animation
  final double pulseRadius;
  
  /// Intensity of the glow effect (0.0 - 1.0)
  final double glowIntensity;
  
  /// Animation style for the marker
  final MarkerStyle style;
  
  /// Whether to show a subtle shadow
  final bool showShadow;
  
  /// Border width for ring-style markers
  final double borderWidth;

  const MarkerConfig({
    this.coreRadius = 6,
    this.pulseRadius = 35,
    this.glowIntensity = 0.4,
    this.style = MarkerStyle.pulse,
    this.showShadow = true,
    this.borderWidth = 2.5,
  });
  
  /// Preset for minimal, subtle markers
  static const MarkerConfig minimal = MarkerConfig(
    coreRadius: 4,
    pulseRadius: 20,
    glowIntensity: 0.2,
    style: MarkerStyle.static,
    showShadow: false,
  );
  
  /// Preset for prominent, attention-grabbing markers
  static const MarkerConfig prominent = MarkerConfig(
    coreRadius: 10,
    pulseRadius: 50,
    glowIntensity: 0.6,
    style: MarkerStyle.radar,
    showShadow: true,
  );
  
  /// Preset for elegant ring-style markers
  static const MarkerConfig elegant = MarkerConfig(
    coreRadius: 5,
    pulseRadius: 30,
    glowIntensity: 0.3,
    style: MarkerStyle.ring,
    showShadow: true,
    borderWidth: 3,
  );
}

/// Defines the animation style for map markers.
enum MarkerStyle {
  /// Classic pulsing animation (default)
  pulse,
  
  /// Static marker with soft glow, no animation
  static,
  
  /// Radar sweep effect
  radar,
  
  /// Ring that expands outward
  ring,
  
  /// Breathing effect (scale up/down)
  breathe,
}

/// A highly customizable painter for map markers with glow effects.
/// 
/// Supports multiple animation styles and is optimized to prevent 
/// unnecessary repaints for better performance.
class MapcnGlowPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final MarkerConfig config;

  MapcnGlowPainter({
    required this.color,
    required this.animationValue,
    this.config = const MarkerConfig(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Prevent crashes from invalid animation values
    final safeAnimValue = animationValue.clamp(0.0, 1.0);
    
    // Draw shadow first (if enabled)
    if (config.showShadow) {
      _drawShadow(canvas, center);
    }
    
    // Draw based on style
    switch (config.style) {
      case MarkerStyle.pulse:
        _drawPulseStyle(canvas, center, safeAnimValue);
        break;
      case MarkerStyle.static:
        _drawStaticStyle(canvas, center);
        break;
      case MarkerStyle.radar:
        _drawRadarStyle(canvas, center, safeAnimValue);
        break;
      case MarkerStyle.ring:
        _drawRingStyle(canvas, center, safeAnimValue);
        break;
      case MarkerStyle.breathe:
        _drawBreatheStyle(canvas, center, safeAnimValue);
        break;
    }
  }
  
  void _drawShadow(Canvas canvas, Offset center) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(1, 2), config.coreRadius + 2, shadowPaint);
  }

  void _drawPulseStyle(Canvas canvas, Offset center, double animValue) {
    // Outer expanding halo
    final outerPaint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * 0.5 * (1 - animValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, config.coreRadius + (config.pulseRadius * animValue), outerPaint);

    // Middle pulse layer
    final middlePaint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * (1 - animValue));
    canvas.drawCircle(center, config.coreRadius + (config.pulseRadius * 0.5 * animValue), middlePaint);

    // Solid core with subtle glow
    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, config.coreRadius, corePaint);
    
    // Bright center highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(center - Offset(config.coreRadius * 0.3, config.coreRadius * 0.3), config.coreRadius * 0.3, highlightPaint);
  }
  
  void _drawStaticStyle(Canvas canvas, Offset center) {
    // Soft outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, config.coreRadius + 8, glowPaint);
    
    // Main core
    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, config.coreRadius, corePaint);
    
    // White border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, config.coreRadius, borderPaint);
  }
  
  void _drawRadarStyle(Canvas canvas, Offset center, double animValue) {
    // Radar sweep arc
    final sweepPaint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * (1 - animValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final sweepAngle = math.pi / 3; // 60 degrees
    final startAngle = animValue * 2 * math.pi - sweepAngle / 2;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: config.pulseRadius * 0.7),
      startAngle,
      sweepAngle,
      false,
      sweepPaint,
    );
    
    // Concentric circles
    for (int i = 1; i <= 3; i++) {
      final ringPaint = Paint()
        ..color = color.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, config.pulseRadius * 0.25 * i, ringPaint);
    }
    
    // Core dot
    final corePaint = Paint()..color = color;
    canvas.drawCircle(center, config.coreRadius * 0.8, corePaint);
  }
  
  void _drawRingStyle(Canvas canvas, Offset center, double animValue) {
    // Expanding ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * (1 - animValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.borderWidth * (1 - animValue * 0.5);
    canvas.drawCircle(center, config.coreRadius + (config.pulseRadius * animValue), ringPaint);
    
    // Second ring (offset timing)
    final ring2Anim = (animValue + 0.5) % 1.0;
    final ring2Paint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * (1 - ring2Anim) * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.borderWidth * (1 - ring2Anim * 0.5);
    canvas.drawCircle(center, config.coreRadius + (config.pulseRadius * ring2Anim), ring2Paint);
    
    // Core with white center
    final corePaint = Paint()..color = color;
    canvas.drawCircle(center, config.coreRadius, corePaint);
    
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, config.coreRadius * 0.4, innerPaint);
  }
  
  void _drawBreatheStyle(Canvas canvas, Offset center, double animValue) {
    // Smooth breathing using sine wave
    final breatheValue = (math.sin(animValue * 2 * math.pi) + 1) / 2;
    final currentRadius = config.coreRadius + (config.coreRadius * 0.4 * breatheValue);
    
    // Outer glow that follows breathing
    final glowPaint = Paint()
      ..color = color.withValues(alpha: config.glowIntensity * 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + (4 * breatheValue));
    canvas.drawCircle(center, currentRadius + 4, glowPaint);
    
    // Main circle
    final corePaint = Paint()..color = color;
    canvas.drawCircle(center, currentRadius, corePaint);
    
    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 + (0.2 * breatheValue));
    canvas.drawCircle(
      center - Offset(currentRadius * 0.2, currentRadius * 0.2), 
      currentRadius * 0.25, 
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(MapcnGlowPainter oldDelegate) {
    // Optimize: only repaint when values actually change
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.color != color ||
           oldDelegate.config != config;
  }
}

/// A simple loading indicator painter for tile loading states.
class MapcnLoadingPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  MapcnLoadingPainter({
    required this.animationValue,
    this.color = Colors.white54,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.15;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Draw spinning arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      animationValue * 2 * math.pi,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(MapcnLoadingPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}