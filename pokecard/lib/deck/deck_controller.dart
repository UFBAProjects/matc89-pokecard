import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/deck/deck.dart';
import 'package:pokecard/deck/deck_repository.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

final deckListControllerProvider =
    StateNotifierProvider<DeckController, AsyncValue<List<PokeDeck>>>(
  (ref) => DeckController(
    PokeDeckRepository(FirebaseFirestore.instance),
  ),
);

class DeckController extends StateNotifier<AsyncValue<List<PokeDeck>>> {
  final PokeDeckRepository repository;

  DeckController(this.repository) : super(const AsyncValue.loading()) {
    getAllDecks();
  }

  Future<void> getAllDecks() async {
    try {
      state = const AsyncValue.loading();
      final decks = await repository.getAllDecks();
      state = AsyncValue.data(decks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveDeck(String deckName, [List<Card>? cards]) async {
    await repository.saveDeck(deckName, cards);
  }

  Future<void> updateDeck(String deckId, String deckName) async {
    await repository.updateDeck(deckId, deckName);
  }

  Future<void> deleteDeck(String deckId) async {
    await repository.deleteDeck(deckId);
  }

  Future<void> addCardInDeck(String deckId, PokeCard card) async {
    await repository.addCardInDeck(deckId, card);
  }
}
