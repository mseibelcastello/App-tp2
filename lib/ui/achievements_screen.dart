import 'package:material_ui/material_ui.dart';

import '../state/achievements.dart';
import '../state/app_state.dart';
import 'scale.dart';

const _gold = Color(0xFFFFB300);

// Pantalla de logros: los que ya conseguiste y cuánto te falta para el resto.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logros',
          style: TextStyle(fontSize: 28 * s, fontWeight: FontWeight.w800, color: colors.primary),
        ),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final stats = appState.stats;
          final done = appState.unlockedAchievements.length;

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24 * s),
            children: [
              // Resumen: cuántos llevás
              Container(
                padding: EdgeInsets.all(16 * s),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(22 * s),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 40 * s, color: _gold),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Text(
                        '$done de ${achievements.length} logros',
                        style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12 * s),
              for (final a in achievements)
                _AchievementTile(
                  achievement: a,
                  progress: a.progress(stats),
                  unlocked: appState.unlockedAchievements.contains(a.id),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Una fila: ícono (dorado si lo conseguiste, gris si no), nombre, descripción
// y una barrita de progreso.
class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.progress,
    required this.unlocked,
  });

  final Achievement achievement;
  final int progress;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    final shown = progress.clamp(0, achievement.target);

    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      padding: EdgeInsets.all(14 * s),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22 * s),
        border: Border.all(color: unlocked ? _gold : Colors.transparent, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 54 * s,
            height: 54 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? _gold : colors.surfaceContainerHighest,
            ),
            child: Icon(
              unlocked ? achievement.icon : Icons.lock_rounded,
              size: 28 * s,
              color: unlocked ? Colors.white : colors.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 14 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(fontSize: 19 * s, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 2 * s),
                Text(
                  achievement.description,
                  style: TextStyle(fontSize: 15 * s, color: colors.onSurfaceVariant),
                ),
                // Barrita de progreso solo en los que faltan (si el objetivo
                // es 1, no hace falta: o lo tenés o no)
                if (!unlocked && achievement.target > 1) ...[
                  SizedBox(height: 8 * s),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: shown / achievement.target,
                            minHeight: 10 * s,
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Text(
                        '$shown/${achievement.target}',
                        style: TextStyle(fontSize: 15 * s, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (unlocked)
            Icon(Icons.check_circle_rounded, size: 28 * s, color: _gold),
        ],
      ),
    );
  }
}
