class WithlistCard {
  final String name;
  final String type;
  final String weight;
  final List<String> abilities;
  final String image;
  final String color;
  final bool isInWithlist; // Adicionando a propriedade isInWithlist

  WithlistCard({
    required this.name,
    required this.type,
    required this.weight,
    required this.abilities,
    required this.image,
    required this.color,
    required this.isInWithlist, // Incluindo isInWithlist no construtor
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'weight': weight,
        'abilities': abilities,
        'image': image,
        'color': color,
        'isInWithlist': isInWithlist, // Adicionando no método toJson
      };

  factory WithlistCard.fromJson(Map<String, dynamic> json) {
    return WithlistCard(
      name: json['name'],
      type: json['type'],
      weight: json['weight'],
      abilities: List<String>.from(json['abilities']),
      image: json['image'],
      color: json['color'],
      isInWithlist: json['isInWithlist'] ?? false, // Recuperando o valor de isInWithlist
    );
  }
}
