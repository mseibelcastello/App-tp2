import 'package:material_ui/material_ui.dart';

import '../ranking/ranking.dart';
import '../state/app_state.dart';
import 'scale.dart';

// Pantalla del ranking: los últimos 20 puntajes, de mayor a menor.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late final Future<List<RankingEntry>> _future = widget.appState.ranking.load();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis mejores puntajes',
          style: TextStyle(fontSize: 28 * s, fontWeight: FontWeight.w800, color: colors.primary),
        ),
      ),
      body: FutureBuilder<List<RankingEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? const <RankingEntry>[];

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24 * s),
            children: [
              Text(
                'Tus últimos $rankingLimit puntajes, guardados en este celu.',
                style: TextStyle(fontSize: 15 * s, color: colors.onSurfaceVariant),
              ),
              SizedBox(height: 12 * s),
              if (entries.isEmpty)
                _EmptyState()
              else
                for (var i = 0; i < entries.length; i++)
                  _EntryTile(position: i + 1, entry: entries[i]),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    return Padding(
      padding: EdgeInsets.only(top: 60 * s),
      child: Column(
        children: [
          Icon(Icons.pets_rounded, size: 64 * s, color: colors.primary),
          SizedBox(height: 12 * s),
          Text(
            'Todavía no hay puntajes',
            style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Jugá una partida y aparecés acá',
            style: TextStyle(fontSize: 16 * s, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// Una fila del ranking: puesto, nombre, fecha y score
class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.position,
    required this.entry,
  });

  final int position;
  final RankingEntry entry;

  static const _medals = [Color(0xFFFFB300), Color(0xFF90A4AE), Color(0xFFBF7B4B)];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;
    final date = entry.createdAt;

    return Container(
      margin: EdgeInsets.only(bottom: 8 * s),
      padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20 * s),
      ),
      child: Row(
        children: [
          // Los 3 primeros llevan una copa de color; el resto, su número
          SizedBox(
            width: 40 * s,
            child: position <= 3
                ? Icon(Icons.emoji_events_rounded, size: 30 * s, color: _medals[position - 1])
                : Text(
                    '$position',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: TextStyle(fontSize: 19 * s, fontWeight: FontWeight.w800)),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(fontSize: 13 * s, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.star_rounded, size: 22 * s, color: const Color(0xFFFFB300)),
          SizedBox(width: 4 * s),
          Text('${entry.score}', style: TextStyle(fontSize: 22 * s, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
