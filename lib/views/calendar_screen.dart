import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/providers.dart';
import '../widgets/recipe_hero_image.dart';
import 'recipe_detail_screen.dart';

// 同一画面でタグが重複しないよう、日付から Hero タグ用のキーを作る。
String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

class CalendarScreen extends HookConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDay = useState(DateTime.now());
    final selectedDay = useState(DateTime.now());

    final monthlyRecipesAsync = ref.watch(
      monthlyRecipesProvider(focusedDay.value.year, focusedDay.value.month),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: Color(0xFFFF6B35), size: 28),
            SizedBox(width: 12),
            Text(
              '今月の献立',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: monthlyRecipesAsync.when(
        data: (monthlyRecipes) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // カレンダー
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focusedDay.value,
                    selectedDayPredicate: (day) =>
                        isSameDay(selectedDay.value, day),
                    onDaySelected: (selected, focused) {
                      selectedDay.value = selected;
                      focusedDay.value = focused;
                    },
                    onPageChanged: (focused) {
                      focusedDay.value = focused;
                    },
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Color(0xFF1A1A1A),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w500,
                      ),
                      weekendTextStyle: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w500,
                      ),
                      outsideTextStyle: TextStyle(
                        color: const Color(0xFF6A6A6A).withValues(alpha: 0.3),
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Color(0xFF6A6A6A),
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // 選択された日のレシピ
                if (monthlyRecipes.containsKey(
                  DateTime(
                    selectedDay.value.year,
                    selectedDay.value.month,
                    selectedDay.value.day,
                  ),
                )) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedDay.value.month}月${selectedDay.value.day}日の献立',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecipeCard(
                          context,
                          DateTime(
                            selectedDay.value.year,
                            selectedDay.value.month,
                            selectedDay.value.day,
                          ),
                          monthlyRecipes[DateTime(
                            selectedDay.value.year,
                            selectedDay.value.month,
                            selectedDay.value.day,
                          )],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                // 今月の献立リスト
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '今月の献立一覧',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: monthlyRecipes.length,
                        itemBuilder: (context, index) {
                          final date = monthlyRecipes.keys.elementAt(index);
                          final recipe = monthlyRecipes[date]!;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildRecipeListItem(context, date, recipe),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: const Color(0xFF6A6A6A).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'エラーが発生しました',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6A6A6A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, DateTime date, recipe) {
    final tagKey = 'featured-${_dateKey(date)}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          RecipeDetailScreen.route(
            context,
            recipe,
            HeroSource.calendar,
            tagKey: tagKey,
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 背景画像（共通の Hero 部品）
            SizedBox(
              width: 160,
              height: double.infinity,
              child: RecipeHeroImage(
                recipeId: recipe.id,
                imageUrl: recipe.imageUrl,
                source: HeroSource.calendar,
                tagKey: tagKey,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            // 情報
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recipe.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: Color(0xFF6A6A6A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.totalTime}分',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFF7931E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.rating.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A6A6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeListItem(BuildContext context, DateTime date, recipe) {
    final tagKey = 'list-${_dateKey(date)}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          RecipeDetailScreen.route(
            context,
            recipe,
            HeroSource.calendar,
            tagKey: tagKey,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          children: [
            // 日付
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.month}月',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // レシピ画像（共通の Hero 部品）
            RecipeHeroImage(
              recipeId: recipe.id,
              imageUrl: recipe.imageUrl,
              source: HeroSource.calendar,
              tagKey: tagKey,
              borderRadius: BorderRadius.circular(10),
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 12),
            // レシピ情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: Color(0xFF6A6A6A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime}分',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A6A6A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFF7931E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A6A6A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFE0E0E0),
            ),
          ],
        ),
      ),
    );
  }
}
