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
        isAutoDispose: true,
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

String _$appDatabaseHash() => r'18ce5c8c4d8ddbfe5a7d819d8fb7d5aca76bf416';

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
        isAutoDispose: true,
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

String _$recipeRepositoryHash() => r'8837d075f875114d7db95bfdbc902b5edde10f3b';

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
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Recipe>>, List<Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recipe>>, List<Recipe>>,
              AsyncValue<List<Recipe>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FilteredRecipes)
final filteredRecipesProvider = FilteredRecipesFamily._();

final class FilteredRecipesProvider
    extends $AsyncNotifierProvider<FilteredRecipes, List<Recipe>> {
  FilteredRecipesProvider._({
    required FilteredRecipesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'filteredRecipesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredRecipesHash();

  @override
  String toString() {
    return r'filteredRecipesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FilteredRecipes create() => FilteredRecipes();

  @override
  bool operator ==(Object other) {
    return other is FilteredRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredRecipesHash() => r'3424a403c3134f58e54ae2b10715b053b42ee89f';

final class FilteredRecipesFamily extends $Family
    with
        $ClassFamilyOverride<
          FilteredRecipes,
          AsyncValue<List<Recipe>>,
          List<Recipe>,
          FutureOr<List<Recipe>>,
          (String, String)
        > {
  FilteredRecipesFamily._()
    : super(
        retry: null,
        name: r'filteredRecipesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredRecipesProvider call(String category, String searchQuery) =>
      FilteredRecipesProvider._(argument: (category, searchQuery), from: this);

  @override
  String toString() => r'filteredRecipesProvider';
}

abstract class _$FilteredRecipes extends $AsyncNotifier<List<Recipe>> {
  late final _$args = ref.$arg as (String, String);
  String get category => _$args.$1;
  String get searchQuery => _$args.$2;

  FutureOr<List<Recipe>> build(String category, String searchQuery);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Recipe>>, List<Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recipe>>, List<Recipe>>,
              AsyncValue<List<Recipe>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
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
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Recipe>>, List<Recipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Recipe>>, List<Recipe>>,
              AsyncValue<List<Recipe>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
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

String _$selectedCategoryHash() => r'17f07f5772ee1f70a1ef95c90a6f9c1566212c75';

abstract class _$SelectedCategory extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
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

String _$searchQueryHash() => r'446383cb599327bea368f8da496260b05a5f9bec';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
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
  void runBuild() {
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
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
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
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
