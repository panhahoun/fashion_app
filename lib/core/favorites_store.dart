import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FavoritesStore {
  static const String _prefsKey = 'favoriteProductIds';
  static final ValueNotifier<Set<int>> idsNotifier = ValueNotifier(<int>{});
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? <String>[];
    idsNotifier.value = raw.map((id) => int.tryParse(id)).whereType<int>().toSet();
    _loaded = true;
  }

  static bool isFavorite(int productId) {
    return idsNotifier.value.contains(productId);
  }

  static Future<void> setFavorite(int productId, bool value) async {
    final next = Set<int>.from(idsNotifier.value);
    if (value) {
      next.add(productId);
    } else {
      next.remove(productId);
    }
    await _save(next);
  }

  static Future<void> toggle(int productId) async {
    final next = Set<int>.from(idsNotifier.value);
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    await _save(next);
  }

  static Future<void> _save(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final asList = ids.map((id) => id.toString()).toList();
    await prefs.setStringList(_prefsKey, asList);
    idsNotifier.value = ids;
  }
}
