// authproviders.dart
import 'dart:async';
import 'package:bible_compass_app/data/remote/authrequests.dart';
import 'package:bible_compass_app/domain/models/user/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Snackbars / UI messages
final successMessageProvider = StateProvider.autoDispose<String>((ref) => "");
final errorMessageProvider = StateProvider.autoDispose<String>((ref) => "");

/// Notifiers
final signUpProvider =
    StateNotifierProvider.autoDispose<SignUpNotifier, UserState>(
      (ref) => SignUpNotifier(ref),
    );

final loginProvider = StateNotifierProvider<LoginNotifier, AuthState>(
  (ref) => LoginNotifier(ref),
);

final verifyProvider =
    StateNotifierProvider.autoDispose<SignUpNotifier, UserState>(
      (ref) => SignUpNotifier(ref),
    );

/// SharedPreferences as a FutureProvider (works with `.future`)
final sharedPrefProvider = FutureProvider<SharedPreferences>(
  (ref) async => SharedPreferences.getInstance(),
);

/// Broadcast stream to notify router/auth listeners
final authEventsProvider = Provider<StreamController<bool>>((ref) {
  final controller = StreamController<bool>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

/// Router consumes this stream (GoRouterRefreshStream(ref.watch(authStatusProvider.stream)))
final authStatusProvider = StreamProvider<bool>((ref) async* {
  // Emit an initial snapshot from prefs
  final prefs = await ref.read(sharedPrefProvider.future);
  final initial = prefs.getBool('status') ?? false;
  yield initial;

  // And continue emitting on auth events
  yield* ref.watch(authEventsProvider).stream;
});

/// Optional legacy state (kept if other code still reads it)
final isAuthenticated = StateProvider<bool>((ref) => false);

// import 'package:bible_compass_app/data/remote/authrequests.dart';
// import 'package:bible_compass_app/domain/models/user/user.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final successMessageProvider = StateProvider.autoDispose<String>((ref) => "");
// final errorMessageProvider = StateProvider.autoDispose<String>((ref) => "");

// final signUpProvider =
//     StateNotifierProvider.autoDispose<SignUpNotifier, UserState>((ref) {
//       return SignUpNotifier();
//     });

// final loginProvider = StateNotifierProvider<LoginNotifier, AuthState>((ref) {
//   return LoginNotifier();
// });

// final verifyProvider =
//     StateNotifierProvider.autoDispose<SignUpNotifier, UserState>((ref) {
//       return SignUpNotifier();
//     });


// final sharedPrefProvider = Provider<Future<SharedPreferences>>((ref) {
//   return SharedPreferences.getInstance();
// });


// final isAuthenticated = StateProvider<bool>((ref) => false);
