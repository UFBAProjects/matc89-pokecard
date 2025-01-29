import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/withlist_packet/withlist_packet_list_controller.dart';
import 'package:pokecard/withlist_packet/withlist_packet.dart';

class WithlistPacketListPage extends ConsumerWidget {
  const WithlistPacketListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final WithlistCardListAsyncValue = ref.watch(WithlistCardListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final controller =
                  ref.read(WithlistCardListControllerProvider.notifier);
              final cards = ref.read(WithlistCardListControllerProvider);

              if (cards is AsyncData<List<WithlistCard>>) {
                try {
                  await controller.saveAllCardsWithlist(cards.value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withlist salva com sucesso!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao salvar a Withlist.'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: WithlistCardListAsyncValue.when(
        data: (cardList) => _buildList(context, ref, cardList),
        error: (error, stackTrace) => Center(
          child: Text('Erro: $error'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<WithlistCard> cardList) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final crossAxisCount = isMobile ? 2 : 3;

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

        // Card color adjustment for Withlist
        final isInWithlist = card.isInWithlist;
        final backgroundColor = isInWithlist
            ? cardColor.withOpacity(0.3)
            : cardColor.withOpacity(0.8);

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
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
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final controller =
                      ref.read(WithlistCardListControllerProvider.notifier);
                  if (isInWithlist) {
                    controller.removeWithlistCard(card.name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${card.name} removido da Withlist!')),
                    );
                  } else {
                    controller.addWithlistCard(card);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${card.name} adicionado à Withlist!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInWithlist ? Colors.red : Colors.green,
                ),
                child: Text(isInWithlist ? 'Remover' : 'Adicionar'),
              ),
            ],
          ),
        );
      },
    );
  }
}