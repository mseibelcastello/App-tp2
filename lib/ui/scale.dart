import 'package:material_ui/material_ui.dart';

// Factor para que textos y botones se adapten al ancho de la pantalla.
// 1.0 = un celu de 400 px de ancho; en uno más ancho crece (hasta 1.4) y en
// uno más angosto achica un poco (hasta 0.9). Uso: fontSize: 20 * context.ui
extension ScreenScale on BuildContext {
  double get ui => (MediaQuery.sizeOf(this).width / 400).clamp(0.9, 1.4);
}
