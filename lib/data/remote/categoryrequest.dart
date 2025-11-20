import 'package:bible_compass_app/domain/models/category/category.dart';
import 'package:bible_compass_app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(const CategoryState());

  Future<Dio> _authedDio() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      throw StateError('token has expired');
    }
    return dio;
  }

  // CREATE
  Future<void> performCreateCategoryRequest(Map<String, dynamic> body) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();
      final res = await dio.post(
        EnvironmentCategoryConfig.adminCreateCategoryUrl,
        data: body,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: res.data, error: '');
      }
    } on StateError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message']?.toString() ?? e.message ?? 'Error',
      );
    }
  }

  // UPDATE
  Future<void> performUpdateCategoryRequest(
    Map<String, dynamic> body,
    String id,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();
      final res = await dio.patch(
        EnvironmentCategoryConfig.adminUpdateCategoryUrl + id,
        data: body,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: res.data, error: '');
      }
    } on StateError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message']?.toString() ?? e.message ?? 'Error',
      );
    }
  }

  // LIST (public in your comment—no auth header)
  Future<CategoryState> performGetCategoriesRequest({
    String search = '',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = Dio();
      final res = await dio.get(
        "${EnvironmentCategoryConfig.adminGetCategoriesUrl}?category_name=$search",
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: res.data, error: '');
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message']?.toString() ?? e.message ?? 'Error',
      );
    }
    return state;
  }

  // SINGLE
  Future<CategoryState> performGetSingleCategoryRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();
      final res = await dio.get(
        EnvironmentCategoryConfig.adminGetCategoryByIdUrl + id,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: res.data, error: '');
      }
    } on StateError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message']?.toString() ?? e.message ?? 'Error',
      );
    }
    return state;
  }

  // DELETE
  Future<CategoryState> performDeleteCategoryRequest(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();
      final res = await dio.delete(
        EnvironmentCategoryConfig.adminDeleteCategoryUrl + id,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: res.data, error: '');
      }
    } on StateError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message']?.toString() ?? e.message ?? 'Error',
      );
    }
    return state;
  }

  // STATS
  Future<CategoryState> performGetCategoryStats() async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = await _authedDio();
      final res = await dio.get(
        EnvironmentCategoryConfig.adminGetCategoryInfoUrl,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        state = state.copyWith(isLoading: false, data: res.data, error: '');
      }
    } on StateError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['message']?.toString() ?? e.message ?? 'Error',
      );
    }
    return state;
  }
}
