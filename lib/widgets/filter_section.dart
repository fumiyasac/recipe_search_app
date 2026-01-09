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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update(value);
              },
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'レシピを検索...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9A9A9A),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6A6A6A),
                  size: 22,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Color(0xFF6A6A6A),
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
              backgroundColor: const Color(0xFFFF6B35),
              unselectedBackgroundColor: Colors.white,
              unselectedLabelStyle: const TextStyle(
                color: Color(0xFF6A6A6A),
                fontWeight: FontWeight.w600,
              ),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              borderWidth: 1.5,
              borderColor: const Color(0xFFFF6B35),
              unselectedBorderColor: const Color(0xFFE0E0E0),
              radius: 8,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
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
