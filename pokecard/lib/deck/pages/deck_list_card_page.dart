import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/deck/deck.dart';
import 'package:pokecard/deck/deck_controller.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class DeckListCardsPage extends ConsumerWidget {
  final String deckId;

  const DeckListCardsPage({
    super.key,
    required this.deckId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsyncValue = ref.watch(getDeckByIdProvider(deckId));

    return Scaffold(
      appBar: AppBar(
          title: deckAsyncValue.when(
        data: (deck) => Text('Deck - ${deck.name}'),
        error: (error, stackTrace) => Text('Error: $error'),
        loading: () => const CircularProgressIndicator(),
      )),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: deckAsyncValue.when(
                data: (deck) => _buildList(context, deck.cards, ref),
                error: (error, stackTrace) => Text('Error: $error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PokeCard> cards, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 3;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];

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

        return GestureDetector(
            onTap: () {
              // caso criemos um item de descrição de carta chama ele aqui quando clicar na carta
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      Text(
                        'Weight: ${card.weight}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      Text(
                        'Abilities: ${card.abilities.join(", ")}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8, 
                    child: _deleteCardButton(context, ref, deckId, index, card),
                  )
                ],
              ),
            ));
      },
    );
  }

  Widget _deleteCardButton(BuildContext context, WidgetRef ref, String deckId,
      int cardIndex, PokeCard card) {
    return Positioned(
      top: 2,
      right: 2,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          _showDeleteConfirmModal(context, ref, deckId, cardIndex, card);
        },
      ),
    );
  }

  void _showDeleteConfirmModal(BuildContext context, WidgetRef ref,
      String deckId, int cardIndex, PokeCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Tem certeza de que deseja excluir a carta do deck?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final deckController =
                      ref.read(deckListControllerProvider.notifier);
                  await deckController.deleteCardFromDeck(deckId, cardIndex);
                  ref.refresh(getDeckByIdProvider(deckId));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${card.name} foi removida do deck com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao remover ${card.name} do deck. Tente novamente.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
