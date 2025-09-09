import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key, Key? key});

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


@override
void initState() {
super.initState();
fetchPokemonDetails();
}


Future<void> fetchPokemonDetails() async {
final response = await http
.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.id}'));


if (response.statusCode == 200) {
setState(() {
pokemonData = json.decode(response.body);
isLoading = false;
});
} else {
throw Exception('Fehler beim Laden der Pokémon-Details');
}
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(widget.name.toUpperCase()),
),
body: isLoading
? const Center(child: CircularProgressIndicator())
: pokemonData == null
? const Center(child: Text('Keine Daten gefunden'))
: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Image.network(
pokemonData!["sprites"]["front_default"],
height: 150,
),
const SizedBox(height: 16),
Text(
'Typen: ' +
(pokemonData!["types"] as List)
.map((t) => t["type"]["name"])
.join(", "),
style: const TextStyle(fontSize: 18),
),
const SizedBox(height: 16),
Text(
'Basis-Stats:',
style: Theme.of(context)
.textTheme
.titleMedium
?.copyWith(fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
Expanded(
child: ListView(
children: (pokemonData!["stats"] as List)
.map((stat) => ListTile(
title: Text(stat["stat"]["name"]),
trailing: Text(stat["base_stat"].toString()),
))
.toList(),
),
)
],
),
),
);
}
}