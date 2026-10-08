import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

// Un rascador de gatos: poste forrado en cuerda con una tapa y una huellita.
// Es el obstáculo del juego. Su rectángulo (position + size) es también su
// zona de choque.
class ScratchPost extends PositionComponent {
  // capAtBottom = true: el poste cuelga del techo y la tapa queda abajo.
  // capAtBottom = false: el poste sale del suelo y la tapa queda arriba.
  ScratchPost({
    required this.capAtBottom,
    required super.position,
    required super.size,
  });

  final bool capAtBottom;

  static const _rope = Color(0xFFE0C097);
  static const _ropeDark = Color(0xFFC9A66B);
  static const _cap = Color(0xFF8D6E63);
  static const _capLight = Color(0xFFA1887F);
  static const _capHeight = 22.0;

  @override
  void render(Canvas canvas) {
    final fill = Paint()..style = PaintingStyle.fill;

    // Cuerpo de cuerda
    fill.color = _rope;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), fill);

    // Vueltas de cuerda: rayitas horizontales
    final line = Paint()
      ..color = _ropeDark
      ..strokeWidth = 2;
    for (double y = 8; y < height; y += 12) {
      canvas.drawLine(Offset(0, y), Offset(width, y), line);
    }

    // Huellita de patita en el medio (solo si el poste es lo bastante largo)
    if (height > 110) {
      _drawPaw(canvas, Offset(width / 2, height / 2));
    }

    // Tapa del extremo que mira al hueco
    final capTop = capAtBottom ? height - _capHeight : 0.0;
    final capRect = Rect.fromLTWH(0, capTop, width, _capHeight);
    fill.color = _cap;
    canvas.drawRRect(RRect.fromRectAndRadius(capRect, const Radius.circular(8)), fill);
    fill.color = _capLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, capTop + 4, width - 12, 5),
        const Radius.circular(3),
      ),
      fill,
    );
  }

  // Huella: una almohadilla grande y cuatro deditos
  void _drawPaw(Canvas canvas, Offset c) {
    final paw = Paint()..color = _ropeDark;
    canvas.drawCircle(c + const Offset(0, 6), 9, paw);
    canvas.drawCircle(c + const Offset(-12, -6), 4.5, paw);
    canvas.drawCircle(c + const Offset(-4, -12), 4.5, paw);
    canvas.drawCircle(c + const Offset(4, -12), 4.5, paw);
    canvas.drawCircle(c + const Offset(12, -6), 4.5, paw);
  }
}
