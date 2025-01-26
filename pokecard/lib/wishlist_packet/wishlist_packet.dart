import 'package:pokecard/mistery_packet/mistery_packet.dart';

class WishlistCard {
  final String id;
  final String name;
  final List<PokeCard> cards; 

  WishlistCard({
    required this.id,
    required this.name,
    required this.cards,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name, 
        'cards': cards.map((card) => card.toJson().toList()) 
      };
}
