import 'package:ai_trip_planner/core/widgets/custom_app_bar.dart';
import 'package:ai_trip_planner/features/trip/data/models/user_model.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/trip_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/hearthstone_card.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/login_modal.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SaveShareBookScreen extends StatefulHookConsumerWidget {
  const SaveShareBookScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SaveShareBookScreenState();
}

class _SaveShareBookScreenState extends ConsumerState<SaveShareBookScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: authState is Authenticated ? 'Your Profile' : 'Save My Trip',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authState is Authenticated
            ? UserProfileScreen(
                user: authState.user,
                onLogout: () => ref.read(authProvider.notifier).logout(),
              )
            : Center(
                child: ElevatedButton(
                  onPressed: () => _showLoginModal(context),
                  child: const Text('Save My Trip'),
                ),
              ),
      ),
    );
  }

  void _showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LoginModal(
        onLoginSuccess: () {
          ref.read(tripProvider.notifier).finalize();
        },
      ),
    );
  }
}

class UserProfileScreen extends HookConsumerWidget {
  final User user;
  final VoidCallback onLogout;

  const UserProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTrips = ref.watch(userTripsProvider);

    return Column(
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username,
                    style: Theme.of(context).textTheme.titleLarge),
                Text(user.email),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('My Trips', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 16),
        Expanded(
          child: userTrips.when(
            data: (trips) => ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return HearthstoneCard(
                  title: trip.destination,
                  description: '${trip.numberOfDays} days',
                  // TODO: on tap to trip details
                  onTap: () {},
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}
