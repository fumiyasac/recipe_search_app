// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(recipeRepository)
final recipeRepositoryProvider = RecipeRepositoryProvider._();

final class RecipeRepositoryProvider
    extends
        $FunctionalProvider<
          RecipeRepository,
          RecipeRepository,
          RecipeRepository
        >
    with $Provider<RecipeRepository> {
  RecipeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecipeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecipeRepository create(Ref ref) {
    return recipeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeRepository>(value),
    );
  }
}

String _$recipeRepositoryHash() => r'b329413cae80fc6cda63ada413b20ea835e68750';

@ProviderFor(RecipeList)
final recipeListProvider = RecipeListProvider._();

final class RecipeListProvider
    extends $AsyncNotifierProvider<RecipeList, List<Recipe>> {
  RecipeListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeListHash();

  @$internal
  @override
  RecipeList create() => RecipeList();
}

String _$recipeListHash() => r'43db59b4d8cbae0bfc052867e024754b2a8d668a';

abstract class _$RecipeList extends $AsyncNotifier<List<Recipe>> {
  FutureOr<List<Recipe>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Recipe>>, List<Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recipe>>, List<Recipe>>,
              AsyncValue<List<Recipe>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FilteredRecipes)
final filteredRecipesProvider = FilteredRecipesProvider._();

final class FilteredRecipesProvider
    extends $AsyncNotifierProvider<FilteredRecipes, List<Recipe>> {
  FilteredRecipesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredRecipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredRecipesHash();

  @$internal
  @override
  FilteredRecipes create() => FilteredRecipes();
}

String _$filteredRecipesHash() => r'c21a2d840cd61cd6153536f8eecffe88aa0e7043';

abstract class _$FilteredRecipes extends $AsyncNotifier<List<Recipe>> {
  FutureOr<List<Recipe>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Recipe>>, List<Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recipe>>, List<Recipe>>,
              AsyncValue<List<Recipe>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FavoriteRecipes)
final favoriteRecipesProvider = FavoriteRecipesProvider._();

final class FavoriteRecipesProvider
    extends $AsyncNotifierProvider<FavoriteRecipes, List<Recipe>> {
  FavoriteRecipesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteRecipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteRecipesHash();

  @$internal
  @override
  FavoriteRecipes create() => FavoriteRecipes();
}

String _$favoriteRecipesHash() => r'eaecbb34787dd2f4bef7261e4fe5ee57c28b4441';

abstract class _$FavoriteRecipes extends $AsyncNotifier<List<Recipe>> {
  FutureOr<List<Recipe>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Recipe>>, List<Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recipe>>, List<Recipe>>,
              AsyncValue<List<Recipe>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(RecipeFilterState)
final recipeFilterStateProvider = RecipeFilterStateProvider._();

final class RecipeFilterStateProvider
    extends $NotifierProvider<RecipeFilterState, FilterState> {
  RecipeFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeFilterStateHash();

  @$internal
  @override
  RecipeFilterState create() => RecipeFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilterState>(value),
    );
  }
}

String _$recipeFilterStateHash() => r'c86b561e2c9f098f69b2ab93bf8ba95e2943e2fd';

abstract class _$RecipeFilterState extends $Notifier<FilterState> {
  FilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FilterState, FilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FilterState, FilterState>,
              FilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedCategory)
final selectedCategoryProvider = SelectedCategoryProvider._();

final class SelectedCategoryProvider
    extends $NotifierProvider<SelectedCategory, String> {
  SelectedCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryHash();

  @$internal
  @override
  SelectedCategory create() => SelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedCategoryHash() => r'022ede462af5ae479e2bf4a3272bba5eac92d822';

abstract class _$SelectedCategory extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'0731fb0813d940c3859a3ef6b9b7748cf1647c21';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MonthlyRecipes)
final monthlyRecipesProvider = MonthlyRecipesFamily._();

final class MonthlyRecipesProvider
    extends $AsyncNotifierProvider<MonthlyRecipes, Map<DateTime, Recipe>> {
  MonthlyRecipesProvider._({
    required MonthlyRecipesFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'monthlyRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyRecipesHash();

  @override
  String toString() {
    return r'monthlyRecipesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MonthlyRecipes create() => MonthlyRecipes();

  @override
  bool operator ==(Object other) {
    return other is MonthlyRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyRecipesHash() => r'f95caa8023d6bf9438a4a8bddc65013e15d20728';

final class MonthlyRecipesFamily extends $Family
    with
        $ClassFamilyOverride<
          MonthlyRecipes,
          AsyncValue<Map<DateTime, Recipe>>,
          Map<DateTime, Recipe>,
          FutureOr<Map<DateTime, Recipe>>,
          (int, int)
        > {
  MonthlyRecipesFamily._()
    : super(
        retry: null,
        name: r'monthlyRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthlyRecipesProvider call(int year, int month) =>
      MonthlyRecipesProvider._(argument: (year, month), from: this);

  @override
  String toString() => r'monthlyRecipesProvider';
}

abstract class _$MonthlyRecipes extends $AsyncNotifier<Map<DateTime, Recipe>> {
  late final _$args = ref.$arg as (int, int);
  int get year => _$args.$1;
  int get month => _$args.$2;

  FutureOr<Map<DateTime, Recipe>> build(int year, int month);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<DateTime, Recipe>>, Map<DateTime, Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<DateTime, Recipe>>,
                Map<DateTime, Recipe>
              >,
              AsyncValue<Map<DateTime, Recipe>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(RecipeFavoriteStatus)
final recipeFavoriteStatusProvider = RecipeFavoriteStatusFamily._();

final class RecipeFavoriteStatusProvider
    extends $AsyncNotifierProvider<RecipeFavoriteStatus, bool> {
  RecipeFavoriteStatusProvider._({
    required RecipeFavoriteStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recipeFavoriteStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeFavoriteStatusHash();

  @override
  String toString() {
    return r'recipeFavoriteStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecipeFavoriteStatus create() => RecipeFavoriteStatus();

  @override
  bool operator ==(Object other) {
    return other is RecipeFavoriteStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeFavoriteStatusHash() =>
    r'b7d1ab8bdbc91ff0d31147112287c8155109e8ca';

final class RecipeFavoriteStatusFamily extends $Family
    with
        $ClassFamilyOverride<
          RecipeFavoriteStatus,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          String
        > {
  RecipeFavoriteStatusFamily._()
    : super(
        retry: null,
        name: r'recipeFavoriteStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecipeFavoriteStatusProvider call(String recipeId) =>
      RecipeFavoriteStatusProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeFavoriteStatusProvider';
}

abstract class _$RecipeFavoriteStatus extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as String;
  String get recipeId => _$args;

  FutureOr<bool> build(String recipeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SelectedTabIndex)
final selectedTabIndexProvider = SelectedTabIndexProvider._();

final class SelectedTabIndexProvider
    extends $NotifierProvider<SelectedTabIndex, int> {
  SelectedTabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabIndexHash();

  @$internal
  @override
  SelectedTabIndex create() => SelectedTabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedTabIndexHash() => r'5ef07cfd6a5dbe273b54d4a97e8b9bf1147b424e';

abstract class _$SelectedTabIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
