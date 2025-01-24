import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/card/card_list_controller.dart';
import 'package:pokecard/card/card.dart';

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
