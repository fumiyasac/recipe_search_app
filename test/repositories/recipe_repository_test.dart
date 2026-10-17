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

  group('getAllRecipes / allRecipes', () {
    test('マスタの全 16 件を返す（お気に入り状態は持たない）', () async {
      final all = await repository.getAllRecipes();
      expect(all, hasLength(16));
    });

    test('allRecipes() も同じ 16 件を返す（同期版）', () {
      expect(repository.allRecipes(), hasLength(16));
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

  group('toggleFavorite / watchFavoriteIds', () {
    test('toggle で登録→解除が切り替わり、DB 状態で判定する', () async {
      final target = (await repository.getAllRecipes()).first;

      await repository.toggleFavorite(target);
      expect(await repository.isFavorite(target.id), isTrue);

      // 同じスナップショットを渡しても DB 状態で判定するので解除になる
      await repository.toggleFavorite(target);
      expect(await repository.isFavorite(target.id), isFalse);
    });

    test('watchFavoriteIds は追加・削除のたびに新しい id 集合を流す', () async {
      final target = (await repository.getAllRecipes()).first;
      final emissions = <Set<String>>[];
      final sub = repository.watchFavoriteIds().listen(emissions.add);
      addTearDown(sub.cancel);

      await pumpEventQueue();
      await repository.toggleFavorite(target); // 追加
      await pumpEventQueue();
      await repository.toggleFavorite(target); // 削除
      await pumpEventQueue();

      // 初期(空) → {target} → 空 の順で流れる
      expect(emissions.first, isEmpty);
      expect(emissions.any((s) => s.contains(target.id)), isTrue);
      expect(emissions.last, isEmpty);
    });
  });
}
