import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:krishfarm/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await Permission.camera.request();
  // await Permission.microphone.request();
  runApp(App());
}
