import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pothole Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pothole Detector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int count = 0;
  bool isStarted = false;

  double accX = 0, accY = 0, accZ = 0;
  double gyroX = 0, gyroY = 0, gyroZ = 0;

  @override
  void initState() {
    super.initState();

    userAccelerometerEvents.listen((event) {
      setState(() {
        accX = event.x;
        accY = event.y;
        accZ = event.z;
      });
    });

    gyroscopeEvents.listen((event) {
      setState(() {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            Text('A{$accX,$accY,$accZ) | G($gyroX,$gyroY,$gyroZ)'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isStarted ? Icons.pause : Icons.play_arrow),
        onPressed: () {
          setState(() {
            count++;
            isStarted = !isStarted;
          });
        },
      ),
    );
  }
}
