import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/app.dart';
import 'package:onward/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main () async{
  WidgetsBinding widgetsBinding=WidgetsFlutterBinding.ensureInitialized();  
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(
    child: const MyApp(),
    ));
}

