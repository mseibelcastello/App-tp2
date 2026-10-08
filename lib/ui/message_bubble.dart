import 'package:material_ui/material_ui.dart';

import '../game/cat_runner_game.dart';
import 'scale.dart';

// El globo con el mensaje del juego. Escucha game.message: si está vacío el
// globo desaparece. Los mensajes "big" (al chocar) son un cartel que ocupa
// aproximadamente el 30% del alto de la pantalla.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.game});

  final CatRunnerGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameMessage>(
      valueListenable: game.message,
      builder: (context, message, _) {
        // AnimatedSwitcher hace un fundido suave cuando cambia el mensaje
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: message.isEmpty
              ? const SizedBox.shrink()
              : KeyedSubtree(
                  key: ValueKey('${message.title}|${message.subtitle}'),
                  child: message.big
                      ? _BigSign(message: message)
                      : _SmallBubble(text: message.title),
                ),
        );
      },
    );
  }
}

// Decoración compartida: tarjeta clara con esquinas redondeadas y sombra suave
BoxDecoration _cardDecoration(BuildContext context, double radius) {
  final colors = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: colors.primary.withValues(alpha: 0.18),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

// Globo chico ("Tocá para empezar", "Pausa")
class _SmallBubble extends StatelessWidget {
  const _SmallBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.85),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 26 * s, vertical: 16 * s),
        decoration: _cardDecoration(context, 30 * s),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28 * s,
            fontWeight: FontWeight.w800, // la letra "gordita" solo para títulos
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

// Cartel grande: 30% del alto de la pantalla
class _BigSign extends StatelessWidget {
  const _BigSign({required this.message});

  final GameMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    final screen = MediaQuery.sizeOf(context);

    return Container(
      width: screen.width * 0.85,
      height: screen.height * 0.30,
      padding: EdgeInsets.all(16 * s),
      decoration: _cardDecoration(context, 36 * s),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_rounded, size: 46 * s, color: colors.primary),
          SizedBox(height: 6 * s),
          // FittedBox: si el título no entra en el ancho, se achica solo
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              message.title,
              style: TextStyle(
                fontSize: 46 * s,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            message.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20 * s,
              height: 1.3,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
