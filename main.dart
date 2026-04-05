import 'dart:async';

import 'package:flutter/material.dart';

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
  double bx = 0;
  double by = 0;
  double bdx = 0.01;
  double bdy = -0.01;
  double barX = 0;
  final double barWidth = 0.3; 
  List<List<bool>> bricks = List.generate(5, (i) => List.generate(10, (j) => true));
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 16),(time){
      setState(() {
        bx+=bdx;
        by+=bdy;
        if (bx-0.02<-1||bx+0.02>1) {
          bdx=-bdx;
        }
        if (by+0.02>0.9&&
            bx>barX-barWidth/2&&
            bx<barX+barWidth/2
        ) {
          bdy=-bdy;
        }if (by>1) {
          bx=0;by=0;
        }
        for (int i = 0; i < bricks.length; i++) {
          for (int j = 0; j < bricks[i].length; j++) {
            if (bricks[i][j]) {
              double brickWidth = 2 / 10;
              double brickHeight = 0.1;
              double brickX = -1 + j * brickWidth + brickWidth / 2;
              double brickY = -1 + i * brickHeight + brickHeight / 2;
              if ((bx - brickX).abs() < brickWidth / 2 &&
                  (by - brickY).abs() < brickHeight / 2) {
                bricks[i][j] = false; 
                bdy = -bdy; 
                score++; 
              }
            }
          }
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        centerTitle: true,
        title: Text(
          "SCORE : $score",
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                bx = 0;
                by = 0;
                score = 0;
                bricks = List.generate(5, (i) => List.generate(10, (j) => true));
              });
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Briques
          Column(
            children: [
              for (int i = 0; i < bricks.length; i++) ...[
                Row(
                  children: [
                    for (int j = 0; j < bricks[i].length; j++) ...[
                      Expanded(
                        child: bricks[i][j]
                            ? Container(
                                height: 20,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.brown,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ]
                  ],
                ),
              ]
            ],
          ),
          Align(
            alignment: Alignment(bx, by),
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          // barre
          Align(
            alignment: Alignment(barX, 0.95),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  barX += details.delta.dx / MediaQuery.of(context).size.width * 2;
                  if (barX - barWidth / 2 < -1) barX = -1 + barWidth / 2;
                  if (barX + barWidth / 2 > 1) barX = 1 - barWidth / 2;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * barWidth,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
