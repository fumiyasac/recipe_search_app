import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import '../viewmodels/providers.dart';

class FilterSection extends HookConsumerWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = [
      'すべて',
      '和食',
      'イタリアン',
      'フレンチ',
      'タイ料理',
      'スペイン料理',
      'ロシア料理',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 検索バー
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update(value);
              },
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Color(0xFF6D4C41),
              ),
              decoration: InputDecoration(
                hintText: 'レシピを検索...',
                hintStyle: TextStyle(
                  color: const Color(0xFF8D6E63).withOpacity(0.5),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFFFF9E80).withOpacity(0.8),
                  size: 22,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: const Color(0xFF8D6E63).withOpacity(0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          searchController.clear();
                          ref.read(searchQueryProvider.notifier).update('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // カテゴリタブ
          DefaultTabController(
            length: categories.length,
            initialIndex: categories.indexOf(selectedCategory),
            child: ButtonsTabBar(
              backgroundColor: const Color(0xFFFF9E80),
              unselectedBackgroundColor: Colors.white,
              unselectedLabelStyle: const TextStyle(
                color: Color(0xFF8D6E63),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              borderWidth: 1,
              borderColor: const Color(0xFFFF9E80).withOpacity(0.3),
              unselectedBorderColor: const Color(0xFFFFE0CC).withOpacity(0.5),
              radius: 100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              onTap: (index) {
                final category = categories[index];
                ref.read(selectedCategoryProvider.notifier).update(category);
              },
              tabs: categories
                  .map(
                    (category) => Tab(
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
