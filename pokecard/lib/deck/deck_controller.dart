import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/deck/deck.dart';
import 'package:pokecard/deck/deck_repository.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

// Provider para gerenciar o estado de decks
final deckListControllerProvider =
    StateNotifierProvider<DeckController, AsyncValue<List<PokeDeck>>>(
  (ref) => DeckController(
    PokeDeckRepository(FirebaseFirestore.instance),
  ),
);

// Provider para carregar todas as cartas do usuário
final getAllMyCardsProvider = FutureProvider<List<PokeCard>>((ref) async {
  final controller = ref.read(deckListControllerProvider.notifier);
  return controller.getAllMyCards();
});

// Provider para carregar todos os decks
final getAllDecksProvider = FutureProvider<List<PokeDeck>>((ref) async {
  final controller = ref.read(deckListControllerProvider.notifier);
  return controller.getAllDecks();
});

final getDeckByIdProvider =
    FutureProvider.family<PokeDeck, String>((ref, deckId) async {
  final controller = ref.read(deckListControllerProvider.notifier);
  return controller.getDeckById(deckId);
});

class DeckController extends StateNotifier<AsyncValue<List<PokeDeck>>> {
  final PokeDeckRepository repository;

  DeckController(this.repository) : super(const AsyncValue.loading());

  // Retorna todas as cartas do usuário
  Future<List<PokeCard>> getAllMyCards() async {
    try {
      final cards = await repository.getAllMyCards();
      return cards;
    } catch (e) {
      throw Exception('Failed to load cards: $e');
    }
  }

  Future<PokeDeck> getDeckById(String deckId) async {
    try {
      final deck = await repository.getDeckById(deckId);
      return deck;
    } catch (e, st) {
      throw Exception('Failed to load decks: $e');
    }
  }

  Future<List<PokeDeck>> getAllDecks() async {
    try {
      final decks = await repository.getAllDecks();
      state = AsyncValue.data(decks); // Atualiza o estado
      return decks;
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Atualiza o estado com erro
      throw Exception('Failed to load decks: $e');
    }
  }

  Future<void> saveDeck(String deckName, [List<Card>? cards]) async {
    await repository.saveDeck(deckName, cards);
  }

  Future<void> updateDeck(String deckId, String deckName) async {
    await repository.updateDeck(deckId, deckName);
  }

  Future<void> deleteCardFromDeck(String deckId, int cardIndex) async {
    await repository.deleteCardFromDeck(deckId, cardIndex);
  }

  Future<void> deleteDeck(String deckId) async {
    await repository.deleteDeck(deckId);
  }

  Future<void> addCardInDeck(String deckId, PokeCard card) async {
    await repository.addCardInDeck(deckId, card);
  }
}
