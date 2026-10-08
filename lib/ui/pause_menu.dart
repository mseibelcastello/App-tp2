import 'package:material_ui/material_ui.dart';

import 'scale.dart';

// Lo que puede elegir el jugador en la ventanita de pausa
enum PauseAction { resume, restart, newGame, shop, ranking, menu }

// La ventanita emergente de pausa. Devuelve lo que se eligió, o null si se
// cerró tocando afuera (lo tratamos como "continuar").
//  - canRestart: false si no hay partida para reiniciar
//  - restartCostsLife: true si reiniciar en este momento cuesta una vida
Future<PauseAction?> showPauseMenu(
  BuildContext context, {
  required bool canRestart,
  required bool restartCostsLife,
}) {
  return showDialog<PauseAction>(
    context: context,
    builder: (context) {
      final s = context.ui;
      final colors = Theme.of(context).colorScheme;

      void choose(PauseAction action) => Navigator.pop(context, action);

      return AlertDialog(
        title: Text(
          'Pausa',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32 * s,
            fontWeight: FontWeight.w800,
            color: colors.primary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuButton(
                icon: Icons.play_arrow_rounded,
                label: 'Continuar',
                primary: true,
                onPressed: () => choose(PauseAction.resume),
              ),
              _MenuButton(
                icon: Icons.replay_rounded,
                label: 'Reiniciar',
                caption: restartCostsLife ? 'Cuesta una vida' : null,
                onPressed: canRestart ? () => choose(PauseAction.restart) : null,
              ),
              _MenuButton(
                icon: Icons.add_circle_rounded,
                label: 'Nueva partida',
                onPressed: () => choose(PauseAction.newGame),
              ),
              _MenuButton(
                icon: Icons.diamond_rounded,
                label: 'Tienda',
                onPressed: () => choose(PauseAction.shop),
              ),
              _MenuButton(
                icon: Icons.emoji_events_rounded,
                label: 'Mis puntajes',
                onPressed: () => choose(PauseAction.ranking),
              ),
              _MenuButton(
                icon: Icons.home_rounded,
                label: 'Menú principal',
                onPressed: () => choose(PauseAction.menu),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// NUEVA PARTIDA pide confirmación porque descarta todo el progreso.
// Devuelve true si el jugador confirmó.
Future<bool> confirmNewGame(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('¿Nueva partida?', style: TextStyle(fontSize: 26 * context.ui)),
      content: Text(
        'Empezás de cero:\n'
        '• Recuperás las 3 vidas\n'
        '• El score vuelve a 0\n'
        '• Tus diamantes y tu gatito se conservan',
        style: TextStyle(fontSize: 17 * context.ui, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Empezar'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

// Un botón ancho con ícono y texto; opcionalmente una aclaración abajo.
// onPressed null = deshabilitado.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.caption,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? caption;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final s = context.ui;
    final colors = Theme.of(context).colorScheme;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 26 * s),
        SizedBox(width: 8 * s),
        Text(label, style: TextStyle(fontSize: 19 * s)),
      ],
    );
    final style = FilledButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 14 * s),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 10 * s),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: primary
                ? FilledButton(onPressed: onPressed, style: style, child: content)
                : FilledButton.tonal(onPressed: onPressed, style: style, child: content),
          ),
          if (caption != null)
            Padding(
              padding: EdgeInsets.only(top: 3 * s),
              child: Text(
                caption!,
                style: TextStyle(fontSize: 13 * s, color: colors.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
