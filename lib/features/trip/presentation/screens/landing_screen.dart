import 'package:ai_trip_planner/features/trip/presentation/provider/auth_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/plan_your_adventure_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/profile_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/login_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to AI Trip Planner',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlanYourAdventureScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Plan a Trip Anonymously'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => const LoginModal(),
                  );
                  if (result == true) {
                    final authState = ref.read(authProvider);
                    if (authState is Authenticated) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: authState.user),
                        ),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Sign in / Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
