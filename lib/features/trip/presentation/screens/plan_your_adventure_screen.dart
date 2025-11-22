import 'package:ai_trip_planner/core/widgets/custom_app_bar.dart';
import 'package:ai_trip_planner/features/trip/domain/repositories/trip_repository.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/plan_your_adventure_bloc.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/plan_your_adventure_event.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/plan_your_adventure_state.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/suggested_cities_screen.dart';
import 'package:ai_trip_planner/features/trip/presentation/screens/trip_details_screen.dart';
import 'package:ai_trip_planner/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_trip_planner/core/theme/app_colors.dart';

class PlanYourAdventureScreen extends StatelessWidget {
  const PlanYourAdventureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlanYourAdventureBloc>(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Plan Your Adventure'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<PlanYourAdventureBloc, PlanYourAdventureState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your dream activities and let us plan the perfect trip!',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          _buildActivityGrid(context, state),
                          const SizedBox(height: 24),
                          _buildDestinationSelection(context, state),
                        ],
                      ),
                    ),
                  ),
                  _buildNextButton(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGrid(
      BuildContext context, PlanYourAdventureState state) {
    final activities = [
      {'icon': Icons.hiking, 'label': 'Hiking'},
      {'icon': Icons.beach_access, 'label': 'Beach'},
      {'icon': Icons.museum, 'label': 'Museums'},
      {'icon': Icons.restaurant, 'label': 'Food Tours'},
      {'icon': Icons.nightlife, 'label': 'Nightlife'},
      {'icon': Icons.snowboarding, 'label': 'Skiing'},
      {'icon': Icons.pets, 'label': 'Wildlife'},
      {'icon': Icons.account_balance, 'label': 'Historical Sites'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final label = activity['label'] as String;
        final isSelected = state.selectedActivities.contains(label);

        return GestureDetector(
          onTap: () {
            if (isSelected) {
              context
                  .read<PlanYourAdventureBloc>()
                  .add(DeselectActivity(label));
            } else {
              context
                  .read<PlanYourAdventureBloc>()
                  .add(SelectActivity(label));
            }
          },
          child: Card(
            elevation: isSelected ? 8 : 2,
            color: isSelected
                ? Theme.of(context).primaryColor.withAlpha(204)
                : AppColors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  activity['icon'] as IconData,
                  size: 35,
                  color: isSelected ? AppColors.white : AppColors.black,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationSelection(
      BuildContext context, PlanYourAdventureState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          initialValue: TextEditingValue(text: state.destination ?? ''),
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            try {
              return await sl<TripRepository>()
                  .getCitySuggestions(textEditingValue.text);
            } catch (e) {
              return const Iterable<String>.empty();
            }
          },
          onSelected: (String selection) {
            context
                .read<PlanYourAdventureBloc>()
                .add(SelectDestination(selection));
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: !state.isAiChoice,
              decoration: const InputDecoration(
                labelText: 'Choose your destination',
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Switch(
              value: state.isAiChoice,
              onChanged: (value) {
                context
                    .read<PlanYourAdventureBloc>()
                    .add(ToggleAiChoice(value));
              },
            ),
            const SizedBox(width: 8),
            const Text('Let AI choose for me'),
          ],
        ),
        const Text(
          "Based on your selected activities, we'll suggest the best destination for you.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNextButton(
      BuildContext context, PlanYourAdventureState state) {
    final isEnabled = (state.destination != null &&
            state.destination!.isNotEmpty) ||
        state.isAiChoice;

    return Center(
      child: ElevatedButton(
        onPressed: isEnabled
            ? () async {
                if (state.isAiChoice) {
                  final preferencesForApi = state.selectedActivities
                      .map((activity) =>
                          activity.toLowerCase().replaceAll(' ', '_'))
                      .toList();
                  if (!context.mounted) return;
                  final selectedCity = await Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, _, __) => SuggestedCitiesScreen(
                        preferences: preferencesForApi,
                      ),
                    ),
                  );

                  if (selectedCity != null) {
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(
                          destination: selectedCity,
                          selectedActivities: state.selectedActivities,
                        ),
                      ),
                    );
                  }
                } else {
                  if (!context.mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripDetailsScreen(
                        destination: state.destination!,
                        selectedActivities: state.selectedActivities,
                      ),
                    ),
                  );
                }
              }
            : null,
        child: const Text('Next'),
      ),
    );
  }
}
