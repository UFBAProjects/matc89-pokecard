import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:pokecard/mistery_packet/mistery_packet.dart';

class WithlistCardRepository {
  final FirebaseFirestore _firestore;

  WithlistCardRepository(this._firestore);

  Future<List<PokeCard>> fetchWithlist() async {
    final collection = _firestore.collection('Withlist');
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
      print("Erro ao buscar os cards da wishlist: $e");  
      throw Exception('Erro ao buscar os cards da wishlist: $e');
    }
  }

  Future<List<PokeCard>> getAllCards() async {
   try {
      const generalEndpoint = 'https://pokeapi.co/api/v2/pokemon?limit=300';

    
      final generalResponse = await http.get(Uri.parse(generalEndpoint));
      if (generalResponse.statusCode != 200) {
        throw Exception('Falha ao encontrar lista de pokemons');
      }

      final generalData = json.decode(generalResponse.body);
      final results = generalData['results'] as List;

      
      final List<Future<PokeCard>> futureCards = results.map((pokemon) async {
        final detailResponse = await http.get(Uri.parse(pokemon['url']));
        if (detailResponse.statusCode != 200) {
          throw Exception('Falha ao encontrar datalhes do pokemon: ${pokemon['name']}');
        }

        final detailData = json.decode(detailResponse.body);

        
        final colorResponse = await http.get(Uri.parse(detailData['species']['url']));
        if (colorResponse.statusCode != 200) {
          throw Exception('Falha ao buscar dados de cor do pokemon: ${pokemon['name']}');
        }

        final colorData = json.decode(colorResponse.body);

        return PokeCard(
          name: detailData['name'],
          image: detailData['sprites']['front_default'] ?? '',
          type: (detailData['types'] as List)
              .map((t) => t['type']['name'] as String)
              .join(', '),
          weight: detailData['weight'],
          abilities: (detailData['abilities'] as List)
              .map((a) => a['ability']['name'] as String)
              .toList(),
          color: colorData['color']['name'],
        );
      }).toList();

      
      return await Future.wait(futureCards);
    } catch (e) {
      print('Erro ao encontrar pokemon: $e'); 
      throw Exception('Erro ao encontrar pokemon: $e');
    }
  }

 Future<void> addCardWithlist(PokeCard card) async {
  final collection = _firestore.collection('Withlist');
  
  try {
    final cardData = card.toJson();

    if (cardData.isEmpty) {
      throw Exception('Os dados do card estão vazios');
    }
    final docRef = await collection.add(cardData);
    final updatedCards = []; 
    await docRef.update({'cards': updatedCards});
    print('Card "${card.name}" adicionado à wishlist com sucesso!');

  } catch (e) {
    print('Erro ao adicionar card "${card.name}" à wishlist: $e');
    throw Exception('Erro ao adicionar card "${card.name}" à wishlist: $e');
  }
}
  Future<void> removeCardWithlist(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection('Withlist')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Nenhum card com o nome "$name" encontrado.');
        return;
      }
        final doc = querySnapshot.docs.first;
        await doc.reference.delete();
        print('Card "$name" removido com sucesso da wishlist.');
    } catch (e) {
      print('Erro ao remover card "$name" da wishlist: $e');
      throw Exception('Erro ao remover card "$name" da wishlist: $e');
    }
  }
}
