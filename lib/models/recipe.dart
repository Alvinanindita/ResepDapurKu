class Recipe {
  final String id;
  final String name;
  final String category;
  final String image;
  final String cookTime;
  final String difficulty;
  final String description;
  final List<String> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.cookTime,
    required this.difficulty,
    required this.description,
    required this.ingredients,
  });

  //Ubah ke Map untuk JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image': image,
      'cookTime': cookTime,
      'difficulty': difficulty,
      'description': description,
      'ingredients': ingredients,
    };
  }

  //Ambil dari Map (JSON)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      image: map['image'],
      cookTime: map['cookTime'],
      difficulty: map['difficulty'],
      description: map['description'],
      ingredients: List<String>.from(map['ingredients']),
    );
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    String? image,
    String? cookTime,
    String? difficulty,
    String? description,
    List<String>? ingredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      image: image ?? this.image,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}