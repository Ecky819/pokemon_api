import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  late FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteService();
  }

  Future<void> _initializeFavoriteService() async {
    _favoriteService = await FavoriteService.getInstance();
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favoriteList = await _favoriteService.getFavorites();
    setState(() {
      favorites = favoriteList;
      isLoading = false;
    });
  }

  Future<void> _removeFavorite(int pokemonId) async {
    await _favoriteService.removeFavorite(pokemonId);
    await _loadFavorites(); // Neu laden

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pokémon aus Favoriten entfernt'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                    const Text(
                      'Meine Favoriten',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Body Content
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.pink[400]!,
                            ),
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
                    )
                  : favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey[400],
                          ),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                builder: (context) => PokemonDetailScreen(
                                  name: pokemon['name'],
                                  id: pokemonId,
                                ),
                              ),
                            );

                            // Favoriten nach Rückkehr neu laden
                            if (result == 'favorites_changed') {
                              await _loadFavorites();
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
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
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
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                      onTap: () => _removeFavorite(pokemonId),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red[400],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
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
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
