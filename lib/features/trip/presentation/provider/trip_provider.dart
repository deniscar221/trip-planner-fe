import 'package:ai_trip_planner/features/trip/domain/repositories/trip_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../injection_container.dart';
import '../../data/models/itinerary_response_model.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

final tripProvider =
    StateNotifierProvider<TripNotifier, AsyncValue<ItineraryResponseModel?>>(
        (ref) {
  return TripNotifier(sl<TripRepository>(), ref);
});

class TripNotifier extends StateNotifier<AsyncValue<ItineraryResponseModel?>> {
  final TripRepository _tripRepository;
  final Ref _ref;
  int? _tripId;

  TripNotifier(this._tripRepository, this._ref)
      : super(const AsyncValue.data(null));

  void setTrip(ItineraryResponse-Model trip) {
    _tripId = trip.id;
    state = AsyncValue.data(trip);
  }

  Future<void> finalize() async {
    if (_tripId != null) {
      await _tripRepository.finalizeTrip(_tripId!);
      _ref.invalidate(userTripsProvider);
    }
  }
}

final userTripsProvider =
    FutureProvider.autoDispose<List<ItineraryResponseModel>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState is Authenticated) {
    final allTrips = await sl<TripRepository>().getUserTrips();
    return allTrips.where((trip) => trip.finalized).toList();
  }
  return [];
});
