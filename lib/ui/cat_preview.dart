import 'package:material_ui/material_ui.dart';

import '../game/cat_painter.dart';
import '../state/catalog.dart';

// El gatito dibujado como un widget común (para la tienda). Usa el mismo
// CatPainter que el juego, así se ve igual.
class CatPreview extends StatelessWidget {
  const CatPreview({
    super.key,
    required this.skin,
    this.accessory,
    this.height = 76,
  });

  final CatSkin skin;
  final CatAccessory? accessory;
  final double height;

  // El gatito mide 64x56; le dejamos margen para la cola y la corona
  static const _boxWidth = 84.0;
  static const _boxHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * _boxWidth / _boxHeight,
      height: height,
      child: FittedBox(
        child: SizedBox(
          width: _boxWidth,
          height: _boxHeight,
          child: CustomPaint(painter: _CatPreviewPainter(skin, accessory)),
        ),
      ),
    );
  }
}

class _CatPreviewPainter extends CustomPainter {
  _CatPreviewPainter(this.skin, this.accessory);

  final CatSkin skin;
  final CatAccessory? accessory;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(16, 14); // centra el gatito dentro de la caja
    CatPainter.paint(canvas, skin, accessory);
  }

  @override
  bool shouldRepaint(_CatPreviewPainter old) =>
      old.skin != skin || old.accessory != accessory;
}
