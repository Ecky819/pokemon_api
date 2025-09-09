import 'package:flutter/material.dart';
import './src/screens/pokemon_list_screen.dart';

void main() {
  runApp(const MyApp(super.key));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const PokemonListScreen(),
    );
  }
}
