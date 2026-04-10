import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/app.dart';

void main () {
  WidgetsBinding widgetsBinding=WidgetsFlutterBinding.ensureInitialized();  
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ProviderScope(
    child: const MyApp(),
    ));
}

