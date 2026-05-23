import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BrickBreaker());
}

class BrickBreaker extends StatelessWidget {
  const BrickBreaker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brick Breaker",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  int lives = 3;
  int level = 1;
  bool gameOver = false;
  bool won = false;
  bool paused = false;
  bool ballLaunched = false;

  double bx = 0;
  double by = 0.7;
  double bdx = 0.012;
  double bdy = -0.012;
  double barX = 0;
  double barWidth = 0.35;

  List<List<int>> bricks = []; // 0=vide, 1=normal, 2=dur (2 coups)
  int combo = 0;
  int maxCombo = 0;

  final List<Color> rowColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  final List<Color> hardBrickColors = [
    Colors.red.shade900,
    Colors.deepOrange.shade900,
    Colors.amber.shade900,
    Colors.teal.shade900,
    Colors.indigo.shade900,
  ];

  final FocusNode _focusNode = FocusNode();
  bool _leftPressed = false;
  bool _rightPressed = false;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _resetBricks();
    _startGame();
  }

  void _resetBricks() {
    final rand = Random();
    bricks = List.generate(
      5,
      (i) => List.generate(10, (j) => rand.nextDouble() < 0.15 ? 2 : 1),
    );
  }

  double get _speed => 0.012 + (level - 1) * 0.003;

  void _startGame() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (time) {
      if (paused || gameOver || won || !ballLaunched) return;
      setState(() {
        // Mouvement barre
        if (_leftPressed) {
          barX -= 0.045;
          if (barX - barWidth / 2 < -1) barX = -1 + barWidth / 2;
        }
        if (_rightPressed) {
          barX += 0.045;
          if (barX + barWidth / 2 > 1) barX = 1 - barWidth / 2;
        }

        bx += bdx;
        by += bdy;

        // Rebond murs gauche/droite
        if (bx - 0.02 < -1 || bx + 0.02 > 1) bdx = -bdx;
        // Rebond plafond
        if (by - 0.02 < -1) bdy = bdy.abs();

        // Rebond barre
        if (by + 0.02 > 0.85 &&
            by + 0.02 < 0.95 &&
            bx > barX - barWidth / 2 &&
            bx < barX + barWidth / 2) {
          bdy = -bdy.abs();
          double hitPos = (bx - barX) / (barWidth / 2);
          bdx = hitPos * 0.025;
          combo = 0;
        }

        // Balle perdue
        if (by > 1.08) {
          lives--;
          combo = 0;
          if (lives <= 0) {
            gameOver = true;
          } else {
            bx = barX;
            by = 0.7;
            bdx = _speed;
            bdy = -_speed;
            ballLaunched = false;
          }
        }

        // Collision briques
        bool anyBrick = false;
        for (int i = 0; i < bricks.length; i++) {
          for (int j = 0; j < bricks[i].length; j++) {
            if (bricks[i][j] > 0) {
              anyBrick = true;
              double brickW = 2 / 10;
              double brickH = 0.11;
              double brickX = -1 + j * brickW + brickW / 2;
              double brickY = -1 + i * brickH + brickH / 2;
              if ((bx - brickX).abs() < brickW / 2 &&
                  (by - brickY).abs() < brickH / 2) {
                bricks[i][j]--;
                bdy = -bdy;
                combo++;
                if (combo > maxCombo) maxCombo = combo;
                int pts = (5 - i) * 10 * level;
                if (combo > 1) pts = (pts * (1 + combo * 0.5)).toInt();
                score += pts;
              }
            }
          }
        }
        if (!anyBrick) {
          // Niveau suivant
          level++;
          barWidth = (0.35 - (level - 1) * 0.02).clamp(0.15, 0.35);
          _resetBricks();
          bx = barX;
          by = 0.7;
          bdx = _speed;
          bdy = -_speed;
          ballLaunched = false;
          if (level > 5) won = true;
        }
      });
    });
  }

  void _restartGame() {
    setState(() {
      score = 0;
      lives = 3;
      level = 1;
      gameOver = false;
      won = false;
      paused = false;
      ballLaunched = false;
      bx = 0;
      by = 0.7;
      bdx = _speed;
      bdy = -_speed;
      barX = 0;
      barWidth = 0.35;
      combo = 0;
      maxCombo = 0;
      _resetBricks();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    final isDown = event is KeyDownEvent;
    final isUp = event is KeyUpEvent;

    if (isDown) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _leftPressed = true;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _rightPressed = true;
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (!ballLaunched && !gameOver && !won) {
          ballLaunched = true;
        } else {
          setState(() => paused = !paused);
        }
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        setState(() => paused = !paused);
      }
    }
    if (isUp) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _leftPressed = false;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _rightPressed = false;
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildOverlay(String title, String subtitle) {
    return Container(
      color: Colors.black.withOpacity(0.80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Combo max : $maxCombo",
                style: const TextStyle(color: Colors.amberAccent, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _restartGame,
              icon: const Icon(Icons.refresh),
              label: const Text("Rejouer"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.indigo.shade900,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Vies
              Row(
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.favorite,
                    color: i < lives ? Colors.red : Colors.grey.shade800,
                    size: 20,
                  ),
                ),
              ),
              // Score + Level
              Column(
                children: [
                  Text("SCORE : $score",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("NIVEAU $level",
                      style: const TextStyle(
                          fontSize: 11, color: Colors.amberAccent)),
                ],
              ),
              // Combo + Pause
              Row(
                children: [
                  if (combo > 1)
                    Text("x$combo",
                        style: const TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  IconButton(
                    icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                    onPressed: () => setState(() => paused = !paused),
                  ),
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            // Briques
            Column(
              children: [
                for (int i = 0; i < bricks.length; i++)
                  Row(
                    children: [
                      for (int j = 0; j < bricks[i].length; j++)
                        Expanded(
                          child: bricks[i][j] > 0
                              ? Container(
                                  height: 22,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: bricks[i][j] == 2
                                        ? hardBrickColors[i]
                                        : rowColors[i],
                                    borderRadius: BorderRadius.circular(3),
                                    border: bricks[i][j] == 2
                                        ? Border.all(
                                            color: Colors.white30, width: 1.5)
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: rowColors[i].withOpacity(0.4),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: bricks[i][j] == 2
                                      ? const Center(
                                          child: Text("■",
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: Colors.white30)))
                                      : null,
                                )
                              : const SizedBox(height: 22),
                        ),
                    ],
                  ),
              ],
            ),

            // Balle
            Align(
              alignment: Alignment(bx, by),
              child: Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white.withOpacity(0.9), blurRadius: 10)
                  ],
                ),
              ),
            ),

            // Message lancer balle
            if (!ballLaunched && !gameOver && !won && !paused)
              Align(
                alignment: const Alignment(0, 0.3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Appuie sur ESPACE pour lancer",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),

            // Barre
            Align(
              alignment: Alignment(barX, 0.92),
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    barX += details.delta.dx /
                        MediaQuery.of(context).size.width *
                        2;
                    if (barX - barWidth / 2 < -1) barX = -1 + barWidth / 2;
                    if (barX + barWidth / 2 > 1) barX = 1 - barWidth / 2;
                    if (!ballLaunched) bx = barX;
                  });
                },
                onTap: () {
                  if (!ballLaunched && !gameOver && !won) {
                    setState(() => ballLaunched = true);
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * barWidth,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.7),
                          blurRadius: 10)
                    ],
                  ),
                ),
              ),
            ),

            // Pause overlay
            if (paused && !gameOver && !won)
              _buildOverlay("⏸ PAUSE", "Appuie sur Échap pour continuer"),

            // Game Over overlay
            if (gameOver)
              _buildOverlay("💀 GAME OVER", "Score final : $score"),

            // Win overlay
            if (won)
              _buildOverlay("🎉 VICTOIRE !", "Score final : $score"),
          ],
        ),
      ),
    );
  }
}