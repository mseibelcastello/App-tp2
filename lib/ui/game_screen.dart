import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import '../game/cat_runner_game.dart';
import '../game/collectible.dart';
import '../state/app_state.dart';
import 'ad_banner.dart';
import 'diamond_shop.dart';
import 'game_header.dart';
import 'message_bubble.dart';
import 'pause_menu.dart';
import 'ranking_screen.dart';
import 'scale.dart';

// Pantalla de juego: el header arriba y el juego ocupando el resto. El único
// control es el botón de pausa (arriba a la derecha), que abre el menú.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Se crea una sola vez (acá, en el State) para que no se reinicie la
  // partida cada vez que Flutter redibuja la pantalla.
  late final CatRunnerGame game;

  AppState get appState => widget.appState;

  @override
  void initState() {
    super.initState();
    // Cada vez que el juego cambia el score, las vidas o recolecta un
    // diamante, se lo pasamos al AppState para que el header se actualice
    game = CatRunnerGame(
      onScoreChanged: appState.setScore,
      onLivesChanged: appState.setLives,
      onDiamondCollected: appState.addDiamonds,
      onSessionFinished: appState.submitScore,
      onGameOverTap: _leaveToMenu,
      onCollect: _onCollect,
      onCrash: (isFinal) => appState.audio.playGameOver(isFinal: isFinal),
    );
    // El pelaje y el accesorio elegidos en la tienda viajan al juego
    appState.addListener(_syncLook);
    _syncLook();
    // La música de fondo suena solo mientras estamos en esta pantalla
    appState.audio.setInGame(true);
  }

  // El gatito atrapó algo: miau + vibración suave, y suma a los logros
  void _onCollect(CollectibleType type) {
    appState.audio.collectFeedback();
    switch (type) {
      case CollectibleType.fish:
        appState.recordFish();
      case CollectibleType.yarn:
        appState.recordYarn();
      case CollectibleType.diamond:
        appState.recordGem();
    }
  }

  void _syncLook() => game.setLook(appState.skin, appState.accessory);

  // Vuelve a la pantalla de inicio (el score ya quedó anotado en el ranking)
  void _leaveToMenu() {
    if (!mounted) return;
    game.submitSession();
    Navigator.pop(context);
  }

  // Se ejecuta al empezar y cada vez que cambia el tema (claro/oscuro):
  // le pasamos al juego los colores del tema, así el fondo siempre combina.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colors = Theme.of(context).colorScheme;
    game.applyColors(
      sky: colors.surfaceContainerLow,
      ground: colors.secondaryContainer,
    );
  }

  @override
  void dispose() {
    appState.removeListener(_syncLook);
    appState.audio.setInGame(false); // al salir al menú, se corta la música
    super.dispose();
  }

  // Abre el menú de pausa. Si estaba jugando, congela el juego mientras tanto.
  // La tienda se abre desde el menú y, al cerrarla, el menú vuelve a aparecer.
  Future<void> _openPauseMenu() async {
    final wePaused = game.status.value == GameStatus.playing;
    if (wePaused) game.togglePause();

    while (mounted) {
      final status = game.status.value;
      final action = await showPauseMenu(
        context,
        canRestart: status == GameStatus.paused || status == GameStatus.gameOver,
        restartCostsLife: status == GameStatus.paused,
      );
      if (!mounted) return;

      switch (action) {
        case PauseAction.shop:
          await showDiamondShop(context, appState);
          if (!mounted) return;
          continue; // al cerrar la tienda, volvemos a mostrar el menú
        case PauseAction.ranking:
          await Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => RankingScreen(appState: appState)),
          );
          if (!mounted) return;
          continue; // al volver del ranking, mostramos el menú otra vez
        case PauseAction.restart:
          game.restart();
          return;
        case PauseAction.newGame:
          final confirmed = await confirmNewGame(context);
          if (!mounted) return;
          if (confirmed) {
            game.newGame();
            return;
          }
          continue; // canceló: volvemos al menú
        case PauseAction.menu:
          _leaveToMenu(); // si dejó la partida a medias, queda en el ranking
          return;
        case PauseAction.resume:
        case null: // tocó afuera del menú
          if (wePaused) game.togglePause();
          return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.ui;

    // PopScope: el botón "atrás" del celu abre el menú de pausa en vez de
    // salir del juego de golpe
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _openPauseMenu();
      },
      child: Scaffold(
        body: Column(
          children: [
            GameHeader(
              state: appState,
              onDiamondsTap: () => showDiamondShop(context, appState),
            ),
            Expanded(
              child: Stack(
                children: [
                  GameWidget(game: game),
                  // IgnorePointer: los toques atraviesan el globo y llegan al juego
                  IgnorePointer(
                    child: Align(
                      alignment: const Alignment(0, -0.45),
                      child: MessageBubble(game: game),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton.filledTonal(
                      onPressed: _openPauseMenu,
                      iconSize: 30 * s,
                      icon: const Icon(Icons.pause_rounded),
                    ),
                  ),
                ],
              ),
            ),
            // Banner de anuncios abajo de todo (no se ve con la cuenta PRO)
            SafeArea(top: false, child: AdBanner(appState: appState)),
          ],
        ),
      ),
    );
  }
}
