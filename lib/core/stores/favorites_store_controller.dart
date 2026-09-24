import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive replacement for the old static [FavoritesStore].
class FavoritesStoreController extends GetxController {
  static const String _prefsKey = 'favoriteProductIds';

  final RxSet<int> ids = <int>{}.obs;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? <String>[];
    ids
      ..clear()
      ..addAll(raw.map((id) => int.tryParse(id)).whereType<int>());
    _loaded = true;
  }

  bool isFavorite(int productId) => ids.contains(productId);

  Future<void> setFavorite(int productId, bool value) async {
    final next = Set<int>.from(ids);
    if (value) {
      next.add(productId);
    } else {
      next.remove(productId);
    }
    await _save(next);
  }

  Future<void> toggle(int productId) async {
    final next = Set<int>.from(ids);
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    await _save(next);
  }

  Future<void> _save(Set<int> next) async {
    final prefs = await SharedPreferences.getInstance();
    final asList = next.map((id) => id.toString()).toList();
    await prefs.setStringList(_prefsKey, asList);
    ids
      ..clear()
      ..addAll(next);
  }
}