import 'package:flutter/material.dart';

/// App Colors - Preview Basket Brand Colors
/// 🎨 نظام الألوان المستخدم في شعار Preview Basket
class AppColors {
  // 🟠 Primary Colors - برتقالي نابض (Vibrant Orange)
  // اللون الأساسي: برتقالي قوي وحيوي يعطي إحساس بالحركة والطاقة
  static const Color primary = Color(0xFFFF7A00); // #FF7A00 - Primary Orange
  static const Color primaryDark = Color(0xFFE65C00); // Darker shade for depth
  static const Color primaryLight = Color(0xFFFF8C1A); // Lighter shade for highlights
  
  // ⚫ Secondary Colors - أسود عميق (Deep Black)
  // اللون الثانوي: أسود غني يعطي فخامة وقوة وتباين عالي
  static const Color secondary = Color(0xFF111111); // #111111 - Deep Black
  static const Color secondaryDark = Color(0xFF000000); // Pure black for emphasis
  static const Color secondaryLight = Color(0xFF2C2C2C); // Lighter black for variants
  
  // Background Colors - Light Theme
  static const Color background = Color(0xFFFAFAFA); // Soft white background
  static const Color surface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light grey variant
  
  // Background Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF111111); // Deep black background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color surfaceVariantDark = Color(0xFF2C2C2C); // Lighter dark variant
  
  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF111111); // Deep black for text
  static const Color textSecondary = Color(0xFF666666); // Grey for secondary text
  static const Color textHint = Color(0xFF999999); // Light grey for hints
  static const Color divider = Color(0xFFE0E0E0); // Divider lines
  
  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure white for text
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Light grey for secondary
  static const Color textHintDark = Color(0xFF757575); // Darker grey for hints
  static const Color dividerDark = Color(0xFF2C2C2C); // Dark divider
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green for success
  static const Color warning = Color(0xFFFF9800); // Amber for warnings
  static const Color error = Color(0xFFF44336); // Red for errors
  static const Color info = Color(0xFFFF7A00); // Orange for info (brand color)
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);
  
  // 🎨 Gradient Colors - تدرجات احترافية
  // تدرج برتقالي للعمق واللمسة الاحترافية
  static const List<Color> primaryGradient = [
    Color(0xFFFF8C1A), // Light orange
    Color(0xFFE65C00), // Dark orange
  ];
  
  // تدرج أسود للخلفيات الفخمة
  static const List<Color> secondaryGradient = [
    Color(0xFF111111), // Deep black
    Color(0xFF2C2C2C), // Lighter black
  ];
  
  // تدرج برتقالي ناعم للأزرار
  static const List<Color> buttonGradient = [
    Color(0xFFFF7A00), // Primary orange
    Color(0xFFFF8C1A), // Light orange
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFD32F2F),
  ];
  
  // Shimmer Colors - للتحميل والانتظار
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
  
  // 🎨 Brand Accent Colors - ألوان مساعدة للعلامة التجارية
  static const Color accent = Color(0xFFFF7A00); // Same as primary for consistency
  static const Color accentLight = Color(0xFFFFB366); // Very light orange
  static const Color accentDark = Color(0xFFCC6200); // Very dark orange
  
  // Card & Container Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color cardBorderDark = Color(0xFF2C2C2C);
  
  // 💡 الإحساس العام للهوية
  // - عصرية
  // - ديناميكية
  // - تجارية
  // - قوية بصرياً
  // - مناسبة لمنصة تسوق أو تطبيق تجارة إلكترونية
}
