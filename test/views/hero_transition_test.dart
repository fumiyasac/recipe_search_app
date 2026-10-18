import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/database/database.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/viewmodels/providers.dart';
import 'package:recipe_search_app/views/calendar_screen.dart';
import 'package:recipe_search_app/views/favorites_screen.dart';
import 'package:recipe_search_app/views/main_navigation_screen.dart';
import 'package:recipe_search_app/views/recipe_detail_screen.dart';
import 'package:recipe_search_app/views/recipe_list_screen.dart';
import 'package:recipe_search_app/widgets/recipe_card.dart';
import 'package:recipe_search_app/widgets/recipe_hero_image.dart';

import '../support/network_image_mock.dart';

Recipe sampleRecipe({String id = '1'}) => Recipe(
  id: id,
  title: '和風カルボナーラ',
  description: '醤油と出汁が香る新感覚のカルボナーラ',
  imageUrl: 'https://example.com/image.jpg',
  category: '和食',
  prepTime: 10,
  cookTime: 15,
  servings: 2,
  calories: 520,
  rating: 4.8,
  ingredients: const ['スパゲッティ'],
  steps: [RecipeStep(stepNumber: 1, description: '茹でる')],
  allergies: const ['卵'],
  comments: const [],
  nutritionInfo: NutritionInfo(
    protein: 22.5,
    fat: 18.3,
    carbs: 65.2,
    fiber: 3.1,
    salt: 2.8,
  ),
  difficulty: 'medium',
  tags: const ['時短'],
  cookingTools: const ['鍋'],
);

(ProviderContainer, AppDatabase) makeContainer() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
  );
  return (container, db);
}

void main() {
  // A/B: 遷移先の Hero がテキスト（情報カード）を含んでいないこと。
  // 修正前は Hero が Stack(画像 + 情報カードのテキスト) を包むため失敗する。
  testWidgets('A/B: 詳細画面の Hero は画像だけを包み、テキストを含まない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: RecipeDetailScreen(recipe: sampleRecipe())),
        ),
      );
      await tester.pumpAndSettle();

      final hero = find.byType(Hero);
      expect(hero, findsOneWidget);
      // Hero のサブツリーに Text があってはいけない（遷移中に押しつぶし＋下線の原因）
      expect(
        find.descendant(of: hero, matching: find.byType(Text)),
        findsNothing,
        reason: 'Hero がテキスト（情報カード）を含んでいる（A/B の原因）',
      );
    });
  });

  // A/B/C/F: home → detail の遷移を途中で pump しても例外が出ないこと。
  testWidgets('home→detail の遷移を 0〜100% で pump しても例外が出ない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pump(); // 遷移開始
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });
  });

  // D: カレンダー画面の遷移元に Hero があること（修正前は無いので失敗）。
  testWidgets('D: カレンダー画面のレシピに Hero がある', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CalendarScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Hero), findsWidgets, reason: 'カレンダーの遷移元に Hero が無い（D）');
    });
  });

  // F: 詳細を下にスクロール（SliverAppBar が縮む）してから戻っても例外が出ないこと。
  testWidgets('F: 詳細をスクロールしてから戻っても例外が出ない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(RecipeDetailScreen), findsOneWidget);

      // 詳細を下にスクロールして SliverAppBar を縮める
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // 戻る（Hero 復路）
      final navigator = Navigator.of(
        tester.element(find.byType(CustomScrollView)),
      );
      navigator.pop();
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(find.byType(RecipeListScreen), findsOneWidget);
    });
  });

  // E: ホームとお気に入りの両タブに同じ tag の Hero が同時に存在し、遷移で tag が重複する。
  testWidgets('E: お気に入り登録済みレシピをホームから開くと Hero tag が重複しない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: MainNavigationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // ホーム先頭カードをお気に入り登録（→ お気に入りタブにも同じ Hero tag が出現）
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();

      // ホームのカード本体をタップして詳細へ遷移
      await tester.tap(find.byType(RecipeCard).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // tag 重複の assertion（"multiple heroes ... same tag"）が出ないこと
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });
  });

  // ── 修正後の仕様テスト ──

  List<Object> heroTags(WidgetTester tester) =>
      tester.widgetList<Hero>(find.byType(Hero)).map((h) => h.tag).toList();

  testWidgets('ホームから遷移すると home タグの Hero で詳細に接続する', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(RecipeDetailScreen), findsOneWidget);
      // 詳細の Hero が home ソースのタグ（先頭レシピ id=1）を持つ
      expect(
        heroTags(tester),
        contains(RecipeHeroTag.image('1', HeroSource.home)),
      );
    });
  });

  testWidgets('お気に入りタブから遷移すると favorites タグの Hero で接続する', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      // 事前に id=1 をお気に入り登録
      final repo = container.read(recipeRepositoryProvider);
      final target = (await repo.getAllRecipes()).first;
      await repo.toggleFavorite(target);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FavoritesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(RecipeDetailScreen), findsOneWidget);
      expect(
        heroTags(tester),
        contains(RecipeHeroTag.image('1', HeroSource.favorites)),
      );
    });
  });

  testWidgets('カレンダーから遷移すると calendar タグの Hero で接続する', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CalendarScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // 選択日の大きいカード（先頭の Hero 画像）をタップ
      await tester.tap(find.byType(RecipeHeroImage).first);
      await tester.pumpAndSettle();

      expect(find.byType(RecipeDetailScreen), findsOneWidget);
      // calendar ソースのタグ（featured-*）で接続している
      expect(
        heroTags(tester).whereType<String>().any(
          (t) => t.startsWith('recipe-image-calendar-featured-'),
        ),
        isTrue,
      );
    });
  });

  testWidgets('戻る遷移でも例外が出ない（flightShuttleBuilder の角丸補間が走る）', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(RecipeDetailScreen))).pop();
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(find.byType(RecipeListScreen), findsOneWidget);
    });
  });

  testWidgets('視差効果を減らす設定が ON でも遷移が破綻しない', (tester) async {
    await provideMockNetworkImages(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: MaterialApp(home: RecipeListScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
    });
  });

  testWidgets('画像読み込みに失敗しても遷移が破綻しない', (tester) async {
    // 不正な画像バイトを返すことで errorBuilder 経路を強制する
    await HttpOverrides.runZoned(() async {
      final (container, db) = makeContainer();
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RecipeListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecipeCard).first);
      await tester.pumpAndSettle();

      // 例外なく詳細に到達し、error プレースホルダ（broken_image）が出る
      expect(find.byType(RecipeDetailScreen), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsWidgets);
    }, createHttpClient: (_) => _BrokenImageHttpClient());
  });
}

// 常に不正な画像バイトを返す HttpClient（errorBuilder を強制するため）。
class _BrokenImageHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _BrokenRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _BrokenRequest();
}

class _BrokenRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _BrokenHeaders();
  @override
  Future<HttpClientResponse> close() async => _BrokenResponse();
}

class _BrokenResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => 3;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([
      <int>[0, 1, 2],
    ]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _BrokenHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}
