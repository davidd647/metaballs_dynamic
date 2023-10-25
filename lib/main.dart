import 'dart:math';
import 'package:flutter/material.dart';

import './opacity_filter.dart';

const rotationalSpeed = 0.1;
const radialOscillationSpeed = 0.42;
const radialOscillationAmplitude = 100.0;
const baseRadial = 50.0;
const ballSize = 100.0;

double degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dynamic Meta balls'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  late List<GMetaBall> gMetaBalls = [];

  @override
  void dispose() {
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();

    gMetaBalls.add(GMetaBall(position: const Offset(0, 0), frame: 0, size: ballSize));
    gMetaBalls.add(GMetaBall(position: const Offset(0, 0), frame: 0, size: ballSize));
    gMetaBalls.add(GMetaBall(position: const Offset(0, 0), frame: 0, size: ballSize));
  }

  int frame = 45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          gMetaBalls.add(GMetaBall(position: const Offset(0, 0), frame: frame, size: ballSize));
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.withOpacity(0.0),
              Colors.blueGrey.withOpacity(0.9),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                frame++;

                // update top/left of all PositionedBall's based on frame...
                double displacementFactor = 360 / gMetaBalls.length;
                for (var x = 0; x < gMetaBalls.length; x++) {
                  gMetaBalls[x] = moveG(gMetaBalls[x], maxHeight, maxWidth, frame, x * displacementFactor);
                }

                return Stack(
                  children: [
                    Stack(
                      children: [
                        ...gMetaBalls.map((GMetaBall ball) {
                          return PositionedBall(
                            top: ball.position.dy,
                            left: ball.position.dx,
                            ballSize: ballSize,
                          );
                        }),
                      ],
                    ),
                    OpacityFilter(
                      opacityFilterValue: 0.5,
                      color1: Colors.deepPurple.shade400,
                      color2: Colors.deepOrange.shade500,
                      child: Stack(
                        children: [
                          ...gMetaBalls.map((GMetaBall ball) {
                            return PositionedBall(
                              top: ball.position.dy,
                              left: ball.position.dx,
                              ballSize: ballSize,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PositionedBall extends StatelessWidget {
  const PositionedBall({
    super.key,
    required this.top,
    required this.left,
    required this.ballSize,
  });

  final double top;
  final double left;
  final double ballSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: ballSize,
        height: ballSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          // color: Colors.orange,
          gradient: RadialGradient(colors: [
            Colors.blueGrey.withOpacity(0.9),
            Colors.blueGrey.withOpacity(0.0),
          ]),
        ),
      ),
    );
  }
}

class GMetaBall {
  int frame;
  Offset position;
  double size;

  GMetaBall({
    required this.frame,
    required this.position,
    required this.size,
  });
}

GMetaBall moveG(GMetaBall ball, double maxHeight, double maxWidth, int frame, double degreesOffset) {
  double screenCenterY = maxHeight / 2;
  double screenCenterX = maxWidth / 2;
  double halfwayThroughBall = ball.size / 2;

  double radialOscillationY =
      (cos(degreesToRadians(frame.toDouble() * radialOscillationSpeed)) * radialOscillationAmplitude);
  double radialOscillationX =
      (sin(degreesToRadians(frame.toDouble() * radialOscillationSpeed)) * radialOscillationAmplitude);

  double top = screenCenterY -
      halfwayThroughBall +
      cos(degreesToRadians(frame.toDouble() * 0.005 + degreesOffset + frame * rotationalSpeed)) * radialOscillationY;

  double left = screenCenterX -
      halfwayThroughBall +
      sin(degreesToRadians(frame.toDouble() * 0.005 + degreesOffset + frame * rotationalSpeed)) * radialOscillationX;

  Offset newPos = Offset(left, top);

  return GMetaBall(frame: ball.frame, position: newPos, size: ball.size);
}
