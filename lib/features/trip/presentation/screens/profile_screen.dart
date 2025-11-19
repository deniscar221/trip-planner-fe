import 'package:ai_trip_planner/features/trip/data/models/user_model.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/trip_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/activity_plan_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/landing_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/plan_your_adventure_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/hearthstone_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ai_trip_planner/core/constants/app_constants.dart';

class ProfileScreen extends HookConsumerWidget {
  final User user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthInitial) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingScreen()),
          (route) => false,
        );
      }
    });

    final userTrips = ref.watch(userTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      NetworkImage('https://picsum.photos/seed/picsum/200/300'),
                ),
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
                OutlinedButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
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
                    final int numberOfDays = trip.dayPlans.length;
                    final imageUrl = trip.dayPlans.isNotEmpty &&
                            trip.dayPlans.first.activities.isNotEmpty
                        ? trip.dayPlans.first.activities.first.imageUrl
                        : null;

                    return HearthstoneCard(
                      imageUrl: imageUrl,
                      title: trip.destination,
                      description: '$numberOfDays days',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActivityPlanScreen(trip: trip),
                          ),
                        );
                      },
                      onShareTap: () {
                        final baseUrl = AppConstants.baseUrl
                            .substring(0, AppConstants.baseUrl.length - 5);
                        final shareableLink =
                            '$baseUrl/shared/${trip.shareableLink}';
                        Clipboard.setData(ClipboardData(text: shareableLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Trip link copied to clipboard!'),
                          ),
                        );
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) {
                  return Center(
                    child: Text('Error: $err'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PlanYourAdventureScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Plan my next trip'),
            ),
          ],
        ),
      ),
    );
  }
}
