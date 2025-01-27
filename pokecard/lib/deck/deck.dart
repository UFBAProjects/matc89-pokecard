

import 'package:pokecard/mistery_packet/mistery_packet.dart';

class PokeDeck {
  final String id;
  final String name;
  final List<PokeCard> cards;

  PokeDeck({
    required this.name,
    required this.id,
    required this.cards,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cards': cards.map((card) => card.toJson()).toList()
      };
}
