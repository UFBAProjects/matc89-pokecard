import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';
import 'package:pokecard/collection/collection_controller.dart';
import 'package:pokecard/widgets/cardWidget.dart';


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
          return PokeCardGrid(cardList: cards);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
