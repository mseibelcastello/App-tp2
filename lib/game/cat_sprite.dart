import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../state/catalog.dart';
import 'cat_painter.dart';

// El gatito dentro del juego. Mide 64x56 y su centro es su posición.
// El dibujo en sí está en cat_painter.dart (se comparte con la tienda).
class CatSprite extends PositionComponent {
  CatSprite({
    required super.position,
    this.skin = CatSkin.naranja,
    this.accessory,
  }) : super(size: Vector2(64, 56), anchor: Anchor.center);

  CatSkin skin;
  CatAccessory? accessory;

  void setLook(CatSkin skin, CatAccessory? accessory) {
    this.skin = skin;
    this.accessory = accessory;
  }

  @override
  void render(Canvas canvas) => CatPainter.paint(canvas, skin, accessory);
}
