import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pokecard/deck/deck.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class PokeDeckRepository {
  final FirebaseFirestore _firestore;

  PokeDeckRepository(this._firestore);

  Future<List<PokeDeck>> getAllDecks() async {
    final collection = _firestore.collection('pokeDecks');

    try {
      final snapshot = await collection.get();
      final decks = snapshot.docs.map((doc) {
        final data = doc.data();
        return PokeDeck(
          id: doc.id,
          name: data['name'] as String,
          cards: (data['cards'] as List<dynamic>).map((card) {
            return PokeCard(
              name: card['name'] as String,
              type: card['type'] as String,
              weight: card['weight'] as int,
              abilities: List<String>.from(card['abilities']),
              image: card['image'] as String,
              color: card['color'] as String,
            );
          }).toList(),
        );
      }).toList();
      return decks;
    } catch (e) {
      throw Exception('Erro ao buscar os decks: $e');
    }
  }

  Future<void> saveDeck(String deckName, [List<Card>? cards]) async {
    final collection = _firestore.collection('pokeDecks');
    try {
      await collection.add({'name': deckName, 'cards': cards ?? []});
    } catch (e) {
      throw Exception('Erro ao salvar o deck: $e');
    }
  }

  Future<void> updateDeck(String deckId, String newDeckName) async {
    final collection = _firestore.collection('pokeDecks');
    try {
      await collection.doc(deckId).update({'name': newDeckName});
    } catch (e) {
      throw Exception('Erro ao atualizar o deck: $e');
    }
  }

  Future<void> addCardInDeck(String deckId, PokeCard card) async {
    final collection = _firestore.collection('pokeDecks');
    try {
      print(deckId);
      print(card.toJson());
      //await collection.add({'name': deckName, 'cards': cards ?? []});
    } catch (e) {
      throw Exception('Erro ao salvar o card no deck: $e');
    }
  }

  Future<void> deleteDeck(String deckId) async {
    final collection = _firestore.collection('pokeDecks');
    try {
      await collection.doc(deckId).delete();
    } catch (e) {
      throw Exception('Erro ao excluir o deck: $e');
    }
  }
}
