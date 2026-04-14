import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hisab_khata/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hisab_khata/firebase_options.dart';
import 'package:hisab_khata/services/fcm_service.dart';
import 'package:hisab_khata/core/di/dependency_injection.dart';
import 'package:hisab_khata/core/storage/storage_service.dart';

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

  // Initialize FCM listeners at startup so foreground popups work even when
  // the user opens the app with an existing session.
  final accessToken = await StorageService.getAccessToken();
  await FCMService.initialize(authToken: accessToken);

  runApp(const MyApp());
}
