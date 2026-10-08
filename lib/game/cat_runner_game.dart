import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../state/app_state.dart' show maxLives;
import '../state/catalog.dart';
import 'cat_sprite.dart';
import 'collectible.dart';
import 'scratch_post.dart';

// En qué momento está la partida. La botonera lo usa para saber qué botones
// habilitar.
enum GameStatus {
  ready, // esperando que empiece
  playing, // jugando
  paused, // en pausa
  gameOver, // el gatito chocó (pero le quedan vidas)
  noLives, // se acabaron las vidas: solo NUEVA PARTIDA sigue
}

// Lo que dice el globo del medio. big = cartel grande (ocupa ~30% del alto de
// la pantalla), para los choques; el resto de los mensajes es chico.
class GameMessage {
  const GameMessage(this.title, {this.subtitle = '', this.big = false});

  final String title;
  final String subtitle;
  final bool big;

  static const none = GameMessage(''); // sin globo
  bool get isEmpty => title.isEmpty;
}

// Un par de rascadores (arriba y abajo) con un hueco en el medio, y
// opcionalmente un objeto para recolectar flotando en el hueco.
class PipePair {
  PipePair(this.top, this.bottom, this.item);

  final ScratchPost top;
  final ScratchPost bottom;
  Collectible? item;
  bool passed = false; // ya la pasó el gatito (y ya sumó el punto)

  void removeFromGame() {
    top.removeFromParent();
    bottom.removeFromParent();
    item?.removeFromParent();
  }
}

// "with TapCallbacks" le permite al juego detectar toques en la pantalla
class CatRunnerGame extends FlameGame with TapCallbacks {
  CatRunnerGame({
    required this.onScoreChanged,
    required this.onLivesChanged,
    required this.onDiamondCollected,
    required this.onSessionFinished,
    required this.onGameOverTap,
    required this.onCollect,
    required this.onCrash,
  });

  // Funciones que nos pasa la pantalla para avisarle lo que pasa en el juego
  final void Function(int score) onScoreChanged;
  final void Function(int lives) onLivesChanged;
  final void Function(int amount) onDiamondCollected;
  // Una partida (las 3 vidas) terminó: recibe el mejor score que hizo
  final void Function(int bestScore) onSessionFinished;
  // Tocaron la pantalla en el Game Over final: hay que volver al menú
  final void Function() onGameOverTap;
  // El gatito agarró algo (pescado, ovillo o diamante): acá suena el "miau"
  final void Function(CollectibleType type) onCollect;
  // El gatito chocó: acá suena el game over suave. isFinal = se acabaron las
  // vidas (suena distinto que un choque con vidas todavía)
  final void Function(bool isFinal) onCrash;

  // --- Constantes: cambiá estos números para ajustar la dificultad ---
  static const gravity = 1400.0; // qué tan rápido cae el gatito
  static const flapSpeed = -450.0; // impulso de cada toque (negativo = arriba)
  static const pipeSpeed = 160.0; // velocidad de los obstáculos
  static const pipeWidth = 70.0;
  static const gapHeight = 210.0; // tamaño del hueco por donde pasa el gatito
  static const spawnEvery = 1.7; // segundos entre un par de obstáculos y otro
  static const fishPoints = 3; // bonus del pescado
  static const yarnPoints = 10; // bonus del ovillo

  // --- Piezas del juego ---
  late CatSprite cat;
  late double groundY; // altura (en pantalla) donde está el suelo
  final pipes = <PipePair>[];
  final random = Random();

  // --- Estado de la partida ---
  double catSpeedY = 0;
  double spawnTimer = spawnEvery;
  int score = 0;
  int lives = maxLives;

  // Una "partida" son las 3 vidas. Al rankear se usa el mejor score de todos
  // los intentos de esa partida.
  int sessionBest = 0;
  bool sessionSubmitted = false;

  // Segundos desde el Game Over final. Los toques se ignoran un ratito para
  // que el toque con el que chocaste no te saque del juego sin querer.
  double _noLivesTime = 0;
  static const _gameOverTapDelay = 0.8;

  // ValueNotifier: igual que AppState, avisa a quien lo escuche cuando cambia
  final status = ValueNotifier<GameStatus>(GameStatus.ready);

  // Texto del globo del medio. Lo dibuja Flutter (ver message_bubble.dart), no
  // Flame, así se adapta solo al tamaño de pantalla.
  final message = ValueNotifier<GameMessage>(const GameMessage('Tocá para empezar'));

  // --- Aspecto: lo pone la pantalla (colores del tema, pelaje y accesorio) ---
  Color skyColor = const Color(0xFFFFF1F5);
  Color groundColor = const Color(0xFFF8BBD0);
  RectangleComponent? _ground;
  CatSkin skin = CatSkin.naranja;
  CatAccessory? accessory;

  void applyColors({required Color sky, required Color ground}) {
    skyColor = sky;
    groundColor = ground;
    _ground?.paint.color = ground; // si el suelo ya existe, lo repinta
  }

  void setLook(CatSkin skin, CatAccessory? accessory) {
    this.skin = skin;
    this.accessory = accessory;
    if (isLoaded) cat.setLook(skin, accessory);
  }

  // El fondo es un color liso: sin sol, sin nubes.
  @override
  Color backgroundColor() => skyColor;

  @override
  Future<void> onLoad() async {
    // Escenario minimalista: solo una franja de suelo
    final groundHeight = size.y * 0.12;
    groundY = size.y - groundHeight;
    _ground = RectangleComponent(
      position: Vector2(0, groundY),
      size: Vector2(size.x, groundHeight),
      paint: Paint()..color = groundColor,
      priority: 1, // se dibuja por encima de los obstáculos
    );
    add(_ground!);

    // El gatito (dibujado en cat_painter.dart), centrado en su posición
    cat = CatSprite(
      position: Vector2(size.x * 0.25, size.y * 0.4),
      skin: skin,
      accessory: accessory,
    )..priority = 2;
    add(cat);
  }

  // update se ejecuta ~60 veces por segundo. dt = segundos desde el último frame.
  @override
  void update(double dt) {
    super.update(dt);
    if (status.value == GameStatus.noLives) _noLivesTime += dt;
    if (status.value != GameStatus.playing) return;

    // 1) Gravedad: el gatito acelera hacia abajo y se mueve
    catSpeedY += gravity * dt;
    cat.y += catSpeedY * dt;
    // Se inclina: nariz arriba al subir, nariz abajo al caer
    cat.angle = (catSpeedY / 700).clamp(-0.5, 0.9);

    // 2) Aparece un par de obstáculos cada spawnEvery segundos
    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      spawnPipes();
      spawnTimer = spawnEvery;
    }

    // 3) Caja de colisión del gatito (un poco más chica que el dibujo)
    final catBox = Rect.fromCenter(
      center: Offset(cat.x, cat.y),
      width: 34,
      height: 34,
    );

    // 4) Mover obstáculos y objetos, recolectar, sumar puntos, borrar los
    //    que salieron y chocar
    for (final pair in List.of(pipes)) {
      pair.top.x -= pipeSpeed * dt;
      pair.bottom.x -= pipeSpeed * dt;

      final item = pair.item;
      if (item != null) {
        item.x -= pipeSpeed * dt;
        if (item.toRect().overlaps(catBox)) {
          collect(item);
          pair.item = null;
        }
      }

      if (pair.top.toRect().overlaps(catBox) ||
          pair.bottom.toRect().overlaps(catBox)) {
        endGame();
      }
      if (!pair.passed && pair.top.x + pipeWidth < cat.x) {
        pair.passed = true;
        score++;
        onScoreChanged(score);
      }
      if (pair.top.x < -pipeWidth) {
        pair.removeFromGame();
        pipes.remove(pair);
      }
    }

    // 5) Tocar el suelo o el techo también es perder
    if (cat.y + 17 >= groundY || cat.y - 17 <= 0) {
      endGame();
    }
  }

  void spawnPipes() {
    // Centro del hueco al azar, sin pegarse al techo ni al suelo
    const margin = 90.0;
    final gapCenter =
        margin + gapHeight / 2 + random.nextDouble() * (groundY - 2 * margin - gapHeight);
    final topHeight = gapCenter - gapHeight / 2;
    final bottomTop = gapCenter + gapHeight / 2;

    // Rascador que cuelga del techo (tapa abajo) y el que sale del suelo (tapa arriba)
    final top = ScratchPost(
      capAtBottom: true,
      position: Vector2(size.x, 0),
      size: Vector2(pipeWidth, topHeight),
    );
    final bottom = ScratchPost(
      capAtBottom: false,
      position: Vector2(size.x, bottomTop),
      size: Vector2(pipeWidth, groundY - bottomTop),
    );

    // Un objeto en el centro del hueco (a veces ninguno)
    final item = _randomCollectible(Vector2(size.x + pipeWidth / 2, gapCenter));

    pipes.add(PipePair(top, bottom, item));
    add(top);
    add(bottom);
    if (item != null) add(item);
  }

  // Elige qué objeto aparece: 25% diamante, 40% pescado, 15% ovillo, 20% nada
  Collectible? _randomCollectible(Vector2 position) {
    final roll = random.nextDouble();
    final CollectibleType type;
    if (roll < 0.25) {
      type = CollectibleType.diamond;
    } else if (roll < 0.65) {
      type = CollectibleType.fish;
    } else if (roll < 0.80) {
      type = CollectibleType.yarn;
    } else {
      return null;
    }
    return Collectible(type: type, position: position);
  }

  // El gatito agarró un objeto: aplica el premio y muestra un "+N" flotando
  void collect(Collectible item) {
    onCollect(item.type);
    switch (item.type) {
      case CollectibleType.fish:
        score += fishPoints;
        onScoreChanged(score);
        _popText('+$fishPoints', item.position, const Color(0xFF00796B));
      case CollectibleType.yarn:
        score += yarnPoints;
        onScoreChanged(score);
        _popText('+$yarnPoints', item.position, const Color(0xFF6A4FB3));
      case CollectibleType.diamond:
        onDiamondCollected(1);
        _popText('+1', item.position, const Color(0xFF00838F));
    }
    item.removeFromParent();
  }

  // Texto que sube y desaparece (feedback al recolectar)
  void _popText(String text, Vector2 at, Color color) {
    final label = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'Sniglet',
          fontWeight: FontWeight.w800,
          fontSize: 26,
          color: color,
        ),
      ),
      anchor: Anchor.center,
      position: at.clone(),
      priority: 4,
    );
    label.add(MoveByEffect(Vector2(0, -50), EffectController(duration: 0.7)));
    label.add(RemoveEffect(delay: 0.7));
    add(label);
  }

  // Choque: cuesta una vida. Se ignora si ya no estábamos jugando, porque en
  // un mismo frame pueden detectarse dos choques (ej. rascador y suelo) y no
  // queremos descontar dos vidas.
  void endGame() {
    if (status.value != GameStatus.playing) return;
    _loseLife();
    onCrash(lives == 0);
    if (lives > 0) {
      // Perdió una vida pero puede seguir: mensaje suave, no "Game Over"
      status.value = GameStatus.gameOver;
      final left = lives == 1 ? 'Te queda 1 vida' : 'Te quedan $lives vidas';
      message.value = GameMessage('¡Auch!', subtitle: '$left\nScore: $score', big: true);
    }
  }

  // Resta una vida y avisa. "Game Over" solo aparece si era la última.
  void _loseLife() {
    sessionBest = max(sessionBest, score); // este intento terminó
    lives--;
    onLivesChanged(lives);
    if (lives == 0) {
      status.value = GameStatus.noLives;
      _noLivesTime = 0;
      message.value = GameMessage(
        'Game Over',
        subtitle: 'Score: $score\nTocá para volver al menú',
        big: true,
      );
      submitSession();
    }
  }

  // Manda el mejor score de la partida al ranking, una sola vez por partida.
  // Se llama al quedarse sin vidas, al empezar una partida nueva y al salir
  // al menú principal (por si la dejaste a medias).
  void submitSession() {
    sessionBest = max(sessionBest, score);
    if (sessionBest > 0 && !sessionSubmitted) {
      sessionSubmitted = true;
      onSessionFinished(sessionBest);
    }
  }

  // ---------- Acciones que usa la botonera (y los toques) ----------

  // INICIO: arranca la partida si estaba esperando
  void startGame() {
    if (status.value != GameStatus.ready) return;
    status.value = GameStatus.playing;
    message.value = GameMessage.none;
  }

  // PAUSA / REANUDAR: congela y descongela el juego
  void togglePause() {
    if (status.value == GameStatus.playing) {
      status.value = GameStatus.paused;
      // No hace falta frenar el motor: update() ya no mueve nada cuando el
      // estado no es "playing". No hay globo: la ventanita de pausa lo cubre.
      message.value = GameMessage.none;
    } else if (status.value == GameStatus.paused) {
      status.value = GameStatus.playing;
      message.value = GameMessage.none;
    }
  }

  // NUEVA PARTIDA: todo de cero. Restaura las vidas y arranca enseguida.
  void newGame() {
    submitSession(); // la partida anterior queda anotada en el ranking
    sessionBest = 0;
    sessionSubmitted = false;
    lives = maxLives;
    onLivesChanged(lives);
    _resetRound();
    startGame();
  }

  // REINICIAR PARTIDA: abandonar una partida en curso cuesta una vida.
  // Si venías de un choque (gameOver) la vida ya se pagó, así que es gratis.
  void restart() {
    final abandoning = status.value == GameStatus.playing ||
        status.value == GameStatus.paused;
    if (abandoning) {
      _loseLife();
      if (lives == 0) return; // sin vidas: queda en "Game Over"
    }
    _resetRound();
  }

  // Deja todo listo para un nuevo intento (no toca las vidas)
  void _resetRound() {
    for (final pair in pipes) {
      pair.removeFromGame();
    }
    pipes.clear();
    cat.position = Vector2(size.x * 0.25, size.y * 0.4);
    cat.angle = 0;
    catSpeedY = 0;
    spawnTimer = spawnEvery;
    score = 0;
    onScoreChanged(0);
    status.value = GameStatus.ready;
    message.value = const GameMessage('Tocá para empezar');
  }

  // Un toque en pantalla:
  //  - en pausa: no hace nada
  //  - Game Over final (sin vidas): vuelve al menú principal
  //  - si perdiste una vida: reintenta (la vida ya se pagó al chocar)
  //  - si todavía no empezó: arranca la partida
  //  - jugando: el gatito aletea (se impulsa hacia arriba)
  @override
  void onTapDown(TapDownEvent event) {
    switch (status.value) {
      case GameStatus.paused:
        return;
      case GameStatus.noLives:
        // Game Over final: un toque (pasado el ratito de gracia) vuelve al menú
        if (_noLivesTime > _gameOverTapDelay) onGameOverTap();
        return;
      case GameStatus.gameOver:
        restart();
        return;
      case GameStatus.ready:
        startGame();
      case GameStatus.playing:
        break;
    }
    catSpeedY = flapSpeed;
  }
}
