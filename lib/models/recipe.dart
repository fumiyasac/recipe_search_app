class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int prepTime; // 分
  final int cookTime; // 分
  final int servings;
  final int calories;
  final double rating;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final List<String> allergies;
  final List<RecipeComment> comments;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.calories,
    required this.rating,
    required this.ingredients,
    required this.steps,
    required this.allergies,
    required this.comments,
    this.isFavorite = false,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    int? prepTime,
    int? cookTime,
    int? servings,
    int? calories,
    double? rating,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    List<String>? allergies,
    List<RecipeComment>? comments,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      allergies: allergies ?? this.allergies,
      comments: comments ?? this.comments,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  int get totalTime => prepTime + cookTime;
}

class RecipeStep {
  final int stepNumber;
  final String description;
  final String? imageUrl;

  RecipeStep({
    required this.stepNumber,
    required this.description,
    this.imageUrl,
  });
}

class RecipeComment {
  final String id;
  final String userName;
  final String userAvatar;
  final String comment;
  final double rating;
  final DateTime createdAt;

  RecipeComment({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}
