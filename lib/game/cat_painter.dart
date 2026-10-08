import 'package:flutter/painting.dart';

import '../state/catalog.dart';

// Dibuja al gatito con formas, en una caja de 64x56 (0,0 = arriba-izquierda).
// Lo usan dos lugares: el juego (CatSprite) y la tienda (CatPreview), así el
// gatito se ve igual en los dos.
class CatPainter {
  static const _pink = Color(0xFFF48FB1); // nariz, orejas, mejillas
  static const _ink = Color(0xFF3E2723); // ojos, boca, bigotes
  static const _careyOrange = Color(0xFFFF9800);
  static const _careyCream = Color(0xFFFFE0B2);
  static const _white = Color(0xFFFAFAFA);

  static void paint(Canvas canvas, CatSkin skin, CatAccessory? accessory) {
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final isDark = skin.pattern != SkinPattern.plain;

    // Cola (detrás de todo): una curva gruesa a la izquierda
    stroke
      ..color = skin.fur
      ..strokeWidth = 8;
    canvas.drawPath(
      Path()
        ..moveTo(12, 46)
        ..quadraticBezierTo(-10, 46, -4, 26),
      stroke,
    );

    // Orejas: triángulo del color del pelo con otro rosa más chico adentro.
    // En el carey la oreja izquierda es naranja.
    fill.color = skin.pattern == SkinPattern.carey ? _careyOrange : skin.fur;
    canvas.drawPath(_triangle(11, 24, 13, 1, 29, 11), fill);
    fill.color = skin.fur;
    canvas.drawPath(_triangle(53, 24, 51, 1, 35, 11), fill);
    fill.color = _pink;
    canvas.drawPath(_triangle(15, 19, 16, 8, 25, 13), fill);
    canvas.drawPath(_triangle(49, 19, 48, 8, 39, 13), fill);

    // Cabeza
    final head = Rect.fromCircle(center: const Offset(32, 32), radius: 24);
    fill.color = skin.fur;
    canvas.drawOval(head, fill);

    // Manchas del pelaje: se recortan para que no se salgan de la cabeza
    if (skin.pattern != SkinPattern.plain) {
      canvas.save();
      canvas.clipPath(Path()..addOval(head));
      if (skin.pattern == SkinPattern.carey) {
        fill.color = _careyOrange;
        canvas.drawCircle(const Offset(16, 20), 14, fill);
        canvas.drawCircle(const Offset(50, 40), 11, fill);
        fill.color = _careyCream;
        canvas.drawCircle(const Offset(32, 48), 9, fill);
      } else {
        // Tuxedo: negro con el hocico y el pecho blancos
        fill.color = _white;
        canvas.drawOval(Rect.fromCenter(center: const Offset(32, 46), width: 32, height: 26), fill);
      }
      canvas.restore();
    } else {
      // Rayitas en la frente (solo en los pelajes lisos)
      stroke
        ..color = skin.furDark
        ..strokeWidth = 2.5;
      canvas.drawLine(const Offset(27, 11), const Offset(28, 17), stroke);
      canvas.drawLine(const Offset(32, 9), const Offset(32, 17), stroke);
      canvas.drawLine(const Offset(37, 11), const Offset(36, 17), stroke);
    }

    // Mejillas
    fill.color = _pink.withValues(alpha: 0.6);
    canvas.drawCircle(const Offset(16, 40), 4.5, fill);
    canvas.drawCircle(const Offset(48, 40), 4.5, fill);

    // Ojos. En pelajes oscuros son ámbar con pupila, para que se vean.
    if (isDark) {
      for (final x in [23.0, 41.0]) {
        fill.color = const Color(0xFFFFC107);
        canvas.drawOval(Rect.fromCenter(center: Offset(x, 30), width: 10, height: 12), fill);
        fill.color = _ink;
        canvas.drawOval(Rect.fromCenter(center: Offset(x, 30), width: 4, height: 10), fill);
        fill.color = const Color(0xFFFFFFFF);
        canvas.drawCircle(Offset(x + 1.5, 27.5), 1.6, fill);
      }
    } else {
      fill.color = _ink;
      canvas.drawOval(Rect.fromCenter(center: const Offset(23, 30), width: 8, height: 11), fill);
      canvas.drawOval(Rect.fromCenter(center: const Offset(41, 30), width: 8, height: 11), fill);
      fill.color = const Color(0xFFFFFFFF);
      canvas.drawCircle(const Offset(24.5, 27.5), 2, fill);
      canvas.drawCircle(const Offset(42.5, 27.5), 2, fill);
    }

    // Nariz rosa y boquita en "w"
    fill.color = _pink;
    canvas.drawPath(_triangle(29, 36, 35, 36, 32, 40), fill);
    stroke
      ..color = _ink
      ..strokeWidth = 1.6;
    canvas.drawPath(
      Path()
        ..moveTo(32, 40)
        ..quadraticBezierTo(32, 45, 27, 44)
        ..moveTo(32, 40)
        ..quadraticBezierTo(32, 45, 37, 44),
      stroke,
    );

    // Bigotes
    stroke.strokeWidth = 1.2;
    canvas.drawLine(const Offset(14, 38), const Offset(1, 35), stroke);
    canvas.drawLine(const Offset(14, 42), const Offset(1, 44), stroke);
    canvas.drawLine(const Offset(50, 38), const Offset(63, 35), stroke);
    canvas.drawLine(const Offset(50, 42), const Offset(63, 44), stroke);

    // Accesorio (siempre al final, encima de todo)
    switch (accessory) {
      case CatAccessory.bow:
        _paintBow(canvas, fill);
      case CatAccessory.glasses:
        _paintGlasses(canvas, fill, stroke);
      case CatAccessory.crown:
        _paintCrown(canvas, fill);
      case null:
        break;
    }
  }

  // Moño rojo en la oreja izquierda
  static void _paintBow(Canvas canvas, Paint fill) {
    fill.color = const Color(0xFFE53935);
    canvas.drawPath(_triangle(13, 12, 2, 5, 2, 19), fill);
    canvas.drawPath(_triangle(13, 12, 24, 5, 24, 19), fill);
    fill.color = const Color(0xFFB71C1C);
    canvas.drawCircle(const Offset(13, 12), 3.5, fill);
  }

  // Anteojos de sol redondeados
  static void _paintGlasses(Canvas canvas, Paint fill, Paint stroke) {
    fill.color = const Color(0xE6212121);
    for (final x in [23.0, 41.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 30), width: 17, height: 13),
          const Radius.circular(5),
        ),
        fill,
      );
    }
    stroke
      ..color = const Color(0xFF212121)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(31, 29), const Offset(33, 29), stroke); // puente
    canvas.drawLine(const Offset(14, 29), const Offset(9, 27), stroke); // patillas
    canvas.drawLine(const Offset(50, 29), const Offset(55, 27), stroke);
    stroke
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(19, 27), const Offset(22, 25), stroke); // brillito
    canvas.drawLine(const Offset(37, 27), const Offset(40, 25), stroke);
  }

  // Corona dorada entre las orejas
  static void _paintCrown(Canvas canvas, Paint fill) {
    fill.color = const Color(0xFFFFC107);
    canvas.drawPath(
      Path()
        ..moveTo(22, 9)
        ..lineTo(22, -3)
        ..lineTo(27, 3)
        ..lineTo(32, -5)
        ..lineTo(37, 3)
        ..lineTo(42, -3)
        ..lineTo(42, 9)
        ..close(),
      fill,
    );
    fill.color = const Color(0xFFE53935);
    canvas.drawCircle(const Offset(32, 4), 2, fill);
  }

  // Arma un triángulo a partir de sus 3 puntos
  static Path _triangle(double x1, double y1, double x2, double y2, double x3, double y3) {
    return Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2)
      ..lineTo(x3, y3)
      ..close();
  }
}
