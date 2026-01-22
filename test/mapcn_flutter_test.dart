import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapcn_flutter/mapcn_flutter.dart';




/// Mock HTTP to prevent test crashes during map tile requests
class HttpOverridesMock extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = HttpOverridesMock();
  });

  testWidgets('Mapcn Flutter Package UI Test', (WidgetTester tester) async {
    // 1. Set fixed size to ensure all UI elements are within the viewport
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.runAsync(() async {
      await tester.pumpWidget(const TestApp());

      // 2. Wait for initial load (avoids infinite animation loops)
      await tester.pump(const Duration(seconds: 2));

      // 3. Verify core components
      expect(find.text("MAPCN PRO"), findsOneWidget);
      expect(find.byType(Mapcn), findsOneWidget);

      // 4. Test Theme Switching
      final switchButton = find.text("NEXT THEME");
      expect(switchButton, findsOneWidget);
      
      await tester.tap(switchButton);
      await tester.pump(const Duration(milliseconds: 500));

      debugPrint("Test passed: Mapcn refactored UI rendered and interactive.");
    });

    addTearDown(tester.view.resetPhysicalSize);
  });
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _MapcnTestPageState();
}

class _MapcnTestPageState extends State<TestPage> {
  // Use the new MapcnStyle enum values
  MapcnStyle _currentStyle = MapcnStyle.midnight;
  final List<LatLng> _points = [const LatLng(36.1912, 5.4087)];

  // Logic to cycle through all available new themes
  void _cycleStyle() {
    setState(() {
      const styles = MapcnStyle.values;
      final nextIndex = (_currentStyle.index + 1) % styles.length;
      _currentStyle = styles[nextIndex];
    });
  }

  // Dynamic color selection based on the new themes
  Color get _dynamicAccent {
    switch (_currentStyle) {
      case MapcnStyle.midnight: return Colors.cyanAccent;
      case MapcnStyle.dracula: return Colors.purpleAccent;
      case MapcnStyle.emerald: return Colors.greenAccent;
      case MapcnStyle.silver: return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Updated Mapcn with custom matrix support and new styles
          Mapcn(
            initialCenter: const LatLng(36.19, 5.41),
            style: _currentStyle,
            points: _points,
            accentColor: _dynamicAccent,
          ),

          // Refactored Header: Modern "Pro" appearance
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _dynamicAccent.withValues(alpha:0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MAPCN PRO",
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  Text(
                    "ACTIVE THEME: ${_currentStyle.name.toUpperCase()}",
                    style: TextStyle(color: _dynamicAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Refactored Controls: Toggle through all 5+ styles
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cycleStyle,
                    icon: const Icon(Icons.style_rounded),
                    label: const Text("NEXT THEME"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.large(
                  backgroundColor: _dynamicAccent,
                  onPressed: () {
                    setState(() {
                      _points.add(LatLng(36.20 + (_points.length * 0.01), 5.42));
                    });
                  },
                  child: const Icon(Icons.add_location_sharp, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}