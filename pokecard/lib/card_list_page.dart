import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokecard/card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_list_page.g.dart';

@riverpod
class CardListController extends _$CardListController {
  @override
  Future<List<PokeCard>> build() {
    return Future.delayed(const Duration(seconds: 2), () => [
      PokeCard(name: "Pikachu", weight: 5),
      PokeCard(name: "Charmander", weight: 8),
      PokeCard(name: "Bulbasaur", weight: 6),
    ]);
  }
}

class CardListPage extends ConsumerWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardListAsyncValue = ref.watch(cardListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cards'),),
      body: Center(
        child: cardListAsyncValue.when(
          data: (cardList) => _buildList(context, cardList),
          error: (error, stackTrace) => Text('Error: $error'),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
  
  _buildList(BuildContext context, List<PokeCard> cardList) {
    return ListView.builder(
      itemCount: cardList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(cardList[index].name),
        subtitle: Text('Weight: ${cardList[index].weight}')
      ),);
  }
}
