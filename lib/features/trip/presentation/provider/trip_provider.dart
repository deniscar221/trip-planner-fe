
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/itinerary_response_model.dart';

final tripProvider =
    StateNotifierProvider<TripNotifier, AsyncValue<ItineraryResponseModel>>(
        (ref) {
  return TripNotifier();
});

class TripNotifier extends StateNotifier<AsyncValue<ItineraryResponseModel>> {
  TripNotifier() : super(const AsyncValue.loading());

  void finalize() async {
    // TODO finalize trip
  }
}

final userTripsProvider = FutureProvider<List<ItineraryResponseModel>>((ref) async {
  // TODO fetch user trips from API
  return [];
});
