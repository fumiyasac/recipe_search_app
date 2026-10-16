import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/models/filter_state.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/models/recipe_filter.dart';

/// テスト用の Recipe ビルダー。フィルタに関係するフィールドだけ指定できる。
Recipe r({
  required String id,
  String category = '和食',
  String title = 'タイトル',
  String description = '説明',
  String difficulty = 'easy',
  int prepTime = 5,
  int cookTime = 5,
  int calories = 300,
  double rating = 4.0,
  List<String> allergies = const [],
  List<String> tags = const [],
  List<String> ingredients = const [],
}) {
  return Recipe(
    id: id,
    title: title,
    description: description,
    imageUrl: '',
    category: category,
    prepTime: prepTime,
    cookTime: cookTime,
    servings: 1,
    calories: calories,
    rating: rating,
    ingredients: ingredients,
    steps: const [],
    allergies: allergies,
    comments: const [],
    difficulty: difficulty,
    tags: tags,
  );
}

List<String> ids(List<Recipe> list) => list.map((e) => e.id).toList();

void main() {
  // 代表的なレシピ集合
  final sample = [
    r(
      id: 'wa',
      category: '和食',
      title: '和風カルボナーラ',
      description: '醤油が香る',
      difficulty: 'medium',
      prepTime: 10,
      cookTime: 15, // totalTime 25
      calories: 520,
      rating: 4.8,
      allergies: ['卵', '乳製品'],
      tags: ['時短', '洋風アレンジ'],
      ingredients: ['スパゲッティ', '卵黄', 'ベーコン'],
    ),
    r(
      id: 'ita',
      category: 'イタリアン',
      title: 'カプレーゼ',
      description: 'Fresh tomato salad',
      difficulty: 'easy',
      prepTime: 5,
      cookTime: 0, // totalTime 5
      calories: 180,
      rating: 4.6,
      allergies: ['乳製品'],
      tags: ['ヘルシー', '時短'],
      ingredients: ['トマト', 'モッツァレラ'],
    ),
    r(
      id: 'hard',
      category: 'フレンチ',
      title: 'ローストビーフ',
      description: '本格派',
      difficulty: 'hard',
      prepTime: 20,
      cookTime: 40, // totalTime 60
      calories: 420,
      rating: 4.0,
      allergies: [],
      tags: ['本格派', 'おもてなし'],
      ingredients: ['牛もも肉', 'にんにく'],
    ),
  ];

  group('フィルタ未指定', () {
    test('initial はすべて素通し（入力は変更しない）', () {
      final result = applyFilters(sample, FilterState.initial());
      expect(ids(result), ['wa', 'ita', 'hard']);
    });

    test('空リストは空を返す', () {
      expect(applyFilters(const <Recipe>[], FilterState.initial()), isEmpty);
    });
  });

  group('1. カテゴリ', () {
    test('一致するカテゴリのみ残る', () {
      final s = FilterState.initial().copyWith(category: '和食');
      expect(ids(applyFilters(sample, s)), ['wa']);
    });

    test('「すべて」は素通し', () {
      final s = FilterState.initial().copyWith(category: 'すべて');
      expect(ids(applyFilters(sample, s)), ['wa', 'ita', 'hard']);
    });
  });

  group('2. 検索クエリ', () {
    test('タイトル部分一致', () {
      final s = FilterState.initial().copyWith(searchQuery: 'カルボ');
      expect(ids(applyFilters(sample, s)), ['wa']);
    });

    test('説明部分一致', () {
      final s = FilterState.initial().copyWith(searchQuery: '本格派');
      expect(ids(applyFilters(sample, s)), ['hard']);
    });

    test('大文字小文字を無視する', () {
      final s = FilterState.initial().copyWith(searchQuery: 'TOMATO');
      expect(ids(applyFilters(sample, s)), ['ita']);
    });

    test('該当なしは 0 件', () {
      final s = FilterState.initial().copyWith(searchQuery: '存在しない語');
      expect(applyFilters(sample, s), isEmpty);
    });
  });

  group('3. 難易度（OR 条件）', () {
    test('複数選択はいずれかに一致で残る', () {
      final s = FilterState.initial().copyWith(difficulties: {'easy', 'hard'});
      expect(ids(applyFilters(sample, s)), ['ita', 'hard']);
    });
  });

  group('4. 調理時間（境界値は含む）', () {
    test('30分以内: totalTime==25,5 が残り 60 は除外', () {
      final s = FilterState.initial().copyWith(
        cookingTimeRange: CookingTimeRange.under30,
      );
      expect(ids(applyFilters(sample, s)), ['wa', 'ita']);
    });

    test('境界値 60 は「1時間以内」に含まれる', () {
      final s = FilterState.initial().copyWith(
        cookingTimeRange: CookingTimeRange.under60,
      );
      expect(ids(applyFilters(sample, s)), ['wa', 'ita', 'hard']);
    });
  });

  group('5. カロリー（境界値は含む）', () {
    test('低カロリー(<=300): 180 のみ', () {
      final s = FilterState.initial().copyWith(calorieRange: CalorieRange.low);
      expect(ids(applyFilters(sample, s)), ['ita']);
    });

    test('中カロリー(<=500): 420 と 180', () {
      final s = FilterState.initial().copyWith(
        calorieRange: CalorieRange.medium,
      );
      expect(ids(applyFilters(sample, s)), ['ita', 'hard']);
    });
  });

  group('6. 評価（境界値は含む）', () {
    test('4.0 以上: 境界の 4.0 も残る', () {
      final s = FilterState.initial().copyWith(minRating: 4.0);
      expect(ids(applyFilters(sample, s)), ['wa', 'ita', 'hard']);
    });

    test('4.7 以上: wa のみ', () {
      final s = FilterState.initial().copyWith(minRating: 4.7);
      expect(ids(applyFilters(sample, s)), ['wa']);
    });
  });

  group('7. アレルギー除外', () {
    test('卵を除外すると wa が消える', () {
      final s = FilterState.initial().copyWith(excludedAllergies: {'卵'});
      expect(ids(applyFilters(sample, s)), ['ita', 'hard']);
    });

    test('乳製品を除外すると wa と ita が消える', () {
      final s = FilterState.initial().copyWith(excludedAllergies: {'乳製品'});
      expect(ids(applyFilters(sample, s)), ['hard']);
    });
  });

  group('8. タグ（AND 条件）', () {
    test('単一タグ: 時短を含む 2 件', () {
      final s = FilterState.initial().copyWith(selectedTags: {'時短'});
      expect(ids(applyFilters(sample, s)), ['wa', 'ita']);
    });

    test('複数タグは全て含む必要がある（AND）', () {
      final s = FilterState.initial().copyWith(selectedTags: {'時短', 'ヘルシー'});
      expect(ids(applyFilters(sample, s)), ['ita']);
    });
  });

  group('9. 材料フィルタ', () {
    test('mustInclude（AND・大文字小文字無視）', () {
      final s = FilterState.initial().copyWith(
        ingredientFilter: const IngredientFilter(mustInclude: {'トマト'}),
      );
      expect(ids(applyFilters(sample, s)), ['ita']);
    });

    test('mustInclude 複数は全て含む必要がある', () {
      final s = FilterState.initial().copyWith(
        ingredientFilter: const IngredientFilter(mustInclude: {'トマト', '牛もも肉'}),
      );
      expect(applyFilters(sample, s), isEmpty);
    });

    test('mustExclude: 含むものを除外', () {
      final s = FilterState.initial().copyWith(
        ingredientFilter: const IngredientFilter(mustExclude: {'卵'}),
      );
      expect(ids(applyFilters(sample, s)), ['ita', 'hard']);
    });

    test('mustInclude と mustExclude の併用', () {
      final s = FilterState.initial().copyWith(
        ingredientFilter: const IngredientFilter(
          mustInclude: {'ベーコン'},
          mustExclude: {'トマト'},
        ),
      );
      expect(ids(applyFilters(sample, s)), ['wa']);
    });

    test('空の IngredientFilter は素通し（内側の分岐に入らない）', () {
      final s = FilterState.initial().copyWith(
        ingredientFilter: const IngredientFilter(),
      );
      expect(ids(applyFilters(sample, s)), ['wa', 'ita', 'hard']);
    });
  });

  group('複数条件の組み合わせ', () {
    test('カテゴリ + タグ + 調理時間', () {
      final s = FilterState.initial().copyWith(
        category: 'イタリアン',
        selectedTags: {'時短'},
        cookingTimeRange: CookingTimeRange.under30,
      );
      expect(ids(applyFilters(sample, s)), ['ita']);
    });

    test('組み合わせで 0 件になる', () {
      final s = FilterState.initial().copyWith(
        category: '和食',
        minRating: 5.0, // wa は 4.8 なので脱落
      );
      expect(applyFilters(sample, s), isEmpty);
    });
  });
}
