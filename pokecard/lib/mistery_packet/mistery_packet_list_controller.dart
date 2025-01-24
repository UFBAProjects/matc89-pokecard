import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/card/card.dart';
import 'package:pokecard/card/card_repository.dart';

final cardListControllerProvider =
    StateNotifierProvider<CardListController, AsyncValue<List<PokeCard>>>(
  (ref) => CardListController(
    PokeCardRepository(FirebaseFirestore.instance),
  ),
);

class CardListController extends StateNotifier<AsyncValue<List<PokeCard>>> {
  final PokeCardRepository repository;

  CardListController(this.repository) : super(const AsyncValue.loading()) {
    fetchPokemonCards(); // Certifique-se de chamar o método ao inicializar
  }

  Future<void> fetchPokemonCards() async {
    try {
      state = const AsyncValue.loading();
      const generalEndpoint =
          'https://pokeapi.co/api/v2/pokemon/?offset=300&limit=300';

      // Fetch general Pokémon data
      final generalResponse = await http.get(Uri.parse(generalEndpoint));
      if (generalResponse.statusCode != 200) {
        throw Exception('Failed to fetch Pokémon list');
      }

      final generalData = json.decode(generalResponse.body);
      final results = generalData['results'] as List;

      // Randomly select 6 Pokémon
      final random = Random();
      final selectedPokemon =
          List.generate(6, (_) => results[random.nextInt(results.length)]);

      // Fetch detailed data for each selected Pokémon
      final List<PokeCard> cards = [];
      for (var pokemon in selectedPokemon) {
        final detailResponse = await http.get(Uri.parse(pokemon['url']));
        if (detailResponse.statusCode != 200) {
          throw Exception(
              'Failed to fetch details for Pokémon: ${pokemon['name']}');
        }

        final detailData = json.decode(detailResponse.body);

        // Fetch color data
        final colorResponse =
            await http.get(Uri.parse(detailData['species']['url']));
        if (colorResponse.statusCode != 200) {
          throw Exception(
              'Failed to fetch color for Pokémon: ${pokemon['name']}');
        }

        final colorData = json.decode(colorResponse.body);

        // Build PokeCard object
        cards.add(PokeCard(
          name: detailData['name'],
          image: detailData['sprites']['front_default'] ?? '',
          type: (detailData['types'] as List)
              .map((t) => t['type']['name'] as String)
              .join(', '),
          weight: detailData['weight'],
          abilities: (detailData['abilities'] as List)
              .map((a) => a['ability']['name'] as String)
              .toList(),
          color: colorData['color']['name'],
        ));
      }

      state = AsyncValue.data(cards);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveCards(List<PokeCard> cards) async {
    try {
      await repository.saveAllCards(cards);
      print('Pokémon cards salvos com sucesso no Firestore!');
    } catch (e) {
      print('Erro ao salvar os Pokémon cards: $e');
      rethrow;
    }
  }
}
