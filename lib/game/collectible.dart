import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

// Los tres objetos que el gatito puede recolectar
enum CollectibleType {
  fish, // pescado: +3 puntos
  yarn, // ovillo de lana: +10 puntos
  diamond, // diamante con huellita: +1 diamante (para la tienda)
}

// Un objeto flotando en el hueco entre los rascadores. Se dibuja con formas
// en una caja de 40x40 y se mece suavemente hacia arriba y abajo.
class Collectible extends PositionComponent {
  Collectible({required this.type, required Vector2 position})
      : _baseY = position.y,
        super(position: position, size: Vector2.all(40), anchor: Anchor.center);

  final CollectibleType type;
  final double _baseY; // altura "de reposo" alrededor de la que se mece
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    y = _baseY + sin(_time * 4) * 4;
  }

  @override
  void render(Canvas canvas) {
    switch (type) {
      case CollectibleType.fish:
        _paintFish(canvas);
      case CollectibleType.yarn:
        _paintYarn(canvas);
      case CollectibleType.diamond:
        _paintDiamond(canvas);
    }
  }

  // Pescadito de costado: cuerpo ovalado, cola triangular, ojo y rayas
  void _paintFish(Canvas canvas) {
    final fill = Paint()..style = PaintingStyle.fill;
    fill.color = const Color(0xFF26A69A);
    canvas.drawPath(
      Path()
        ..moveTo(30, 20)
        ..lineTo(40, 9)
        ..lineTo(40, 31)
        ..close(),
      fill,
    );
    canvas.drawOval(const Rect.fromLTWH(2, 10, 31, 20), fill);
    fill.color = const Color(0xFF80CBC4);
    canvas.drawOval(const Rect.fromLTWH(6, 19, 22, 8), fill); // pancita
    final stripe = Paint()
      ..color = const Color(0xFF00796B)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(18, 13), const Offset(18, 18), stripe);
    canvas.drawLine(const Offset(23, 13), const Offset(23, 18), stripe);
    fill.color = const Color(0xFF3E2723);
    canvas.drawCircle(const Offset(10, 17), 2.2, fill); // ojo
  }

  // Ovillo de lana: círculo con vueltas de hilo y una hebra suelta
  void _paintYarn(Canvas canvas) {
    final fill = Paint()..color = const Color(0xFF9575CD);
    canvas.drawCircle(const Offset(20, 20), 15, fill);
    final thread = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2
      ..color = const Color(0xFFD1C4E9);
    canvas.drawArc(const Rect.fromLTWH(7, 7, 26, 26), 0.3, 2.2, false, thread);
    canvas.drawArc(const Rect.fromLTWH(10, 5, 22, 30), 2.4, 2.4, false, thread);
    canvas.drawArc(const Rect.fromLTWH(5, 11, 30, 20), 4.6, 1.8, false, thread);
    // Hebra suelta
    thread.color = const Color(0xFF9575CD);
    thread.strokeWidth = 2.5;
    canvas.drawPath(
      Path()
        ..moveTo(31, 31)
        ..quadraticBezierTo(38, 33, 36, 39),
      thread,
    );
  }

  // Diamante: gema celeste con facetas y una huellita de patita
  void _paintDiamond(Canvas canvas) {
    final fill = Paint()..color = const Color(0xFF26C6DA);
    final gem = Path()
      ..moveTo(20, 3)
      ..lineTo(35, 14)
      ..lineTo(20, 37)
      ..lineTo(5, 14)
      ..close();
    canvas.drawPath(gem, fill);
    // Faceta de arriba, más clara
    fill.color = const Color(0x66FFFFFF);
    canvas.drawPath(
      Path()
        ..moveTo(20, 3)
        ..lineTo(28, 14)
        ..lineTo(12, 14)
        ..close(),
      fill,
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x99FFFFFF);
    canvas.drawLine(const Offset(5, 14), const Offset(35, 14), edge);
    canvas.drawLine(const Offset(12, 14), const Offset(20, 37), edge);
    canvas.drawLine(const Offset(28, 14), const Offset(20, 37), edge);
    canvas.drawPath(gem, edge..color = const Color(0xFF00838F));
    // Huellita de patita
    fill.color = const Color(0xCCFFFFFF);
    canvas.drawCircle(const Offset(20, 24), 3.2, fill);
    canvas.drawCircle(const Offset(15.5, 20.5), 1.5, fill);
    canvas.drawCircle(const Offset(20, 18.5), 1.5, fill);
    canvas.drawCircle(const Offset(24.5, 20.5), 1.5, fill);
  }
}
