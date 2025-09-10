import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favoritesFuture;
  late FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _initializeFavorites();
  }

  Future<List<Map<String, dynamic>>> _initializeFavorites() async {
    _favoriteService = await FavoriteService.getInstance();
    return await _favoriteService.getFavorites();
  }

  // Refresh favorites - für Pull-to-Refresh oder nach Änderungen
  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = _favoriteService.getFavorites();
    });
  }

  Future<void> _removeFavorite(int pokemonId) async {
    try {
      await _favoriteService.removeFavorite(pokemonId);

      // Refresh the favorites list
      _refreshFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pokémon aus Favoriten entfernt'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          const Text(
            'Lade Favoriten...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.pink[300]),
          const SizedBox(height: 20),
          Text(
            'Fehler beim Laden',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshFavorites,
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Noch keine Favoriten',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Füge Pokémon zu deinen Favoriten hinzu!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Switch to Pokemon list tab (index 0)
              // You might need to pass a callback from parent to handle this
              DefaultTabController.of(context)?.animateTo(0);
            },
            icon: const Icon(Icons.search),
            label: const Text('Pokémon entdecken'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid(List<Map<String, dynamic>> favorites) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshFavorites();
        await _favoritesFuture;
      },
      color: Colors.pink[400],
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(), // Für Pull-to-Refresh
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final pokemon = favorites[index];
          final pokemonId = pokemon['id'];
          final imageUrl =
              pokemon['imageUrl'] ??
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PokemonDetailScreen(name: pokemon['name'], id: pokemonId),
                ),
              );

              // Favoriten nach Rückkehr neu laden
              if (result == 'favorites_changed') {
                _refreshFavorites();
              }
            },
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.pink[50]!],
                  ),
                ),
                child: Stack(
                  children: [
                    // Hauptinhalt
                    Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Hero(
                              tag: 'pokemon-$pokemonId',
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.pink[400]!,
                                              ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.catching_pokemon,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.pink[400],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '#${pokemonId.toString().padLeft(3, '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  pokemon['name']
                                      .toString()
                                      .split('-')[0]
                                      .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Entfernen Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // Bestätigungsdialog anzeigen
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Favorit entfernen'),
                              content: Text(
                                'Möchtest du ${pokemon['name'].toString().toUpperCase()} aus deinen Favoriten entfernen?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Abbrechen'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _removeFavorite(pokemonId);
                                  },
                                  child: const Text(
                                    'Entfernen',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // Favoriten Herz Icon
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(Icons.favorite, color: Colors.red, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              decoration: BoxDecoration(
                color: Colors.pink[400],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Meine Favoriten',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Refresh Button
                    IconButton(
                      onPressed: _refreshFavorites,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'Favoriten aktualisieren',
                    ),
                  ],
                ),
              ),
            ),

            // Body Content with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  // Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }

                  // Error State
                  if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  }

                  // Success State
                  if (snapshot.hasData) {
                    final favorites = snapshot.data!;

                    if (favorites.isEmpty) {
                      return _buildEmptyFavorites();
                    }

                    return _buildFavoritesGrid(favorites);
                  }

                  // Fallback
                  return _buildLoadingWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
