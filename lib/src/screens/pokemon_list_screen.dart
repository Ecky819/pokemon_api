import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon_detail_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pokemons = data['results'];
        isLoading = false;
      });
    } else {
      throw Exception('Fehler beim Laden der Pokémon-Daten');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
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
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.red, Colors.redAccent, Colors.black],
                          stops: [0.3, 0.6, 1.0],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Pokédex',
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
                              Colors.red[400]!,
                            ),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Lade Pokémon...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
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
                      itemCount: pokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = pokemons[index];
                        final pokemonId = index + 1;
                        final imageUrl =
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PokemonDetailScreen(
                                  name: pokemon['name'],
                                  id: pokemonId,
                                ),
                              ),
                            );
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
                                  colors: [Colors.white, Colors.blue[50]!],
                                ),
                              ),
                              child: Column(
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
                                        color: Colors.red[400],
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
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
