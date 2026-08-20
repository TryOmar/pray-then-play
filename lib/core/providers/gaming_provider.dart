import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../models/game_profile.dart';
import '../models/gaming_window.dart';
import '../services/storage_service.dart';
import 'prayer_provider.dart';

// User's active configured games
final userGamesProvider =
    StateNotifierProvider<UserGamesNotifier, List<GameProfile>>((ref) {
  return UserGamesNotifier();
});

class UserGamesNotifier extends StateNotifier<List<GameProfile>> {
  UserGamesNotifier() : super(StorageService.getUserGames());

  void setGames(List<GameProfile> games) {
    state = games;
    StorageService.setUserGames(games);
  }

  void toggleGameSelected(String gameId) {
    state = state.map((g) {
      if (g.id == gameId) {
        return g.copyWith(isSelected: !g.isSelected);
      }
      return g;
    }).toList();
    StorageService.setUserGames(state);
  }

  void toggleModeEnabled(String gameId, String modeName) {
    state = state.map((g) {
      if (g.id == gameId) {
        final updatedModes = g.modes.map((m) {
          if (m.name == modeName) {
            return m.copyWith(isEnabled: !m.isEnabled);
          }
          return m;
        }).toList();
        return g.copyWith(modes: updatedModes);
      }
      return g;
    }).toList();
    StorageService.setUserGames(state);
  }

  void addCustomGame(GameProfile game) {
    state = [...state, game];
    StorageService.setUserGames(state);
  }

  void addCatalogGame(GameProfile game) {
    if (!state.any((g) => g.id == game.id)) {
      state = [...state, game.copyWith(isSelected: true)];
    } else {
      state = state.map((g) {
        if (g.id == game.id) {
          return g.copyWith(isSelected: true);
        }
        return g;
      }).toList();
    }
    StorageService.setUserGames(state);
  }

  void removeGame(String gameId) {
    state = state.where((g) => g.id != gameId).toList();
    StorageService.setUserGames(state);
  }
}

// Active/Selected games only
final activeSelectedGamesProvider = Provider<List<GameProfile>>((ref) {
  final all = ref.watch(userGamesProvider);
  return all.where((g) => g.isSelected && g.enabledModes.isNotEmpty).toList();
});

// Gaming Windows for today
final gamingWindowsProvider = Provider<List<GamingWindow>>((ref) {
  final prayerTimes = ref.watch(dailyPrayerTimesProvider);
  if (prayerTimes == null) return [];

  final now = DateTime.now();
  final windows = <GamingWindow>[];

  // Calculate windows between consecutive prayers
  final prayers = prayerTimes.allPrayers;
  for (int i = 0; i < prayers.length - 1; i++) {
    final current = prayers[i];
    final next = prayers[i + 1];

    final start = current.value;
    final end = next.value;
    final totalMinutes = end.difference(start).inMinutes;

    if (totalMinutes <= 0) continue;

    // Window 1: Comfortable / Safe gaming window
    final safeEnd = end.subtract(const Duration(minutes: 30));
    if (safeEnd.isAfter(start)) {
      final isCurrent = now.isAfter(start) && now.isBefore(safeEnd);
      windows.add(GamingWindow(
        start: start,
        end: safeEnd,
        status: GamingStatus.safe,
        label: 'Comfortable Gaming Window',
        isCurrent: isCurrent,
      ));
    }

    // Window 2: Short games only (30 to 10 min before prayer)
    final cautionStart = end.subtract(const Duration(minutes: 30));
    final cautionEnd = end.subtract(const Duration(minutes: 10));
    if (cautionEnd.isAfter(cautionStart)) {
      final isCurrent = now.isAfter(cautionStart) && now.isBefore(cautionEnd);
      windows.add(GamingWindow(
        start: cautionStart,
        end: cautionEnd,
        status: GamingStatus.caution,
        label: 'Short Games Only',
        isCurrent: isCurrent,
      ));
    }

    // Window 3: Don't queue / Prayer preparation (10 min before to prayer time)
    final dontQueueStart = end.subtract(const Duration(minutes: 10));
    final isCurrent = now.isAfter(dontQueueStart) && now.isBefore(end);
    windows.add(GamingWindow(
      start: dontQueueStart,
      end: end,
      status: GamingStatus.dontQueue,
      label: 'Prayer Preparation (${next.key})',
      isCurrent: isCurrent,
    ));
  }

  return windows;
});

// In-match tracking
final inMatchProvider = StateNotifierProvider<InMatchNotifier, bool>((ref) {
  return InMatchNotifier();
});

class InMatchNotifier extends StateNotifier<bool> {
  InMatchNotifier() : super(StorageService.isInMatch);

  void startMatch() {
    state = true;
    StorageService.setInMatch(true);
    StorageService.setMatchStartTime(DateTime.now());
  }

  void endMatch() {
    state = false;
    StorageService.setInMatch(false);
    StorageService.setMatchStartTime(null);
  }
}
