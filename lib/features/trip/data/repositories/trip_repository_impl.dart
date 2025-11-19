import 'dart:convert';

import 'package:ai_trip_planner/core/constants/app_constants.dart';
import 'package:ai_trip_planner/core/network/error_interceptor.dart';
import 'package:ai_trip_planner/core/network/logging_interceptor.dart';
import 'package:ai_trip_planner/features/trip/data/models/itinerary_response_model.dart';
import 'package:ai_trip_planner/features/trip/data/models/suggested_city_model.dart';
import 'package:ai_trip_planner/features/trip/data/models/activity_model.dart';
import 'package:ai_trip_planner/features/trip/domain/repositories/trip_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TripRepositoryImpl implements TripRepository {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  TripRepositoryImpl(
      {required this.dio,
      required this.secureStorage,
      required ProviderContainer container}) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(container),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    ]);
  }

  @override
  Future<List<SuggestedCityModel>> getSuggestedCities(
      List<String> preferences) async {
    final response = await dio.post(
      'trip/suggestions/cities',
      data: {'preferences': preferences},
    );
    return (response.data as List)
        .map((city) => SuggestedCityModel.fromJson(city))
        .toList();
  }

  @override
  Future<ItineraryResponseModel> startTrip(
      String destination,
      String startDate,
      String endDate,
      int numberOfAdults,
      int numberOfChildren) async {
    final response = await dio.post(
      'trip/start',
      data: {
        'destination': destination,
        'startDate': startDate,
        'endDate': endDate,
        'numberOfAdults': numberOfAdults,
        'numberOfChildren': numberOfChildren,
      },
    );
    return ItineraryResponseModel.fromJson(response.data);
  }

  @override
  Future<List<ActivityModel>> getSuggestedActivities(
      int tripId, int dayNumber) async {
    final response =
        await dio.get('trip/$tripId/days/$dayNumber/suggestions/activities');

    final activities = (response.data as List)
        .map((activity) => ActivityModel.fromJson(activity))
        .toList();

    for (var activity in activities) {
      if (activity.imageUrl ==
          'https://asiapioneertravel.com/wp-content/uploads/2024/10/imperial-citadel-of-Thang-Long.jpg') {
        activity.imageUrl =
            'https://hanoi-vietnam.com/wp-content/uploads/2024/02/thang-long-imperial-citadel-1.jpg';
      } else if (activity.imageUrl ==
          'http://www.vietnamairlines.com/~/media/SEO-images/2025%20SEO/Traffic%20TA/MB/Ngoc%20Son%20Temple/ngoc-son-temple-thumb.jpg') {
        activity.imageUrl =
            'https://media.istockphoto.com/id/1155301593/photo/ngoc-son-temple-at-hoan-kiem-lake-in-hanoi-vietnam.jpg?s=612x612&w=0&k=20&c=2-v2UFV_39o-Rk5q4sL2s2_9tD1s7_f33i7N4v5ze54=';
      }
    }

    return activities;
  }

  @override
  Future<ItineraryResponseModel> selectActivity(
      int tripId, int dayNumber, ActivityModel activity) async {
    final response = await dio.post(
      'trip/$tripId/days/$dayNumber/activities',
      data: activity.toJson(),
    );
    return ItineraryResponseModel.fromJson(response.data);
  }

  @override
  Future<String> signIn(String username, String password) async {
    final response = await dio.post(
      'auth/signin',
      data: {'username': username, 'password': password},
    );
    Map<String, dynamic> data =
        response.data is String ? json.decode(response.data) : response.data;
    return data['accessToken'];
  }

  @override
  Future<String> signUp(String username, String email, String password) async {
    await dio.post(
      'auth/signup',
      data: {'username': username, 'email': email, 'password': password},
    );
    return signIn(username, password);
  }

  @override
  Future<void> finalizeTrip(int tripId) async {
    await dio.post('trip/$tripId/finalize');
  }

  @override
  Future<List<ItineraryResponseModel>> getUserTrips() async {
    final response = await dio.get('trips');
    return (response.data as List)
        .map((trip) => ItineraryResponseModel.fromJson(trip))
        .toList();
  }
}
