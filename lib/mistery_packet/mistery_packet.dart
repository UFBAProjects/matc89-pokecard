class PokeCard {
  final String name;
  final String type;
  final int weight;
  final List<String> abilities;
  final String image;
  final String color;

  PokeCard({
    required this.name,
    required this.type,
    required this.weight,
    required this.abilities,
    required this.image,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'weight': weight,
        'abilities': abilities,
        'image': image,
        'color': color,
      };
}
