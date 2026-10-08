import 'package:material_ui/material_ui.dart';

import '../state/app_state.dart';
import '../state/catalog.dart';
import 'cat_preview.dart';
import 'payment_screen.dart';
import 'scale.dart';

const _gemColor = Color(0xFF00ACC1);

// Abre la ventana de diamantes (una hoja que sube desde abajo)
Future<void> showDiamondShop(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DiamondShop(state: state),
  );
}

// La ventana de diamantes: saldo, packs para conseguir diamantes (compra
// simulada) y la tienda de pelajes y accesorios para el gatito.
// Los diamantes son solo estética: no dan ventajas en el juego.
class DiamondShop extends StatelessWidget {
  const DiamondShop({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = context.ui;
    final colors = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              // Título y saldo
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Diamantes',
                      style: TextStyle(
                        fontSize: 30 * s,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(22 * s),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond_rounded, size: 24 * s, color: _gemColor),
                        SizedBox(width: 6 * s),
                        Text(
                          '${state.diamonds}',
                          style: TextStyle(fontSize: 24 * s, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4 * s),
              Text(
                'Sirven para vestir a tu gatito. No dan ventajas en el juego.',
                style: TextStyle(fontSize: 15 * s, color: colors.onSurfaceVariant),
              ),

              // --- Conseguir diamantes ---
              _SectionTitle('Conseguir diamantes'),
              Text(
                'Compra simulada: te lleva a una pantalla de pago, pero no se cobra nada.',
                style: TextStyle(fontSize: 14 * s, color: colors.onSurfaceVariant),
              ),
              SizedBox(height: 10 * s),
              for (final pack in DiamondPack.all)
                _PackTile(pack: pack, onBuy: () => _buyPack(context, pack)),

              // --- Pelajes ---
              _SectionTitle('Pelajes'),
              _Grid(
                children: [
                  for (final skin in CatSkin.values)
                    _ItemCard(
                      preview: CatPreview(skin: skin, accessory: state.accessory),
                      name: skin.label,
                      price: skin.price,
                      owned: state.ownedSkins.contains(skin),
                      equipped: state.skin == skin,
                      diamonds: state.diamonds,
                      onBuy: () => state.buySkin(skin),
                      onEquip: () => state.equipSkin(skin),
                    ),
                ],
              ),

              // --- Accesorios ---
              _SectionTitle('Accesorios'),
              _Grid(
                children: [
                  // "Ninguno" para sacar el accesorio puesto
                  _ItemCard(
                    preview: CatPreview(skin: state.skin),
                    name: 'Ninguno',
                    price: 0,
                    owned: true,
                    equipped: state.accessory == null,
                    diamonds: state.diamonds,
                    onBuy: () {},
                    onEquip: () => state.equipAccessory(null),
                  ),
                  for (final acc in CatAccessory.values)
                    _ItemCard(
                      preview: CatPreview(skin: state.skin, accessory: acc),
                      name: acc.label,
                      price: acc.price,
                      owned: state.ownedAccessories.contains(acc),
                      equipped: state.accessory == acc,
                      diamonds: state.diamonds,
                      onBuy: () => state.buyAccessory(acc),
                      onEquip: () => state.equipAccessory(acc),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Compra simulada de un pack: sale a la pantalla de pago y, si el pago se
  // aprueba, suma los diamantes.
  Future<void> _buyPack(BuildContext context, DiamondPack pack) async {
    final approved = await showPayment(
      context,
      product: 'Pack ${pack.name}: ${pack.diamonds} diamantes',
      price: pack.price,
    );
    if (approved) state.addDiamonds(pack.diamonds);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final s = context.ui;
    return Padding(
      padding: EdgeInsets.only(top: 22 * s, bottom: 6 * s),
      child: Text(
        text,
        style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// Una fila de pack: ícono, nombre, cantidad y botón con el precio
class _PackTile extends StatelessWidget {
  const _PackTile({required this.pack, required this.onBuy});

  final DiamondPack pack;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20 * s),
      ),
      child: Row(
        children: [
          Icon(Icons.diamond_rounded, size: 34 * s, color: _gemColor),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.name, style: TextStyle(fontSize: 18 * s, fontWeight: FontWeight.w800)),
                Text(
                  '${pack.diamonds} diamantes',
                  style: TextStyle(fontSize: 15 * s, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onBuy,
            child: Text(pack.price, style: TextStyle(fontSize: 16 * s)),
          ),
        ],
      ),
    );
  }
}

// Dos columnas de tarjetas
class _Grid extends StatelessWidget {
  const _Grid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final c in children) SizedBox(width: width, child: c)],
        );
      },
    );
  }
}

// Tarjeta de un pelaje o accesorio. Según su estado muestra: "Puesto",
// "Usar" (ya lo tenés) o el precio para comprarlo.
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.preview,
    required this.name,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.diamonds,
    required this.onBuy,
    required this.onEquip,
  });

  final Widget preview;
  final String name;
  final int price;
  final bool owned;
  final bool equipped;
  final int diamonds;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    final canAfford = diamonds >= price;

    final Widget action;
    if (equipped) {
      action = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 20 * s, color: colors.primary),
          SizedBox(width: 4 * s),
          Text('Puesto', style: TextStyle(fontSize: 16 * s, color: colors.primary)),
        ],
      );
    } else if (owned) {
      action = SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: onEquip,
          child: Text('Usar', style: TextStyle(fontSize: 16 * s)),
        ),
      );
    } else {
      action = SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: canAfford ? onBuy : null, // sin diamantes suficientes: apagado
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diamond_rounded, size: 18 * s),
              SizedBox(width: 4 * s),
              Text('$price', style: TextStyle(fontSize: 16 * s)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22 * s),
        // Borde de color en el que está puesto
        border: Border.all(
          color: equipped ? colors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          preview,
          SizedBox(height: 6 * s),
          Text(name, style: TextStyle(fontSize: 18 * s, fontWeight: FontWeight.w800)),
          SizedBox(height: 8 * s),
          action,
          if (!owned && !canAfford)
            Padding(
              padding: EdgeInsets.only(top: 4 * s),
              child: Text(
                'Te faltan ${price - diamonds}',
                style: TextStyle(fontSize: 13 * s, color: colors.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
