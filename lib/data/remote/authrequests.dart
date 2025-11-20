// authrequests.dart
import 'dart:convert';
import 'package:bible_compass_app/domain/models/user/user.dart';
import 'package:bible_compass_app/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_compass_app/domain/providers/authproviders.dart';

class SignUpNotifier extends StateNotifier<UserState> {
  SignUpNotifier(this.ref) : super(const UserState());
  final Ref ref;

  Future<void> performSignupRequest(Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = Dio();

      final response = await dio.post(
        EnvironmentUserConfig.signUpUrl,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data as Map<String, dynamic>,
          error: '',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        state = state.copyWith(
          isLoading: false,
          error: e.response?.data['message'],
        );
      } else {
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message.toString());
        state = state.copyWith(isLoading: false, error: e.message.toString());
      }
    }
  }

  Future<void> performVerifyUserRequest(Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = Dio();

      final response = await dio.post(
        EnvironmentUserConfig.verifyUpUrl,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data as Map<String, dynamic>,
          error: '',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        state = state.copyWith(
          isLoading: false,
          error: e.response?.data['message'],
        );
      } else {
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message.toString());
        state = state.copyWith(isLoading: false, error: e.message.toString());
      }
    }
  }
}

class LoginNotifier extends StateNotifier<AuthState> {
  LoginNotifier(this.ref) : super(const AuthState());
  final Ref ref;

  Future<void> performLogin(Map<String, dynamic> payload) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = Dio();

      final response = await dio.post(
        EnvironmentUserConfig.loginUpUrl,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        state = state.copyWith(isLoading: false, data: data, error: '');

        // Persist login snapshot
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('details', jsonEncode(data));
        await prefs.setString('email', data['data']['email'].toString());
        await prefs.setString('username', data['data']['username'].toString());
        await prefs.setString('type', data['data']['type'].toString());
        await prefs.setString('token', data['data']['token'].toString());
        await prefs.setString(
          'token_type',
          data['data']['token_type'].toString(),
        );
        await prefs.setBool('upgrade', data['data']['upgrade'] as bool);
        await prefs.setBool('status', true);

        // ✅ Notify router/auth listeners
        ref.read(authEventsProvider).add(true);
        // Optionally keep legacy flag in sync:
        ref.read(isAuthenticated.notifier).state = true;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        state = state.copyWith(
          isLoading: false,
          error: e.response?.data['message'],
        );
      } else {
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message.toString());
        state = state.copyWith(isLoading: false, error: e.message.toString());
      }
    }
  }

  void hydrateFromCache(Map<String, dynamic> details) {
    state = state.copyWith(isLoading: false, data: details, error: '');
  }

  Future<void> performGetUser(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: '');
      final dio = Dio();

      // Auth header
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || JwtDecoder.isExpired(token)) {
        state = state.copyWith(isLoading: false, error: 'Token has expired');
        // Also notify listeners if token invalid
        await prefs.setBool('status', false);
        ref.read(authEventsProvider).add(false);
        ref.read(isAuthenticated.notifier).state = false;
        return;
      }
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
        '${EnvironmentUserConfig.getProfileByIdUrl}$id',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          data: response.data as Map<String, dynamic>,
          error: '',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        state = state.copyWith(
          isLoading: false,
          error: e.response?.data['message'],
        );
      } else {
        debugPrint(e.requestOptions.toString());
        debugPrint(e.message.toString());
        state = state.copyWith(isLoading: false, error: e.message.toString());
      }
    }
  }

  /// Optional logout helper
  Future<void> performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.setBool('status', false);
    ref.read(authEventsProvider).add(false);
    ref.read(isAuthenticated.notifier).state = false;
    state = const AuthState(); // clear state
  }
}
