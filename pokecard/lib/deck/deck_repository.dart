import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pokecard/deck/deck.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class PokeDeckRepository {
  final FirebaseFirestore _firestore;

  PokeDeckRepository(this._firestore);

  Future<PokeDeck> getDeckById(String deckId) async {
    final collection = _firestore.collection('pokeDecks');

    try {
      final docSnapshot = await collection.doc(deckId).get();

      if (!docSnapshot.exists) {
        throw Exception('Deck não encontrado!');
      }

      final data = docSnapshot.data()!;

      return PokeDeck(
        id: docSnapshot.id,
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
    } catch (e) {
      throw Exception('Erro ao buscar o deck: $e');
    }
  }

  Future<List<PokeCard>> getAllMyCards() async {
    final collection = _firestore.collection('pokecards');

    try {
      final snapshot = await collection.get();
      final decks = snapshot.docs.map((doc) {
        final data = doc.data();
        return PokeCard(
          name: data['name'] as String,
          type: data['type'] as String,
          weight: data['weight'] as int,
          abilities: List<String>.from(data['abilities']),
          image: data['image'] as String,
          color: data['color'] as String,
        );
      }).toList();
      return decks;
    } catch (e) {
      throw Exception('Erro ao buscar os decks: $e');
    }
  }

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
      final deckDoc = collection.doc(deckId);

      final snapshot = await deckDoc.get();
      if (!snapshot.exists) {
        throw Exception('Deck não encontrado com o ID $deckId');
      }
      final deckData = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> currentCards = deckData['cards'] ?? [];
      final updatedCards = List.from(currentCards)..add(card.toJson());

      await deckDoc.update({'cards': updatedCards});
    } catch (e) {
      throw Exception('Erro ao adicionar a carta no deck: $e');
    }
  }

  Future<void> deleteCardFromDeck(String deckId, int cardIndex) async {
    final collection = _firestore.collection('pokeDecks');
    try {
      final snapshot = await collection.doc(deckId).get();
      if (!snapshot.exists) {
        throw Exception('Deck não encontrado');
      }
      final data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> cards = data['cards'];
      if (cardIndex < 0 || cardIndex >= cards.length) {
        throw Exception('Índice do card inválido');
      }
      cards.removeAt(cardIndex);
      await collection.doc(deckId).update({'cards': cards});
    } catch (e) {
      throw Exception('Erro ao deletar o card do deck: $e');
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
