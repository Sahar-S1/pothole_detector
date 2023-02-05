import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pothole_detector/geolocator.dart';

const String TOKEN = "xmLHqhccNdNafFLFqVKXFL127l3Ethyl";
const String ENDPOINT = "https://app.ies.vsit.appsinfra.in/";

var dio = Dio(
  BaseOptions(
    baseUrl: ENDPOINT,
  ),
);

Future<void> reportPothole(BuildContext ctx, double accZ) async {
  var pos = await determinePosition();

  var res = await dio.post(
    'items/pothole',
    options: Options(
      headers: {
        "Authorization": "Bearer $TOKEN",
      },
    ),
    data: {
      "location": {
        "coordinates": [pos.longitude, pos.latitude],
        "type": "Point",
      },
      "severity": accZ,
    },
  );

  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(res.data.toString()),
    ),
  );
}
