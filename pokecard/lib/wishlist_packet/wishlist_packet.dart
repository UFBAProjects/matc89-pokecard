import 'package:pokecard/mistery_packet/mistery_packet.dart';

class WithlistCard {
  final List<PokeCard> cards; 

  WishlistCard({
    required this.cards,
  });

  Map<String, dynamic> toJson() => { 
        'cards': cards.map((card) => card.toJson()).toList(),  
      };

  factory WishlistCard.fromJson(Map<String, dynamic> json){
    return WishlistCard(
      cards: (json['cards'] as List<dynamic>).map((item) => Card(
        name: item['name'],
        type: item['type'],
        weight: item['weight'],
        abilities: item['abilities'],
        image: item['image'],
        color: item['color'],
      )).toList(), 
    ); 
  }
}
