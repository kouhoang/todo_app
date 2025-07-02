import 'package:flutter/material.dart';
import 'package:hybrid_hex_color_converter/hybrid_hex_color_converter.dart';

class AppColors {
  static final Color primary = HexColor.fromHex('#6366F1');
  static final Color secondary = HexColor.fromHex('#4A3780');
  static final Color background = HexColor.fromHex('#F1F5F9');
  static final Color surface = HexColor.fromHex('#FFFFFF');
  static final Color error = HexColor.fromHex('#EF4444');
  static final Color success = HexColor.fromHex('#10B981');
  static final Color warning = HexColor.fromHex('#F59E0B');
  static final Color boxBackground = Color(0xFFF8F8F8);
  static final Color boxBorder = Color(0xFFE0E0E0);

  // Task Category Colors
  static final Color listCategory = HexColor.fromHex('#3B82F6');
  static final Color calendarCategory = HexColor.fromHex('#8B5CF6');
  static final Color trophyCategory = HexColor.fromHex('#F59E0B');

  // Text Colors
  static final Color textPrimary = HexColor.fromHex('#1F2937');
  static final Color textSecondary = HexColor.fromHex('#6B7280');
  static final Color textTertiary = HexColor.fromHex('#9CA3AF');
}
