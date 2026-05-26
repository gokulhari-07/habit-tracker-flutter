import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/features/auth/presentation/providers/auth_controller.dart';
import 'package:onward/features/habits/presentation/screens/home_screen.dart';

class AuthGateScreen extends ConsumerWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
     FlutterNativeSplash.remove();
    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.self_improvement,
                    size: 80,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Welcome to Onward',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Track habits. Build consistency.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signInWithGoogle();
                      },
                      child: const Text('Continue with Google'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                    child: const Text('Continue as Guest'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (e, _) => Scaffold(
        body: Center(
          child: Text(e.toString()),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}