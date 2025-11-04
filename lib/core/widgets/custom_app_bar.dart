import 'package:ai_trip_planner/features/trip/presentation/provider/auth_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/landing_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            final authState = ref.read(authProvider);
            if (authState is Authenticated) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: authState.user),
                ),
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
