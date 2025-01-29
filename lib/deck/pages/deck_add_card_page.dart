import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/deck/deck_controller.dart';

class DeckAddCardsPage extends ConsumerWidget {
  final String deckId;

  const DeckAddCardsPage({
    super.key,
    required this.deckId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardListAsyncValue = ref.watch(getAllMyCardsProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Escolha uma carta que deseja adicionar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: Center(
                    child: cardListAsyncValue.when(
              data: (cards) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 600 ? 2 : 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    final card = cards[index];

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
                    final cardColor =
                        colorMap[card.color.toLowerCase()] ?? Colors.grey;
                    return GestureDetector(
                      onTap: () async {
                        final confirmAddCard = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar'),
                              content: Text(
                                  'Deseja adicionar ${card.name} ao deck?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Não'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Sim'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmAddCard == true) {
                          try {
                            await ref
                                .read(deckListControllerProvider.notifier)
                                .addCardInDeck(deckId, card);
                            ref.refresh(getDeckByIdProvider(deckId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${card.name} foi adicionada ao deck com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erro ao adicionar ${card.name} ao deck. Tente novamente.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
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
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black),
                            ),
                            Text(
                              'Weight: ${card.weight}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black),
                            ),
                            Text(
                              'Abilities: ${card.abilities.join(", ")}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Erro: $error')),
            )))
          ],
        ));
  }
}
