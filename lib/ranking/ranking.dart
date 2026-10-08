import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// El ranking guarda como máximo esta cantidad de puntajes. Al entrar uno
// nuevo y pasarse del límite, se borra el MÁS VIEJO (no el más bajo).
const int rankingLimit = 20;

// Un puntaje en el ranking
class RankingEntry {
  const RankingEntry({
    required this.name,
    required this.score,
    required this.createdAt,
  });

  final String name;
  final int score;
  final DateTime createdAt;

  Map<String, Object> toJson() => {
        'name': name,
        'score': score,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory RankingEntry.fromJson(Map<String, dynamic> json) => RankingEntry(
        name: json['name'] as String,
        score: json['score'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}

// Ordena de mayor a menor score; a igual score, gana el que llegó primero
List<RankingEntry> sortByScore(List<RankingEntry> entries) {
  return [...entries]..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.createdAt.compareTo(b.createdAt);
    });
}

// El ranking, guardado en el celu (shared_preferences): funciona sin internet
// y sigue ahí al cerrar la app. Sin prefs (en los tests) guarda en memoria.
class RankingRepository {
  RankingRepository([this.prefs]);

  final SharedPreferences? prefs;
  static const _key = 'ranking';
  List<RankingEntry> _memory = [];

  List<RankingEntry> _read() {
    final p = prefs;
    if (p == null) return _memory;
    final raw = p.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [for (final e in list) RankingEntry.fromJson(e as Map<String, dynamic>)];
  }

  Future<void> _write(List<RankingEntry> entries) async {
    final p = prefs;
    if (p == null) {
      _memory = entries;
      return;
    }
    await p.setString(_key, jsonEncode([for (final e in entries) e.toJson()]));
  }

  // Agrega un puntaje. Si nos pasamos del límite, borra los más viejos.
  Future<void> add(RankingEntry entry) async {
    // Del más viejo al más nuevo; si hay de más, sacamos los primeros
    final entries = [..._read(), entry]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    while (entries.length > rankingLimit) {
      entries.removeAt(0);
    }
    await _write(entries);
  }

  // Devuelve los puntajes ordenados de mayor a menor
  Future<List<RankingEntry>> load() async => sortByScore(_read());
}
