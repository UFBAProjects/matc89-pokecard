import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/withlist_packet/withlist_packet_list_controller.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class WithlistAddCardsPage extends ConsumerWidget {
  const WithlistAddCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withlistCardsAsyncValue = ref.watch(getAllMyCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha uma carta para adicionar na wishlist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: withlistCardsAsyncValue.when(
        data: (cards) => _buildGridView(context, ref, cards),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
      ),
    );
  }

  Widget _buildGridView(
      BuildContext context, WidgetRef ref, List<PokeCard> cards) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _buildCard(context, ref, card);
      },
    );
  }

 Widget _buildCard(BuildContext context, WidgetRef ref, PokeCard card) {
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
    onTap: () => _showConfirmDialog(context, ref, card),
    child: Container(
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.2),  
        borderRadius: BorderRadius.circular(10),  
        border: Border.all(color: Colors.black, width: 2), 
      ),
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
    ),
  );
}

  Future<void> _showConfirmDialog(
      BuildContext context, WidgetRef ref, PokeCard card) async {
    final confirmAddCard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text('Deseja adicionar ${card.name} a withlist?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Não')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sim')),
          ],
        );
      },
    );

    if (confirmAddCard == true) {
      _addCardToWithlist(context, ref, card);
    }
  }

  Future<void> _addCardToWithlist(
      BuildContext context, WidgetRef ref, PokeCard card) async {
    try {
      await ref
          .read(WithlistCardListControllerProvider.notifier)
          .addWithlistCard(card);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${card.name} foi adicionada a wishlist com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      ref.refresh(WithlistCardListControllerProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erro ao adicionar ${card.name} a wishlist. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _lightenColor(String colorName) {
    final colorMap = {
      'black': 'black',
      'blue': 'blue',
      'brown': 'brown',
      'gray': 'gray',
      'green': 'green',
      'pink': 'pink',
      'purple': 'purple',
      'red': 'red',
      'white': 'white',
      'yellow': 'yellow',
    };
    return colorMap[colorName.toLowerCase()] ?? 'gray';
  }
}
