## 1.1.0

### 🛤️ Route Drawing & Performance Update

#### ✨ New Features

**Route Drawing:**
- Added `MapcnRoute` class for defining routes between points
- Added `RouteConfig` for comprehensive route customization
- Added 5 route styles: `solid`, `dashed`, `dotted`, `gradient`, `animated`
- Added direction arrows on routes
- Added customizable start/end endpoint markers
- Added route animation support with progress control

**Route Utilities (`RouteUtils`):**
- Added `calculateDistance()` - Haversine distance between points
- Added `calculateBearing()` - Direction between points
- Added `simplifyRoute()` - Douglas-Peucker route simplification
- Added `totalDistance()` - Full route length calculation
- Added `interpolatePoint()` - Point interpolation along segment
- Added `interpolateAlongRoute()` - Point at distance along route

**Performance:**
- Added `enableRepaintBoundary` option for isolating map repaints
- Added `enableTileCaching` option for tile load optimization
- Optimized route rendering with configurable arrow spacing
- Improved marker `shouldRepaint` logic

#### 🔧 Improvements

- Routes integrate seamlessly with existing markers and themes
- Route arrows respect map rotation
- Endpoint markers match theme styling
- Updated example app with route showcase
- Updated documentation with route examples

---

## 1.0.0

###  Major Release - Complete Package Overhaul

####  New Features

**Themes:**
- Added 4 new themes: `sunset`, `ocean`, `sepia`, `highContrast`
- Added `MapcnThemes.createCustomTheme()` for easy custom matrix creation
- Added `MapcnThemes.invert()` and `MapcnThemes.combine()` utilities
- Added `MapcnThemes.getRecommendedAccentColor()` for theme-matched accents

**Markers:**
- Added `MarkerConfig` class for comprehensive marker customization
- Added 5 marker animation styles: `pulse`, `static`, `radar`, `ring`, `breathe`
- Added preset configurations: `MarkerConfig.minimal`, `prominent`, `elegant`
- Added shadow support and glow intensity control
- Optimized `shouldRepaint` for better performance

**Controller:**
- Added `isReady` property to check map initialization state
- Added `zoomIn()` and `zoomOut()` convenience methods
- Added `rotateTo()` and `resetRotation()` for map rotation
- Added `jumpTo()` for instant camera moves
- Added `camera`, `center`, `zoom` getters for current state
- Added pending operations queue (safe to call methods before map ready)
- Added `onStopReached` callback for guided tours
- Added customizable `curve` parameter for animations

**Widget:**
- Added `onMapReady` callback
- Added `onCameraMove` callback for camera position updates
- Added `showTooltip` option to disable built-in popup
- Added `tooltipBuilder` for custom marker popups
- Added `showLoadingIndicator` option
- Added `showAttribution` for OSM license compliance
- Added `minZoom` and `maxZoom` constraints
- Added `pulseDuration` for animation speed control

**UI/UX:**
- Enhanced glassmorphism tooltip with animations
- Added scale and fade transitions for popups
- Improved loading indicator appearance
- Added error banner for tile loading failures
- Better theme-matched background colors

#### 🛡️ Crash Prevention

- Added null-safety checks throughout
- Added `mounted` state verification before setState
- Added animation value clamping (0.0 - 1.0)
- Added safe controller disposal
- Added try-catch in animation callbacks
- Added matrix length validation for custom themes
- Added empty list checks for fitAllPoints/startTour


####  Documentation

- Complete README rewrite with examples
- Added API reference tables
- Added theme comparison table
- Added error prevention section

---

## 0.0.1

* Initial release with basic map functionality
