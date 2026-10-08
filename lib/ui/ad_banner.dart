import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../state/app_state.dart';
import 'scale.dart';

// Un anuncio de mentira (simula la monetización). Todos son de cosas de
// gatitos, con marcas inventadas.
class _Ad {
  const _Ad(this.title, this.text, this.icon, this.color);

  final String title;
  final String text;
  final IconData icon;
  final Color color;
}

const _ads = [
  _Ad('Croquetas Michi', 'Premios crocantes para tu gato', Icons.set_meal_rounded, Color(0xFFFFB74D)),
  _Ad('Cuentos con bigotes', 'Gatos aventureros para leer', Icons.menu_book_rounded, Color(0xFF81C784)),
  _Ad('Peluches Pelusa', 'Compañeros suaves para dormir', Icons.toys_rounded, Color(0xFF64B5F6)),
  _Ad('Adopción responsable', 'Un michi te está esperando', Icons.pets_rounded, Color(0xFFBA68C8)),
];

// Banner de anuncios que va abajo de la pantalla. Cambia de anuncio cada 6
// segundos. Con la cuenta PRO no se muestra.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key, required this.appState});

  final AppState appState;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() => _index = (_index + 1) % _ads.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Tocar el anuncio: avisa que es simulado
  void _onTap() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Anuncio simulado', style: TextStyle(fontSize: 24 * context.ui)),
        content: Text(
          'En una app real, esto abriría la página del anunciante.\n'
          'Con la cuenta PRO no ves anuncios.',
          style: TextStyle(fontSize: 17 * context.ui, height: 1.4),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        if (widget.appState.accountType == AccountType.pro) {
          return const SizedBox.shrink(); // PRO: sin anuncios
        }
        return _buildBanner(context);
      },
    );
  }

  Widget _buildBanner(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    final ad = _ads[_index];

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 6 * s, 12, 8 * s),
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18 * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _onTap,
          // Fundido suave al cambiar de anuncio
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(_index),
              height: 64 * s,
              padding: EdgeInsets.symmetric(horizontal: 10 * s),
              child: Row(
                children: [
                  Container(
                    width: 46 * s,
                    height: 46 * s,
                    decoration: BoxDecoration(
                      color: ad.color,
                      borderRadius: BorderRadius.circular(14 * s),
                    ),
                    child: Icon(ad.icon, size: 28 * s, color: Colors.white),
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Etiqueta que marca que es un anuncio
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 1),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.outline),
                                borderRadius: BorderRadius.circular(6 * s),
                              ),
                              child: Text(
                                'Anuncio',
                                style: TextStyle(fontSize: 10 * s, color: colors.onSurfaceVariant),
                              ),
                            ),
                            SizedBox(width: 6 * s),
                            Flexible(
                              child: Text(
                                ad.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          ad.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13 * s, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: _onTap,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 14 * s),
                      minimumSize: Size(0, 36 * s),
                    ),
                    child: Text('Ver', style: TextStyle(fontSize: 15 * s)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
