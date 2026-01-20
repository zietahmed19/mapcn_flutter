import 'package:flutter/material.dart';

/// Pre-built color matrix themes for map styling.
/// 
/// These matrices are used with [ColorFilter.matrix] to transform the
/// visual appearance of map tiles.
/// 
/// Example usage:
/// ```dart
/// Mapcn(
///   style: MapcnStyle.midnight,
///   // or use custom matrix:
///   customMatrix: MapcnThemes.createCustomTheme(
///     brightness: -0.2,
///     contrast: 1.1,
///     tint: Colors.blue,
///   ),
/// )
/// ```
class MapcnThemes {
  // Prevent instantiation
  MapcnThemes._();

  /// Deep Midnight Blue Theme - Elegant dark blue appearance
  /// Best for: Night mode, professional dashboards
  static const List<double> midnight = <double>[
    -1.0, 0.0, 0.0, 0.0, 255.0,
    0.0, -1.0, 0.0, 0.0, 255.0,
    0.0, 0.0, -1.0, 0.0, 255.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  /// Grayscale / Silver Theme - Clean monochrome look
  /// Best for: Minimal designs, data visualization overlays
  static const List<double> silver = <double>[
    0.21, 0.72, 0.07, 0, 0,
    0.21, 0.72, 0.07, 0, 0,
    0.21, 0.72, 0.07, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// Dracula Theme - Purple/Dark with vibrant accents
  /// Best for: Developer tools, code-focused apps
  static const List<double> dracula = <double>[
    0.5, 0, 0, 0, 30, 
    0, 0.3, 0, 0, 10, 
    0, 0, 0.9, 0, 40, 
    0, 0, 0, 1, 0,
  ];

  /// Emerald Theme - Deep forest green
  /// Best for: Nature apps, environmental dashboards
  static const List<double> emerald = <double>[
    0.1, 0, 0, 0, 5,
    0, 0.5, 0, 0, 15,
    0, 0, 0.2, 0, 10,
    0, 0, 0, 1, 0,
  ];

  /// MapCN Dark Theme - Pure black & silver grayscale inversion
  /// Best for: High contrast dark mode, AMOLED screens
  static const List<double> mapcnDark = <double>[
    -0.33, -0.33, -0.33, 0.0, 255.0,
    -0.33, -0.33, -0.33, 0.0, 255.0,
    -0.33, -0.33, -0.33, 0.0, 255.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];
  
  /// Sunset Theme - Warm orange/amber tones
  /// Best for: Cozy interfaces, travel apps
  static const List<double> sunset = <double>[
    1.2, 0.1, 0.0, 0.0, 20.0,
    0.1, 0.6, 0.0, 0.0, 10.0,
    0.0, 0.0, 0.4, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];
  
  /// Ocean Theme - Deep blue underwater feel
  /// Best for: Marine apps, calm interfaces
  static const List<double> ocean = <double>[
    0.2, 0.1, 0.1, 0.0, 0.0,
    0.1, 0.5, 0.2, 0.0, 20.0,
    0.1, 0.2, 1.0, 0.0, 40.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];
  
  /// Sepia Theme - Vintage paper look
  /// Best for: Historical apps, classic design
  static const List<double> sepia = <double>[
    0.393, 0.769, 0.189, 0, 0,
    0.349, 0.686, 0.168, 0, 0,
    0.272, 0.534, 0.131, 0, 0,
    0, 0, 0, 1, 0,
  ];
  
  /// High Contrast Theme - Maximum visibility
  /// Best for: Accessibility, bright environments
  static const List<double> highContrast = <double>[
    2.0, -0.5, -0.5, 0.0, -128.0,
    -0.5, 2.0, -0.5, 0.0, -128.0,
    -0.5, -0.5, 2.0, 0.0, -128.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];

  /// Identity matrix - no color transformation (normal map)
  static const List<double> identity = <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// Creates a custom theme matrix with adjustable parameters.
  /// 
  /// [brightness] - Adjusts overall brightness (-1.0 to 1.0)
  /// [contrast] - Adjusts contrast (0.0 to 2.0, 1.0 is normal)
  /// [saturation] - Adjusts color saturation (0.0 to 2.0, 1.0 is normal)
  /// [tint] - Optional color tint overlay
  /// [tintStrength] - How strong the tint should be (0.0 to 1.0)
  /// 
  /// Example:
  /// ```dart
  /// final customTheme = MapcnThemes.createCustomTheme(
  ///   brightness: -0.1,
  ///   contrast: 1.2,
  ///   saturation: 0.8,
  ///   tint: Colors.blue,
  ///   tintStrength: 0.2,
  /// );
  /// ```
  static List<double> createCustomTheme({
    double brightness = 0.0,
    double contrast = 1.0,
    double saturation = 1.0,
    Color? tint,
    double tintStrength = 0.3,
  }) {
    // Clamp values to safe ranges
    brightness = brightness.clamp(-1.0, 1.0);
    contrast = contrast.clamp(0.0, 2.0);
    saturation = saturation.clamp(0.0, 2.0);
    tintStrength = tintStrength.clamp(0.0, 1.0);
    
    // Brightness offset (convert -1..1 to -255..255)
    final double b = brightness * 255;
    
    // Contrast matrix adjustment
    final double c = contrast;
    final double t = (1.0 - c) / 2.0 * 255;
    
    // Saturation weights (standard luminance coefficients)
    const double lumR = 0.2126;
    const double lumG = 0.7152;
    const double lumB = 0.0722;
    
    final double sr = (1 - saturation) * lumR;
    final double sg = (1 - saturation) * lumG;
    final double sb = (1 - saturation) * lumB;
    
    // Build the combined matrix
    List<double> matrix = [
      (sr + saturation) * c, sg * c, sb * c, 0, t + b,
      sr * c, (sg + saturation) * c, sb * c, 0, t + b,
      sr * c, sg * c, (sb + saturation) * c, 0, t + b,
      0, 0, 0, 1, 0,
    ];
    
    // Apply tint if provided
    if (tint != null) {
      final double tr = tint.r * tintStrength;
      final double tg = tint.g * tintStrength;
      final double tb = tint.b * tintStrength;
      final double inv = 1.0 - tintStrength;
      
      matrix = [
        matrix[0] * inv + tr, matrix[1] * inv, matrix[2] * inv, 0, matrix[4],
        matrix[5] * inv, matrix[6] * inv + tg, matrix[7] * inv, 0, matrix[9],
        matrix[10] * inv, matrix[11] * inv, matrix[12] * inv + tb, 0, matrix[14],
        0, 0, 0, 1, 0,
      ];
    }
    
    return matrix;
  }
  
  /// Inverts the colors of a theme matrix.
  /// 
  /// Useful for creating a "negative" version of any theme.
  static List<double> invert(List<double> matrix) {
    if (matrix.length != 20) return mapcnDark;
    
    const List<double> invertMatrix = [
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ];
    
    return _multiplyMatrices(matrix, invertMatrix);
  }
  
  /// Combines two theme matrices.
  /// 
  /// Apply [second] transformation after [first].
  static List<double> combine(List<double> first, List<double> second) {
    if (first.length != 20 || second.length != 20) return identity;
    return _multiplyMatrices(first, second);
  }
  
  /// Internal matrix multiplication for 5x4 color matrices.
  static List<double> _multiplyMatrices(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0);
    
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        double sum = 0;
        for (int k = 0; k < 4; k++) {
          sum += a[i * 5 + k] * b[k * 5 + j];
        }
        if (j == 4) {
          sum += a[i * 5 + 4];
        }
        result[i * 5 + j] = sum;
      }
    }
    
    return result;
  }
  
  /// Returns recommended accent colors for each built-in theme.
  /// 
  /// These colors are optimized for visibility against each theme.
  static Color getRecommendedAccentColor(MapcnStyleExtended style) {
    switch (style) {
      case MapcnStyleExtended.midnight:
        return const Color(0xFF64B5F6); // Light blue
      case MapcnStyleExtended.silver:
        return const Color(0xFFE91E63); // Pink
      case MapcnStyleExtended.dracula:
        return const Color(0xFFBD93F9); // Purple
      case MapcnStyleExtended.emerald:
        return const Color(0xFF00E676); // Green
      case MapcnStyleExtended.dark:
        return const Color(0xFF00E676); // Bright green
      case MapcnStyleExtended.sunset:
        return const Color(0xFFFFD54F); // Amber
      case MapcnStyleExtended.ocean:
        return const Color(0xFF26C6DA); // Cyan
      case MapcnStyleExtended.sepia:
        return const Color(0xFFD84315); // Deep orange
      case MapcnStyleExtended.highContrast:
        return const Color(0xFFFFEB3B); // Yellow
      case MapcnStyleExtended.normal:
        return const Color(0xFFF44336); // Red
      case MapcnStyleExtended.custom:
        return const Color(0xFF00E676); // Default green
    }
  }
}

/// Extended style enum with all available themes.
enum MapcnStyleExtended {
  midnight,
  silver,
  dracula,
  emerald,
  dark,
  sunset,
  ocean,
  sepia,
  highContrast,
  normal,
  custom,
}