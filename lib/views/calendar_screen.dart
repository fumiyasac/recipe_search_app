import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/providers.dart';
import 'recipe_detail_screen.dart';

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
            Icon(
              Icons.calendar_month,
              color: Color(0xFFFF9E80),
              size: 28,
            ),
            SizedBox(width: 12),
            Text('今月の献立'),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9E80).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF6D4C41),
            ),
          ),
          onPressed: () => Navigator.pop(context),
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D4C41),
                        fontFamily: 'Playfair',
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: const Color(0xFFFF9E80),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: const Color(0xFFFF9E80),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFFF9E80),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: const TextStyle(
                        color: Color(0xFF6D4C41),
                        fontFamily: 'Poppins',
                      ),
                      weekendTextStyle: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontFamily: 'Poppins',
                      ),
                      outsideTextStyle: TextStyle(
                        color: const Color(0xFF8D6E63).withOpacity(0.3),
                        fontFamily: 'Poppins',
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF6D4C41),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: const Color(0xFF8D6E63).withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      weekendStyle: TextStyle(
                        color: const Color(0xFFFF6B6B).withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
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
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D4C41),
                            fontFamily: 'Playfair',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecipeCard(
                          context,
                          monthlyRecipes[
                            DateTime(
                              selectedDay.value.year,
                              selectedDay.value.month,
                              selectedDay.value.day,
                            )
                          ],
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
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6D4C41),
                          fontFamily: 'Playfair',
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
                            child: _buildRecipeListItem(
                              context,
                              date,
                              recipe,
                            ),
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9E80)),
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
                  color: const Color(0xFF8D6E63).withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'エラーが発生しました',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF8D6E63).withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景画像
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                recipe.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // グラデーション
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // 情報
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9E80),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Playfair',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime}分',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: const Color(0xFFFFB74D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeListItem(BuildContext context, DateTime date, recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 日付
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9E80).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.month}月',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF8D6E63).withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9E80),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // レシピ画像
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D4C41),
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: const Color(0xFF8D6E63).withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime}分',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF8D6E63).withOpacity(0.7),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star,
                        size: 14,
                        color: const Color(0xFFFFB74D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF8D6E63).withOpacity(0.7),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color(0xFF8D6E63).withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
