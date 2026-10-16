import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class FavoriteRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text()();
  TextColumn get category => text()();
  IntColumn get prepTime => integer()();
  IntColumn get cookTime => integer()();
  IntColumn get servings => integer()();
  IntColumn get calories => integer()();
  RealColumn get rating => real()();
  TextColumn get ingredients => text()(); // JSON string
  TextColumn get steps => text()(); // JSON string
  TextColumn get allergies => text()(); // JSON string
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [FavoriteRecipes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// テスト用コンストラクタ。`NativeDatabase.memory()` などの任意の
  /// [QueryExecutor] を注入してインメモリ DB で検証できる。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // お気に入りレシピを取得
  Future<List<FavoriteRecipe>> getAllFavorites() async {
    return await select(favoriteRecipes).get();
  }

  // お気に入りレシピを追加
  Future<int> addFavorite(FavoriteRecipesCompanion recipe) async {
    return await into(favoriteRecipes).insert(recipe);
  }

  // お気に入りレシピを削除
  Future<int> removeFavorite(String id) async {
    return await (delete(favoriteRecipes)..where((t) => t.id.equals(id))).go();
  }

  // お気に入りかどうかをチェック
  Future<bool> isFavorite(String id) async {
    final result = await (select(
      favoriteRecipes,
    )..where((t) => t.id.equals(id))).get();
    return result.isNotEmpty;
  }

  // IDでお気に入りレシピを取得
  Future<FavoriteRecipe?> getFavoriteById(String id) async {
    final result = await (select(
      favoriteRecipes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return result;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'recipes.sqlite'));
    return NativeDatabase(file);
  });
}
