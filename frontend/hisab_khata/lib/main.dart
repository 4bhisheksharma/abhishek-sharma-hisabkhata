import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hisab_khata/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hisab_khata/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
