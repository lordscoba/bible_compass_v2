// lib/domain/providers/favproviders.dart
import 'package:bible_compass_app/data/remote/favoritesrequest.dart';
import 'package:bible_compass_app/domain/models/favourites/favorite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for like/unlike/list actions
final favProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((
  ref,
) {
  return FavoriteNotifier();
});

/// Read-only status provider for (keyword, email) pair
/// If you prefer, you can import `favoriteApiProvider` directly where needed.
/// Here we simply re-expose it under a clearer name for UI code.
final favoriteStatusProvider = favoriteApiProvider;

// import 'package:bible_compass_app/data/remote/favoritesrequest.dart';
// import 'package:bible_compass_app/domain/models/favourites/favorite.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final favProvider =
//     StateNotifierProvider.autoDispose<FavoriteNotifier, FavoriteState>((ref) {
//   return FavoriteNotifier();
// });

// final favProviderstatus =
//     StateNotifierProvider.autoDispose<FavoriteNotifier, FavoriteState>((ref) {
//   return FavoriteNotifier();
// });
