import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:tp2/game/cat_runner_game.dart';
import 'package:tp2/main.dart';
import 'package:tp2/ranking/ranking.dart';
import 'package:tp2/state/app_state.dart';
import 'package:tp2/state/catalog.dart';

// Simula la pantalla de un celu (1080x2340 px a 2.625 de densidad = 411x891)
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('la pantalla de inicio muestra Comenzar y Tienda', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(GatitoRunnerApp(appState: AppState()));

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Tienda'), findsOneWidget);
  });

  testWidgets('Comenzar abre el juego con un botón de pausa', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(GatitoRunnerApp(appState: AppState()));

    await tester.tap(find.text('Comenzar'));
    await tester.pump(); // arranca la navegación
    await tester.pump(const Duration(milliseconds: 500)); // termina la animación

    expect(find.byType(GameWidget<CatRunnerGame>), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  test('el ranking guarda como máximo 20 y borra el más viejo', () async {
    final repo = RankingRepository();
    for (var i = 1; i <= 25; i++) {
      await repo.add(RankingEntry(name: 'J$i', score: i, createdAt: DateTime(2026, 1, i)));
    }

    final entries = await repo.load();
    expect(entries.length, rankingLimit);
    expect(entries.any((e) => e.name == 'J5'), isFalse); // los 5 más viejos se fueron
    expect(entries.any((e) => e.name == 'J6'), isTrue);
    expect(entries.first.score, 25); // ordenado de mayor a menor score
  });

  test('se borra el más viejo aunque tenga el score más alto', () async {
    final repo = RankingRepository();
    await repo.add(RankingEntry(name: 'Viejo', score: 999, createdAt: DateTime(2026, 1, 1)));
    for (var i = 1; i <= 20; i++) {
      await repo.add(RankingEntry(name: 'J$i', score: i, createdAt: DateTime(2026, 2, i)));
    }

    final entries = await repo.load();
    expect(entries.length, rankingLimit);
    expect(entries.any((e) => e.name == 'Viejo'), isFalse);
  });

  test('atrapar un pescado desbloquea el logro y deja un aviso', () {
    final state = AppState();

    state.recordFish();

    expect(state.unlockedAchievements.contains('first_fish'), isTrue);
    expect(state.takeAchievementToast()?.title, 'Primer pescado');
    expect(state.takeAchievementToast(), isNull); // el aviso sale una sola vez
  });

  test('un logro no se desbloquea dos veces', () {
    final state = AppState();

    state.recordFish();
    state.takeAchievementToast();
    state.recordFish(); // el segundo pescado no repite el aviso

    expect(state.takeAchievementToast(), isNull);
    expect(state.fishCollected, 2);
  });

  test('llegar a 10 puntos desbloquea Michi volador (y Primer vuelo)', () {
    final state = AppState();

    state.setScore(10);

    expect(state.unlockedAchievements, containsAll(['first_flight', 'flyer']));
    expect(state.unlockedAchievements.contains('super_cat'), isFalse);
  });

  test('comprar un pelaje especial desbloquea Michi a la moda', () {
    final state = AppState()..diamonds = 25;

    state.buySkin(CatSkin.tuxedo);

    expect(state.unlockedAchievements.contains('fashion'), isTrue);
  });

  test('comprar un pelaje descuenta diamantes y lo deja puesto', () {
    final state = AppState()..diamonds = 25;

    expect(state.buySkin(CatSkin.tuxedo), isTrue);
    expect(state.diamonds, 0);
    expect(state.skin, CatSkin.tuxedo);
  });

  test('sin diamantes suficientes no se puede comprar', () {
    final state = AppState()..diamonds = 10;

    expect(state.buySkin(CatSkin.carey), isFalse); // cuesta 20
    expect(state.diamonds, 10);
    expect(state.ownedSkins.contains(CatSkin.carey), isFalse);
  });
}
