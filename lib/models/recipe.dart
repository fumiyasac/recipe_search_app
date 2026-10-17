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
  // お気に入り状態は Recipe に持たせない。favoriteIdsProvider（drift の watch()）が
  // 唯一の情報源であり、スナップショットに状態を持たせるとズレて不具合の原因になる。
  final NutritionInfo? nutritionInfo;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> tags;
  final List<String> cookingTools;

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
    this.nutritionInfo,
    this.difficulty = 'medium',
    this.tags = const [],
    this.cookingTools = const [],
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
    NutritionInfo? nutritionInfo,
    String? difficulty,
    List<String>? tags,
    List<String>? cookingTools,
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
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      cookingTools: cookingTools ?? this.cookingTools,
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

class NutritionInfo {
  final double protein; // タンパク質 (g)
  final double fat; // 脂質 (g)
  final double carbs; // 炭水化物 (g)
  final double fiber; // 食物繊維 (g)
  final double salt; // 塩分 (g)

  NutritionInfo({
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.salt,
  });
}
