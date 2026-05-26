import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onward/features/auth/presentation/providers/auth_controller.dart';

class AuthTestScreen extends ConsumerWidget {
  const AuthTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    FlutterNativeSplash.remove();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .signInWithGoogle();
                },
                child: const Text('Sign in with Google'),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user.photoUrl != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.photoUrl!),
                  ),

                const SizedBox(height: 16),

                Text(
                  user.name ?? 'No Name',
                  style: const TextStyle(fontSize: 20),
                ),

                Text(user.email ?? 'No Email'),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signOut();
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
