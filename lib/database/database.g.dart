// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FavoriteRecipesTable extends FavoriteRecipes
    with TableInfo<$FavoriteRecipesTable, FavoriteRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prepTimeMeta = const VerificationMeta(
    'prepTime',
  );
  @override
  late final GeneratedColumn<int> prepTime = GeneratedColumn<int>(
    'prep_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cookTimeMeta = const VerificationMeta(
    'cookTime',
  );
  @override
  late final GeneratedColumn<int> cookTime = GeneratedColumn<int>(
    'cook_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientsMeta = const VerificationMeta(
    'ingredients',
  );
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
    'ingredients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    imageUrl,
    category,
    prepTime,
    cookTime,
    servings,
    calories,
    rating,
    ingredients,
    steps,
    allergies,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRecipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('prep_time')) {
      context.handle(
        _prepTimeMeta,
        prepTime.isAcceptableOrUnknown(data['prep_time']!, _prepTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_prepTimeMeta);
    }
    if (data.containsKey('cook_time')) {
      context.handle(
        _cookTimeMeta,
        cookTime.isAcceptableOrUnknown(data['cook_time']!, _cookTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_cookTimeMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    } else if (isInserting) {
      context.missing(_servingsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('ingredients')) {
      context.handle(
        _ingredientsMeta,
        ingredients.isAcceptableOrUnknown(
          data['ingredients']!,
          _ingredientsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientsMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    } else if (isInserting) {
      context.missing(_allergiesMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRecipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      prepTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_time'],
      )!,
      cookTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cook_time'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      )!,
      ingredients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      )!,
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $FavoriteRecipesTable createAlias(String alias) {
    return $FavoriteRecipesTable(attachedDatabase, alias);
  }
}

class FavoriteRecipe extends DataClass implements Insertable<FavoriteRecipe> {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int prepTime;
  final int cookTime;
  final int servings;
  final int calories;
  final double rating;
  final String ingredients;
  final String steps;
  final String allergies;
  final DateTime savedAt;
  const FavoriteRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.calories,
    required this.rating,
    required this.ingredients,
    required this.steps,
    required this.allergies,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['image_url'] = Variable<String>(imageUrl);
    map['category'] = Variable<String>(category);
    map['prep_time'] = Variable<int>(prepTime);
    map['cook_time'] = Variable<int>(cookTime);
    map['servings'] = Variable<int>(servings);
    map['calories'] = Variable<int>(calories);
    map['rating'] = Variable<double>(rating);
    map['ingredients'] = Variable<String>(ingredients);
    map['steps'] = Variable<String>(steps);
    map['allergies'] = Variable<String>(allergies);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  FavoriteRecipesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteRecipesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      imageUrl: Value(imageUrl),
      category: Value(category),
      prepTime: Value(prepTime),
      cookTime: Value(cookTime),
      servings: Value(servings),
      calories: Value(calories),
      rating: Value(rating),
      ingredients: Value(ingredients),
      steps: Value(steps),
      allergies: Value(allergies),
      savedAt: Value(savedAt),
    );
  }

  factory FavoriteRecipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRecipe(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      category: serializer.fromJson<String>(json['category']),
      prepTime: serializer.fromJson<int>(json['prepTime']),
      cookTime: serializer.fromJson<int>(json['cookTime']),
      servings: serializer.fromJson<int>(json['servings']),
      calories: serializer.fromJson<int>(json['calories']),
      rating: serializer.fromJson<double>(json['rating']),
      ingredients: serializer.fromJson<String>(json['ingredients']),
      steps: serializer.fromJson<String>(json['steps']),
      allergies: serializer.fromJson<String>(json['allergies']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'category': serializer.toJson<String>(category),
      'prepTime': serializer.toJson<int>(prepTime),
      'cookTime': serializer.toJson<int>(cookTime),
      'servings': serializer.toJson<int>(servings),
      'calories': serializer.toJson<int>(calories),
      'rating': serializer.toJson<double>(rating),
      'ingredients': serializer.toJson<String>(ingredients),
      'steps': serializer.toJson<String>(steps),
      'allergies': serializer.toJson<String>(allergies),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  FavoriteRecipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    int? prepTime,
    int? cookTime,
    int? servings,
    int? calories,
    double? rating,
    String? ingredients,
    String? steps,
    String? allergies,
    DateTime? savedAt,
  }) => FavoriteRecipe(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    category: category ?? this.category,
    prepTime: prepTime ?? this.prepTime,
    cookTime: cookTime ?? this.cookTime,
    servings: servings ?? this.servings,
    calories: calories ?? this.calories,
    rating: rating ?? this.rating,
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps,
    allergies: allergies ?? this.allergies,
    savedAt: savedAt ?? this.savedAt,
  );
  FavoriteRecipe copyWithCompanion(FavoriteRecipesCompanion data) {
    return FavoriteRecipe(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      category: data.category.present ? data.category.value : this.category,
      prepTime: data.prepTime.present ? data.prepTime.value : this.prepTime,
      cookTime: data.cookTime.present ? data.cookTime.value : this.cookTime,
      servings: data.servings.present ? data.servings.value : this.servings,
      calories: data.calories.present ? data.calories.value : this.calories,
      rating: data.rating.present ? data.rating.value : this.rating,
      ingredients: data.ingredients.present
          ? data.ingredients.value
          : this.ingredients,
      steps: data.steps.present ? data.steps.value : this.steps,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRecipe(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('prepTime: $prepTime, ')
          ..write('cookTime: $cookTime, ')
          ..write('servings: $servings, ')
          ..write('calories: $calories, ')
          ..write('rating: $rating, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('allergies: $allergies, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    imageUrl,
    category,
    prepTime,
    cookTime,
    servings,
    calories,
    rating,
    ingredients,
    steps,
    allergies,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRecipe &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.category == this.category &&
          other.prepTime == this.prepTime &&
          other.cookTime == this.cookTime &&
          other.servings == this.servings &&
          other.calories == this.calories &&
          other.rating == this.rating &&
          other.ingredients == this.ingredients &&
          other.steps == this.steps &&
          other.allergies == this.allergies &&
          other.savedAt == this.savedAt);
}

class FavoriteRecipesCompanion extends UpdateCompanion<FavoriteRecipe> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> imageUrl;
  final Value<String> category;
  final Value<int> prepTime;
  final Value<int> cookTime;
  final Value<int> servings;
  final Value<int> calories;
  final Value<double> rating;
  final Value<String> ingredients;
  final Value<String> steps;
  final Value<String> allergies;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const FavoriteRecipesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.category = const Value.absent(),
    this.prepTime = const Value.absent(),
    this.cookTime = const Value.absent(),
    this.servings = const Value.absent(),
    this.calories = const Value.absent(),
    this.rating = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.steps = const Value.absent(),
    this.allergies = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteRecipesCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    required int prepTime,
    required int cookTime,
    required int servings,
    required int calories,
    required double rating,
    required String ingredients,
    required String steps,
    required String allergies,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       imageUrl = Value(imageUrl),
       category = Value(category),
       prepTime = Value(prepTime),
       cookTime = Value(cookTime),
       servings = Value(servings),
       calories = Value(calories),
       rating = Value(rating),
       ingredients = Value(ingredients),
       steps = Value(steps),
       allergies = Value(allergies),
       savedAt = Value(savedAt);
  static Insertable<FavoriteRecipe> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? category,
    Expression<int>? prepTime,
    Expression<int>? cookTime,
    Expression<int>? servings,
    Expression<int>? calories,
    Expression<double>? rating,
    Expression<String>? ingredients,
    Expression<String>? steps,
    Expression<String>? allergies,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (category != null) 'category': category,
      if (prepTime != null) 'prep_time': prepTime,
      if (cookTime != null) 'cook_time': cookTime,
      if (servings != null) 'servings': servings,
      if (calories != null) 'calories': calories,
      if (rating != null) 'rating': rating,
      if (ingredients != null) 'ingredients': ingredients,
      if (steps != null) 'steps': steps,
      if (allergies != null) 'allergies': allergies,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteRecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? imageUrl,
    Value<String>? category,
    Value<int>? prepTime,
    Value<int>? cookTime,
    Value<int>? servings,
    Value<int>? calories,
    Value<double>? rating,
    Value<String>? ingredients,
    Value<String>? steps,
    Value<String>? allergies,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return FavoriteRecipesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      allergies: allergies ?? this.allergies,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (prepTime.present) {
      map['prep_time'] = Variable<int>(prepTime.value);
    }
    if (cookTime.present) {
      map['cook_time'] = Variable<int>(cookTime.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRecipesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('category: $category, ')
          ..write('prepTime: $prepTime, ')
          ..write('cookTime: $cookTime, ')
          ..write('servings: $servings, ')
          ..write('calories: $calories, ')
          ..write('rating: $rating, ')
          ..write('ingredients: $ingredients, ')
          ..write('steps: $steps, ')
          ..write('allergies: $allergies, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FavoriteRecipesTable favoriteRecipes = $FavoriteRecipesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [favoriteRecipes];
}

typedef $$FavoriteRecipesTableCreateCompanionBuilder =
    FavoriteRecipesCompanion Function({
      required String id,
      required String title,
      required String description,
      required String imageUrl,
      required String category,
      required int prepTime,
      required int cookTime,
      required int servings,
      required int calories,
      required double rating,
      required String ingredients,
      required String steps,
      required String allergies,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$FavoriteRecipesTableUpdateCompanionBuilder =
    FavoriteRecipesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<String> imageUrl,
      Value<String> category,
      Value<int> prepTime,
      Value<int> cookTime,
      Value<int> servings,
      Value<int> calories,
      Value<double> rating,
      Value<String> ingredients,
      Value<String> steps,
      Value<String> allergies,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

class $$FavoriteRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteRecipesTable> {
  $$FavoriteRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepTime => $composableBuilder(
    column: $table.prepTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cookTime => $composableBuilder(
    column: $table.cookTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteRecipesTable> {
  $$FavoriteRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepTime => $composableBuilder(
    column: $table.prepTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cookTime => $composableBuilder(
    column: $table.cookTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteRecipesTable> {
  $$FavoriteRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get prepTime =>
      $composableBuilder(column: $table.prepTime, builder: (column) => column);

  GeneratedColumn<int> get cookTime =>
      $composableBuilder(column: $table.cookTime, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$FavoriteRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteRecipesTable,
          FavoriteRecipe,
          $$FavoriteRecipesTableFilterComposer,
          $$FavoriteRecipesTableOrderingComposer,
          $$FavoriteRecipesTableAnnotationComposer,
          $$FavoriteRecipesTableCreateCompanionBuilder,
          $$FavoriteRecipesTableUpdateCompanionBuilder,
          (
            FavoriteRecipe,
            BaseReferences<
              _$AppDatabase,
              $FavoriteRecipesTable,
              FavoriteRecipe
            >,
          ),
          FavoriteRecipe,
          PrefetchHooks Function()
        > {
  $$FavoriteRecipesTableTableManager(
    _$AppDatabase db,
    $FavoriteRecipesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> prepTime = const Value.absent(),
                Value<int> cookTime = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<String> ingredients = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<String> allergies = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteRecipesCompanion(
                id: id,
                title: title,
                description: description,
                imageUrl: imageUrl,
                category: category,
                prepTime: prepTime,
                cookTime: cookTime,
                servings: servings,
                calories: calories,
                rating: rating,
                ingredients: ingredients,
                steps: steps,
                allergies: allergies,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required String imageUrl,
                required String category,
                required int prepTime,
                required int cookTime,
                required int servings,
                required int calories,
                required double rating,
                required String ingredients,
                required String steps,
                required String allergies,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteRecipesCompanion.insert(
                id: id,
                title: title,
                description: description,
                imageUrl: imageUrl,
                category: category,
                prepTime: prepTime,
                cookTime: cookTime,
                servings: servings,
                calories: calories,
                rating: rating,
                ingredients: ingredients,
                steps: steps,
                allergies: allergies,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteRecipesTable,
      FavoriteRecipe,
      $$FavoriteRecipesTableFilterComposer,
      $$FavoriteRecipesTableOrderingComposer,
      $$FavoriteRecipesTableAnnotationComposer,
      $$FavoriteRecipesTableCreateCompanionBuilder,
      $$FavoriteRecipesTableUpdateCompanionBuilder,
      (
        FavoriteRecipe,
        BaseReferences<_$AppDatabase, $FavoriteRecipesTable, FavoriteRecipe>,
      ),
      FavoriteRecipe,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FavoriteRecipesTableTableManager get favoriteRecipes =>
      $$FavoriteRecipesTableTableManager(_db, _db.favoriteRecipes);
}
