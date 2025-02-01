import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/mistery_packet/mistery_packet.dart'; // Importa a classe PokeCard

class CollectionRepository {
  final FirebaseFirestore _firestore;

  CollectionRepository(this._firestore);

  Future<List<PokeCard>> getAllCards() async {
    final collection = _firestore.collection('pokecards'); // Certifique-se de que a coleção está correta

    try {
      final snapshot = await collection.get();
      final cards = snapshot.docs.map((doc) {
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
      return cards;
    } catch (e) {
      throw Exception('Erro ao buscar os cards: $e');
    }
  }
}
