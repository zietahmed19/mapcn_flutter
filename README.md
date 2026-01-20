# Mapcn Flutter 🗺️

**[📖 اقرأ بالعربية](README_AR.md)**

A beautiful, customizable dark-themed map widget for Flutter with animated markers, routes, multiple themes, and smooth camera animations. Built on top of `flutter_map` for seamless integration.

![Mapcn](https://pub.dev/packages/mapcn_flutter)

## ✨ Features

- * 11 Built-in Themes** - Dark, Midnight, Dracula, Emerald, Silver, Sunset, Ocean, Sepia, High Contrast, and more
- * 5 Marker Animation Styles** - Pulse, Static, Radar, Ring, and Breathe effects
- * Route Drawing** - Draw routes between points with customizable styles, arrows, and endpoints
- * Smooth Camera Animations** - FlyTo, Guided Tours, Fit All Points with beautiful easing curves
- * Crash-Resistant** - Null-safe, proper error handling, and safe animation disposal
- * Highly Customizable** - Colors, marker sizes, animation speeds, and custom theme matrices
- * Developer Friendly** - Comprehensive API documentation and easy-to-use controller
- * Performance Optimized** - RepaintBoundary, tile caching, and efficient repainting
- * OSM Attribution** - Proper OpenStreetMap license compliance built-in

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  mapcn_flutter: ^1.0.0
  latlong2: ^0.9.0
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:mapcn_flutter/mapcn_flutter.dart';
import 'package:latlong2/latlong.dart';

Mapcn(
  initialCenter: LatLng(51.5074, -0.1278),
  initialZoom: 10,
  style: MapcnStyle.dark,
  points: [
    LatLng(51.5074, -0.1278),
    LatLng(48.8566, 2.3522),
  ],
  accentColor: Color(0xFF00E676),
)
```

### With Controller (Recommended)

```dart
class _MyMapState extends State<MyMap> with TickerProviderStateMixin {
  late final MapcnController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapcnController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Mapcn(
      controller: _controller,
      initialCenter: LatLng(0, 0),
      points: myPoints,
      onMapReady: () => print('Map is ready!'),
      onPointTap: (point) => _controller.flyTo(point, zoom: 12),
    );
  }
}
```

## 🎨 Available Themes

| Theme | Description | Best For |
|-------|-------------|----------|
| `dark` | Pure black & silver | AMOLED screens, dark mode |
| `midnight` | Deep midnight blue | Professional dashboards |
| `silver` | Grayscale monochrome | Minimal designs |
| `dracula` | Purple/dark tones | Developer tools |
| `emerald` | Deep forest green | Nature apps |
| `sunset` | Warm orange/amber | Cozy interfaces |
| `ocean` | Deep blue | Marine apps |
| `sepia` | Vintage paper look | Historical apps |
| `highContrast` | Maximum visibility | Accessibility |
| `normal` | Standard OSM | Light mode |
| `custom` | Your own matrix | Full control |

### Custom Theme Matrix

```dart
Mapcn(
  style: MapcnStyle.custom,
  customMatrix: MapcnThemes.createCustomTheme(
    brightness: -0.1,
    contrast: 1.2,
    saturation: 0.8,
    tint: Colors.blue,
    tintStrength: 0.2,
  ),
)
```

## 🔮 Marker Styles

```dart
Mapcn(
  markerConfig: MarkerConfig(
    style: MarkerStyle.pulse,    // pulse, static, radar, ring, breathe
    coreRadius: 6,
    pulseRadius: 35,
    glowIntensity: 0.4,
    showShadow: true,
  ),
)
```

**Preset Configurations:**
- `MarkerConfig.minimal` - Subtle, small markers
- `MarkerConfig.prominent` - Large, attention-grabbing
- `MarkerConfig.elegant` - Ring-style, refined look

##  Route Drawing

Draw beautiful routes between points with full customization:

```dart
Mapcn(
  initialCenter: LatLng(40.0, -50.0),
  points: [newYork, london, paris],
  routes: [
    MapcnRoute(
      id: 'transatlantic',
      points: [
        LatLng(40.7128, -74.0060),  // New York
        LatLng(52.0, -35.0),         // Mid-Atlantic waypoint
        LatLng(51.5074, -0.1278),    // London
      ],
      config: RouteConfig(
        color: Colors.cyanAccent,
        width: 3.0,
        style: RouteStyle.solid,     // solid, dashed, dotted
        showArrows: true,
        showEndpoints: true,
        startColor: Colors.green,
        endColor: Colors.red,
      ),
    ),
  ],
)
```

### Route Styles

| Style | Description |
|-------|-------------|
| `RouteStyle.solid` | Continuous line |
| `RouteStyle.dashed` | Dashed line pattern |
| `RouteStyle.dotted` | Dotted line pattern |
| `RouteStyle.gradient` | Gradient from start to end |
| `RouteStyle.animated` | Animated route progression |

### RouteConfig Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `color` | `Color` | blue | Route line color |
| `width` | `double` | `3.0` | Line thickness |
| `style` | `RouteStyle` | `solid` | Line pattern style |
| `showArrows` | `bool` | `true` | Show direction arrows |
| `showEndpoints` | `bool` | `true` | Show start/end markers |
| `startColor` | `Color?` | `null` | Start marker color |
| `endColor` | `Color?` | `null` | End marker color |
| `arrowSpacing` | `double` | `100.0` | Distance between arrows |

### Route Utilities

```dart
// Calculate distance between two points
double distance = RouteUtils.calculateDistance(pointA, pointB);

// Get bearing/direction
double bearing = RouteUtils.calculateBearing(pointA, pointB);

// Simplify route for performance
List<LatLng> simplified = RouteUtils.simplifyRoute(points, tolerance: 0.0001);

// Get total route distance
double total = RouteUtils.totalDistance(points);

// Interpolate point along route
LatLng midPoint = RouteUtils.interpolatePoint(start, end, fraction: 0.5);
```

## Controller Methods

```dart
// Animate to location
_controller.flyTo(LatLng(48.8566, 2.3522), zoom: 12);

// Fit all points on screen
_controller.fitAllPoints(myPoints, padding: 50);

// Zoom controls
_controller.zoomIn();
_controller.zoomOut();
_controller.zoomStep(2.0);

// Rotation
_controller.rotateTo(45);
_controller.resetRotation();

// Guided tour through locations
await _controller.startTour(
  [paris, london, tokyo],
  zoom: 10,
  stopDuration: Duration(seconds: 2),
  onStopReached: (index, stop) => print('At stop $index'),
);

// Instant move (no animation)
_controller.jumpTo(LatLng(0, 0), zoom: 5);
```

##  All Widget Options

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `initialCenter` | `LatLng` | **required** | Starting map center |
| `initialZoom` | `double` | `3.0` | Starting zoom level |
| `style` | `MapcnStyle` | `dark` | Visual theme |
| `points` | `List<LatLng>` | `[]` | Marker locations |
| `accentColor` | `Color` | `#00E676` | Marker & UI accent |
| `controller` | `MapcnController?` | `null` | Animation controller |
| `markerConfig` | `MarkerConfig` | `default` | Marker appearance |
| `onPointTap` | `Function(LatLng)?` | `null` | Marker tap callback |
| `onMapReady` | `VoidCallback?` | `null` | Map ready callback |
| `showTooltip` | `bool` | `true` | Show built-in popup |
| `tooltipBuilder` | `Widget Function?` | `null` | Custom popup |
| `showLoadingIndicator` | `bool` | `true` | Show loading spinner |
| `showAttribution` | `bool` | `true` | Show OSM attribution |
| `minZoom` | `double` | `2.0` | Minimum zoom level |
| `maxZoom` | `double` | `18.0` | Maximum zoom level |
| `pulseDuration` | `Duration` | `2s` | Animation cycle time |

##  Error Prevention

The package includes built-in protections:

- Safe controller disposal
-  Animation value clamping
-  Null-safe operations
-  Mount state checking
-  Pending operations queue (operations before map ready)
-  Matrix validation for custom themes
-  Graceful tile loading error handling

##  License

mention me @Ahmed Ziet

##  Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ for the Flutter community Ahmed Ziet 
