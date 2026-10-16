import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/recipe.dart';

class NutritionChart extends StatelessWidget {
  final NutritionInfo nutritionInfo;

  const NutritionChart({super.key, required this.nutritionInfo});

  @override
  Widget build(BuildContext context) {
    // 三大栄養素の合計を計算
    final total =
        nutritionInfo.protein + nutritionInfo.fat + nutritionInfo.carbs;

    // 各栄養素の割合を計算
    final proteinPercentage = total > 0
        ? (nutritionInfo.protein / total * 100)
        : 0.0;
    final fatPercentage = total > 0 ? (nutritionInfo.fat / total * 100) : 0.0;
    final carbsPercentage = total > 0
        ? (nutritionInfo.carbs / total * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // グラフタイトル
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '栄養バランス',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 円グラフ - レスポンシブ対応
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final availableWidth = constraints.maxWidth;

              // より細かい画面サイズ判定
              final isSmallScreen = screenWidth < 380 || availableWidth < 300;
              final isTinyScreen = screenWidth < 340;

              // 画面サイズに応じたサイズ調整（さらに小さく）
              final chartSize = isTinyScreen
                  ? 100.0
                  : (isSmallScreen ? 110.0 : 120.0);
              final centerSpaceRadius = isTinyScreen
                  ? 25.0
                  : (isSmallScreen ? 28.0 : 32.0);
              final radius = isTinyScreen
                  ? 32.0
                  : (isSmallScreen ? 35.0 : 38.0);
              final titleFontSize = isTinyScreen
                  ? 8.0
                  : (isSmallScreen ? 9.0 : 10.0);

              // 小画面では縦並び、それ以外は横並び
              final useVerticalLayout =
                  screenWidth < 340 || availableWidth < 280;

              return useVerticalLayout
                  ? _buildVerticalLayout(
                      chartSize,
                      centerSpaceRadius,
                      radius,
                      titleFontSize,
                      proteinPercentage,
                      fatPercentage,
                      carbsPercentage,
                      isTinyScreen,
                    )
                  : _buildHorizontalLayout(
                      chartSize,
                      centerSpaceRadius,
                      radius,
                      titleFontSize,
                      proteinPercentage,
                      fatPercentage,
                      carbsPercentage,
                      isSmallScreen,
                    );
            },
          ),
          const SizedBox(height: 16),
          // 区切り線
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // その他の栄養素
          Row(
            children: [
              Expanded(
                child: _buildNutritionDetailCard(
                  '食物繊維',
                  '${nutritionInfo.fiber.toStringAsFixed(1)}g',
                  Icons.eco,
                  const Color(0xFF8BC34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNutritionDetailCard(
                  '塩分',
                  '${nutritionInfo.salt.toStringAsFixed(1)}g',
                  Icons.water_drop,
                  const Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(
    double chartSize,
    double centerSpaceRadius,
    double radius,
    double titleFontSize,
    double proteinPercentage,
    double fatPercentage,
    double carbsPercentage,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        // 円グラフ
        Expanded(
          flex: 5,
          child: Center(
            child: SizedBox(
              height: chartSize,
              width: chartSize,
              child: _buildPieChart(
                centerSpaceRadius,
                radius,
                titleFontSize,
                proteinPercentage,
                fatPercentage,
                carbsPercentage,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 凡例
        Expanded(
          flex: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLegendItem(
                'タンパク質',
                '${nutritionInfo.protein.toStringAsFixed(1)}g',
                const Color(0xFF4CAF50),
                isSmallScreen,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                '脂質',
                '${nutritionInfo.fat.toStringAsFixed(1)}g',
                const Color(0xFFF7931E),
                isSmallScreen,
              ),
              const SizedBox(height: 6),
              _buildLegendItem(
                '炭水化物',
                '${nutritionInfo.carbs.toStringAsFixed(1)}g',
                const Color(0xFF2196F3),
                isSmallScreen,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(
    double chartSize,
    double centerSpaceRadius,
    double radius,
    double titleFontSize,
    double proteinPercentage,
    double fatPercentage,
    double carbsPercentage,
    bool isTinyScreen,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 円グラフ
        Center(
          child: SizedBox(
            height: chartSize,
            width: chartSize,
            child: _buildPieChart(
              centerSpaceRadius,
              radius,
              titleFontSize,
              proteinPercentage,
              fatPercentage,
              carbsPercentage,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 凡例
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCompactLegendItem(
              'タンパク質',
              '${nutritionInfo.protein.toStringAsFixed(1)}g',
              const Color(0xFF4CAF50),
            ),
            _buildCompactLegendItem(
              '脂質',
              '${nutritionInfo.fat.toStringAsFixed(1)}g',
              const Color(0xFFF7931E),
            ),
            _buildCompactLegendItem(
              '炭水化物',
              '${nutritionInfo.carbs.toStringAsFixed(1)}g',
              const Color(0xFF2196F3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(
    double centerSpaceRadius,
    double radius,
    double titleFontSize,
    double proteinPercentage,
    double fatPercentage,
    double carbsPercentage,
  ) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: centerSpaceRadius,
        sections: [
          // タンパク質
          PieChartSectionData(
            color: const Color(0xFF4CAF50),
            value: nutritionInfo.protein,
            title: '${proteinPercentage.toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 0.5),
                  blurRadius: 1.5,
                ),
              ],
            ),
            badgeWidget: null,
          ),
          // 脂質
          PieChartSectionData(
            color: const Color(0xFFF7931E),
            value: nutritionInfo.fat,
            title: '${fatPercentage.toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 0.5),
                  blurRadius: 1.5,
                ),
              ],
            ),
          ),
          // 炭水化物
          PieChartSectionData(
            color: const Color(0xFF2196F3),
            value: nutritionInfo.carbs,
            title: '${carbsPercentage.toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 0.5),
                  blurRadius: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 7 : 8,
            height: isSmallScreen ? 7 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 5 : 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 8 : 9,
                    color: const Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegendItem(String label, String value, Color color) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              color: Color(0xFF6A6A6A),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionDetailCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
