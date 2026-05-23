# 🎮 Brick Breaker - Flutter

Un jeu Brick Breaker classique développé avec Flutter,
sans utiliser de moteur de jeu externe (pas de Flame).

## Aperçu

- Balle qui rebondit sur les murs et la raquette
- Briques normales et briques dures (2 coups)
- Score en temps réel avec système de combo
- 5 niveaux progressifs
- 3 vies avec indicateur visuel

## Technologies utilisées

- Flutter / Dart
- `Timer.periodic` pour la boucle de jeu
- `Align` + `Alignment` pour positionner la balle et la raquette
- `GestureDetector` pour déplacer la raquette au doigt
- `KeyboardListener` pour les touches clavier

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Contrôles

| Touche | Action |
|--------|--------|
| ⬅️ ➡️ Flèches | Déplacer la raquette |
| ESPACE | Lancer la balle |
| ÉCHAP | Pause / Reprendre |

## Fonctionnalités

- ✅ Mouvement de la balle
- ✅ Rebond sur les murs et le plafond
- ✅ Collision balle / raquette avec angle dynamique
- ✅ Collision balle / briques
- ✅ Briques dures (nécessitent 2 coups)
- ✅ Score avec multiplicateur de combo
- ✅ 5 niveaux (vitesse et difficulté progressives)
- ✅ 3 vies
- ✅ Pause
- ✅ Écrans Game Over / Victoire
- ✅ Contrôle clavier (flèches + espace)
- ✅ Contrôle tactile (glisser + tap)

## Auteur

**AB-060** - [github.com/AB-060](https://github.com/AB-060)