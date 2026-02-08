import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hisab_khata/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hisab_khata/firebase_options.dart';
import 'package:hisab_khata/services/fcm_service.dart';
import 'package:hisab_khata/core/di/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Dependency Injection
  DependencyInjection().init();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}
