import 'package:material_ui/material_ui.dart';

import 'state/app_state.dart';
import 'ui/start_screen.dart';

Future<void> main() async {
  // Necesario para usar plugins (shared_preferences) antes de runApp
  WidgetsFlutterBinding.ensureInitialized();
  // Lee lo guardado en el celu: diamantes, pelajes, accesorios, ranking, modo
  // oscuro...
  final appState = await AppState.load();
  // Cada vez que algo cambia, vemos si hay un logro nuevo para avisar
  appState.addListener(() => _showAchievementToasts(appState));
  runApp(GatitoRunnerApp(appState: appState));
}

// Con esta llave mostramos avisos (SnackBar) desde cualquier pantalla
final _messengerKey = GlobalKey<ScaffoldMessengerState>();

// Muestra un aviso por cada logro recién desbloqueado
void _showAchievementToasts(AppState appState) {
  for (var a = appState.takeAchievementToast();
      a != null;
      a = appState.takeAchievementToast()) {
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // margen abajo para que no tape el banner de anuncios
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡Logro desbloqueado!', style: TextStyle(fontSize: 14)),
                  Text(
                    a.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Los temas se crean una sola vez (ColorScheme.fromSeed es un cálculo pesado y
// la app se reconstruye cada vez que cambia el estado). fontFamily aplica la
// letra Sniglet a todos los textos de Flutter.
final _lightTheme = ThemeData(
  fontFamily: 'Sniglet',
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
);

final _darkTheme = ThemeData(
  fontFamily: 'Sniglet',
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.pinkAccent,
    brightness: Brightness.dark,
  ),
);

class GatitoRunnerApp extends StatelessWidget {
  const GatitoRunnerApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder: cuando cambia el modo oscuro en AppState, se
    // reconstruye la app con el otro tema
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Michi Volador',
          scaffoldMessengerKey: _messengerKey,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: StartScreen(appState: appState),
        );
      },
    );
  }
}
