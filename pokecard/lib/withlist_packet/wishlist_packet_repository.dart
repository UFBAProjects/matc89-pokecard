import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokecard/withlist_packet/withlist_packet.dart';

class WithlistCardRepository {
  final FirebaseFirestore _firestore;

  WithlistCardRepository(this._firestore);

  Future<List<WithlistCard>> fetchWithlist() async {
    try{
      final querySnapshot = await _firestore.collection('wishlist').get();
      final withlist = querySnapshot.docs.map((doc){
        return WithlistCard.fromJson(doc.data()); 
      }).toList(); 
      return withlist; 
    }
    catch(e){
      rethrow; 
    }
  }
  Future<void> saveAllWithlistCard(List<WithlistCard> cards) async{
    final batch = _firestore.batch(); 
    final collection = _firestore.collection('withlist'); 

    for (var card in cards){
      final docRef = collection.doc();
      batch.set(docRef, card.toJson()); 
    }
    try{
      await batch.commit(); 
      print('Cards adicionados na withlist com sucesso!');
    }
    catch(e){
      print('Erro ao adicionar cards a withlist: $e'); 
      rethrow;
    }
  }
  Future<void> addCardWithlist(WithlistCard card) async{
    try{
      await _firestore.collection('withlist').add(card.toJson()); 
      print('Card adicionado na withlist com sucesso!'); 
    }
    catch(e){
      print('Erro ao adicionar card a withlist: $e');
      rethrow;
    }
  }
  Future<void> removeCardWithlist(String name) async {
    try{
      final querySnapshot = await _firestore.collection('withlist').where('name', isEqualTo: name).get(); 
      if(querySnapshot.docs.isEmpty){
        print('Card com o nome $name não encontrado'); 
      }
      for(var doc in querySnapshot.docs){
        await doc.reference.delete(); 
        print('Card $name excluído com sucesso da withlist.');
      }
    }
    catch(e){
      print('Erro ao remover card $name da withlist: $e');
      rethrow;
    }
  }
}