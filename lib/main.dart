import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:pothole_detector/geolocator.dart';
import 'package:pothole_detector/pothole_reporter.dart';

const int SAMPLE_RATE = 100;
const int THRESHOLD = 7;

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

  DateTime? lastRecordedAcc;
  DateTime? lastRecordedGyro;

  double accX = 0, accY = 0, accZ = 0;
  double gyroX = 0, gyroY = 0, gyroZ = 0;

  Position? currentPosition;

  bool isPothole = false;

  @override
  void initState() {
    super.initState();

    userAccelerometerEvents.listen((event) {
      DateTime? last = lastRecordedAcc;
      DateTime now = DateTime.now();
      int? diff = last != null
          ? now.millisecondsSinceEpoch - last.millisecondsSinceEpoch
          : null;

      if (diff == null || diff > SAMPLE_RATE) {
        setState(() {
          accX = event.x;
          accY = event.y;
          accZ = event.z;
          lastRecordedAcc = now;
          isPothole = isPothole || accZ > THRESHOLD;
          if (accZ > THRESHOLD) reportPothole(context, accZ);
        });
      }
    });

    gyroscopeEvents.listen((event) {
      DateTime? last = lastRecordedGyro;
      DateTime now = DateTime.now();
      int? diff = last != null
          ? now.millisecondsSinceEpoch - last.millisecondsSinceEpoch
          : null;

      if (diff == null || diff > SAMPLE_RATE) {
        setState(() {
          gyroX = event.x;
          gyroY = event.y;
          gyroZ = event.z;
          lastRecordedGyro = now;
        });
      }
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
            Text(
              'A{${accX.toStringAsFixed(2)},${accY.toStringAsFixed(2)},${accZ.toStringAsFixed(2)})'
              ' | '
              'G(${gyroX.toStringAsFixed(2)},${gyroY.toStringAsFixed(2)},${gyroZ.toStringAsFixed(2)})',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              currentPosition.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            IconButton(
              icon: Icon(
                Icons.circle,
                color: isPothole ? Colors.red : Colors.green,
              ),
              iconSize: 100,
              onPressed: () {
                setState(() {
                  isPothole = false;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isStarted ? Icons.pause : Icons.play_arrow),
        onPressed: () async {
          if (count.toString().endsWith("99")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Victory 🥳🥳🥳")),
            );
          }

          Position? pos;

          try {
            pos = await determinePosition();
          } catch (e) {
            print(e);
          }

          setState(() {
            count++;
            isStarted = !isStarted;
            currentPosition = pos;
          });
        },
      ),
    );
  }
}
