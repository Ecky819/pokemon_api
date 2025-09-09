import 'package:flutter/material.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({Key? key});

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
        final response =
            await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            pokemons = data['results'];
            isLoading = false;
          });
        } else {
          throw Exception('Fehler beim Laden der Pokemon-Daten');
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pokedex'),
            centerTitle: true,
            ),
          body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = pokemons[index];
              final pokemonId = index + 1;
              final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';
              return ListTile(
                leading: Image.network(imageUrl)
                title: Text(
                  pokemon['name'].toString().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(
                        name: pokemon['name'],
                        ),
                        ),
                        );
                },
            },
              ),
          );
          }
      }

      class

            }
        )
      }
  }
   