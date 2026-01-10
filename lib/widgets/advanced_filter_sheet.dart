import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../viewmodels/providers.dart';
import '../models/filter_state.dart';

class AdvancedFilterSheet extends HookConsumerWidget {
  const AdvancedFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(ref),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _DifficultyFilterSection(),
                    SizedBox(height: 16),
                    _CookingTimeFilterSection(),
                    SizedBox(height: 16),
                    _CalorieFilterSection(),
                    SizedBox(height: 16),
                    _RatingFilterSection(),
                    SizedBox(height: 16),
                    _AllergyFilterSection(),
                    SizedBox(height: 16),
                    _TagFilterSection(),
                    SizedBox(height: 16),
                    _IngredientFilterSection(),
                  ],
                ),
              ),
              _buildFooter(context, filterState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '詳細フィルタ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(recipeFilterStateProvider.notifier).reset();
            },
            child: const Text(
              'リセット',
              style: TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, FilterState filterState) {
    final activeCount = filterState.activeFilterCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            activeCount > 0 ? '適用 ($activeCount件)' : '適用',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// 1. 難易度フィルタ
class _DifficultyFilterSection extends HookConsumerWidget {
  const _DifficultyFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    final difficulties = {
      'easy': '簡単',
      'medium': '普通',
      'hard': '難しい',
    };

    return ExpansionTile(
      title: const Text('難易度'),
      subtitle: filterState.difficulties.isNotEmpty
          ? Text('${filterState.difficulties.length}件選択中')
          : null,
      shape: const Border(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: difficulties.entries.map((entry) {
              final isSelected = filterState.difficulties.contains(entry.key);
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(recipeFilterStateProvider.notifier)
                      .toggleDifficulty(entry.key);
                },
                selectedColor: const Color(0xFFFF6B35),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6A6A6A),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// 2. 調理時間フィルタ
class _CookingTimeFilterSection extends HookConsumerWidget {
  const _CookingTimeFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    return ExpansionTile(
      title: const Text('調理時間'),
      subtitle: filterState.cookingTimeRange != null
          ? Text(filterState.cookingTimeRange!.label)
          : null,
      shape: const Border(),
      children: [
        RadioListTile<CookingTimeRange?>(
          title: const Text('指定なし'),
          value: null,
          groupValue: filterState.cookingTimeRange,
          onChanged: (value) {
            ref
                .read(recipeFilterStateProvider.notifier)
                .updateCookingTimeRange(value);
          },
          activeColor: const Color(0xFFFF6B35),
        ),
        ...CookingTimeRange.values.map((range) {
          return RadioListTile<CookingTimeRange?>(
            title: Text(range.label),
            value: range,
            groupValue: filterState.cookingTimeRange,
            onChanged: (value) {
              ref
                  .read(recipeFilterStateProvider.notifier)
                  .updateCookingTimeRange(value);
            },
            activeColor: const Color(0xFFFF6B35),
          );
        }),
      ],
    );
  }
}

// 3. カロリーフィルタ
class _CalorieFilterSection extends HookConsumerWidget {
  const _CalorieFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    return ExpansionTile(
      title: const Text('カロリー'),
      subtitle: filterState.calorieRange != null
          ? Text(filterState.calorieRange!.label)
          : null,
      shape: const Border(),
      children: [
        RadioListTile<CalorieRange?>(
          title: const Text('指定なし'),
          value: null,
          groupValue: filterState.calorieRange,
          onChanged: (value) {
            ref
                .read(recipeFilterStateProvider.notifier)
                .updateCalorieRange(value);
          },
          activeColor: const Color(0xFFFF6B35),
        ),
        ...CalorieRange.values.map((range) {
          return RadioListTile<CalorieRange?>(
            title: Text(range.label),
            value: range,
            groupValue: filterState.calorieRange,
            onChanged: (value) {
              ref
                  .read(recipeFilterStateProvider.notifier)
                  .updateCalorieRange(value);
            },
            activeColor: const Color(0xFFFF6B35),
          );
        }),
      ],
    );
  }
}

// 4. 評価フィルタ
class _RatingFilterSection extends HookConsumerWidget {
  const _RatingFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    return ExpansionTile(
      title: const Text('評価'),
      subtitle: filterState.minRating != null
          ? Text('★${filterState.minRating!.toStringAsFixed(1)}以上')
          : null,
      shape: const Border(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Slider(
                value: filterState.minRating ?? 0,
                min: 0,
                max: 5,
                divisions: 10,
                label: filterState.minRating != null
                    ? '★${filterState.minRating!.toStringAsFixed(1)}'
                    : '指定なし',
                activeColor: const Color(0xFFFF6B35),
                onChanged: (value) {
                  ref
                      .read(recipeFilterStateProvider.notifier)
                      .updateMinRating(value > 0 ? value : null);
                },
              ),
              if (filterState.minRating != null)
                TextButton(
                  onPressed: () {
                    ref
                        .read(recipeFilterStateProvider.notifier)
                        .updateMinRating(null);
                  },
                  child: const Text(
                    'クリア',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// 5. アレルギー除外フィルタ
class _AllergyFilterSection extends HookConsumerWidget {
  const _AllergyFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    final allergies = ['卵', '乳製品', '小麦', '大豆', '甲殻類', '軟体動物', '魚'];

    return ExpansionTile(
      title: const Text('アレルギー除外'),
      subtitle: filterState.excludedAllergies.isNotEmpty
          ? Text('${filterState.excludedAllergies.length}件除外中')
          : null,
      shape: const Border(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergies.map((allergy) {
              final isSelected = filterState.excludedAllergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) {
                  ref
                      .read(recipeFilterStateProvider.notifier)
                      .toggleAllergyExclusion(allergy);
                },
                selectedColor: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFFFF6B35),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF6A6A6A),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// 6. タグフィルタ
class _TagFilterSection extends HookConsumerWidget {
  const _TagFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);

    final tags = [
      '時短',
      '洋風アレンジ',
      'ベジタリアン',
      'ヘルシー',
      '作り置き可',
      '本格派',
      'パーティー向け',
      'スパイシー',
      'おもてなし',
    ];

    return ExpansionTile(
      title: const Text('タグ'),
      subtitle: filterState.selectedTags.isNotEmpty
          ? Text('${filterState.selectedTags.length}件選択中')
          : null,
      shape: const Border(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              final isSelected = filterState.selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(recipeFilterStateProvider.notifier).toggleTag(tag);
                },
                selectedColor: const Color(0xFFFF6B35),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6A6A6A),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// 7. 材料検索フィルタ
class _IngredientFilterSection extends HookConsumerWidget {
  const _IngredientFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(recipeFilterStateProvider);
    final includeController = useTextEditingController();
    final excludeController = useTextEditingController();

    String? subtitle;
    if (filterState.ingredientFilter != null) {
      final includeCount = filterState.ingredientFilter!.mustInclude.length;
      final excludeCount = filterState.ingredientFilter!.mustExclude.length;
      if (includeCount > 0 || excludeCount > 0) {
        subtitle = '含む: $includeCount件, 除外: $excludeCount件';
      }
    }

    return ExpansionTile(
      title: const Text('材料検索'),
      subtitle: subtitle != null ? Text(subtitle) : null,
      shape: const Border(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '含む材料',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: includeController,
                      decoration: InputDecoration(
                        hintText: '例: トマト',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFFFF6B35)),
                    onPressed: () {
                      if (includeController.text.isNotEmpty) {
                        final current =
                            filterState.ingredientFilter ?? const IngredientFilter();

                        ref.read(recipeFilterStateProvider.notifier).updateIngredientFilter(
                              IngredientFilter(
                                mustInclude: {
                                  ...current.mustInclude,
                                  includeController.text
                                },
                                mustExclude: current.mustExclude,
                              ),
                            );
                        includeController.clear();
                      }
                    },
                  ),
                ],
              ),
              if (filterState.ingredientFilter?.mustInclude.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filterState.ingredientFilter!.mustInclude.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          final current = filterState.ingredientFilter!;
                          final newSet = Set<String>.from(current.mustInclude)
                            ..remove(ingredient);
                          ref.read(recipeFilterStateProvider.notifier).updateIngredientFilter(
                                IngredientFilter(
                                  mustInclude: newSet,
                                  mustExclude: current.mustExclude,
                                ),
                              );
                        },
                        backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        deleteIconColor: const Color(0xFFFF6B35),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                '含まない材料',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: excludeController,
                      decoration: InputDecoration(
                        hintText: '例: チーズ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFFFF6B35)),
                    onPressed: () {
                      if (excludeController.text.isNotEmpty) {
                        final current =
                            filterState.ingredientFilter ?? const IngredientFilter();

                        ref.read(recipeFilterStateProvider.notifier).updateIngredientFilter(
                              IngredientFilter(
                                mustInclude: current.mustInclude,
                                mustExclude: {
                                  ...current.mustExclude,
                                  excludeController.text
                                },
                              ),
                            );
                        excludeController.clear();
                      }
                    },
                  ),
                ],
              ),
              if (filterState.ingredientFilter?.mustExclude.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filterState.ingredientFilter!.mustExclude.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          final current = filterState.ingredientFilter!;
                          final newSet = Set<String>.from(current.mustExclude)
                            ..remove(ingredient);
                          ref.read(recipeFilterStateProvider.notifier).updateIngredientFilter(
                                IngredientFilter(
                                  mustInclude: current.mustInclude,
                                  mustExclude: newSet,
                                ),
                              );
                        },
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        deleteIconColor: Colors.red,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
