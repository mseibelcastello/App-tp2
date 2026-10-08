# Michi Volador

TP2 de Laboratorio Orientado a Aplicaciones Móviles. Un juego para chicos hecho
con **Flutter** y el motor **Flame**: un michi vuela entre rascadores,
junta pescados, ovillos y diamantes, y se viste con lo que desbloquea.

Funciona **sin internet**: todo se guarda en el celu.

## Qué tiene

- Juego de un toque: el michi aletea al tocar y hay que pasar entre los rascadores.
- Objetos para recolectar: pescado (+3), ovillo (+10) y diamante (moneda de la tienda).
- 3 vidas por partida. Reiniciar en plena partida cuesta una vida; nueva partida las restaura.
- Header con usuario, tipo de cuenta (BASIC / PRO), vidas, score y diamantes.
- Menú de pausa con Continuar, Reiniciar, Nueva partida, Tienda, Mis puntajes y Menú principal.
- Tienda de diamantes: pelajes (carey, tuxedo...) y accesorios. Los diamantes son solo estética, no dan ventajas.
- Monetización simulada: packs de diamantes y cuenta PRO con una pantalla de pago falsa (no se cobra nada).
- Banner de anuncios simulado (desaparece con PRO).
- Mis mejores puntajes (los últimos 20) y 10 logros.
- Modo claro y oscuro.
- Música lofi dentro del juego, miau y vibración al recolectar, y sonidos suaves de game over.

## Estructura

```
lib/
  main.dart            arranque, temas y avisos de logros
  game/                el juego (Flame): gatito, rascadores, objetos
  state/               estado de la app, catálogo de la tienda y logros
  ranking/             puntajes guardados en el celu
  audio/               música, sonidos y vibración
  ui/                  pantallas y widgets (inicio, juego, tienda, pago, logros...)
assets/
  audio/               sonidos (créditos en CREDITS.txt)
  fonts/               letra Sniglet (licencia OFL)
  icon/                ícono de la app
```

## Cómo correrlo

```
flutter pub get
flutter run
flutter test
```

Para generar el APK: `flutter build apk --release`.
