import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../models/recipe.dart';
import '../database/database.dart';

class RecipeRepository {
  final AppDatabase _database;

  RecipeRepository(this._database);

  // サンプルレシピデータ
  List<Recipe> _getAllRecipes() {
    return [
      Recipe(
        id: '1',
        title: '和風カルボナーラ',
        description: '醤油と出汁が香る新感覚のカルボナーラ。クリーミーで濃厚な味わい',
        imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=800',
        category: '和食',
        prepTime: 10,
        cookTime: 15,
        servings: 2,
        calories: 520,
        rating: 4.8,
        ingredients: [
          'スパゲッティ 200g',
          '卵黄 2個',
          'ベーコン 80g',
          '醤油 大さじ1',
          '出汁 50ml',
          'パルメザンチーズ 40g',
          '黒胡椒 適量',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: 'パスタを茹で始める'),
          RecipeStep(stepNumber: 2, description: 'ベーコンを細切りにして炒める'),
          RecipeStep(stepNumber: 3, description: '卵黄、醤油、出汁、チーズを混ぜる'),
          RecipeStep(stepNumber: 4, description: '茹でたパスタと炒めたベーコンを和える'),
          RecipeStep(stepNumber: 5, description: '火を止めてソースを絡める'),
        ],
        allergies: ['卵', '乳製品', '小麦'],
        comments: [
          RecipeComment(
            id: 'c1',
            userName: '料理好きママ',
            userAvatar: 'https://i.pravatar.cc/150?img=1',
            comment: '家族に大好評でした!醤油の風味が最高です',
            rating: 5.0,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
      Recipe(
        id: '2',
        title: 'トマトとモッツァレラのカプレーゼ',
        description: '新鮮なトマトとモッツァレラチーズのシンプルな前菜',
        imageUrl: 'https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=800',
        category: 'イタリアン',
        prepTime: 5,
        cookTime: 0,
        servings: 2,
        calories: 180,
        rating: 4.6,
        ingredients: [
          'トマト 2個',
          'モッツァレラチーズ 200g',
          'バジル 適量',
          'オリーブオイル 大さじ2',
          'バルサミコ酢 大さじ1',
          '塩 少々',
          '黒胡椒 少々',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: 'トマトとモッツァレラを薄切りにする'),
          RecipeStep(stepNumber: 2, description: '交互に並べる'),
          RecipeStep(stepNumber: 3, description: 'バジルをちぎってのせる'),
          RecipeStep(stepNumber: 4, description: 'オリーブオイルとバルサミコをかける'),
        ],
        allergies: ['乳製品'],
        comments: [],
      ),
      Recipe(
        id: '3',
        title: 'チキンテリヤキ丼',
        description: 'ジューシーな照り焼きチキンがご飯にぴったり',
        imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=800',
        category: '和食',
        prepTime: 15,
        cookTime: 20,
        servings: 2,
        calories: 650,
        rating: 4.9,
        ingredients: [
          '鶏もも肉 300g',
          '醤油 大さじ3',
          'みりん 大さじ3',
          '砂糖 大さじ2',
          '酒 大さじ2',
          'ご飯 2杯分',
          '刻み海苔 適量',
          'ネギ 適量',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: '鶏肉を一口大に切る'),
          RecipeStep(stepNumber: 2, description: 'フライパンで皮目から焼く'),
          RecipeStep(stepNumber: 3, description: '調味料を混ぜてタレを作る'),
          RecipeStep(stepNumber: 4, description: 'タレを加えて煮詰める'),
          RecipeStep(stepNumber: 5, description: 'ご飯に盛り付けて完成'),
        ],
        allergies: ['大豆'],
        comments: [
          RecipeComment(
            id: 'c2',
            userName: 'グルメ太郎',
            userAvatar: 'https://i.pravatar.cc/150?img=12',
            comment: 'タレの味付けが絶妙!リピート確定です',
            rating: 5.0,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      Recipe(
        id: '4',
        title: 'マルゲリータピザ',
        description: 'トマトソースとモッツァレラチーズのシンプルな本格ピザ',
        imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800',
        category: 'イタリアン',
        prepTime: 90,
        cookTime: 15,
        servings: 2,
        calories: 520,
        rating: 4.8,
        ingredients: [
          '強力粉 200g',
          'ドライイースト 3g',
          '砂糖 小さじ1',
          '塩 小さじ1/2',
          'オリーブオイル 大さじ1',
          'ぬるま湯 120ml',
          'トマトソース 100g',
          'モッツァレラチーズ 150g',
          'バジル 適量',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: '生地の材料を混ぜてこねる'),
          RecipeStep(stepNumber: 2, description: '生地を60分発酵させる'),
          RecipeStep(stepNumber: 3, description: '生地を薄く伸ばす'),
          RecipeStep(stepNumber: 4, description: 'トマトソースとチーズをのせる'),
          RecipeStep(stepNumber: 5, description: '230℃のオーブンで15分焼く'),
          RecipeStep(stepNumber: 6, description: 'バジルをのせて完成'),
        ],
        allergies: ['小麦', '乳製品'],
        comments: [],
      ),
      Recipe(
        id: '5',
        title: 'シーフードパエリア',
        description: 'エビとムール貝の旨味が詰まった本格パエリア',
        imageUrl: 'https://images.unsplash.com/photo-1534080564583-6be75777b70a?w=800',
        category: 'スペイン料理',
        prepTime: 25,
        cookTime: 30,
        servings: 4,
        calories: 580,
        rating: 4.8,
        ingredients: [
          '米 2合',
          'エビ 8尾',
          'ムール貝 12個',
          'イカ 1杯',
          'トマト 2個',
          'サフラン 少々',
          'パプリカパウダー 小さじ1',
          'にんにく 2片',
          'オリーブオイル 大さじ3',
          'レモン 1個',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: 'シーフードの下処理をする'),
          RecipeStep(stepNumber: 2, description: 'にんにくを炒めて香りを出す'),
          RecipeStep(stepNumber: 3, description: '米とサフランを加える'),
          RecipeStep(stepNumber: 4, description: 'シーフードをのせる'),
          RecipeStep(stepNumber: 5, description: '蓋をして炊き上げる'),
        ],
        allergies: ['甲殻類', '軟体動物'],
        comments: [],
      ),
      Recipe(
        id: '6',
        title: 'ガパオライス',
        description: 'タイの定番料理。バジルの香りが食欲をそそる',
        imageUrl: 'https://images.unsplash.com/photo-1569562211093-4ed0d0758f12?w=800',
        category: 'タイ料理',
        prepTime: 15,
        cookTime: 10,
        servings: 2,
        calories: 520,
        rating: 4.7,
        ingredients: [
          '鶏ひき肉 300g',
          'バジル 1束',
          'パプリカ 1個',
          'ナンプラー 大さじ2',
          'オイスターソース 大さじ1',
          '砂糖 小さじ1',
          'にんにく 2片',
          '唐辛子 2本',
          'ご飯 2杯分',
          '目玉焼き 2個',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: 'にんにくと唐辛子を炒める'),
          RecipeStep(stepNumber: 2, description: 'ひき肉を加えて炒める'),
          RecipeStep(stepNumber: 3, description: 'パプリカと調味料を加える'),
          RecipeStep(stepNumber: 4, description: 'バジルを加えてさっと炒める'),
          RecipeStep(stepNumber: 5, description: 'ご飯と目玉焼きと一緒に盛り付ける'),
        ],
        allergies: ['卵', '大豆'],
        comments: [],
      ),
      Recipe(
        id: '7',
        title: 'サーモンのムニエル',
        description: 'バターの香りが広がる上品な一皿',
        imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800',
        category: 'フレンチ',
        prepTime: 10,
        cookTime: 15,
        servings: 2,
        calories: 380,
        rating: 4.6,
        ingredients: [
          'サーモン切り身 2枚',
          '小麦粉 適量',
          'バター 30g',
          'レモン 1/2個',
          'パセリ 適量',
          '塩胡椒 適量',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: 'サーモンに塩胡椒をする'),
          RecipeStep(stepNumber: 2, description: '小麦粉を薄くまぶす'),
          RecipeStep(stepNumber: 3, description: 'バターで両面を焼く'),
          RecipeStep(stepNumber: 4, description: 'レモン汁を加える'),
          RecipeStep(stepNumber: 5, description: 'パセリを散らして完成'),
        ],
        allergies: ['魚', '乳製品', '小麦'],
        comments: [],
      ),
      Recipe(
        id: '8',
        title: 'ビーフストロガノフ',
        description: 'ロシアの伝統料理。牛肉とサワークリームの絶妙なハーモニー',
        imageUrl: 'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=800',
        category: 'ロシア料理',
        prepTime: 20,
        cookTime: 30,
        servings: 4,
        calories: 620,
        rating: 4.8,
        ingredients: [
          '牛肉薄切り 400g',
          'マッシュルーム 200g',
          '玉ねぎ 1個',
          'サワークリーム 200ml',
          '赤ワイン 100ml',
          'ビーフブイヨン 200ml',
          '小麦粉 大さじ2',
          'バター 30g',
        ],
        steps: [
          RecipeStep(stepNumber: 1, description: '牛肉に小麦粉をまぶす'),
          RecipeStep(stepNumber: 2, description: '玉ねぎとマッシュルームを炒める'),
          RecipeStep(stepNumber: 3, description: '牛肉を加えて焼く'),
          RecipeStep(stepNumber: 4, description: '赤ワインとブイヨンで煮込む'),
          RecipeStep(stepNumber: 5, description: 'サワークリームを加えて仕上げる'),
        ],
        allergies: ['乳製品', '小麦'],
        comments: [],
      ),
    ];
  }

  // 全レシピを取得
  Future<List<Recipe>> getAllRecipes() async {
    final recipes = _getAllRecipes();
    final favoriteIds = await _database.getAllFavorites();
    final favoriteIdSet = favoriteIds.map((f) => f.id).toSet();

    return recipes
        .map((recipe) =>
            recipe.copyWith(isFavorite: favoriteIdSet.contains(recipe.id)))
        .toList();
  }

  // カテゴリでフィルタ
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await getAllRecipes();
    if (category == 'すべて') return recipes;
    return recipes.where((r) => r.category == category).toList();
  }

  // 検索
  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await getAllRecipes();
    if (query.isEmpty) return recipes;

    return recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query.toLowerCase()) ||
          recipe.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // お気に入りレシピを取得
  Future<List<Recipe>> getFavoriteRecipes() async {
    final favorites = await _database.getAllFavorites();
    final allRecipes = _getAllRecipes();

    return allRecipes
        .where((recipe) => favorites.any((f) => f.id == recipe.id))
        .map((recipe) => recipe.copyWith(isFavorite: true))
        .toList();
  }

  // お気に入りに追加
  Future<void> addToFavorites(Recipe recipe) async {
    await _database.addFavorite(
      FavoriteRecipesCompanion(
        id: drift.Value(recipe.id),
        title: drift.Value(recipe.title),
        description: drift.Value(recipe.description),
        imageUrl: drift.Value(recipe.imageUrl),
        category: drift.Value(recipe.category),
        prepTime: drift.Value(recipe.prepTime),
        cookTime: drift.Value(recipe.cookTime),
        servings: drift.Value(recipe.servings),
        calories: drift.Value(recipe.calories),
        rating: drift.Value(recipe.rating),
        ingredients: drift.Value(jsonEncode(recipe.ingredients)),
        steps: drift.Value(jsonEncode(recipe.steps.map((s) => {
          'stepNumber': s.stepNumber,
          'description': s.description,
        }).toList())),
        allergies: drift.Value(jsonEncode(recipe.allergies)),
        savedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  // お気に入りから削除
  Future<void> removeFromFavorites(String recipeId) async {
    await _database.removeFavorite(recipeId);
  }

  // お気に入りチェック
  Future<bool> isFavorite(String recipeId) async {
    return await _database.isFavorite(recipeId);
  }

  // IDでレシピを取得
  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
