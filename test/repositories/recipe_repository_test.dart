import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/repositories/recipe_repository.dart';

// RecipeRepository の検索系メソッドを、インメモリ drift を使って検証する。
// レシピのマスタデータは _getAllRecipes() のハードコード（16 件）。
void main() {
  late AppDatabase db;
  late RecipeRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = RecipeRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('getAllRecipes', () {
    test('マスタの全 16 件を返し、初期は全て未お気に入り', () async {
      final all = await repository.getAllRecipes();
      expect(all, hasLength(16));
      expect(all.every((r) => r.isFavorite == false), isTrue);
    });

    test('お気に入り登録済みの recipe は isFavorite=true になる', () async {
      final target = (await repository.getAllRecipes()).first;
      await repository.addToFavorites(target);

      final all = await repository.getAllRecipes();
      final updated = all.firstWhere((r) => r.id == target.id);
      expect(updated.isFavorite, isTrue);
      // 他は未お気に入りのまま
      expect(all.where((r) => r.isFavorite).map((r) => r.id), [target.id]);
    });
  });

  group('getRecipesByCategory', () {
    test('「すべて」は全件を返す', () async {
      final result = await repository.getRecipesByCategory('すべて');
      expect(result, hasLength(16));
    });

    test('和食は 3 件で全て category==和食', () async {
      final result = await repository.getRecipesByCategory('和食');
      expect(result, hasLength(3));
      expect(result.every((r) => r.category == '和食'), isTrue);
    });

    test('存在しないカテゴリは 0 件', () async {
      expect(await repository.getRecipesByCategory('宇宙料理'), isEmpty);
    });
  });

  group('searchRecipes', () {
    test('空クエリは全件を返す', () async {
      expect(await repository.searchRecipes(''), hasLength(16));
    });

    test('タイトル／説明への部分一致', () async {
      final result = await repository.searchRecipes('カレー');
      expect(result, isNotEmpty);
      expect(
        result.every(
          (r) => r.title.contains('カレー') || r.description.contains('カレー'),
        ),
        isTrue,
      );
      expect(result.map((r) => r.id), contains('10')); // グリーンカレー
    });

    test('該当しないクエリは 0 件', () async {
      expect(await repository.searchRecipes('存在しない料理名'), isEmpty);
    });
  });

  group('getRecipeById', () {
    test('存在する ID はその recipe を返す', () async {
      final recipe = await repository.getRecipeById('1');
      expect(recipe, isNotNull);
      expect(recipe!.id, '1');
    });

    test('存在しない ID は null を返す', () async {
      expect(await repository.getRecipeById('does-not-exist'), isNull);
    });
  });

  group('お気に入りの追加・削除', () {
    test('add → getFavoriteRecipes → remove の往復', () async {
      final target = (await repository.getAllRecipes()).first;

      await repository.addToFavorites(target);
      expect(await repository.isFavorite(target.id), isTrue);
      final favs = await repository.getFavoriteRecipes();
      expect(favs.map((r) => r.id), [target.id]);
      expect(favs.single.isFavorite, isTrue);

      await repository.removeFromFavorites(target.id);
      expect(await repository.isFavorite(target.id), isFalse);
      expect(await repository.getFavoriteRecipes(), isEmpty);
    });
  });
}
