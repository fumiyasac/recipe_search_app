import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_search_app/models/recipe.dart';
import 'package:recipe_search_app/widgets/nutrition_chart.dart';

Widget _wrap(Widget child, {Size size = const Size(400, 800)}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    ),
  );
}

void main() {
  final nutrition = NutritionInfo(
    protein: 22.5,
    fat: 18.3,
    carbs: 65.2,
    fiber: 3.1,
    salt: 2.8,
  );

  testWidgets('栄養バランスの見出しと凡例・副栄養素を表示する', (tester) async {
    await tester.pumpWidget(_wrap(NutritionChart(nutritionInfo: nutrition)));
    await tester.pumpAndSettle();

    expect(find.text('栄養バランス'), findsOneWidget);
    expect(find.text('タンパク質'), findsWidgets);
    expect(find.text('脂質'), findsWidgets);
    expect(find.text('炭水化物'), findsWidgets);
    // 副栄養素カード
    expect(find.text('食物繊維'), findsOneWidget);
    expect(find.text('塩分'), findsOneWidget);
    expect(find.text('3.1g'), findsOneWidget);
  });

  testWidgets('狭い画面幅では縦レイアウトでも描画できる', (tester) async {
    await tester.pumpWidget(
      _wrap(
        NutritionChart(nutritionInfo: nutrition),
        size: const Size(300, 800),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('栄養バランス'), findsOneWidget);
  });

  testWidgets('全栄養素が 0 でもクラッシュしない', (tester) async {
    await tester.pumpWidget(
      _wrap(
        NutritionChart(
          nutritionInfo: NutritionInfo(
            protein: 0,
            fat: 0,
            carbs: 0,
            fiber: 0,
            salt: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('栄養バランス'), findsOneWidget);
  });
}
