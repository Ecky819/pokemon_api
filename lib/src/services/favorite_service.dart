import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteService {
  static const String _favoritesKey = 'favorite_pokemons';
  static FavoriteService? _instance;
  // Verwendung von Shared Preferences für die Speicherung der Favoriten
  static SharedPreferences? _prefs;

  FavoriteService._();

  static Future<FavoriteService> getInstance() async {
    _instance ??= FavoriteService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Pokémon zu Favoriten hinzufügen
  Future<void> addFavorite(Map<String, dynamic> pokemon) async {
    final favorites = await getFavorites();

    // Prüfen ob bereits vorhanden
    final isAlreadyFavorite = favorites.any(
      (fav) => fav['id'] == pokemon['id'],
    );

    if (!isAlreadyFavorite) {
      favorites.add(pokemon);
      await _saveFavorites(favorites);
    }
  }

  // Pokémon aus Favoriten entfernen
  Future<void> removeFavorite(int pokemonId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((pokemon) => pokemon['id'] == pokemonId);
    await _saveFavorites(favorites);
  }

  // Prüfen ob Pokémon favorisiert ist
  Future<bool> isFavorite(int pokemonId) async {
    final favorites = await getFavorites();
    return favorites.any((pokemon) => pokemon['id'] == pokemonId);
  }

  // Alle Favoriten abrufen
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final favoritesString = _prefs?.getString(_favoritesKey);
    if (favoritesString == null) return [];

    try {
      final List<dynamic> favoritesList = json.decode(favoritesString);
      return favoritesList
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Favoriten speichern
  Future<void> _saveFavorites(List<Map<String, dynamic>> favorites) async {
    final favoritesString = json.encode(favorites);
    await _prefs?.setString(_favoritesKey, favoritesString);
  }

  // Alle Favoriten löschen
  Future<void> clearFavorites() async {
    await _prefs?.remove(_favoritesKey);
  }

  // Favorite toggle (hinzufügen/entfernen)
  Future<bool> toggleFavorite(Map<String, dynamic> pokemon) async {
    final isFav = await isFavorite(pokemon['id']);

    if (isFav) {
      await removeFavorite(pokemon['id']);
      return false;
    } else {
      await addFavorite(pokemon);
      return true;
    }
  }
}
