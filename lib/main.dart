import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/app.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(ProviderScope(
    child: const MyApp(),
    ));
}

