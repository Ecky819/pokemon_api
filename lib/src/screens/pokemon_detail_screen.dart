import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonDetailScreen extends StatefulWidget {
  final String name;
  final int id;

  const PokemonDetailScreen({super.key, required this.name, required this.id});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Map<String, dynamic>? pokemonData;
  bool isLoading = true;

  // Typ-spezifische Farben
  final Map<String, Color> typeColors = {
    'normal': const Color(0xFFA8A878),
    'fire': const Color(0xFFF08030),
    'water': const Color(0xFF6890F0),
    'electric': const Color(0xFFF8D030),
    'grass': const Color(0xFF78C850),
    'ice': const Color(0xFF98D8D8),
    'fighting': const Color(0xFFC03028),
    'poison': const Color(0xFFA040A0),
    'ground': const Color(0xFFE0C068),
    'flying': const Color(0xFFA890F0),
    'psychic': const Color(0xFFF85888),
    'bug': const Color(0xFFA8B820),
    'rock': const Color(0xFFB8A038),
    'ghost': const Color(0xFF705898),
    'dragon': const Color(0xFF7038F8),
    'dark': const Color(0xFF705848),
    'steel': const Color(0xFFB8B8D0),
    'fairy': const Color(0xFFEE99AC),
  };

  @override
  void initState() {
    super.initState();
    fetchPokemonDetails();
  }

  Future<void> fetchPokemonDetails() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.id}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Fehler beim Laden der Pokémon-Details');
    }
  }

  Color getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  Widget buildStatBar(String statName, int baseStat, int maxStat) {
    final percentage = baseStat / maxStat;
    final displayName = statName
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.toUpperCase())
        .join(' ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.greenAccent[400]!, Colors.green[600]!],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              baseStat.toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red, Colors.blue],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lade Pokémon-Details...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : pokemonData == null
          ? const Center(child: Text('Keine Daten gefunden'))
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: pokemonData!["types"].isNotEmpty
                      ? [
                          getTypeColor(
                            pokemonData!["types"][0]["type"]["name"],
                          ),
                          getTypeColor(
                            pokemonData!["types"][0]["type"]["name"],
                          ).withOpacity(0.7),
                        ]
                      : [Colors.blue, Colors.indigo],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Custom AppBar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '#${widget.id.toString().padLeft(3, '0')}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pokémon Bild
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Hero(
                          tag: 'pokemon-${widget.id}',
                          child: Image.network(
                            pokemonData!["sprites"]["other"]["official-artwork"]["front_default"] ??
                                pokemonData!["sprites"]["front_default"],
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Details Container
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Typen
                              const Text(
                                'Typen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: (pokemonData!["types"] as List)
                                    .map<Widget>((type) {
                                      final typeName = type["type"]["name"];
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getTypeColor(typeName),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: getTypeColor(
                                                typeName,
                                              ).withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          typeName.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                              const SizedBox(height: 20),

                              // Basis-Stats
                              const Text(
                                'Basis-Stats',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Stats Container
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        getTypeColor(
                                          pokemonData!["types"][0]["type"]["name"],
                                        ).withOpacity(0.8),
                                        getTypeColor(
                                          pokemonData!["types"][0]["type"]["name"],
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: (pokemonData!["stats"] as List)
                                        .map<Widget>(
                                          (stat) => buildStatBar(
                                            stat["stat"]["name"],
                                            stat["base_stat"],
                                            200, // Maximaler Stat-Wert für die Prozent-Berechnung
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
