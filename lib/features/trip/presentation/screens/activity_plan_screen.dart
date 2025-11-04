import 'package:ai_trip_planner/core/theme/app_colors.dart';
import 'package:ai_trip_planner/core/widgets/custom_app_bar.dart';
import 'package:ai_trip_planner/core/widgets/error_state_widget.dart';
import 'package:ai_trip_planner/features/trip/data/models/itinerary_response_model.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/auth_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/provider/trip_provider.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/activity_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/activity_plan_bloc.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/activity_plan_event.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/activity_plan_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/activity_selection_modal.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/animated_list_item.dart';
import 'package:ai_trip_planner/features/trip/presentation/widgets/login_modal.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/profile_screen.dart';
import 'package:ai_trip_planner/injection_container.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityPlanScreen extends ConsumerWidget {
  final String? destination;
  final String? departureCity;
  final int? numberOfChildren;
  final int? numberOfAdults;
  final String? fromDate;
  final String? toDate;
  final List<String>? interests;
  final ItineraryResponseModel? trip;

  const ActivityPlanScreen({
    super.key,
    this.destination,
    this.departureCity,
    this.numberOfChildren,
    this.numberOfAdults,
    this.fromDate,
    this.toDate,
    this.interests,
    this.trip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<ActivityPlanBloc>();
        if (trip != null) {
          bloc.add(ViewTrip(trip!));
        } else {
          bloc.add(GetInitialActivityPlan(
            destination: destination!,
            departureCity: departureCity,
            numberOfChildren: numberOfChildren!,
            numberOfAdults: numberOfAdults!,
            fromDate: fromDate!,
            toDate: toDate!,
            interests: interests!,
          ));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Activity Plan'),
        backgroundColor: Colors.grey[100],
        body: BlocConsumer<ActivityPlanBloc, ActivityPlanState>(
          listener: (context, state) {
            if (state is ActivityPlanLoaded) {
              ref.read(tripProvider.notifier).setTrip(state.itinerary);

              if (state.suggestedActivities != null) {
                final bloc = context.read<ActivityPlanBloc>();
                showDialog(
                  context: context,
                  builder: (_) => ActivitySelectionModal(
                    activities: state.suggestedActivities!,
                    onActivitySelected: (activity) {
                      final tripId = state.itinerary.id;
                      final dayNumber = state.dayNumberForSuggestions;
                      if (dayNumber != null) {
                        bloc.add(
                            SelectActivityForDay(tripId, dayNumber, activity));
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ).then((_) {
                  bloc.add(ClearSuggestedActivities());
                });
              }
            }
          },
          builder: (context, state) {
            if (state is ActivityPlanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ActivityPlanLoaded) {
              final isButtonEnabled = state.itinerary.dayPlans
                  .any((day) => day.activities.isNotEmpty);

              return Column(
                children: [
                  Expanded(
                    child: _buildDayCards(context, state),
                  ),
                  if (trip == null)
                    _buildSaveTripButton(context, isButtonEnabled),
                ],
              );
            } else if (state is ActivityPlanError) {
              return ErrorStateWidget(
                message: 'Oops! Something went wrong.',
                onTryAgain: () {
                  final bloc = context.read<ActivityPlanBloc>();
                  if (trip != null) {
                    bloc.add(ViewTrip(trip!));
                  } else {
                    bloc.add(GetInitialActivityPlan(
                      destination: destination!,
                      departureCity: departureCity,
                      numberOfChildren: numberOfChildren!,
                      numberOfAdults: numberOfAdults!,
                      fromDate: fromDate!,
                      toDate: toDate!,
                      interests: interests!,
                    ));
                  }
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildDayCards(BuildContext context, ActivityPlanLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.itinerary.dayPlans.length,
      itemBuilder: (context, index) {
        final dayPlan = state.itinerary.dayPlans[index];
        final bool hasActivities = dayPlan.activities.isNotEmpty;
        final String? firstImage =
            hasActivities ? dayPlan.activities.first.image : null;

        return AnimatedListItem(
          index: index,
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: firstImage != null
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(firstImage),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          AppColors.black.withAlpha(128),
                          BlendMode.darken,
                        ),
                      ),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${dayPlan.dayNumber}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasActivities
                                ? AppColors.white
                                : Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityBubbles(context, state, dayPlan.dayNumber),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityBubbles(
      BuildContext context, ActivityPlanLoaded state, int dayNumber) {
    final dayPlan =
        state.itinerary.dayPlans.firstWhere((dp) => dp.dayNumber == dayNumber);
    final activities = dayPlan.activities;

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return AnimatedListItem(
            index: index,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivityDetailsScreen(activity: activity),
                  ),
                );
              },
              child: Hero(
                tag: activity.image ?? 'activity-hero-${activity.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(
                    child: activity.image != null
                        ? Image.network(
                            activity.image!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.local_activity,
                                  color: Colors.white);
                            },
                          )
                        : const Icon(Icons.local_activity,
                            color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        }),
        if (dayPlan.canFitAnotherActivityInTheSameDay && trip == null)
          AnimatedListItem(
            index: activities.length,
            child: GestureDetector(
              onTap: () {
                context.read<ActivityPlanBloc>().add(
                    GetSuggestedActivitiesForDay(
                        state.itinerary.id, dayNumber));
              },
              child: state.dayNumberForSuggestions == dayNumber
                  ? const SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                          child:
                              CircularProgressIndicator(strokeWidth: 2)))
                  : DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(30),
                      color: Colors.grey,
                      strokeWidth: 2,
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.transparent,
                        child: Icon(Icons.add,
                            color: Colors.grey, size: 30),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveTripButton(BuildContext context, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final authState = ref.watch(authProvider);

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              onPressed: isEnabled
                  ? () async {
                      if (authState is Authenticated) {
                        ref.read(tripProvider.notifier).finalize();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: authState.user),
                          ),
                        );
                      } else {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => const LoginModal(),
                        );
                        if (result == true) {
                          ref.read(tripProvider.notifier).finalize();
                          final updatedAuthState = ref.read(authProvider);
                          if (updatedAuthState is Authenticated) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(user: updatedAuthState.user),
                              ),
                            );
                          }
                        }
                      }
                    }
                  : null,
              child: const Text('Save Trip'),
            );
          },
        ),
      ),
    );
  }
}
