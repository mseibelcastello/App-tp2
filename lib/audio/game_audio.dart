import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

// Todo el sonido y la vibración del juego: la música lofi (solo dentro del
// juego), el miau al recolectar y los sonidos de game over. Los archivos están
// en assets/audio, así que funciona sin internet.
//
// Cualquier error se ignora (solo se anota): un problema con el sonido nunca
// tiene que romper el juego.
class GameAudio {
  // enabled = false en los tests, donde no existen los plugins
  GameAudio({this.enabled = true});

  final bool enabled;

  // Ajustes del jugador
  bool musicOn = true;
  bool sfxOn = true; // miau y sonidos de game over
  bool vibrationOn = true;

  // ¿Está el jugador en la pantalla de juego? La música solo suena ahí.
  bool _inGame = false;

  // ¿El celu tiene motor de vibración? Se averigua una vez al iniciar.
  bool _canVibrate = false;

  static const _music = 'lofi_loop.wav';
  static const _meow = 'meow.ogg';
  static const _crash = 'game_over.wav'; // choque, todavía quedan vidas
  static const _final = 'game_over_final.wav'; // se acabaron las vidas
  static const _musicVolume = 0.35; // la música queda de fondo, bajita
  static const _meowVolume = 0.9;
  static const _gameOverVolume = 0.6; // suaves, que no asusten

  // Carga los sonidos en memoria para que suenen sin demora
  Future<void> init() async {
    if (!enabled) return;
    try {
      await FlameAudio.audioCache.loadAll([_music, _meow, _crash, _final]);
      // initialize() hace que la música se pause sola cuando la app pasa a
      // segundo plano, y siga al volver
      FlameAudio.bgm.initialize();
    } catch (e) {
      debugPrint('Audio: no se pudo iniciar ($e)');
    }
    try {
      _canVibrate = await Vibration.hasVibrator();
    } catch (e) {
      debugPrint('Vibración: no se pudo consultar ($e)');
    }
  }

  // El jugador entró o salió de la pantalla de juego
  void setInGame(bool value) {
    _inGame = value;
    syncMusic();
  }

  // La música suena solo si está en el juego Y el ajuste está prendido
  Future<void> syncMusic() async {
    if (!enabled) return;
    try {
      if (_inGame && musicOn) {
        if (!FlameAudio.bgm.isPlaying) {
          await FlameAudio.bgm.play(_music, volume: _musicVolume);
        }
      } else {
        await FlameAudio.bgm.stop();
      }
    } catch (e) {
      debugPrint('Audio: la música falló ($e)');
    }
  }

  // Al recolectar algo: un "miau" y una vibración corta
  void collectFeedback() {
    if (!enabled) return;
    if (sfxOn) {
      try {
        FlameAudio.play(_meow, volume: _meowVolume);
      } catch (e) {
        debugPrint('Audio: el miau falló ($e)');
      }
    }
    if (vibrationOn) _vibrate();
  }

  // Vibra con el motor del celu directamente (más fuerte y confiable que la
  // "respuesta táctil" del sistema, que depende de la configuración del celu).
  // Si no se puede, usa la vibración fuerte del sistema.
  void _vibrate() {
    try {
      if (_canVibrate) {
        Vibration.vibrate(duration: 80, amplitude: 200);
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      debugPrint('Vibración: falló ($e)');
    }
  }

  // Al chocar. Si se acabaron las vidas suena una nana más larga; si todavía
  // quedan, unas campanitas cortas. Los dos son suaves, no de "perdiste".
  void playGameOver({required bool isFinal}) {
    if (!enabled || !sfxOn) return;
    try {
      FlameAudio.play(isFinal ? _final : _crash, volume: _gameOverVolume);
    } catch (e) {
      debugPrint('Audio: el sonido de game over falló ($e)');
    }
  }
}
