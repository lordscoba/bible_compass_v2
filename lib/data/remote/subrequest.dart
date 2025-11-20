// lib/data/remote/subrequest.dart
import 'package:bible_compass_app/domain/models/subscription/subscription.dart';
import 'package:bible_compass_app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubNotifier extends StateNotifier<SubscriptionState> {
  SubNotifier() : super(const SubscriptionState());

  Future<Dio> _authedDio() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || JwtDecoder.isExpired(token)) {
      // caller will handle the user feedback
      throw DioException(
        requestOptions: RequestOptions(),
        error: 'Token has expired',
      );
    }
    dio.options.headers['Authorization'] = 'Bearer $token';
    return dio;
  }

  Future<void> performPayStackInitRequest(
    dynamic payload,
    String userId,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.post(
        '${EnvironmentSubConfig.paystackSubInit}$userId',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
  }

  Future<SubscriptionState> performGetVerifySubRequest(String rid) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.get(
        '${EnvironmentSubConfig.paystackSubVerify}$rid',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }

  Future<void> performCreateSubRequest(dynamic payload, String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.post(
        '${EnvironmentSubConfig.adminCreateSubscriptionUrl}$userId',
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
  }

  Future<void> performUpdateSubRequest(dynamic payload, String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.patch(
        '${EnvironmentSubConfig.adminUpdateSubscriptionUrl}$id',
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
  }

  Future<SubscriptionState> performGetSubsRequest({String search = ''}) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final url =
          '${EnvironmentSubConfig.adminGetSubscriptionsUrl}?username=$search&type=$search';
      final response = await dio.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }

  Future<SubscriptionState> performGetUserSubsRequests(
    String id, {
    String search = '',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.get(
        '${EnvironmentSubConfig.adminGetUserSubscriptions}$id',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }

  Future<SubscriptionState> performGetSingleSubRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.get(
        '${EnvironmentSubConfig.adminGetSubscriptionByIdUrl}$id',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }

  Future<SubscriptionState> performDeleteSubRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.delete(
        '${EnvironmentSubConfig.adminDeleteSubscriptionByIdUrl}$id',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }

  Future<SubscriptionState> performGetSubStats() async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.get(
        EnvironmentSubConfig.adminGetSubscriptionInfoUrl,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }

  Future<SubscriptionState> performGetUserSubStats(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();

      final response = await dio.get(
        '${EnvironmentSubConfig.adminGetUserSubscriptionsStats}$userId',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          error: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message'] ?? e.message,
      );
    }
    return state;
  }
}
