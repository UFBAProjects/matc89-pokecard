import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';
import 'package:pokecard/collection/collection_controller.dart';

class PokeCardListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtém o estado dos cards
    final pokeCardsState = ref.watch(collectionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PokéCards Collection'),
      ),
      body: pokeCardsState.when(
        data: (cards) {
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              // Mapeia a cor para a cor do Flutter
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
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
