import 'package:material_ui/material_ui.dart';

import '../state/app_state.dart';
import 'scale.dart';

// Barra de arriba: avatar + nombre + tipo de cuenta + vidas, y a la derecha
// el score y los diamantes. Tocar los diamantes abre la tienda.
// Se redibuja sola cuando AppState cambia.
class GameHeader extends StatelessWidget {
  const GameHeader({super.key, required this.state, required this.onDiamondsTap});

  final AppState state;
  final VoidCallback onDiamondsTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui; // factor de escala según el ancho de la pantalla

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          // SafeArea adentro del Container: el color llega hasta arriba del
          // todo, pero el contenido queda debajo de la barra de estado.
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24 * s,
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  child: Text(
                    state.username[0],
                    style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.username,
                        style: TextStyle(
                          fontSize: 22 * s,
                          fontWeight: FontWeight.w800,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      Row(
                        children: [
                          AccountBadge(isPro: state.accountType == AccountType.pro),
                          const SizedBox(width: 8),
                          _Hearts(lives: state.lives),
                        ],
                      ),
                    ],
                  ),
                ),
                StatPill(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFB300),
                  value: state.score,
                ),
                const SizedBox(width: 8),
                StatPill(
                  icon: Icons.diamond_rounded,
                  iconColor: const Color(0xFF00ACC1),
                  value: state.diamonds,
                  onTap: onDiamondsTap,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Corazones de vida: llenos los que quedan, vacíos los perdidos
class _Hearts extends StatelessWidget {
  const _Hearts({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    final s = context.ui;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < maxLives; i++)
          Icon(
            i < lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 19 * s,
            color: const Color(0xFFE53935),
          ),
      ],
    );
  }
}

// Etiqueta "BASIC" o "PRO" (también la usa la pantalla de inicio)
class AccountBadge extends StatelessWidget {
  const AccountBadge({super.key, required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final s = context.ui;
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: isPro ? const Color(0xFFFFC107) : Colors.black26,
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Text(
        isPro ? 'PRO' : 'BASIC',
        style: TextStyle(fontSize: 13 * s, color: Colors.black87),
      ),
    );
  }
}

// Cápsula con un ícono y un número (para el score y los diamantes).
// Si tiene onTap, se puede tocar. (También la usa la pantalla de inicio.)
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(22 * s),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 6 * s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22 * s, color: iconColor),
              SizedBox(width: 4 * s),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
