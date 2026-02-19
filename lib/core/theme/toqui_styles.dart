import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class ToquiStyles {
  static final container = Style(
    $box.padding(16),
    $box.margin.vertical(8),
    $box.margin.horizontal(16),
    $box.borderRadius(20),
    $box.color(const Color(0xFFF8F9FE)),
    $box.shadow.color(Colors.black.withAlpha(20)),
    $box.shadow.blurRadius(10),
    $box.shadow.offset(0, 4),
  );

  static final titleText = Style(
    $text.style.fontWeight.bold(),
    $text.style.fontSize(18),
    $text.style.color(Colors.black87),
  );

  static final tagTcp = Style(
    $box.padding.horizontal(8),
    $box.padding.vertical(4),
    $box.borderRadius(8),
    $box.color(Colors.blue.withAlpha(30)),
    $text.style.color(Colors.blue),
    $text.style.fontSize(12),
    $text.style.fontWeight.bold(),
  );

  static final connectButton = Style(
    $box.width(double.infinity),
    $box.padding(12),
    $box.borderRadius(12),
    $box.color(Colors.blue),
    $text.style.color(Colors.white),
    $text.style.fontWeight.bold(),
    $box.alignment.center(),
  );
}
