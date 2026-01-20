import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapcn_flutter/mapcn_flutter.dart';
import 'dart:ui';

void main() {
  runApp(const MaterialApp(
    home: MapcnExampleApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MapcnExampleApp extends StatefulWidget {
  const MapcnExampleApp({super.key});

  @override
  State<MapcnExampleApp> createState() => _MapcnExampleAppState();
}

class _MapcnExampleAppState extends State<MapcnExampleApp> with TickerProviderStateMixin {
  MapcnStyle _selectedStyle = MapcnStyle.dark;
  MarkerStyle _selectedMarkerStyle = MarkerStyle.pulse;
  late MapcnController _mapcnController;
  bool _isMapReady = false;
  bool _showRoutes = true;
  RouteStyle _selectedRouteStyle = RouteStyle.solid;

  @override
  void initState() {
    super.initState();
    _mapcnController = MapcnController(vsync: this);
  }

  @override
  void dispose() {
    _mapcnController.dispose();
    super.dispose();
  }

  // Define named locations for the navigator
  final Map<String, LatLng> _locations = {
    "NEW YORK": const LatLng(40.7128, -74.0060),
    "PARIS": const LatLng(48.8566, 2.3522),
    "TOKYO": const LatLng(35.6895, 139.6917),
    "SYDNEY": const LatLng(-33.8688, 151.2093),
    "LONDON": const LatLng(51.5074, -0.1278),
    "DUBAI": const LatLng(25.2048, 55.2708),
  };

  // Define routes between cities
  List<MapcnRoute> get _routes {
    if (!_showRoutes) return [];
    return [
      MapcnRoute(
        id: 'nyc-london',
        points: [
          _locations["NEW YORK"]!,
          const LatLng(52.0, -35.0), // Mid-Atlantic waypoint
          _locations["LONDON"]!,
        ],
        config: RouteConfig(
          color: Colors.cyanAccent,
          width: 3.0,
          style: _selectedRouteStyle,
          showArrows: true,
          showEndpoints: true,
          startColor: Colors.greenAccent,
          endColor: Colors.redAccent,
        ),
      ),
      MapcnRoute(
        id: 'london-dubai',
        points: [
          _locations["LONDON"]!,
          const LatLng(45.0, 20.0), // Europe waypoint
          _locations["DUBAI"]!,
        ],
        config: RouteConfig(
          color: Colors.orangeAccent,
          width: 2.5,
          style: _selectedRouteStyle,
          showArrows: true,
          showEndpoints: true,
        ),
      ),
      MapcnRoute(
        id: 'dubai-tokyo',
        points: [
          _locations["DUBAI"]!,
          const LatLng(30.0, 80.0), // India waypoint
          const LatLng(35.0, 120.0), // China waypoint
          _locations["TOKYO"]!,
        ],
        config: RouteConfig(
          color: Colors.purpleAccent,
          width: 2.5,
          style: _selectedRouteStyle,
          showArrows: true,
          showEndpoints: true,
        ),
      ),
      MapcnRoute(
        id: 'tokyo-sydney',
        points: [
          _locations["TOKYO"]!,
          const LatLng(10.0, 140.0), // Pacific waypoint
          _locations["SYDNEY"]!,
        ],
        config: RouteConfig(
          color: Colors.tealAccent,
          width: 2.5,
          style: _selectedRouteStyle,
          showArrows: true,
          showEndpoints: true,
        ),
      ),
    ];
  }

  Color get _accentColor {
    return switch (_selectedStyle) {
      MapcnStyle.dark       => const Color(0xFF00E676),
      MapcnStyle.midnight   => Colors.cyanAccent,
      MapcnStyle.dracula    => Colors.purpleAccent,
      MapcnStyle.emerald    => Colors.greenAccent,
      MapcnStyle.silver     => Colors.orangeAccent,
      MapcnStyle.sunset     => Colors.amber,
      MapcnStyle.ocean      => Colors.cyan,
      MapcnStyle.sepia      => Colors.deepOrange,
      MapcnStyle.highContrast => Colors.yellow,
      _                     => Colors.blueAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Map Widget
          Positioned.fill(
            child: Mapcn(
              key: ValueKey('$_selectedStyle-$_selectedMarkerStyle-$_showRoutes-$_selectedRouteStyle'),
              controller: _mapcnController,
              initialCenter: const LatLng(20.0, 0.0),
              initialZoom: 2.5,
              style: _selectedStyle,
              points: _locations.values.toList(),
              accentColor: _accentColor,
              routes: _routes,
              markerConfig: MarkerConfig(
                style: _selectedMarkerStyle,
                coreRadius: 6,
                pulseRadius: 35,
                glowIntensity: 0.4,
              ),
              onMapReady: () => setState(() => _isMapReady = true),
              onPointTap: (p) => _mapcnController.flyTo(p, zoom: 12),
            ),
          ),

          // Navigator Panel
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildLocationNavigator(),
            ),
          ),

          // Right Controls Panel
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.3,
            child: _buildRightControls(),
          ),

          // Bottom UI (Legend, Themes & Marker Styles)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegend(),
                  const SizedBox(height: 12),
                  if (_showRoutes) _buildRouteStyleSelector(),
                  if (_showRoutes) const SizedBox(height: 12),
                  _buildMarkerStyleSelector(),
                  const SizedBox(height: 12),
                  _buildThemeSelector(),
                ],
              ),
            ),
          ),
          
          // Map ready indicator
          if (!_isMapReady)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
        ],
      ),
    );
  }

  Widget _buildRightControls() {
    return Column(
      children: [
        // Zoom controls
        _controlBtn(Icons.add, () => _mapcnController.zoomIn()),
        const SizedBox(height: 8),
        _controlBtn(Icons.remove, () => _mapcnController.zoomOut()),
        const SizedBox(height: 16),
        // Toggle routes
        _controlBtn(
          _showRoutes ? Icons.route : Icons.alt_route,
          () => setState(() => _showRoutes = !_showRoutes),
          isActive: _showRoutes,
        ),
        const SizedBox(height: 8),
        // Fit all points
        _controlBtn(Icons.fit_screen, () => _mapcnController.fitAllPoints(_locations.values.toList())),
        const SizedBox(height: 8),
        // Start tour
        _controlBtn(Icons.play_arrow, () => _startGuidedTour()),
        const SizedBox(height: 8),
        // Reset rotation
        _controlBtn(Icons.explore, () => _mapcnController.resetRotation()),
      ],
    );
  }
  
  void _startGuidedTour() {
    _mapcnController.startTour(
      _locations.values.toList(),
      zoom: 8,
      stopDuration: const Duration(seconds: 2),
      onStopReached: (index, stop) {
        debugPrint('Reached stop $index: $stop');
      },
    );
  }

  Widget _controlBtn(IconData icon, VoidCallback tap, {bool isActive = false}) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? _accentColor.withValues(alpha: 0.3) : Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? _accentColor : Colors.white10),
        ),
        child: Icon(icon, color: isActive ? _accentColor : Colors.white, size: 20),
      ),
    );
  }

  Widget _buildLocationNavigator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "LOCATION NAVIGATOR",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              ..._locations.entries.map((entry) => _buildLocationTile(entry.key, entry.value)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile(String name, LatLng coords) {
    return InkWell(
      onTap: () => _mapcnController.flyTo(coords, zoom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: _accentColor, size: 14),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 30, 30).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(_accentColor, "Global Node"),
          _divider(),
          const Icon(Icons.info_outline, color: Colors.white24, size: 12),
          const SizedBox(width: 6),
          const Text("Live Data", style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _divider() => Container(
        height: 12, width: 1, color: Colors.white12,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );

  Widget _buildMarkerStyleSelector() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MarkerStyle.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = MarkerStyle.values[index];
          final isSelected = _selectedMarkerStyle == style;
          return GestureDetector(
            onTap: () => setState(() => _selectedMarkerStyle = style),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? _accentColor.withValues(alpha: 0.3) : Colors.white10,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _accentColor : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                style.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? _accentColor : Colors.white60,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteStyleSelector() {
    final routeStyles = [RouteStyle.solid, RouteStyle.dotted, RouteStyle.dashed];
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: routeStyles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = routeStyles[index];
          final isSelected = _selectedRouteStyle == style;
          return GestureDetector(
            onTap: () => setState(() => _selectedRouteStyle = style),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.cyanAccent.withValues(alpha: 0.3) : Colors.white10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.cyanAccent : Colors.white10,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.route,
                    size: 12,
                    color: isSelected ? Colors.cyanAccent : Colors.white60,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    style.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.cyanAccent : Colors.white60,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: MapcnStyle.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final style = MapcnStyle.values[index];
          if (style == MapcnStyle.custom) return const SizedBox.shrink();
          
          final isSelected = _selectedStyle == style;
          return ChoiceChip(
            label: Text(style.name.toUpperCase()),
            selected: isSelected,
            onSelected: (val) {
              if (val) setState(() => _selectedStyle = style);
            },
            selectedColor: _accentColor,
            backgroundColor: Colors.white10,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}