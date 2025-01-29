import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/deck/deck.dart';
import 'package:pokecard/deck/deck_controller.dart';
import 'package:pokecard/deck/pages/deck_add_card_page.dart';
import 'package:pokecard/deck/pages/deck_list_card_page.dart';

class DeckListPage extends ConsumerWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckListAsyncValue = ref.watch(getAllDecksProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Decks')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: deckListAsyncValue.when(
                data: (deckList) => _buildList(context, deckList, ref),
                error: (error, stackTrace) => Text('Error: $error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildList(
      BuildContext context, List<PokeDeck> deckList, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 3;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: deckList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _addDeckButton(context, ref);
        }
        final deck = deckList[index - 1];
        return GestureDetector(
            onTap: () {
              // Navegar para a página do Deck
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeckListCardsPage(
                    deckId: deck.id,
                  ),
                ),
              );
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
                  Center(
                    child: Text(
                      deck.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _deleteDeckButton(context, ref, deck.id),
                  _addCardButton(context, ref, deck.id),
                  _editDeckButton(context, ref, deck.id, deck.name),
                ],
              ),
            ));
      },
    );
  }

  Widget _addDeckButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        _showAddDeckModal(context, ref);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 40,
              color: Colors.blue,
            ),
            SizedBox(height: 8),
            Text(
              'Adicionar um deck',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteDeckButton(BuildContext context, WidgetRef ref, String deckId) {
    return Positioned(
      top: 2,
      right: 2,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          _showDeleteConfirmModal(context, ref, deckId);
        },
      ),
    );
  }

  Widget _editDeckButton(
      BuildContext context, WidgetRef ref, String deckId, String currentName) {
    return Positioned(
      top: 2,
      right: 62,
      child: IconButton(
        icon: const Icon(Icons.edit, color: Colors.orange),
        onPressed: () {
          _showEditDeckModal(context, ref, deckId, currentName);
        },
      ),
    );
  }

  Widget _addCardButton(BuildContext context, WidgetRef ref, String deckId) {
    return Positioned(
      top: 2,
      right: 32,
      child: IconButton(
        icon: Icon(Icons.add, color: Colors.green),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeckAddCardsPage(deckId: deckId),
            ),
          );
        },
      ),
    );
  }

  void _showAddDeckModal(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar um novo deck'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nome do Deck'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final deckController =
                      ref.read(deckListControllerProvider.notifier);
                  await deckController.saveDeck(controller.text);
                  ref.refresh(getAllDecksProvider);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeckModal(
      BuildContext context, WidgetRef ref, String deckId, String currentName) {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar nome do deck'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nome do Deck'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  final deckController =
                      ref.read(deckListControllerProvider.notifier);
                  await deckController.updateDeck(deckId, controller.text);
                  ref.refresh(getAllDecksProvider);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmModal(
      BuildContext context, WidgetRef ref, String deckId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza de que deseja excluir este deck?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final deckController =
                    ref.read(deckListControllerProvider.notifier);
                await deckController.deleteDeck(deckId);
                ref.refresh(getAllDecksProvider);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
