import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class PokeCardRepository {
  final FirebaseFirestore _firestore;

  PokeCardRepository(this._firestore);

  Future<void> saveAllCards(List<PokeCard> cards) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('pokecards');

    for (var card in cards) {
      final docRef = collection.doc();
      batch.set(docRef, card.toJson());
    }

    await batch.commit();
  }
}
