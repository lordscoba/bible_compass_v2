import 'package:bible_compass_app/domain/models/keyword/keyword.dart';
import 'package:bible_compass_app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class KeywordNotifier extends StateNotifier<KeywordState> {
  KeywordNotifier() : super(const KeywordState());

  Dio _dio() => Dio();

  Future<void> perfromCreateKeywordRequest(dynamic body, String catId) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = _dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final res = await dio.post(
        '${EnvironmentKeywordConfig.adminCreateKeywordUrl}$catId',
        data: body,
      );

      state = state.copyWith(
        isLoading: false,
        data: (res.data as Map).cast<String, dynamic>(),
        error: '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data is Map
            ? (e.response!.data['message']?.toString() ?? 'Request failed')
            : e.message ?? 'Request failed',
      );
    }
  }

  Future<void> perfromUpdateKeywordRequest(dynamic body, String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = _dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final res = await dio.patch(
        '${EnvironmentKeywordConfig.adminUpdateKeywordUrl}$id',
        data: body,
      );

      state = state.copyWith(
        isLoading: false,
        data: (res.data as Map).cast<String, dynamic>(),
        error: '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data is Map
            ? (e.response!.data['message']?.toString() ?? 'Request failed')
            : e.message ?? 'Request failed',
      );
    }
  }

  Future<KeywordState> perfromGetKeywordsRequest(
    String catId, {
    String search = '',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = _dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final res = await dio.get(
        '${EnvironmentKeywordConfig.adminGetKeywordsUrl}$catId',
        queryParameters: {'keyword': search},
      );

      state = state.copyWith(
        isLoading: false,
        data: (res.data as Map).cast<String, dynamic>(),
        error: '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data is Map
            ? (e.response!.data['message']?.toString() ?? 'Request failed')
            : e.message ?? 'Request failed',
      );
    }
    return state;
  }

  Future<KeywordState> perfromGetSingleKeywordRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = _dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final res = await dio.get(
        '${EnvironmentKeywordConfig.adminGetKeywordByIdUrl}$id',
      );

      state = state.copyWith(
        isLoading: false,
        data: (res.data as Map).cast<String, dynamic>(),
        error: '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data is Map
            ? (e.response!.data['message']?.toString() ?? 'Request failed')
            : e.message ?? 'Request failed',
      );
    }
    return state;
  }

  Future<KeywordState> performDeleteKeywordRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = _dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final res = await dio.delete(
        '${EnvironmentKeywordConfig.adminDeleteKeywordUrl}$id',
      );

      state = state.copyWith(
        isLoading: false,
        data: (res.data as Map).cast<String, dynamic>(),
        error: '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data is Map
            ? (e.response!.data['message']?.toString() ?? 'Request failed')
            : e.message ?? 'Request failed',
      );
    }
    return state;
  }

  Future<KeywordState> perfromGetKeywordStats() async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = _dio();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final res = await dio.get(
        EnvironmentKeywordConfig.adminGetKeywordsInfoUrl,
      );

      state = state.copyWith(
        isLoading: false,
        data: (res.data as Map).cast<String, dynamic>(),
        error: '',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data is Map
            ? (e.response!.data['message']?.toString() ?? 'Request failed')
            : e.message ?? 'Request failed',
      );
    }
    return state;
  }
}

/// Public fetcher used by the screen
final keywordApiProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, Tuple2<String, String>>((
      ref,
      tuple,
    ) async {
      try {
        final dio = Dio();
        final res = await dio.get(
          '${EnvironmentKeywordConfig.adminGetKeywordsUrl}${tuple.item1}',
          queryParameters: {'keyword': tuple.item2},
        );
        final data = res.data;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
        throw Exception('Unexpected response format');
      } on DioException catch (e) {
        if (kDebugMode) {
          debugPrint('keywordApiProvider error: ${e.message}');
        }
        // Return a consistent shape so the UI can show something
        return {
          'error': true,
          'message': e.message ?? 'Request failed',
          'data': const [],
        };
      }
    });
