import 'package:ai_trip_planner/features/trip/presentation/bloc/plan_your_adventure_event.dart';
import 'package:ai_trip_planner/features/trip/presentation/bloc/plan_your_adventure_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlanYourAdventureBloc
    extends Bloc<PlanYourAdventureEvent, PlanYourAdventureState> {
  PlanYourAdventureBloc() : super(const PlanYourAdventureState()) {
    on<SelectActivity>(_onSelectActivity);
    on<DeselectActivity>(_onDeselectActivity);
    on<SelectDestination>(_onSelectDestination);
    on<ToggleAiChoice>(_onToggleAiChoice);
  }

  void _onSelectActivity(
      SelectActivity event, Emitter<PlanYourAdventureState> emit) {
    final updatedActivities = List<String>.from(state.selectedActivities)
      ..add(event.activity);
    emit(state.copyWith(selectedActivities: updatedActivities));
  }

  void _onDeselectActivity(
      DeselectActivity event, Emitter<PlanYourAdventureState> emit) {
    final updatedActivities = List<String>.from(state.selectedActivities)
      ..remove(event.activity);
    emit(state.copyWith(selectedActivities: updatedActivities));
  }

  void _onSelectDestination(
      SelectDestination event, Emitter<PlanYourAdventureState> emit) {
    emit(state.copyWith(destination: event.destination, isAiChoice: false));
  }

  void _onToggleAiChoice(
      ToggleAiChoice event, Emitter<PlanYourAdventureState> emit) {
    if (event.isAiChoice) {
      emit(state.copyWith(isAiChoice: true, forceNullDestination: true));
    } else {
      emit(state.copyWith(isAiChoice: false));
    }
  }
}
