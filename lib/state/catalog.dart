import 'package:flutter/painting.dart';

// Cómo se dibuja el pelaje: liso, o con manchas (carey) o con babero (tuxedo)
enum SkinPattern { plain, carey, tuxedo }

// Pelajes del gatito. price 0 = viene gratis; los demás se desbloquean con
// diamantes. Los diamantes NO dan ventajas en el juego: son solo estética.
enum CatSkin {
  naranja('Naranja', 0, Color(0xFFFFA726), Color(0xFFEF8A00), SkinPattern.plain),
  gris('Gris', 0, Color(0xFFB0BEC5), Color(0xFF78909C), SkinPattern.plain),
  crema('Crema', 0, Color(0xFFFFF3E0), Color(0xFFE0C9A6), SkinPattern.plain),
  carey('Carey', 20, Color(0xFF4E342E), Color(0xFF3E2723), SkinPattern.carey),
  tuxedo('Tuxedo', 25, Color(0xFF263238), Color(0xFF1B2327), SkinPattern.tuxedo);

  const CatSkin(this.label, this.price, this.fur, this.furDark, this.pattern);

  final String label;
  final int price;
  final Color fur; // color principal del pelo
  final Color furDark; // rayitas
  final SkinPattern pattern;
}

// Accesorios que se le ponen encima al gatito
enum CatAccessory {
  bow('Moño', 5),
  glasses('Anteojos', 10),
  crown('Corona', 15);

  const CatAccessory(this.label, this.price);

  final String label;
  final int price;
}

// Packs de diamantes de la tienda. La compra es SIMULADA: no se cobra nada.
class DiamondPack {
  const DiamondPack(this.name, this.diamonds, this.price);

  final String name;
  final int diamonds;
  final String price; // texto, solo para mostrar

  static const all = [
    DiamondPack('Puñado', 50, r'$0,99'),
    DiamondPack('Bolsita', 150, r'$2,49'),
    DiamondPack('Cofre', 500, r'$6,99'),
  ];
}
