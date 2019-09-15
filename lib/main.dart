import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamebling',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var zombies = [];
  Stopwatch lastZombieCreate = new Stopwatch();
  ui.Image zombieImage;
  bool isImageloaded = false;

  initZombiesTimer() {
    Timer.periodic(Duration(milliseconds: 50), (Timer t) {
      if (lastZombieCreate.elapsedMilliseconds > 3000) {
        createZombie();
        lastZombieCreate.reset();
      }
      for (var i = 0; i < zombies.length; i++) {
        zombies[i]['x'] = zombies[i]['x'] - 1;
      }
      this.setState(() {
        zombies = zombies;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    lastZombieCreate.start();
    initZombiesTimer();
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load('images/zombie.png');
    zombieImage = await loadImage(new Uint8List.view(data.buffer));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          painter: Field(zombies: zombies, zombieImage: zombieImage),
        ),
      ),
    );
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  createZombie() {
    var zombie = {
      'leg_angle': 0,
      'hand_angle': 0,
      'x': MediaQuery.of(context).size.width,
      'y': new Random().nextInt(5),
      'type': Random().nextInt(10)%2 == 0 ? 'zombie' : 'black'
    };
    zombies.add(zombie);
    this.setState(() {
      zombies = zombies;
    });
  }
}

class Field extends CustomPainter {
  double fieldW;
  double offsetTop;

  var zombies;
  ui.Image zombieImage;

  Field({this.zombies, this.zombieImage});

  @override
  void paint(Canvas canvas, Size size) {
    drawFields(canvas, size);
    drawZombies(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }


  void drawFields(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color.fromARGB(255, 41, 158, 30)
      ..style = PaintingStyle.fill;

    var paint2 = Paint()
      ..color = Color.fromARGB(255, 45, 122, 38)
      ..style = PaintingStyle.fill;

    fieldW = (size.width) / 13;
    offsetTop = (size.height - (fieldW * 6)) / 2;

    for (var i = 0; i < 6; i++) {
      for (var a = 0; a < 15; a++) {
        var offset = Offset(a * fieldW, i * fieldW + offsetTop);
        if (i % 2 == 0) {
          if (a % 2 == 0) {
            drawField(canvas, paint1, offset);
          } else {
            drawField(canvas, paint2, offset);
          }
        } else {
          if (a % 2 == 0) {
            drawField(canvas, paint2, offset);
          } else {
            drawField(canvas, paint1, offset);
          }
        }
      }
    }
  }

  void drawField(Canvas canvas, Paint paint, Offset offset) {
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, fieldW, fieldW), paint);
  }

  void drawZombies(Canvas canvas) {
    for (var zombie in zombies) {
      drawZombie(canvas, zombie);
    }
  }

  void drawZombie(Canvas canvas, var zombie) {
    var origin = zombie['y'];
    var paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    stdout.writeln(zombie['y']);

    if (zombie['type'] == 'black') {
      canvas.drawCircle(Offset(zombie['x'].toDouble(), origin * fieldW + offsetTop), 5, paint);
      canvas.drawRect(Rect.fromLTWH(zombie['x'].toDouble(), origin * fieldW + offsetTop + 6, 3.toDouble(), 17.toDouble()), paint);
      canvas.drawRect(Rect.fromLTWH(zombie['x'] - 10.toDouble(), origin * fieldW + offsetTop + 7, 10.toDouble(), 2.toDouble()), paint);
      canvas.drawRect(Rect.fromLTWH(zombie['x'] - 10.toDouble(), origin * fieldW + offsetTop + 7, 10.toDouble(), 2.toDouble()), paint);
      canvas.drawRect(Rect.fromLTWH(zombie['x'] - 1.toDouble(), origin * fieldW + offsetTop + 22, 2.toDouble(), 20.toDouble()), paint);
      canvas.drawRect(Rect.fromLTWH(zombie['x'] + 2.toDouble(), origin * fieldW + offsetTop + 22, 2.toDouble(), 20.toDouble()), paint);
    } else {
      if (zombieImage != null) {
        canvas.drawImage(zombieImage, Offset(zombie['x'].toDouble(), origin * fieldW + offsetTop), paint);
      }
    }
  }
}
