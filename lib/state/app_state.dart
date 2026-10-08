import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/game_audio.dart';
import '../ranking/ranking.dart';
import 'achievements.dart';
import 'catalog.dart';

enum AccountType { basic, pro }

// Cantidad de vidas con la que empieza cada partida nueva
const int maxLives = 3;

// Los datos del jugador. Es un ChangeNotifier: cuando algo cambia llamamos
// notifyListeners() y los widgets que lo escuchan se redibujan solos.
// Los diamantes, lo desbloqueado y los logros se guardan en el celu
// (shared_preferences), así que siguen ahí al cerrar y abrir la app, incluso
// sin internet.
class AppState extends ChangeNotifier {
  AppState({this.prefs, RankingRepository? ranking, GameAudio? audio})
      : ranking = ranking ?? RankingRepository(prefs),
        audio = audio ?? GameAudio(enabled: false); // sin sonido en los tests

  final SharedPreferences? prefs; // null en los tests

  // El sonido y la vibración
  final GameAudio audio;

  // Guarda y lee el ranking (en el celu)
  final RankingRepository ranking;

  // La autenticación es simulada: el usuario ya entra logueado.
  final String username = 'Mica';

  // Se reinician en cada partida (no se guardan)
  int score = 0;
  int lives = maxLives;

  // Se guardan
  AccountType accountType = AccountType.basic;
  bool darkMode = false;
  bool musicOn = true;
  bool sfxOn = true;
  bool vibrationOn = true;
  int bestScore = 0;
  int diamonds = 0;
  final ownedSkins = <CatSkin>{
    for (final s in CatSkin.values)
      if (s.price == 0) s,
  };
  final ownedAccessories = <CatAccessory>{};
  CatSkin skin = CatSkin.naranja; // pelaje puesto
  CatAccessory? accessory; // accesorio puesto (null = ninguno)

  // Estadísticas para los logros (se guardan)
  int fishCollected = 0;
  int yarnCollected = 0;
  int gemsCollected = 0;
  final unlockedAchievements = <String>{}; // ids de los logros ya conseguidos

  // Logros recién conseguidos que todavía no se le mostraron al jugador
  final _achievementToasts = <Achievement>[];

  // Lee lo guardado en el celu. Se llama una vez, antes de abrir la app.
  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, audio: GameAudio());
    state.diamonds = prefs.getInt('diamonds') ?? 0;
    state.musicOn = state.audio.musicOn = prefs.getBool('musicOn') ?? true;
    state.sfxOn = state.audio.sfxOn = prefs.getBool('sfxOn') ?? true;
    state.vibrationOn = state.audio.vibrationOn = prefs.getBool('vibrationOn') ?? true;
    state.bestScore = prefs.getInt('bestScore') ?? 0;
    state.darkMode = prefs.getBool('darkMode') ?? false;
    state.accountType =
        (prefs.getBool('pro') ?? false) ? AccountType.pro : AccountType.basic;
    state.ownedSkins.addAll(_readEnums(prefs, 'ownedSkins', CatSkin.values));
    state.ownedAccessories
        .addAll(_readEnums(prefs, 'ownedAccessories', CatAccessory.values));
    final skins = _readEnums(prefs, 'skin', CatSkin.values);
    if (skins.isNotEmpty && state.ownedSkins.contains(skins.first)) {
      state.skin = skins.first;
    }
    final accs = _readEnums(prefs, 'accessory', CatAccessory.values);
    if (accs.isNotEmpty && state.ownedAccessories.contains(accs.first)) {
      state.accessory = accs.first;
    }
    state.fishCollected = prefs.getInt('fish') ?? 0;
    state.yarnCollected = prefs.getInt('yarn') ?? 0;
    state.gemsCollected = prefs.getInt('gems') ?? 0;
    state.unlockedAchievements.addAll(prefs.getStringList('achievements') ?? const []);
    // Si ya cumplía algún logro de antes, queda desbloqueado sin aviso
    state._checkAchievements();
    state._achievementToasts.clear();

    // Prepara el sonido (la música no arranca acá: solo suena dentro del juego)
    await state.audio.init();
    return state;
  }

  // Convierte una lista de nombres guardados en valores del enum, ignorando
  // los que ya no existan.
  static List<T> _readEnums<T extends Enum>(
      SharedPreferences prefs, String key, List<T> values) {
    final names = prefs.getStringList(key) ?? const [];
    return [
      for (final v in values)
        if (names.contains(v.name)) v,
    ];
  }

  void _save() {
    final p = prefs;
    if (p == null) return;
    p.setInt('diamonds', diamonds);
    p.setInt('bestScore', bestScore);
    p.setBool('darkMode', darkMode);
    p.setBool('musicOn', musicOn);
    p.setBool('sfxOn', sfxOn);
    p.setBool('vibrationOn', vibrationOn);
    p.setBool('pro', accountType == AccountType.pro);
    p.setStringList('ownedSkins', [for (final s in ownedSkins) s.name]);
    p.setStringList('ownedAccessories', [for (final a in ownedAccessories) a.name]);
    p.setStringList('skin', [skin.name]);
    p.setStringList('accessory', [if (accessory != null) accessory!.name]);
    p.setInt('fish', fishCollected);
    p.setInt('yarn', yarnCollected);
    p.setInt('gems', gemsCollected);
    p.setStringList('achievements', unlockedAchievements.toList());
  }

  // ---------- Logros ----------

  // Los números actuales del jugador, de los que salen los logros
  PlayerStats get stats => PlayerStats(
        fish: fishCollected,
        yarn: yarnCollected,
        gems: gemsCollected,
        bestRound: bestScore,
        extras: ownedAccessories.length + ownedSkins.where((s) => s.price > 0).length,
      );

  // Busca logros que se acaban de cumplir: los marca como conseguidos y los
  // deja en la cola para avisarle al jugador. Devuelve true si hubo alguno.
  bool _checkAchievements() {
    var any = false;
    final current = stats;
    for (final a in achievements) {
      if (!unlockedAchievements.contains(a.id) && a.isUnlocked(current)) {
        unlockedAchievements.add(a.id);
        _achievementToasts.add(a);
        any = true;
      }
    }
    return any;
  }

  // Devuelve el próximo logro por avisar (y lo saca de la cola), o null
  Achievement? takeAchievementToast() {
    return _achievementToasts.isEmpty ? null : _achievementToasts.removeAt(0);
  }

  // El gatito atrapó algo: suma a las estadísticas y revisa los logros
  void recordFish() {
    fishCollected++;
    _afterStatChange();
  }

  void recordYarn() {
    yarnCollected++;
    _afterStatChange();
  }

  void recordGem() {
    gemsCollected++;
    _afterStatChange();
  }

  void _afterStatChange() {
    _checkAchievements();
    _save();
    notifyListeners();
  }

  // ---------- Partida ----------

  void setScore(int value) {
    score = value;
    if (value > bestScore) {
      bestScore = value;
      _checkAchievements();
      _save();
    }
    notifyListeners();
  }

  void setLives(int value) {
    lives = value;
    notifyListeners();
  }

  // Anota el puntaje de una partida terminada en el ranking
  void submitScore(int value) {
    ranking.add(RankingEntry(name: username, score: value, createdAt: DateTime.now()));
  }

  // ---------- Ajustes ----------

  void setDarkMode(bool value) {
    darkMode = value;
    _save();
    notifyListeners();
  }

  void setMusicOn(bool value) {
    musicOn = audio.musicOn = value;
    audio.syncMusic();
    _save();
    notifyListeners();
  }

  void setSfxOn(bool value) {
    sfxOn = audio.sfxOn = value;
    _save();
    notifyListeners();
  }

  void setVibrationOn(bool value) {
    vibrationOn = audio.vibrationOn = value;
    _save();
    notifyListeners();
  }

  // Pasar a PRO es una simulación: no se cobra nada.
  void setPro(bool value) {
    accountType = value ? AccountType.pro : AccountType.basic;
    _save();
    notifyListeners();
  }

  // ---------- Diamantes ----------

  // Suma diamantes (los recolecta el gatito, o se "compran" en un pack)
  void addDiamonds(int amount) {
    diamonds += amount;
    _save();
    notifyListeners();
  }

  // ---------- Tienda de pelajes y accesorios ----------

  // Compra el pelaje y lo deja puesto. Devuelve false si no alcanzan los diamantes.
  bool buySkin(CatSkin item) {
    if (ownedSkins.contains(item)) return true;
    if (diamonds < item.price) return false;
    diamonds -= item.price;
    ownedSkins.add(item);
    skin = item;
    _checkAchievements();
    _save();
    notifyListeners();
    return true;
  }

  void equipSkin(CatSkin item) {
    if (!ownedSkins.contains(item)) return;
    skin = item;
    _save();
    notifyListeners();
  }

  bool buyAccessory(CatAccessory item) {
    if (ownedAccessories.contains(item)) return true;
    if (diamonds < item.price) return false;
    diamonds -= item.price;
    ownedAccessories.add(item);
    accessory = item;
    _checkAchievements();
    _save();
    notifyListeners();
    return true;
  }

  // null = sacarle el accesorio
  void equipAccessory(CatAccessory? item) {
    if (item != null && !ownedAccessories.contains(item)) return;
    accessory = item;
    _save();
    notifyListeners();
  }
}
