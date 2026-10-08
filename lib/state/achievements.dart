import 'package:material_ui/material_ui.dart';

// Lo que el jugador fue juntando a lo largo del tiempo. Los logros se
// calculan a partir de estos números.
class PlayerStats {
  const PlayerStats({
    this.fish = 0,
    this.yarn = 0,
    this.gems = 0,
    this.bestRound = 0,
    this.extras = 0,
  });

  final int fish; // pescados atrapados
  final int yarn; // ovillos atrapados
  final int gems; // diamantes juntados (no es el saldo: no baja al gastar)
  final int bestRound; // mejor score en una vuelta
  final int extras; // pelajes especiales y accesorios que tiene
}

// Un logro: se desbloquea cuando progress(stats) llega a target
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.progress,
  });

  final String id; // se guarda en el celu, por eso no hay que cambiarlo
  final String title;
  final String description;
  final IconData icon;
  final int target;
  final int Function(PlayerStats stats) progress;

  bool isUnlocked(PlayerStats stats) => progress(stats) >= target;
}

final achievements = <Achievement>[
  Achievement(
    id: 'first_flight',
    title: 'Primer vuelo',
    description: 'Pasá entre tu primer par de rascadores',
    icon: Icons.flight_rounded,
    target: 1,
    progress: (s) => s.bestRound,
  ),
  Achievement(
    id: 'flyer',
    title: 'Michi volador',
    description: 'Llegá a 10 puntos en una vuelta',
    icon: Icons.air_rounded,
    target: 10,
    progress: (s) => s.bestRound,
  ),
  Achievement(
    id: 'super_cat',
    title: 'Súper michi',
    description: 'Llegá a 25 puntos en una vuelta',
    icon: Icons.rocket_launch_rounded,
    target: 25,
    progress: (s) => s.bestRound,
  ),
  Achievement(
    id: 'first_fish',
    title: 'Primer pescado',
    description: 'Atrapá tu primer pescado',
    icon: Icons.set_meal_rounded,
    target: 1,
    progress: (s) => s.fish,
  ),
  Achievement(
    id: 'fisher',
    title: 'Pescador',
    description: 'Atrapá 25 pescados',
    icon: Icons.set_meal_rounded,
    target: 25,
    progress: (s) => s.fish,
  ),
  Achievement(
    id: 'first_yarn',
    title: 'Ovillo de lana',
    description: 'Atrapá tu primer ovillo',
    icon: Icons.toys_rounded,
    target: 1,
    progress: (s) => s.yarn,
  ),
  Achievement(
    id: 'yarn_fan',
    title: 'Fanático del ovillo',
    description: 'Atrapá 10 ovillos',
    icon: Icons.toys_rounded,
    target: 10,
    progress: (s) => s.yarn,
  ),
  Achievement(
    id: 'first_gem',
    title: 'Primer diamante',
    description: 'Juntá tu primer diamante',
    icon: Icons.diamond_rounded,
    target: 1,
    progress: (s) => s.gems,
  ),
  Achievement(
    id: 'collector',
    title: 'Coleccionista',
    description: 'Juntá 20 diamantes',
    icon: Icons.diamond_rounded,
    target: 20,
    progress: (s) => s.gems,
  ),
  Achievement(
    id: 'fashion',
    title: 'Michi a la moda',
    description: 'Conseguí un pelaje especial o un accesorio',
    icon: Icons.checkroom_rounded,
    target: 1,
    progress: (s) => s.extras,
  ),
];
