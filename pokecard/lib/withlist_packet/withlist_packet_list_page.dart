import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';
import 'package:pokecard/withlist_packet/withlist_packet_list_controller.dart';
import 'package:pokecard/withlist_packet/withlist_packet_add_card_list_page.dart';

class WithlistPacketListPage extends ConsumerWidget {
  const WithlistPacketListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withlistCardsAsyncValue = ref.watch(WithlistCardListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: withlistCardsAsyncValue.when(
                data: (withlistCards) => _buildList(context, withlistCards , ref),
                error: (error, stackTrace) => Text('Error: $error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WithlistAddCardsPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PokeCard> withlist, WidgetRef ref) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  final crossAxisCount = isMobile ? 2 : 3;
  
  return GridView.builder(
    padding: const EdgeInsets.all(10),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 0.75,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: withlist.length,
    itemBuilder: (context, index) {
      final card = withlist[index];
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
      final cardColor = _getDisabledColor(colorMap[card.color.toLowerCase()] ?? Colors.grey);

      return Container(
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.2), 
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
            Positioned(
              top: 8,
              right: 8,
              child: _deleteCardButton(context, ref, card), 
            ),
          ],
        ),
      );
    },
  );
}

Color _getDisabledColor(Color originalColor) {
  HSLColor hslColor = HSLColor.fromColor(originalColor);

  HSLColor desaturatedColor = hslColor.withSaturation(hslColor.saturation * 0.3);

  return desaturatedColor.toColor();
}
  Widget _deleteCardButton(BuildContext context, WidgetRef ref, PokeCard card) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        _showDeleteConfirmModal(context, ref, card);
      },
    );
  }

  void _showDeleteConfirmModal(BuildContext context, WidgetRef ref, PokeCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza de que deseja excluir a carta da wishlist?'),
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
                  final withlistController = ref.read(WithlistCardListControllerProvider.notifier);
                  await withlistController.removeWithlistCard(card.name);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${card.name} foi removida da wishlist com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao remover ${card.name} da wishlist. Tente novamente.'),
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
