import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../state/achievements.dart';
import '../state/app_state.dart';
import 'achievements_screen.dart';
import 'ad_banner.dart';
import 'cat_preview.dart';
import 'diamond_shop.dart';
import 'game_header.dart';
import 'game_screen.dart';
import 'payment_screen.dart';
import 'ranking_screen.dart';
import 'scale.dart';

// Pantalla de inicio: título, el gatito, Comenzar, Tienda y los ajustes.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key, required this.appState});

  final AppState appState;

  // Empieza una partida: score y vidas en limpio y abre la pantalla de juego
  void _play(BuildContext context) {
    appState.setScore(0);
    appState.setLives(maxLives);
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => GameScreen(appState: appState)),
    );
  }

  // Pasar a PRO es una compra simulada: sale a la pantalla de pago y, si se
  // aprueba, activa la cuenta. No se cobra nada.
  Future<void> _buyPro(BuildContext context) async {
    final approved = await showPayment(
      context,
      product: 'Cuenta PRO (sin anuncios)',
      price: r'$4,99',
    );
    if (approved) appState.setPro(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.ui;

    return Scaffold(
      // Columna: la lista ocupa todo el espacio y el banner queda pegado abajo
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: ListenableBuilder(
                listenable: appState,
                builder: (context, _) {
                  final isPro = appState.accountType == AccountType.pro;

                  return ListView(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 28 * s),
                    children: [
                      // Barra de arriba: usuario a la izquierda, diamantes a la derecha
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24 * s,
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            child: Text(
                              appState.username[0],
                              style: TextStyle(
                                fontSize: 22 * s,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.username,
                                  style: TextStyle(
                                    fontSize: 22 * s,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                AccountBadge(isPro: isPro),
                              ],
                            ),
                          ),
                          StatPill(
                            icon: Icons.diamond_rounded,
                            iconColor: const Color(0xFF00ACC1),
                            value: appState.diamonds,
                            onTap: () => showDiamondShop(context, appState),
                          ),
                        ],
                      ),

                      // Título con el gatito flotando
                      SizedBox(height: 28 * s),
                      Center(
                        child: _FloatingCat(
                          child: CatPreview(
                            skin: appState.skin,
                            accessory: appState.accessory,
                            height: 170 * s,
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Text(
                        'Michi Volador',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42 * s,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        'Pasá entre los rascadores y juntá pescados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17 * s,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 14 * s),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 24 * s,
                            color: const Color(0xFFFFB300),
                          ),
                          SizedBox(width: 4 * s),
                          Text(
                            'Mejor score: ${appState.bestScore}',
                            style: TextStyle(
                              fontSize: 19 * s,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      // Botones principales
                      SizedBox(height: 26 * s),
                      FilledButton(
                        onPressed: () => _play(context),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 18 * s),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 34 * s),
                            SizedBox(width: 6 * s),
                            Text(
                              'Comenzar',
                              style: TextStyle(fontSize: 24 * s),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      // Tienda y Ranking, lado a lado
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: () =>
                                  showDiamondShop(context, appState),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16 * s),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.diamond_rounded, size: 26 * s),
                                  SizedBox(width: 6 * s),
                                  Text(
                                    'Tienda',
                                    style: TextStyle(fontSize: 20 * s),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * s),
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RankingScreen(appState: appState),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16 * s),
                              ),
                              // FittedBox: si no entra en el botón, se achica solo
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      size: 26 * s,
                                    ),
                                    SizedBox(width: 6 * s),
                                    Text(
                                      'Mis puntajes',
                                      style: TextStyle(fontSize: 20 * s),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * s),

                      // Logros, con cuántos llevás
                      FilledButton.tonal(
                        onPressed: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AchievementsScreen(appState: appState),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16 * s),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 26 * s,
                              color: const Color(0xFFFFB300),
                            ),
                            SizedBox(width: 6 * s),
                            Text(
                              'Logros  ${appState.unlockedAchievements.length}/${achievements.length}',
                              style: TextStyle(fontSize: 20 * s),
                            ),
                          ],
                        ),
                      ),

                      // Ajustes
                      SizedBox(height: 28 * s),
                      Text(
                        'Ajustes',
                        style: TextStyle(
                          fontSize: 22 * s,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      // Material (y no Container): las filas con efecto de toque
                      // pintan sobre el Material más cercano
                      Material(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(22 * s),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            SwitchListTile(
                              secondary: Icon(
                                Icons.dark_mode_rounded,
                                size: 28 * s,
                              ),
                              title: Text(
                                'Modo oscuro',
                                style: TextStyle(fontSize: 18 * s),
                              ),
                              value: appState.darkMode,
                              onChanged: appState.setDarkMode,
                            ),
                            SwitchListTile(
                              secondary: Icon(
                                Icons.music_note_rounded,
                                size: 28 * s,
                              ),
                              title: Text(
                                'Música del juego',
                                style: TextStyle(fontSize: 18 * s),
                              ),
                              value: appState.musicOn,
                              onChanged: appState.setMusicOn,
                            ),
                            SwitchListTile(
                              secondary: Icon(
                                Icons.volume_up_rounded,
                                size: 28 * s,
                              ),
                              title: Text(
                                'Maullidos y sonidos',
                                style: TextStyle(fontSize: 18 * s),
                              ),
                              value: appState.sfxOn,
                              onChanged: appState.setSfxOn,
                            ),
                            SwitchListTile(
                              secondary: Icon(
                                Icons.vibration_rounded,
                                size: 28 * s,
                              ),
                              title: Text(
                                'Vibración',
                                style: TextStyle(fontSize: 18 * s),
                              ),
                              value: appState.vibrationOn,
                              onChanged: appState.setVibrationOn,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.workspace_premium_rounded,
                                size: 28 * s,
                              ),
                              title: Text(
                                'Cuenta PRO',
                                style: TextStyle(fontSize: 18 * s),
                              ),
                              subtitle: Text(
                                isPro
                                    ? 'Activa: sin anuncios'
                                    : 'Sin anuncios entre partidas',
                                style: TextStyle(fontSize: 14 * s),
                              ),
                              trailing: isPro
                                  ? TextButton(
                                      onPressed: () => appState.setPro(false),
                                      child: Text(
                                        'Quitar',
                                        style: TextStyle(fontSize: 15 * s),
                                      ),
                                    )
                                  : FilledButton.tonal(
                                      onPressed: () => _buyPro(context),
                                      child: Text(
                                        'Activar',
                                        style: TextStyle(fontSize: 15 * s),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(top: false, child: AdBanner(appState: appState)),
        ],
      ),
    );
  }
}

// Hace que el gatito suba y baje suavemente, como flotando
class _FloatingCat extends StatefulWidget {
  const _FloatingCat({required this.child});

  final Widget child;

  @override
  State<_FloatingCat> createState() => _FloatingCatState();
}

class _FloatingCatState extends State<_FloatingCat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(); // vuelve a empezar solo, para siempre

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // sin() da una oscilación suave entre -1 y 1
        final dy = sin(_controller.value * 2 * pi) * 8;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
    );
  }
}
