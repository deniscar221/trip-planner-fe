import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'plan_your_adventure_state.g.dart';

@CopyWith(copyWithNull: true)
class PlanYourAdventureState extends Equatable {
  final List<String> selectedActivities;
  final String? destination;
  final bool isAiChoice;

  const PlanYourAdventureState({
    this.selectedActivities = const [],
    this.destination,
    this.isAiChoice = false,
  });

  @override
  List<Object?> get props => [selectedActivities, destination, isAiChoice];
}
