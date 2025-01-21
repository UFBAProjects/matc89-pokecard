import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_list_page.g.dart';

class PokeCardRepository {
  final FirebaseFirestore _firestore;

  PokeCardRepository(this._firestore);

  Future<void> saveAllCards(List<PokeCard> cards) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('pokecards');

    for (var card in cards) {
      final docRef = collection.doc();
      batch.set(docRef, card.toJson());
    }

    await batch.commit();
  }
}

@riverpod
class CardListController extends _$CardListController {
  final PokeCardRepository repository =
      PokeCardRepository(FirebaseFirestore.instance);

  @override
  Future<List<PokeCard>> build() async {
    return await fetchPokemonCards();
  }

  Future<List<PokeCard>> fetchPokemonCards() async {
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
        image: detailData['sprites']['back_default'] ?? '',
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

    return cards;
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

class CardListPage extends ConsumerWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardListAsyncValue = ref.watch(cardListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: cardListAsyncValue.when(
                data: (cardList) => _buildList(context, cardList),
                error: (error, stackTrace) => Text('Error: $error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final controller =
                    ref.read(cardListControllerProvider.notifier);
                final cardList = ref.read(cardListControllerProvider);

                if (cardList is AsyncData<List<PokeCard>>) {
                  try {
                    await controller.saveCards(cardList.value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pokémon cards salvos com sucesso!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Erro ao salvar os Pokémon cards.')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PokeCard> cardList) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 3; // 2 cards por coluna no mobile

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cardList.length,
      itemBuilder: (context, index) {
        final card = cardList[index];

        // Map Pokémon color to Flutter colors
        final colorMap = {
          'black': Colors.black,
          'blue': Colors.blue,
          'brown': Colors.brown,
          'gray': Colors.grey,
          'green': Colors.green,
          'pink': Colors.pink,
          'purple': Colors.purple,
          'red': Colors.red,
          'white': Colors.white,
          'yellow': Colors.yellow,
        };
        final cardColor = colorMap[card.color.toLowerCase()] ?? Colors.grey;

        return Container(
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
          ),
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Image.network(
                  card.image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${card.type}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Text(
                'Weight: ${card.weight}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              Text(
                'Abilities: ${card.abilities.join(", ")}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }
}
