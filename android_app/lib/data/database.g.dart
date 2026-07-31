// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Sex>($UserProfilesTable.$convertersex);
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentWeightKgMeta = const VerificationMeta(
    'currentWeightKg',
  );
  @override
  late final GeneratedColumn<double> currentWeightKg = GeneratedColumn<double>(
    'current_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedBodyFatPercentageMeta =
      const VerificationMeta('estimatedBodyFatPercentage');
  @override
  late final GeneratedColumn<double> estimatedBodyFatPercentage =
      GeneratedColumn<double>(
        'estimated_body_fat_percentage',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<GoalMode, String> goalMode =
      GeneratedColumn<String>(
        'goal_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalMode>($UserProfilesTable.$convertergoalMode);
  @override
  late final GeneratedColumnWithTypeConverter<GoalPace, String> goalPace =
      GeneratedColumn<String>(
        'goal_pace',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalPace>($UserProfilesTable.$convertergoalPace);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel, String>
  activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityLevel>($UserProfilesTable.$converteractivityLevel);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    age,
    sex,
    heightCm,
    currentWeightKg,
    targetWeightKg,
    estimatedBodyFatPercentage,
    goalMode,
    goalPace,
    activityLevel,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('current_weight_kg')) {
      context.handle(
        _currentWeightKgMeta,
        currentWeightKg.isAcceptableOrUnknown(
          data['current_weight_kg']!,
          _currentWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentWeightKgMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('estimated_body_fat_percentage')) {
      context.handle(
        _estimatedBodyFatPercentageMeta,
        estimatedBodyFatPercentage.isAcceptableOrUnknown(
          data['estimated_body_fat_percentage']!,
          _estimatedBodyFatPercentageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      sex: $UserProfilesTable.$convertersex.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        )!,
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      currentWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_weight_kg'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      estimatedBodyFatPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_body_fat_percentage'],
      ),
      goalMode: $UserProfilesTable.$convertergoalMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_mode'],
        )!,
      ),
      goalPace: $UserProfilesTable.$convertergoalPace.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_pace'],
        )!,
      ),
      activityLevel: $UserProfilesTable.$converteractivityLevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity_level'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Sex, String, String> $convertersex =
      const EnumNameConverter<Sex>(Sex.values);
  static JsonTypeConverter2<GoalMode, String, String> $convertergoalMode =
      const EnumNameConverter<GoalMode>(GoalMode.values);
  static JsonTypeConverter2<GoalPace, String, String> $convertergoalPace =
      const EnumNameConverter<GoalPace>(GoalPace.values);
  static JsonTypeConverter2<ActivityLevel, String, String>
  $converteractivityLevel = const EnumNameConverter<ActivityLevel>(
    ActivityLevel.values,
  );
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;
  final String name;
  final int age;
  final Sex sex;
  final double heightCm;
  final double currentWeightKg;
  final double? targetWeightKg;
  final double? estimatedBodyFatPercentage;
  final GoalMode goalMode;
  final GoalPace goalPace;
  final ActivityLevel activityLevel;
  final DateTime createdAt;
  const UserProfileRow({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.currentWeightKg,
    this.targetWeightKg,
    this.estimatedBodyFatPercentage,
    required this.goalMode,
    required this.goalPace,
    required this.activityLevel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    {
      map['sex'] = Variable<String>(
        $UserProfilesTable.$convertersex.toSql(sex),
      );
    }
    map['height_cm'] = Variable<double>(heightCm);
    map['current_weight_kg'] = Variable<double>(currentWeightKg);
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || estimatedBodyFatPercentage != null) {
      map['estimated_body_fat_percentage'] = Variable<double>(
        estimatedBodyFatPercentage,
      );
    }
    {
      map['goal_mode'] = Variable<String>(
        $UserProfilesTable.$convertergoalMode.toSql(goalMode),
      );
    }
    {
      map['goal_pace'] = Variable<String>(
        $UserProfilesTable.$convertergoalPace.toSql(goalPace),
      );
    }
    {
      map['activity_level'] = Variable<String>(
        $UserProfilesTable.$converteractivityLevel.toSql(activityLevel),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      age: Value(age),
      sex: Value(sex),
      heightCm: Value(heightCm),
      currentWeightKg: Value(currentWeightKg),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      estimatedBodyFatPercentage:
          estimatedBodyFatPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedBodyFatPercentage),
      goalMode: Value(goalMode),
      goalPace: Value(goalPace),
      activityLevel: Value(activityLevel),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      sex: $UserProfilesTable.$convertersex.fromJson(
        serializer.fromJson<String>(json['sex']),
      ),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      currentWeightKg: serializer.fromJson<double>(json['currentWeightKg']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      estimatedBodyFatPercentage: serializer.fromJson<double?>(
        json['estimatedBodyFatPercentage'],
      ),
      goalMode: $UserProfilesTable.$convertergoalMode.fromJson(
        serializer.fromJson<String>(json['goalMode']),
      ),
      goalPace: $UserProfilesTable.$convertergoalPace.fromJson(
        serializer.fromJson<String>(json['goalPace']),
      ),
      activityLevel: $UserProfilesTable.$converteractivityLevel.fromJson(
        serializer.fromJson<String>(json['activityLevel']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'sex': serializer.toJson<String>(
        $UserProfilesTable.$convertersex.toJson(sex),
      ),
      'heightCm': serializer.toJson<double>(heightCm),
      'currentWeightKg': serializer.toJson<double>(currentWeightKg),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'estimatedBodyFatPercentage': serializer.toJson<double?>(
        estimatedBodyFatPercentage,
      ),
      'goalMode': serializer.toJson<String>(
        $UserProfilesTable.$convertergoalMode.toJson(goalMode),
      ),
      'goalPace': serializer.toJson<String>(
        $UserProfilesTable.$convertergoalPace.toJson(goalPace),
      ),
      'activityLevel': serializer.toJson<String>(
        $UserProfilesTable.$converteractivityLevel.toJson(activityLevel),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfileRow copyWith({
    int? id,
    String? name,
    int? age,
    Sex? sex,
    double? heightCm,
    double? currentWeightKg,
    Value<double?> targetWeightKg = const Value.absent(),
    Value<double?> estimatedBodyFatPercentage = const Value.absent(),
    GoalMode? goalMode,
    GoalPace? goalPace,
    ActivityLevel? activityLevel,
    DateTime? createdAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    age: age ?? this.age,
    sex: sex ?? this.sex,
    heightCm: heightCm ?? this.heightCm,
    currentWeightKg: currentWeightKg ?? this.currentWeightKg,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    estimatedBodyFatPercentage: estimatedBodyFatPercentage.present
        ? estimatedBodyFatPercentage.value
        : this.estimatedBodyFatPercentage,
    goalMode: goalMode ?? this.goalMode,
    goalPace: goalPace ?? this.goalPace,
    activityLevel: activityLevel ?? this.activityLevel,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      sex: data.sex.present ? data.sex.value : this.sex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      currentWeightKg: data.currentWeightKg.present
          ? data.currentWeightKg.value
          : this.currentWeightKg,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      estimatedBodyFatPercentage: data.estimatedBodyFatPercentage.present
          ? data.estimatedBodyFatPercentage.value
          : this.estimatedBodyFatPercentage,
      goalMode: data.goalMode.present ? data.goalMode.value : this.goalMode,
      goalPace: data.goalPace.present ? data.goalPace.value : this.goalPace,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('estimatedBodyFatPercentage: $estimatedBodyFatPercentage, ')
          ..write('goalMode: $goalMode, ')
          ..write('goalPace: $goalPace, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    age,
    sex,
    heightCm,
    currentWeightKg,
    targetWeightKg,
    estimatedBodyFatPercentage,
    goalMode,
    goalPace,
    activityLevel,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.sex == this.sex &&
          other.heightCm == this.heightCm &&
          other.currentWeightKg == this.currentWeightKg &&
          other.targetWeightKg == this.targetWeightKg &&
          other.estimatedBodyFatPercentage == this.estimatedBodyFatPercentage &&
          other.goalMode == this.goalMode &&
          other.goalPace == this.goalPace &&
          other.activityLevel == this.activityLevel &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> age;
  final Value<Sex> sex;
  final Value<double> heightCm;
  final Value<double> currentWeightKg;
  final Value<double?> targetWeightKg;
  final Value<double?> estimatedBodyFatPercentage;
  final Value<GoalMode> goalMode;
  final Value<GoalPace> goalPace;
  final Value<ActivityLevel> activityLevel;
  final Value<DateTime> createdAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.currentWeightKg = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.estimatedBodyFatPercentage = const Value.absent(),
    this.goalMode = const Value.absent(),
    this.goalPace = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int age,
    required Sex sex,
    required double heightCm,
    required double currentWeightKg,
    this.targetWeightKg = const Value.absent(),
    this.estimatedBodyFatPercentage = const Value.absent(),
    required GoalMode goalMode,
    required GoalPace goalPace,
    required ActivityLevel activityLevel,
    required DateTime createdAt,
  }) : name = Value(name),
       age = Value(age),
       sex = Value(sex),
       heightCm = Value(heightCm),
       currentWeightKg = Value(currentWeightKg),
       goalMode = Value(goalMode),
       goalPace = Value(goalPace),
       activityLevel = Value(activityLevel),
       createdAt = Value(createdAt);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? sex,
    Expression<double>? heightCm,
    Expression<double>? currentWeightKg,
    Expression<double>? targetWeightKg,
    Expression<double>? estimatedBodyFatPercentage,
    Expression<String>? goalMode,
    Expression<String>? goalPace,
    Expression<String>? activityLevel,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
      if (currentWeightKg != null) 'current_weight_kg': currentWeightKg,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (estimatedBodyFatPercentage != null)
        'estimated_body_fat_percentage': estimatedBodyFatPercentage,
      if (goalMode != null) 'goal_mode': goalMode,
      if (goalPace != null) 'goal_pace': goalPace,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? age,
    Value<Sex>? sex,
    Value<double>? heightCm,
    Value<double>? currentWeightKg,
    Value<double?>? targetWeightKg,
    Value<double?>? estimatedBodyFatPercentage,
    Value<GoalMode>? goalMode,
    Value<GoalPace>? goalPace,
    Value<ActivityLevel>? activityLevel,
    Value<DateTime>? createdAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      estimatedBodyFatPercentage:
          estimatedBodyFatPercentage ?? this.estimatedBodyFatPercentage,
      goalMode: goalMode ?? this.goalMode,
      goalPace: goalPace ?? this.goalPace,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $UserProfilesTable.$convertersex.toSql(sex.value),
      );
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (currentWeightKg.present) {
      map['current_weight_kg'] = Variable<double>(currentWeightKg.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (estimatedBodyFatPercentage.present) {
      map['estimated_body_fat_percentage'] = Variable<double>(
        estimatedBodyFatPercentage.value,
      );
    }
    if (goalMode.present) {
      map['goal_mode'] = Variable<String>(
        $UserProfilesTable.$convertergoalMode.toSql(goalMode.value),
      );
    }
    if (goalPace.present) {
      map['goal_pace'] = Variable<String>(
        $UserProfilesTable.$convertergoalPace.toSql(goalPace.value),
      );
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(
        $UserProfilesTable.$converteractivityLevel.toSql(activityLevel.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('estimatedBodyFatPercentage: $estimatedBodyFatPercentage, ')
          ..write('goalMode: $goalMode, ')
          ..write('goalPace: $goalPace, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GoalPeriodsTable extends GoalPeriods
    with TableInfo<$GoalPeriodsTable, GoalPeriodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id)',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationWeeksMeta = const VerificationMeta(
    'durationWeeks',
  );
  @override
  late final GeneratedColumn<int> durationWeeks = GeneratedColumn<int>(
    'duration_weeks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalMode, String> goalMode =
      GeneratedColumn<String>(
        'goal_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalMode>($GoalPeriodsTable.$convertergoalMode);
  @override
  late final GeneratedColumnWithTypeConverter<GoalPace, String> goalPace =
      GeneratedColumn<String>(
        'goal_pace',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalPace>($GoalPeriodsTable.$convertergoalPace);
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calorieAdjustmentMeta = const VerificationMeta(
    'calorieAdjustment',
  );
  @override
  late final GeneratedColumn<double> calorieAdjustment =
      GeneratedColumn<double>(
        'calorie_adjustment',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastCheckInDateMeta = const VerificationMeta(
    'lastCheckInDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckInDate =
      GeneratedColumn<DateTime>(
        'last_check_in_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    startDate,
    durationWeeks,
    goalMode,
    goalPace,
    isActive,
    completedAt,
    calorieAdjustment,
    lastCheckInDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalPeriodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('duration_weeks')) {
      context.handle(
        _durationWeeksMeta,
        durationWeeks.isAcceptableOrUnknown(
          data['duration_weeks']!,
          _durationWeeksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationWeeksMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('calorie_adjustment')) {
      context.handle(
        _calorieAdjustmentMeta,
        calorieAdjustment.isAcceptableOrUnknown(
          data['calorie_adjustment']!,
          _calorieAdjustmentMeta,
        ),
      );
    }
    if (data.containsKey('last_check_in_date')) {
      context.handle(
        _lastCheckInDateMeta,
        lastCheckInDate.isAcceptableOrUnknown(
          data['last_check_in_date']!,
          _lastCheckInDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalPeriodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalPeriodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      durationWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_weeks'],
      )!,
      goalMode: $GoalPeriodsTable.$convertergoalMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_mode'],
        )!,
      ),
      goalPace: $GoalPeriodsTable.$convertergoalPace.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_pace'],
        )!,
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      calorieAdjustment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calorie_adjustment'],
      )!,
      lastCheckInDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_check_in_date'],
      ),
    );
  }

  @override
  $GoalPeriodsTable createAlias(String alias) {
    return $GoalPeriodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GoalMode, String, String> $convertergoalMode =
      const EnumNameConverter<GoalMode>(GoalMode.values);
  static JsonTypeConverter2<GoalPace, String, String> $convertergoalPace =
      const EnumNameConverter<GoalPace>(GoalPace.values);
}

class GoalPeriodRow extends DataClass implements Insertable<GoalPeriodRow> {
  final int id;
  final int? profileId;
  final DateTime startDate;
  final int durationWeeks;
  final GoalMode goalMode;
  final GoalPace goalPace;
  final bool isActive;
  final DateTime? completedAt;
  final double calorieAdjustment;
  final DateTime? lastCheckInDate;
  const GoalPeriodRow({
    required this.id,
    this.profileId,
    required this.startDate,
    required this.durationWeeks,
    required this.goalMode,
    required this.goalPace,
    required this.isActive,
    this.completedAt,
    required this.calorieAdjustment,
    this.lastCheckInDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['duration_weeks'] = Variable<int>(durationWeeks);
    {
      map['goal_mode'] = Variable<String>(
        $GoalPeriodsTable.$convertergoalMode.toSql(goalMode),
      );
    }
    {
      map['goal_pace'] = Variable<String>(
        $GoalPeriodsTable.$convertergoalPace.toSql(goalPace),
      );
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['calorie_adjustment'] = Variable<double>(calorieAdjustment);
    if (!nullToAbsent || lastCheckInDate != null) {
      map['last_check_in_date'] = Variable<DateTime>(lastCheckInDate);
    }
    return map;
  }

  GoalPeriodsCompanion toCompanion(bool nullToAbsent) {
    return GoalPeriodsCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      startDate: Value(startDate),
      durationWeeks: Value(durationWeeks),
      goalMode: Value(goalMode),
      goalPace: Value(goalPace),
      isActive: Value(isActive),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      calorieAdjustment: Value(calorieAdjustment),
      lastCheckInDate: lastCheckInDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckInDate),
    );
  }

  factory GoalPeriodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalPeriodRow(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      durationWeeks: serializer.fromJson<int>(json['durationWeeks']),
      goalMode: $GoalPeriodsTable.$convertergoalMode.fromJson(
        serializer.fromJson<String>(json['goalMode']),
      ),
      goalPace: $GoalPeriodsTable.$convertergoalPace.fromJson(
        serializer.fromJson<String>(json['goalPace']),
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      calorieAdjustment: serializer.fromJson<double>(json['calorieAdjustment']),
      lastCheckInDate: serializer.fromJson<DateTime?>(json['lastCheckInDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'durationWeeks': serializer.toJson<int>(durationWeeks),
      'goalMode': serializer.toJson<String>(
        $GoalPeriodsTable.$convertergoalMode.toJson(goalMode),
      ),
      'goalPace': serializer.toJson<String>(
        $GoalPeriodsTable.$convertergoalPace.toJson(goalPace),
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'calorieAdjustment': serializer.toJson<double>(calorieAdjustment),
      'lastCheckInDate': serializer.toJson<DateTime?>(lastCheckInDate),
    };
  }

  GoalPeriodRow copyWith({
    int? id,
    Value<int?> profileId = const Value.absent(),
    DateTime? startDate,
    int? durationWeeks,
    GoalMode? goalMode,
    GoalPace? goalPace,
    bool? isActive,
    Value<DateTime?> completedAt = const Value.absent(),
    double? calorieAdjustment,
    Value<DateTime?> lastCheckInDate = const Value.absent(),
  }) => GoalPeriodRow(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    startDate: startDate ?? this.startDate,
    durationWeeks: durationWeeks ?? this.durationWeeks,
    goalMode: goalMode ?? this.goalMode,
    goalPace: goalPace ?? this.goalPace,
    isActive: isActive ?? this.isActive,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    calorieAdjustment: calorieAdjustment ?? this.calorieAdjustment,
    lastCheckInDate: lastCheckInDate.present
        ? lastCheckInDate.value
        : this.lastCheckInDate,
  );
  GoalPeriodRow copyWithCompanion(GoalPeriodsCompanion data) {
    return GoalPeriodRow(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      durationWeeks: data.durationWeeks.present
          ? data.durationWeeks.value
          : this.durationWeeks,
      goalMode: data.goalMode.present ? data.goalMode.value : this.goalMode,
      goalPace: data.goalPace.present ? data.goalPace.value : this.goalPace,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      calorieAdjustment: data.calorieAdjustment.present
          ? data.calorieAdjustment.value
          : this.calorieAdjustment,
      lastCheckInDate: data.lastCheckInDate.present
          ? data.lastCheckInDate.value
          : this.lastCheckInDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalPeriodRow(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('startDate: $startDate, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('goalMode: $goalMode, ')
          ..write('goalPace: $goalPace, ')
          ..write('isActive: $isActive, ')
          ..write('completedAt: $completedAt, ')
          ..write('calorieAdjustment: $calorieAdjustment, ')
          ..write('lastCheckInDate: $lastCheckInDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    startDate,
    durationWeeks,
    goalMode,
    goalPace,
    isActive,
    completedAt,
    calorieAdjustment,
    lastCheckInDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalPeriodRow &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.startDate == this.startDate &&
          other.durationWeeks == this.durationWeeks &&
          other.goalMode == this.goalMode &&
          other.goalPace == this.goalPace &&
          other.isActive == this.isActive &&
          other.completedAt == this.completedAt &&
          other.calorieAdjustment == this.calorieAdjustment &&
          other.lastCheckInDate == this.lastCheckInDate);
}

class GoalPeriodsCompanion extends UpdateCompanion<GoalPeriodRow> {
  final Value<int> id;
  final Value<int?> profileId;
  final Value<DateTime> startDate;
  final Value<int> durationWeeks;
  final Value<GoalMode> goalMode;
  final Value<GoalPace> goalPace;
  final Value<bool> isActive;
  final Value<DateTime?> completedAt;
  final Value<double> calorieAdjustment;
  final Value<DateTime?> lastCheckInDate;
  const GoalPeriodsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.goalMode = const Value.absent(),
    this.goalPace = const Value.absent(),
    this.isActive = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.calorieAdjustment = const Value.absent(),
    this.lastCheckInDate = const Value.absent(),
  });
  GoalPeriodsCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required DateTime startDate,
    required int durationWeeks,
    required GoalMode goalMode,
    required GoalPace goalPace,
    this.isActive = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.calorieAdjustment = const Value.absent(),
    this.lastCheckInDate = const Value.absent(),
  }) : startDate = Value(startDate),
       durationWeeks = Value(durationWeeks),
       goalMode = Value(goalMode),
       goalPace = Value(goalPace);
  static Insertable<GoalPeriodRow> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? startDate,
    Expression<int>? durationWeeks,
    Expression<String>? goalMode,
    Expression<String>? goalPace,
    Expression<bool>? isActive,
    Expression<DateTime>? completedAt,
    Expression<double>? calorieAdjustment,
    Expression<DateTime>? lastCheckInDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (startDate != null) 'start_date': startDate,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
      if (goalMode != null) 'goal_mode': goalMode,
      if (goalPace != null) 'goal_pace': goalPace,
      if (isActive != null) 'is_active': isActive,
      if (completedAt != null) 'completed_at': completedAt,
      if (calorieAdjustment != null) 'calorie_adjustment': calorieAdjustment,
      if (lastCheckInDate != null) 'last_check_in_date': lastCheckInDate,
    });
  }

  GoalPeriodsCompanion copyWith({
    Value<int>? id,
    Value<int?>? profileId,
    Value<DateTime>? startDate,
    Value<int>? durationWeeks,
    Value<GoalMode>? goalMode,
    Value<GoalPace>? goalPace,
    Value<bool>? isActive,
    Value<DateTime?>? completedAt,
    Value<double>? calorieAdjustment,
    Value<DateTime?>? lastCheckInDate,
  }) {
    return GoalPeriodsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      startDate: startDate ?? this.startDate,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      goalMode: goalMode ?? this.goalMode,
      goalPace: goalPace ?? this.goalPace,
      isActive: isActive ?? this.isActive,
      completedAt: completedAt ?? this.completedAt,
      calorieAdjustment: calorieAdjustment ?? this.calorieAdjustment,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (durationWeeks.present) {
      map['duration_weeks'] = Variable<int>(durationWeeks.value);
    }
    if (goalMode.present) {
      map['goal_mode'] = Variable<String>(
        $GoalPeriodsTable.$convertergoalMode.toSql(goalMode.value),
      );
    }
    if (goalPace.present) {
      map['goal_pace'] = Variable<String>(
        $GoalPeriodsTable.$convertergoalPace.toSql(goalPace.value),
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (calorieAdjustment.present) {
      map['calorie_adjustment'] = Variable<double>(calorieAdjustment.value);
    }
    if (lastCheckInDate.present) {
      map['last_check_in_date'] = Variable<DateTime>(lastCheckInDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('startDate: $startDate, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('goalMode: $goalMode, ')
          ..write('goalPace: $goalPace, ')
          ..write('isActive: $isActive, ')
          ..write('completedAt: $completedAt, ')
          ..write('calorieAdjustment: $calorieAdjustment, ')
          ..write('lastCheckInDate: $lastCheckInDate')
          ..write(')'))
        .toString();
  }
}

class $FoodProductsTable extends FoodProducts
    with TableInfo<$FoodProductsTable, FoodProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesPer100gMeta = const VerificationMeta(
    'caloriesPer100g',
  );
  @override
  late final GeneratedColumn<double> caloriesPer100g = GeneratedColumn<double>(
    'calories_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPer100gMeta = const VerificationMeta(
    'proteinPer100g',
  );
  @override
  late final GeneratedColumn<double> proteinPer100g = GeneratedColumn<double>(
    'protein_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPer100gMeta = const VerificationMeta(
    'carbsPer100g',
  );
  @override
  late final GeneratedColumn<double> carbsPer100g = GeneratedColumn<double>(
    'carbs_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPer100gMeta = const VerificationMeta(
    'fatPer100g',
  );
  @override
  late final GeneratedColumn<double> fatPer100g = GeneratedColumn<double>(
    'fat_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberPer100gMeta = const VerificationMeta(
    'fiberPer100g',
  );
  @override
  late final GeneratedColumn<double> fiberPer100g = GeneratedColumn<double>(
    'fiber_per100g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    barcode,
    caloriesPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    fiberPer100g,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('calories_per100g')) {
      context.handle(
        _caloriesPer100gMeta,
        caloriesPer100g.isAcceptableOrUnknown(
          data['calories_per100g']!,
          _caloriesPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesPer100gMeta);
    }
    if (data.containsKey('protein_per100g')) {
      context.handle(
        _proteinPer100gMeta,
        proteinPer100g.isAcceptableOrUnknown(
          data['protein_per100g']!,
          _proteinPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPer100gMeta);
    }
    if (data.containsKey('carbs_per100g')) {
      context.handle(
        _carbsPer100gMeta,
        carbsPer100g.isAcceptableOrUnknown(
          data['carbs_per100g']!,
          _carbsPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPer100gMeta);
    }
    if (data.containsKey('fat_per100g')) {
      context.handle(
        _fatPer100gMeta,
        fatPer100g.isAcceptableOrUnknown(data['fat_per100g']!, _fatPer100gMeta),
      );
    } else if (isInserting) {
      context.missing(_fatPer100gMeta);
    }
    if (data.containsKey('fiber_per100g')) {
      context.handle(
        _fiberPer100gMeta,
        fiberPer100g.isAcceptableOrUnknown(
          data['fiber_per100g']!,
          _fiberPer100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fiberPer100gMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      caloriesPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_per100g'],
      )!,
      proteinPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per100g'],
      )!,
      carbsPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per100g'],
      )!,
      fatPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per100g'],
      )!,
      fiberPer100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_per100g'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodProductsTable createAlias(String alias) {
    return $FoodProductsTable(attachedDatabase, alias);
  }
}

class FoodProductRow extends DataClass implements Insertable<FoodProductRow> {
  final int id;
  final String name;
  final String? brand;
  final String? barcode;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final DateTime createdAt;
  const FoodProductRow({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['calories_per100g'] = Variable<double>(caloriesPer100g);
    map['protein_per100g'] = Variable<double>(proteinPer100g);
    map['carbs_per100g'] = Variable<double>(carbsPer100g);
    map['fat_per100g'] = Variable<double>(fatPer100g);
    map['fiber_per100g'] = Variable<double>(fiberPer100g);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodProductsCompanion toCompanion(bool nullToAbsent) {
    return FoodProductsCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      caloriesPer100g: Value(caloriesPer100g),
      proteinPer100g: Value(proteinPer100g),
      carbsPer100g: Value(carbsPer100g),
      fatPer100g: Value(fatPer100g),
      fiberPer100g: Value(fiberPer100g),
      createdAt: Value(createdAt),
    );
  }

  factory FoodProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodProductRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      caloriesPer100g: serializer.fromJson<double>(json['caloriesPer100g']),
      proteinPer100g: serializer.fromJson<double>(json['proteinPer100g']),
      carbsPer100g: serializer.fromJson<double>(json['carbsPer100g']),
      fatPer100g: serializer.fromJson<double>(json['fatPer100g']),
      fiberPer100g: serializer.fromJson<double>(json['fiberPer100g']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'caloriesPer100g': serializer.toJson<double>(caloriesPer100g),
      'proteinPer100g': serializer.toJson<double>(proteinPer100g),
      'carbsPer100g': serializer.toJson<double>(carbsPer100g),
      'fatPer100g': serializer.toJson<double>(fatPer100g),
      'fiberPer100g': serializer.toJson<double>(fiberPer100g),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FoodProductRow copyWith({
    int? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fiberPer100g,
    DateTime? createdAt,
  }) => FoodProductRow(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    barcode: barcode.present ? barcode.value : this.barcode,
    caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    carbsPer100g: carbsPer100g ?? this.carbsPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    fiberPer100g: fiberPer100g ?? this.fiberPer100g,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodProductRow copyWithCompanion(FoodProductsCompanion data) {
    return FoodProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      caloriesPer100g: data.caloriesPer100g.present
          ? data.caloriesPer100g.value
          : this.caloriesPer100g,
      proteinPer100g: data.proteinPer100g.present
          ? data.proteinPer100g.value
          : this.proteinPer100g,
      carbsPer100g: data.carbsPer100g.present
          ? data.carbsPer100g.value
          : this.carbsPer100g,
      fatPer100g: data.fatPer100g.present
          ? data.fatPer100g.value
          : this.fatPer100g,
      fiberPer100g: data.fiberPer100g.present
          ? data.fiberPer100g.value
          : this.fiberPer100g,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('fiberPer100g: $fiberPer100g, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    barcode,
    caloriesPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    fiberPer100g,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.caloriesPer100g == this.caloriesPer100g &&
          other.proteinPer100g == this.proteinPer100g &&
          other.carbsPer100g == this.carbsPer100g &&
          other.fatPer100g == this.fatPer100g &&
          other.fiberPer100g == this.fiberPer100g &&
          other.createdAt == this.createdAt);
}

class FoodProductsCompanion extends UpdateCompanion<FoodProductRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> barcode;
  final Value<double> caloriesPer100g;
  final Value<double> proteinPer100g;
  final Value<double> carbsPer100g;
  final Value<double> fatPer100g;
  final Value<double> fiberPer100g;
  final Value<DateTime> createdAt;
  const FoodProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.caloriesPer100g = const Value.absent(),
    this.proteinPer100g = const Value.absent(),
    this.carbsPer100g = const Value.absent(),
    this.fatPer100g = const Value.absent(),
    this.fiberPer100g = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoodProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    required double fiberPer100g,
    required DateTime createdAt,
  }) : name = Value(name),
       caloriesPer100g = Value(caloriesPer100g),
       proteinPer100g = Value(proteinPer100g),
       carbsPer100g = Value(carbsPer100g),
       fatPer100g = Value(fatPer100g),
       fiberPer100g = Value(fiberPer100g),
       createdAt = Value(createdAt);
  static Insertable<FoodProductRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<double>? caloriesPer100g,
    Expression<double>? proteinPer100g,
    Expression<double>? carbsPer100g,
    Expression<double>? fatPer100g,
    Expression<double>? fiberPer100g,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (caloriesPer100g != null) 'calories_per100g': caloriesPer100g,
      if (proteinPer100g != null) 'protein_per100g': proteinPer100g,
      if (carbsPer100g != null) 'carbs_per100g': carbsPer100g,
      if (fatPer100g != null) 'fat_per100g': fatPer100g,
      if (fiberPer100g != null) 'fiber_per100g': fiberPer100g,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoodProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? barcode,
    Value<double>? caloriesPer100g,
    Value<double>? proteinPer100g,
    Value<double>? carbsPer100g,
    Value<double>? fatPer100g,
    Value<double>? fiberPer100g,
    Value<DateTime>? createdAt,
  }) {
    return FoodProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      fiberPer100g: fiberPer100g ?? this.fiberPer100g,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (caloriesPer100g.present) {
      map['calories_per100g'] = Variable<double>(caloriesPer100g.value);
    }
    if (proteinPer100g.present) {
      map['protein_per100g'] = Variable<double>(proteinPer100g.value);
    }
    if (carbsPer100g.present) {
      map['carbs_per100g'] = Variable<double>(carbsPer100g.value);
    }
    if (fatPer100g.present) {
      map['fat_per100g'] = Variable<double>(fatPer100g.value);
    }
    if (fiberPer100g.present) {
      map['fiber_per100g'] = Variable<double>(fiberPer100g.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('caloriesPer100g: $caloriesPer100g, ')
          ..write('proteinPer100g: $proteinPer100g, ')
          ..write('carbsPer100g: $carbsPer100g, ')
          ..write('fatPer100g: $fatPer100g, ')
          ..write('fiberPer100g: $fiberPer100g, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FoodLogEntriesTable extends FoodLogEntries
    with TableInfo<$FoodLogEntriesTable, FoodLogEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MealCategory, String>
  mealCategory = GeneratedColumn<String>(
    'meal_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MealCategory>($FoodLogEntriesTable.$convertermealCategory);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGramsMeta = const VerificationMeta(
    'carbsGrams',
  );
  @override
  late final GeneratedColumn<double> carbsGrams = GeneratedColumn<double>(
    'carbs_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberGramsMeta = const VerificationMeta(
    'fiberGrams',
  );
  @override
  late final GeneratedColumn<double> fiberGrams = GeneratedColumn<double>(
    'fiber_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    mealCategory,
    name,
    grams,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLogEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbs_grams')) {
      context.handle(
        _carbsGramsMeta,
        carbsGrams.isAcceptableOrUnknown(data['carbs_grams']!, _carbsGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('fiber_grams')) {
      context.handle(
        _fiberGramsMeta,
        fiberGrams.isAcceptableOrUnknown(data['fiber_grams']!, _fiberGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberGramsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLogEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLogEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      mealCategory: $FoodLogEntriesTable.$convertermealCategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meal_category'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      fiberGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_grams'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $FoodLogEntriesTable createAlias(String alias) {
    return $FoodLogEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealCategory, String, String>
  $convertermealCategory = const EnumNameConverter<MealCategory>(
    MealCategory.values,
  );
}

class FoodLogEntryRow extends DataClass implements Insertable<FoodLogEntryRow> {
  final int id;
  final DateTime date;
  final MealCategory mealCategory;
  final String name;
  final double grams;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final String? note;
  const FoodLogEntryRow({
    required this.id,
    required this.date,
    required this.mealCategory,
    required this.name,
    required this.grams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['meal_category'] = Variable<String>(
        $FoodLogEntriesTable.$convertermealCategory.toSql(mealCategory),
      );
    }
    map['name'] = Variable<String>(name);
    map['grams'] = Variable<double>(grams);
    map['calories'] = Variable<double>(calories);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbs_grams'] = Variable<double>(carbsGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    map['fiber_grams'] = Variable<double>(fiberGrams);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FoodLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodLogEntriesCompanion(
      id: Value(id),
      date: Value(date),
      mealCategory: Value(mealCategory),
      name: Value(name),
      grams: Value(grams),
      calories: Value(calories),
      proteinGrams: Value(proteinGrams),
      carbsGrams: Value(carbsGrams),
      fatGrams: Value(fatGrams),
      fiberGrams: Value(fiberGrams),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory FoodLogEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLogEntryRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      mealCategory: $FoodLogEntriesTable.$convertermealCategory.fromJson(
        serializer.fromJson<String>(json['mealCategory']),
      ),
      name: serializer.fromJson<String>(json['name']),
      grams: serializer.fromJson<double>(json['grams']),
      calories: serializer.fromJson<double>(json['calories']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbsGrams: serializer.fromJson<double>(json['carbsGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      fiberGrams: serializer.fromJson<double>(json['fiberGrams']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'mealCategory': serializer.toJson<String>(
        $FoodLogEntriesTable.$convertermealCategory.toJson(mealCategory),
      ),
      'name': serializer.toJson<String>(name),
      'grams': serializer.toJson<double>(grams),
      'calories': serializer.toJson<double>(calories),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbsGrams': serializer.toJson<double>(carbsGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'fiberGrams': serializer.toJson<double>(fiberGrams),
      'note': serializer.toJson<String?>(note),
    };
  }

  FoodLogEntryRow copyWith({
    int? id,
    DateTime? date,
    MealCategory? mealCategory,
    String? name,
    double? grams,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    Value<String?> note = const Value.absent(),
  }) => FoodLogEntryRow(
    id: id ?? this.id,
    date: date ?? this.date,
    mealCategory: mealCategory ?? this.mealCategory,
    name: name ?? this.name,
    grams: grams ?? this.grams,
    calories: calories ?? this.calories,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbsGrams: carbsGrams ?? this.carbsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    fiberGrams: fiberGrams ?? this.fiberGrams,
    note: note.present ? note.value : this.note,
  );
  FoodLogEntryRow copyWithCompanion(FoodLogEntriesCompanion data) {
    return FoodLogEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      mealCategory: data.mealCategory.present
          ? data.mealCategory.value
          : this.mealCategory,
      name: data.name.present ? data.name.value : this.name,
      grams: data.grams.present ? data.grams.value : this.grams,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbsGrams: data.carbsGrams.present
          ? data.carbsGrams.value
          : this.carbsGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      fiberGrams: data.fiberGrams.present
          ? data.fiberGrams.value
          : this.fiberGrams,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealCategory: $mealCategory, ')
          ..write('name: $name, ')
          ..write('grams: $grams, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    mealCategory,
    name,
    grams,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLogEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.mealCategory == this.mealCategory &&
          other.name == this.name &&
          other.grams == this.grams &&
          other.calories == this.calories &&
          other.proteinGrams == this.proteinGrams &&
          other.carbsGrams == this.carbsGrams &&
          other.fatGrams == this.fatGrams &&
          other.fiberGrams == this.fiberGrams &&
          other.note == this.note);
}

class FoodLogEntriesCompanion extends UpdateCompanion<FoodLogEntryRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<MealCategory> mealCategory;
  final Value<String> name;
  final Value<double> grams;
  final Value<double> calories;
  final Value<double> proteinGrams;
  final Value<double> carbsGrams;
  final Value<double> fatGrams;
  final Value<double> fiberGrams;
  final Value<String?> note;
  const FoodLogEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.mealCategory = const Value.absent(),
    this.name = const Value.absent(),
    this.grams = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbsGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.note = const Value.absent(),
  });
  FoodLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required MealCategory mealCategory,
    required String name,
    required double grams,
    required double calories,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required double fiberGrams,
    this.note = const Value.absent(),
  }) : date = Value(date),
       mealCategory = Value(mealCategory),
       name = Value(name),
       grams = Value(grams),
       calories = Value(calories),
       proteinGrams = Value(proteinGrams),
       carbsGrams = Value(carbsGrams),
       fatGrams = Value(fatGrams),
       fiberGrams = Value(fiberGrams);
  static Insertable<FoodLogEntryRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? mealCategory,
    Expression<String>? name,
    Expression<double>? grams,
    Expression<double>? calories,
    Expression<double>? proteinGrams,
    Expression<double>? carbsGrams,
    Expression<double>? fatGrams,
    Expression<double>? fiberGrams,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (mealCategory != null) 'meal_category': mealCategory,
      if (name != null) 'name': name,
      if (grams != null) 'grams': grams,
      if (calories != null) 'calories': calories,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (fiberGrams != null) 'fiber_grams': fiberGrams,
      if (note != null) 'note': note,
    });
  }

  FoodLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<MealCategory>? mealCategory,
    Value<String>? name,
    Value<double>? grams,
    Value<double>? calories,
    Value<double>? proteinGrams,
    Value<double>? carbsGrams,
    Value<double>? fatGrams,
    Value<double>? fiberGrams,
    Value<String?>? note,
  }) {
    return FoodLogEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      mealCategory: mealCategory ?? this.mealCategory,
      name: name ?? this.name,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mealCategory.present) {
      map['meal_category'] = Variable<String>(
        $FoodLogEntriesTable.$convertermealCategory.toSql(mealCategory.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbsGrams.present) {
      map['carbs_grams'] = Variable<double>(carbsGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (fiberGrams.present) {
      map['fiber_grams'] = Variable<double>(fiberGrams.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('mealCategory: $mealCategory, ')
          ..write('name: $name, ')
          ..write('grams: $grams, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $FavoriteFoodsTable extends FavoriteFoods
    with TableInfo<$FavoriteFoodsTable, FavoriteFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGramsMeta = const VerificationMeta(
    'carbsGrams',
  );
  @override
  late final GeneratedColumn<double> carbsGrams = GeneratedColumn<double>(
    'carbs_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberGramsMeta = const VerificationMeta(
    'fiberGrams',
  );
  @override
  late final GeneratedColumn<double> fiberGrams = GeneratedColumn<double>(
    'fiber_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    grams,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteFoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbs_grams')) {
      context.handle(
        _carbsGramsMeta,
        carbsGrams.isAcceptableOrUnknown(data['carbs_grams']!, _carbsGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('fiber_grams')) {
      context.handle(
        _fiberGramsMeta,
        fiberGrams.isAcceptableOrUnknown(data['fiber_grams']!, _fiberGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberGramsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteFoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      fiberGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_grams'],
      )!,
    );
  }

  @override
  $FavoriteFoodsTable createAlias(String alias) {
    return $FavoriteFoodsTable(attachedDatabase, alias);
  }
}

class FavoriteFoodRow extends DataClass implements Insertable<FavoriteFoodRow> {
  final int id;
  final String name;
  final double grams;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  const FavoriteFoodRow({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['grams'] = Variable<double>(grams);
    map['calories'] = Variable<double>(calories);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbs_grams'] = Variable<double>(carbsGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    map['fiber_grams'] = Variable<double>(fiberGrams);
    return map;
  }

  FavoriteFoodsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteFoodsCompanion(
      id: Value(id),
      name: Value(name),
      grams: Value(grams),
      calories: Value(calories),
      proteinGrams: Value(proteinGrams),
      carbsGrams: Value(carbsGrams),
      fatGrams: Value(fatGrams),
      fiberGrams: Value(fiberGrams),
    );
  }

  factory FavoriteFoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteFoodRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      grams: serializer.fromJson<double>(json['grams']),
      calories: serializer.fromJson<double>(json['calories']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbsGrams: serializer.fromJson<double>(json['carbsGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      fiberGrams: serializer.fromJson<double>(json['fiberGrams']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'grams': serializer.toJson<double>(grams),
      'calories': serializer.toJson<double>(calories),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbsGrams': serializer.toJson<double>(carbsGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'fiberGrams': serializer.toJson<double>(fiberGrams),
    };
  }

  FavoriteFoodRow copyWith({
    int? id,
    String? name,
    double? grams,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
  }) => FavoriteFoodRow(
    id: id ?? this.id,
    name: name ?? this.name,
    grams: grams ?? this.grams,
    calories: calories ?? this.calories,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbsGrams: carbsGrams ?? this.carbsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    fiberGrams: fiberGrams ?? this.fiberGrams,
  );
  FavoriteFoodRow copyWithCompanion(FavoriteFoodsCompanion data) {
    return FavoriteFoodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      grams: data.grams.present ? data.grams.value : this.grams,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbsGrams: data.carbsGrams.present
          ? data.carbsGrams.value
          : this.carbsGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      fiberGrams: data.fiberGrams.present
          ? data.fiberGrams.value
          : this.fiberGrams,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('grams: $grams, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    grams,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteFoodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.grams == this.grams &&
          other.calories == this.calories &&
          other.proteinGrams == this.proteinGrams &&
          other.carbsGrams == this.carbsGrams &&
          other.fatGrams == this.fatGrams &&
          other.fiberGrams == this.fiberGrams);
}

class FavoriteFoodsCompanion extends UpdateCompanion<FavoriteFoodRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> grams;
  final Value<double> calories;
  final Value<double> proteinGrams;
  final Value<double> carbsGrams;
  final Value<double> fatGrams;
  final Value<double> fiberGrams;
  const FavoriteFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.grams = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbsGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
  });
  FavoriteFoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double grams,
    required double calories,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required double fiberGrams,
  }) : name = Value(name),
       grams = Value(grams),
       calories = Value(calories),
       proteinGrams = Value(proteinGrams),
       carbsGrams = Value(carbsGrams),
       fatGrams = Value(fatGrams),
       fiberGrams = Value(fiberGrams);
  static Insertable<FavoriteFoodRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? grams,
    Expression<double>? calories,
    Expression<double>? proteinGrams,
    Expression<double>? carbsGrams,
    Expression<double>? fatGrams,
    Expression<double>? fiberGrams,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (grams != null) 'grams': grams,
      if (calories != null) 'calories': calories,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (fiberGrams != null) 'fiber_grams': fiberGrams,
    });
  }

  FavoriteFoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? grams,
    Value<double>? calories,
    Value<double>? proteinGrams,
    Value<double>? carbsGrams,
    Value<double>? fatGrams,
    Value<double>? fiberGrams,
  }) {
    return FavoriteFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbsGrams.present) {
      map['carbs_grams'] = Variable<double>(carbsGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (fiberGrams.present) {
      map['fiber_grams'] = Variable<double>(fiberGrams.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('grams: $grams, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams')
          ..write(')'))
        .toString();
  }
}

class $MealTemplatesTable extends MealTemplates
    with TableInfo<$MealTemplatesTable, MealTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MealCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealCategory>($MealTemplatesTable.$convertercategory);
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGramsMeta = const VerificationMeta(
    'carbsGrams',
  );
  @override
  late final GeneratedColumn<double> carbsGrams = GeneratedColumn<double>(
    'carbs_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberGramsMeta = const VerificationMeta(
    'fiberGrams',
  );
  @override
  late final GeneratedColumn<double> fiberGrams = GeneratedColumn<double>(
    'fiber_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbs_grams')) {
      context.handle(
        _carbsGramsMeta,
        carbsGrams.isAcceptableOrUnknown(data['carbs_grams']!, _carbsGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('fiber_grams')) {
      context.handle(
        _fiberGramsMeta,
        fiberGrams.isAcceptableOrUnknown(data['fiber_grams']!, _fiberGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberGramsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $MealTemplatesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      fiberGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_grams'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MealTemplatesTable createAlias(String alias) {
    return $MealTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealCategory, String, String> $convertercategory =
      const EnumNameConverter<MealCategory>(MealCategory.values);
}

class MealTemplateRow extends DataClass implements Insertable<MealTemplateRow> {
  final int id;
  final String name;
  final MealCategory category;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final DateTime createdAt;
  const MealTemplateRow({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $MealTemplatesTable.$convertercategory.toSql(category),
      );
    }
    map['calories'] = Variable<double>(calories);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbs_grams'] = Variable<double>(carbsGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    map['fiber_grams'] = Variable<double>(fiberGrams);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MealTemplatesCompanion toCompanion(bool nullToAbsent) {
    return MealTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      calories: Value(calories),
      proteinGrams: Value(proteinGrams),
      carbsGrams: Value(carbsGrams),
      fatGrams: Value(fatGrams),
      fiberGrams: Value(fiberGrams),
      createdAt: Value(createdAt),
    );
  }

  factory MealTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealTemplateRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: $MealTemplatesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      calories: serializer.fromJson<double>(json['calories']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbsGrams: serializer.fromJson<double>(json['carbsGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      fiberGrams: serializer.fromJson<double>(json['fiberGrams']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
        $MealTemplatesTable.$convertercategory.toJson(category),
      ),
      'calories': serializer.toJson<double>(calories),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbsGrams': serializer.toJson<double>(carbsGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'fiberGrams': serializer.toJson<double>(fiberGrams),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MealTemplateRow copyWith({
    int? id,
    String? name,
    MealCategory? category,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    DateTime? createdAt,
  }) => MealTemplateRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    calories: calories ?? this.calories,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbsGrams: carbsGrams ?? this.carbsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    fiberGrams: fiberGrams ?? this.fiberGrams,
    createdAt: createdAt ?? this.createdAt,
  );
  MealTemplateRow copyWithCompanion(MealTemplatesCompanion data) {
    return MealTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbsGrams: data.carbsGrams.present
          ? data.carbsGrams.value
          : this.carbsGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      fiberGrams: data.fiberGrams.present
          ? data.fiberGrams.value
          : this.fiberGrams,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealTemplateRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealTemplateRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.calories == this.calories &&
          other.proteinGrams == this.proteinGrams &&
          other.carbsGrams == this.carbsGrams &&
          other.fatGrams == this.fatGrams &&
          other.fiberGrams == this.fiberGrams &&
          other.createdAt == this.createdAt);
}

class MealTemplatesCompanion extends UpdateCompanion<MealTemplateRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<MealCategory> category;
  final Value<double> calories;
  final Value<double> proteinGrams;
  final Value<double> carbsGrams;
  final Value<double> fatGrams;
  final Value<double> fiberGrams;
  final Value<DateTime> createdAt;
  const MealTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbsGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MealTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required MealCategory category,
    required double calories,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required double fiberGrams,
    required DateTime createdAt,
  }) : name = Value(name),
       category = Value(category),
       calories = Value(calories),
       proteinGrams = Value(proteinGrams),
       carbsGrams = Value(carbsGrams),
       fatGrams = Value(fatGrams),
       fiberGrams = Value(fiberGrams),
       createdAt = Value(createdAt);
  static Insertable<MealTemplateRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? calories,
    Expression<double>? proteinGrams,
    Expression<double>? carbsGrams,
    Expression<double>? fatGrams,
    Expression<double>? fiberGrams,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (calories != null) 'calories': calories,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (fiberGrams != null) 'fiber_grams': fiberGrams,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MealTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<MealCategory>? category,
    Value<double>? calories,
    Value<double>? proteinGrams,
    Value<double>? carbsGrams,
    Value<double>? fatGrams,
    Value<double>? fiberGrams,
    Value<DateTime>? createdAt,
  }) {
    return MealTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $MealTemplatesTable.$convertercategory.toSql(category.value),
      );
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbsGrams.present) {
      map['carbs_grams'] = Variable<double>(carbsGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (fiberGrams.present) {
      map['fiber_grams'] = Variable<double>(fiberGrams.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TrainingSessionsTable extends TrainingSessions
    with TableInfo<$TrainingSessionsTable, TrainingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrainingType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrainingType>($TrainingSessionsTable.$convertertype);
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyWeightKgMeta = const VerificationMeta(
    'bodyWeightKg',
  );
  @override
  late final GeneratedColumn<double> bodyWeightKg = GeneratedColumn<double>(
    'body_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedCaloriesBurnedMeta =
      const VerificationMeta('estimatedCaloriesBurned');
  @override
  late final GeneratedColumn<double> estimatedCaloriesBurned =
      GeneratedColumn<double>(
        'estimated_calories_burned',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    type,
    durationMinutes,
    rpe,
    bodyWeightKg,
    estimatedCaloriesBurned,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    } else if (isInserting) {
      context.missing(_rpeMeta);
    }
    if (data.containsKey('body_weight_kg')) {
      context.handle(
        _bodyWeightKgMeta,
        bodyWeightKg.isAcceptableOrUnknown(
          data['body_weight_kg']!,
          _bodyWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyWeightKgMeta);
    }
    if (data.containsKey('estimated_calories_burned')) {
      context.handle(
        _estimatedCaloriesBurnedMeta,
        estimatedCaloriesBurned.isAcceptableOrUnknown(
          data['estimated_calories_burned']!,
          _estimatedCaloriesBurnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedCaloriesBurnedMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: $TrainingSessionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      )!,
      bodyWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_weight_kg'],
      )!,
      estimatedCaloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_calories_burned'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TrainingSessionsTable createAlias(String alias) {
    return $TrainingSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrainingType, String, String> $convertertype =
      const EnumNameConverter<TrainingType>(TrainingType.values);
}

class TrainingSessionRow extends DataClass
    implements Insertable<TrainingSessionRow> {
  final int id;
  final DateTime date;
  final TrainingType type;
  final int durationMinutes;
  final int rpe;
  final double bodyWeightKg;
  final double estimatedCaloriesBurned;
  final String? note;
  const TrainingSessionRow({
    required this.id,
    required this.date,
    required this.type,
    required this.durationMinutes,
    required this.rpe,
    required this.bodyWeightKg,
    required this.estimatedCaloriesBurned,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['type'] = Variable<String>(
        $TrainingSessionsTable.$convertertype.toSql(type),
      );
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['rpe'] = Variable<int>(rpe);
    map['body_weight_kg'] = Variable<double>(bodyWeightKg);
    map['estimated_calories_burned'] = Variable<double>(
      estimatedCaloriesBurned,
    );
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TrainingSessionsCompanion toCompanion(bool nullToAbsent) {
    return TrainingSessionsCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      durationMinutes: Value(durationMinutes),
      rpe: Value(rpe),
      bodyWeightKg: Value(bodyWeightKg),
      estimatedCaloriesBurned: Value(estimatedCaloriesBurned),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory TrainingSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingSessionRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: $TrainingSessionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      rpe: serializer.fromJson<int>(json['rpe']),
      bodyWeightKg: serializer.fromJson<double>(json['bodyWeightKg']),
      estimatedCaloriesBurned: serializer.fromJson<double>(
        json['estimatedCaloriesBurned'],
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(
        $TrainingSessionsTable.$convertertype.toJson(type),
      ),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'rpe': serializer.toJson<int>(rpe),
      'bodyWeightKg': serializer.toJson<double>(bodyWeightKg),
      'estimatedCaloriesBurned': serializer.toJson<double>(
        estimatedCaloriesBurned,
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  TrainingSessionRow copyWith({
    int? id,
    DateTime? date,
    TrainingType? type,
    int? durationMinutes,
    int? rpe,
    double? bodyWeightKg,
    double? estimatedCaloriesBurned,
    Value<String?> note = const Value.absent(),
  }) => TrainingSessionRow(
    id: id ?? this.id,
    date: date ?? this.date,
    type: type ?? this.type,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    rpe: rpe ?? this.rpe,
    bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
    estimatedCaloriesBurned:
        estimatedCaloriesBurned ?? this.estimatedCaloriesBurned,
    note: note.present ? note.value : this.note,
  );
  TrainingSessionRow copyWithCompanion(TrainingSessionsCompanion data) {
    return TrainingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      bodyWeightKg: data.bodyWeightKg.present
          ? data.bodyWeightKg.value
          : this.bodyWeightKg,
      estimatedCaloriesBurned: data.estimatedCaloriesBurned.present
          ? data.estimatedCaloriesBurned.value
          : this.estimatedCaloriesBurned,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSessionRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('rpe: $rpe, ')
          ..write('bodyWeightKg: $bodyWeightKg, ')
          ..write('estimatedCaloriesBurned: $estimatedCaloriesBurned, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    type,
    durationMinutes,
    rpe,
    bodyWeightKg,
    estimatedCaloriesBurned,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingSessionRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.durationMinutes == this.durationMinutes &&
          other.rpe == this.rpe &&
          other.bodyWeightKg == this.bodyWeightKg &&
          other.estimatedCaloriesBurned == this.estimatedCaloriesBurned &&
          other.note == this.note);
}

class TrainingSessionsCompanion extends UpdateCompanion<TrainingSessionRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<TrainingType> type;
  final Value<int> durationMinutes;
  final Value<int> rpe;
  final Value<double> bodyWeightKg;
  final Value<double> estimatedCaloriesBurned;
  final Value<String?> note;
  const TrainingSessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.rpe = const Value.absent(),
    this.bodyWeightKg = const Value.absent(),
    this.estimatedCaloriesBurned = const Value.absent(),
    this.note = const Value.absent(),
  });
  TrainingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required TrainingType type,
    required int durationMinutes,
    required int rpe,
    required double bodyWeightKg,
    required double estimatedCaloriesBurned,
    this.note = const Value.absent(),
  }) : date = Value(date),
       type = Value(type),
       durationMinutes = Value(durationMinutes),
       rpe = Value(rpe),
       bodyWeightKg = Value(bodyWeightKg),
       estimatedCaloriesBurned = Value(estimatedCaloriesBurned);
  static Insertable<TrainingSessionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? durationMinutes,
    Expression<int>? rpe,
    Expression<double>? bodyWeightKg,
    Expression<double>? estimatedCaloriesBurned,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (rpe != null) 'rpe': rpe,
      if (bodyWeightKg != null) 'body_weight_kg': bodyWeightKg,
      if (estimatedCaloriesBurned != null)
        'estimated_calories_burned': estimatedCaloriesBurned,
      if (note != null) 'note': note,
    });
  }

  TrainingSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<TrainingType>? type,
    Value<int>? durationMinutes,
    Value<int>? rpe,
    Value<double>? bodyWeightKg,
    Value<double>? estimatedCaloriesBurned,
    Value<String?>? note,
  }) {
    return TrainingSessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rpe: rpe ?? this.rpe,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      estimatedCaloriesBurned:
          estimatedCaloriesBurned ?? this.estimatedCaloriesBurned,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TrainingSessionsTable.$convertertype.toSql(type.value),
      );
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (bodyWeightKg.present) {
      map['body_weight_kg'] = Variable<double>(bodyWeightKg.value);
    }
    if (estimatedCaloriesBurned.present) {
      map['estimated_calories_burned'] = Variable<double>(
        estimatedCaloriesBurned.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('rpe: $rpe, ')
          ..write('bodyWeightKg: $bodyWeightKg, ')
          ..write('estimatedCaloriesBurned: $estimatedCaloriesBurned, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $WeightLogsTable extends WeightLogs
    with TableInfo<$WeightLogsTable, WeightLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, weightKg, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WeightLogsTable createAlias(String alias) {
    return $WeightLogsTable(attachedDatabase, alias);
  }
}

class WeightLogRow extends DataClass implements Insertable<WeightLogRow> {
  final int id;
  final DateTime date;
  final double weightKg;
  final String? note;
  const WeightLogRow({
    required this.id,
    required this.date,
    required this.weightKg,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WeightLogsCompanion toCompanion(bool nullToAbsent) {
    return WeightLogsCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: Value(weightKg),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WeightLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightLogRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double>(weightKg),
      'note': serializer.toJson<String?>(note),
    };
  }

  WeightLogRow copyWith({
    int? id,
    DateTime? date,
    double? weightKg,
    Value<String?> note = const Value.absent(),
  }) => WeightLogRow(
    id: id ?? this.id,
    date: date ?? this.date,
    weightKg: weightKg ?? this.weightKg,
    note: note.present ? note.value : this.note,
  );
  WeightLogRow copyWithCompanion(WeightLogsCompanion data) {
    return WeightLogRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weightKg, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightLogRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.note == this.note);
}

class WeightLogsCompanion extends UpdateCompanion<WeightLogRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> weightKg;
  final Value<String?> note;
  const WeightLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.note = const Value.absent(),
  });
  WeightLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double weightKg,
    this.note = const Value.absent(),
  }) : date = Value(date),
       weightKg = Value(weightKg);
  static Insertable<WeightLogRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (note != null) 'note': note,
    });
  }

  WeightLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? weightKg,
    Value<String?>? note,
  }) {
    return WeightLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementLogsTable extends BodyMeasurementLogs
    with TableInfo<$BodyMeasurementLogsTable, BodyMeasurementLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestCmMeta = const VerificationMeta(
    'chestCm',
  );
  @override
  late final GeneratedColumn<double> chestCm = GeneratedColumn<double>(
    'chest_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
    'hips_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armCmMeta = const VerificationMeta('armCm');
  @override
  late final GeneratedColumn<double> armCm = GeneratedColumn<double>(
    'arm_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thighCmMeta = const VerificationMeta(
    'thighCm',
  );
  @override
  late final GeneratedColumn<double> thighCm = GeneratedColumn<double>(
    'thigh_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    waistCm,
    chestCm,
    hipsCm,
    armCm,
    thighCm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurement_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurementLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('chest_cm')) {
      context.handle(
        _chestCmMeta,
        chestCm.isAcceptableOrUnknown(data['chest_cm']!, _chestCmMeta),
      );
    }
    if (data.containsKey('hips_cm')) {
      context.handle(
        _hipsCmMeta,
        hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta),
      );
    }
    if (data.containsKey('arm_cm')) {
      context.handle(
        _armCmMeta,
        armCm.isAcceptableOrUnknown(data['arm_cm']!, _armCmMeta),
      );
    }
    if (data.containsKey('thigh_cm')) {
      context.handle(
        _thighCmMeta,
        thighCm.isAcceptableOrUnknown(data['thigh_cm']!, _thighCmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurementLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurementLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      chestCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_cm'],
      ),
      hipsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_cm'],
      ),
      armCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arm_cm'],
      ),
      thighCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thigh_cm'],
      ),
    );
  }

  @override
  $BodyMeasurementLogsTable createAlias(String alias) {
    return $BodyMeasurementLogsTable(attachedDatabase, alias);
  }
}

class BodyMeasurementLogRow extends DataClass
    implements Insertable<BodyMeasurementLogRow> {
  final int id;
  final DateTime date;
  final double? waistCm;
  final double? chestCm;
  final double? hipsCm;
  final double? armCm;
  final double? thighCm;
  const BodyMeasurementLogRow({
    required this.id,
    required this.date,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || chestCm != null) {
      map['chest_cm'] = Variable<double>(chestCm);
    }
    if (!nullToAbsent || hipsCm != null) {
      map['hips_cm'] = Variable<double>(hipsCm);
    }
    if (!nullToAbsent || armCm != null) {
      map['arm_cm'] = Variable<double>(armCm);
    }
    if (!nullToAbsent || thighCm != null) {
      map['thigh_cm'] = Variable<double>(thighCm);
    }
    return map;
  }

  BodyMeasurementLogsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementLogsCompanion(
      id: Value(id),
      date: Value(date),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      chestCm: chestCm == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCm),
      hipsCm: hipsCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsCm),
      armCm: armCm == null && nullToAbsent
          ? const Value.absent()
          : Value(armCm),
      thighCm: thighCm == null && nullToAbsent
          ? const Value.absent()
          : Value(thighCm),
    );
  }

  factory BodyMeasurementLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurementLogRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      chestCm: serializer.fromJson<double?>(json['chestCm']),
      hipsCm: serializer.fromJson<double?>(json['hipsCm']),
      armCm: serializer.fromJson<double?>(json['armCm']),
      thighCm: serializer.fromJson<double?>(json['thighCm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'waistCm': serializer.toJson<double?>(waistCm),
      'chestCm': serializer.toJson<double?>(chestCm),
      'hipsCm': serializer.toJson<double?>(hipsCm),
      'armCm': serializer.toJson<double?>(armCm),
      'thighCm': serializer.toJson<double?>(thighCm),
    };
  }

  BodyMeasurementLogRow copyWith({
    int? id,
    DateTime? date,
    Value<double?> waistCm = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    Value<double?> armCm = const Value.absent(),
    Value<double?> thighCm = const Value.absent(),
  }) => BodyMeasurementLogRow(
    id: id ?? this.id,
    date: date ?? this.date,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    chestCm: chestCm.present ? chestCm.value : this.chestCm,
    hipsCm: hipsCm.present ? hipsCm.value : this.hipsCm,
    armCm: armCm.present ? armCm.value : this.armCm,
    thighCm: thighCm.present ? thighCm.value : this.thighCm,
  );
  BodyMeasurementLogRow copyWithCompanion(BodyMeasurementLogsCompanion data) {
    return BodyMeasurementLogRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      chestCm: data.chestCm.present ? data.chestCm.value : this.chestCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      armCm: data.armCm.present ? data.armCm.value : this.armCm,
      thighCm: data.thighCm.present ? data.thighCm.value : this.thighCm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementLogRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('waistCm: $waistCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('armCm: $armCm, ')
          ..write('thighCm: $thighCm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, waistCm, chestCm, hipsCm, armCm, thighCm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurementLogRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.waistCm == this.waistCm &&
          other.chestCm == this.chestCm &&
          other.hipsCm == this.hipsCm &&
          other.armCm == this.armCm &&
          other.thighCm == this.thighCm);
}

class BodyMeasurementLogsCompanion
    extends UpdateCompanion<BodyMeasurementLogRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double?> waistCm;
  final Value<double?> chestCm;
  final Value<double?> hipsCm;
  final Value<double?> armCm;
  final Value<double?> thighCm;
  const BodyMeasurementLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.thighCm = const Value.absent(),
  });
  BodyMeasurementLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.waistCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.thighCm = const Value.absent(),
  }) : date = Value(date);
  static Insertable<BodyMeasurementLogRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? waistCm,
    Expression<double>? chestCm,
    Expression<double>? hipsCm,
    Expression<double>? armCm,
    Expression<double>? thighCm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (waistCm != null) 'waist_cm': waistCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (armCm != null) 'arm_cm': armCm,
      if (thighCm != null) 'thigh_cm': thighCm,
    });
  }

  BodyMeasurementLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double?>? waistCm,
    Value<double?>? chestCm,
    Value<double?>? hipsCm,
    Value<double?>? armCm,
    Value<double?>? thighCm,
  }) {
    return BodyMeasurementLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      hipsCm: hipsCm ?? this.hipsCm,
      armCm: armCm ?? this.armCm,
      thighCm: thighCm ?? this.thighCm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (chestCm.present) {
      map['chest_cm'] = Variable<double>(chestCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (armCm.present) {
      map['arm_cm'] = Variable<double>(armCm.value);
    }
    if (thighCm.present) {
      map['thigh_cm'] = Variable<double>(thighCm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('waistCm: $waistCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('armCm: $armCm, ')
          ..write('thighCm: $thighCm')
          ..write(')'))
        .toString();
  }
}

class $DayStatusesTable extends DayStatuses
    with TableInfo<$DayStatusesTable, DayStatusRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DayStatusType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DayStatusType>($DayStatusesTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [id, date, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayStatusRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayStatusRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayStatusRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: $DayStatusesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
    );
  }

  @override
  $DayStatusesTable createAlias(String alias) {
    return $DayStatusesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DayStatusType, String, String> $convertertype =
      const EnumNameConverter<DayStatusType>(DayStatusType.values);
}

class DayStatusRow extends DataClass implements Insertable<DayStatusRow> {
  final int id;
  final DateTime date;
  final DayStatusType type;
  const DayStatusRow({
    required this.id,
    required this.date,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['type'] = Variable<String>(
        $DayStatusesTable.$convertertype.toSql(type),
      );
    }
    return map;
  }

  DayStatusesCompanion toCompanion(bool nullToAbsent) {
    return DayStatusesCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
    );
  }

  factory DayStatusRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayStatusRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: $DayStatusesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(
        $DayStatusesTable.$convertertype.toJson(type),
      ),
    };
  }

  DayStatusRow copyWith({int? id, DateTime? date, DayStatusType? type}) =>
      DayStatusRow(
        id: id ?? this.id,
        date: date ?? this.date,
        type: type ?? this.type,
      );
  DayStatusRow copyWithCompanion(DayStatusesCompanion data) {
    return DayStatusRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayStatusRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayStatusRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type);
}

class DayStatusesCompanion extends UpdateCompanion<DayStatusRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<DayStatusType> type;
  const DayStatusesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
  });
  DayStatusesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required DayStatusType type,
  }) : date = Value(date),
       type = Value(type);
  static Insertable<DayStatusRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
    });
  }

  DayStatusesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<DayStatusType>? type,
  }) {
    return DayStatusesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $DayStatusesTable.$convertertype.toSql(type.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayStatusesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $DailyTargetSnapshotsTable extends DailyTargetSnapshots
    with TableInfo<$DailyTargetSnapshotsTable, DailyTargetSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyTargetSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalMode, String> goalMode =
      GeneratedColumn<String>(
        'goal_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalMode>($DailyTargetSnapshotsTable.$convertergoalMode);
  @override
  late final GeneratedColumnWithTypeConverter<GoalPace, String> goalPace =
      GeneratedColumn<String>(
        'goal_pace',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalPace>($DailyTargetSnapshotsTable.$convertergoalPace);
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGramsMeta = const VerificationMeta(
    'carbsGrams',
  );
  @override
  late final GeneratedColumn<double> carbsGrams = GeneratedColumn<double>(
    'carbs_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberGramsMeta = const VerificationMeta(
    'fiberGrams',
  );
  @override
  late final GeneratedColumn<double> fiberGrams = GeneratedColumn<double>(
    'fiber_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trainingCaloriesMeta = const VerificationMeta(
    'trainingCalories',
  );
  @override
  late final GeneratedColumn<double> trainingCalories = GeneratedColumn<double>(
    'training_calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    goalMode,
    goalPace,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
    trainingCalories,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_target_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyTargetSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbs_grams')) {
      context.handle(
        _carbsGramsMeta,
        carbsGrams.isAcceptableOrUnknown(data['carbs_grams']!, _carbsGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('fiber_grams')) {
      context.handle(
        _fiberGramsMeta,
        fiberGrams.isAcceptableOrUnknown(data['fiber_grams']!, _fiberGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberGramsMeta);
    }
    if (data.containsKey('training_calories')) {
      context.handle(
        _trainingCaloriesMeta,
        trainingCalories.isAcceptableOrUnknown(
          data['training_calories']!,
          _trainingCaloriesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trainingCaloriesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyTargetSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyTargetSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      goalMode: $DailyTargetSnapshotsTable.$convertergoalMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_mode'],
        )!,
      ),
      goalPace: $DailyTargetSnapshotsTable.$convertergoalPace.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal_pace'],
        )!,
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      fiberGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_grams'],
      )!,
      trainingCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}training_calories'],
      )!,
    );
  }

  @override
  $DailyTargetSnapshotsTable createAlias(String alias) {
    return $DailyTargetSnapshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GoalMode, String, String> $convertergoalMode =
      const EnumNameConverter<GoalMode>(GoalMode.values);
  static JsonTypeConverter2<GoalPace, String, String> $convertergoalPace =
      const EnumNameConverter<GoalPace>(GoalPace.values);
}

class DailyTargetSnapshotRow extends DataClass
    implements Insertable<DailyTargetSnapshotRow> {
  final int id;
  final DateTime date;
  final GoalMode goalMode;
  final GoalPace goalPace;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final double trainingCalories;
  const DailyTargetSnapshotRow({
    required this.id,
    required this.date,
    required this.goalMode,
    required this.goalPace,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.trainingCalories,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['goal_mode'] = Variable<String>(
        $DailyTargetSnapshotsTable.$convertergoalMode.toSql(goalMode),
      );
    }
    {
      map['goal_pace'] = Variable<String>(
        $DailyTargetSnapshotsTable.$convertergoalPace.toSql(goalPace),
      );
    }
    map['calories'] = Variable<double>(calories);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbs_grams'] = Variable<double>(carbsGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    map['fiber_grams'] = Variable<double>(fiberGrams);
    map['training_calories'] = Variable<double>(trainingCalories);
    return map;
  }

  DailyTargetSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return DailyTargetSnapshotsCompanion(
      id: Value(id),
      date: Value(date),
      goalMode: Value(goalMode),
      goalPace: Value(goalPace),
      calories: Value(calories),
      proteinGrams: Value(proteinGrams),
      carbsGrams: Value(carbsGrams),
      fatGrams: Value(fatGrams),
      fiberGrams: Value(fiberGrams),
      trainingCalories: Value(trainingCalories),
    );
  }

  factory DailyTargetSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyTargetSnapshotRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      goalMode: $DailyTargetSnapshotsTable.$convertergoalMode.fromJson(
        serializer.fromJson<String>(json['goalMode']),
      ),
      goalPace: $DailyTargetSnapshotsTable.$convertergoalPace.fromJson(
        serializer.fromJson<String>(json['goalPace']),
      ),
      calories: serializer.fromJson<double>(json['calories']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbsGrams: serializer.fromJson<double>(json['carbsGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      fiberGrams: serializer.fromJson<double>(json['fiberGrams']),
      trainingCalories: serializer.fromJson<double>(json['trainingCalories']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'goalMode': serializer.toJson<String>(
        $DailyTargetSnapshotsTable.$convertergoalMode.toJson(goalMode),
      ),
      'goalPace': serializer.toJson<String>(
        $DailyTargetSnapshotsTable.$convertergoalPace.toJson(goalPace),
      ),
      'calories': serializer.toJson<double>(calories),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbsGrams': serializer.toJson<double>(carbsGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'fiberGrams': serializer.toJson<double>(fiberGrams),
      'trainingCalories': serializer.toJson<double>(trainingCalories),
    };
  }

  DailyTargetSnapshotRow copyWith({
    int? id,
    DateTime? date,
    GoalMode? goalMode,
    GoalPace? goalPace,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? fiberGrams,
    double? trainingCalories,
  }) => DailyTargetSnapshotRow(
    id: id ?? this.id,
    date: date ?? this.date,
    goalMode: goalMode ?? this.goalMode,
    goalPace: goalPace ?? this.goalPace,
    calories: calories ?? this.calories,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbsGrams: carbsGrams ?? this.carbsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    fiberGrams: fiberGrams ?? this.fiberGrams,
    trainingCalories: trainingCalories ?? this.trainingCalories,
  );
  DailyTargetSnapshotRow copyWithCompanion(DailyTargetSnapshotsCompanion data) {
    return DailyTargetSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      goalMode: data.goalMode.present ? data.goalMode.value : this.goalMode,
      goalPace: data.goalPace.present ? data.goalPace.value : this.goalPace,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbsGrams: data.carbsGrams.present
          ? data.carbsGrams.value
          : this.carbsGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      fiberGrams: data.fiberGrams.present
          ? data.fiberGrams.value
          : this.fiberGrams,
      trainingCalories: data.trainingCalories.present
          ? data.trainingCalories.value
          : this.trainingCalories,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyTargetSnapshotRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('goalMode: $goalMode, ')
          ..write('goalPace: $goalPace, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('trainingCalories: $trainingCalories')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    goalMode,
    goalPace,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    fiberGrams,
    trainingCalories,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyTargetSnapshotRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.goalMode == this.goalMode &&
          other.goalPace == this.goalPace &&
          other.calories == this.calories &&
          other.proteinGrams == this.proteinGrams &&
          other.carbsGrams == this.carbsGrams &&
          other.fatGrams == this.fatGrams &&
          other.fiberGrams == this.fiberGrams &&
          other.trainingCalories == this.trainingCalories);
}

class DailyTargetSnapshotsCompanion
    extends UpdateCompanion<DailyTargetSnapshotRow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<GoalMode> goalMode;
  final Value<GoalPace> goalPace;
  final Value<double> calories;
  final Value<double> proteinGrams;
  final Value<double> carbsGrams;
  final Value<double> fatGrams;
  final Value<double> fiberGrams;
  final Value<double> trainingCalories;
  const DailyTargetSnapshotsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.goalMode = const Value.absent(),
    this.goalPace = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbsGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.trainingCalories = const Value.absent(),
  });
  DailyTargetSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required GoalMode goalMode,
    required GoalPace goalPace,
    required double calories,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    required double fiberGrams,
    required double trainingCalories,
  }) : date = Value(date),
       goalMode = Value(goalMode),
       goalPace = Value(goalPace),
       calories = Value(calories),
       proteinGrams = Value(proteinGrams),
       carbsGrams = Value(carbsGrams),
       fatGrams = Value(fatGrams),
       fiberGrams = Value(fiberGrams),
       trainingCalories = Value(trainingCalories);
  static Insertable<DailyTargetSnapshotRow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? goalMode,
    Expression<String>? goalPace,
    Expression<double>? calories,
    Expression<double>? proteinGrams,
    Expression<double>? carbsGrams,
    Expression<double>? fatGrams,
    Expression<double>? fiberGrams,
    Expression<double>? trainingCalories,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (goalMode != null) 'goal_mode': goalMode,
      if (goalPace != null) 'goal_pace': goalPace,
      if (calories != null) 'calories': calories,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (fiberGrams != null) 'fiber_grams': fiberGrams,
      if (trainingCalories != null) 'training_calories': trainingCalories,
    });
  }

  DailyTargetSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<GoalMode>? goalMode,
    Value<GoalPace>? goalPace,
    Value<double>? calories,
    Value<double>? proteinGrams,
    Value<double>? carbsGrams,
    Value<double>? fatGrams,
    Value<double>? fiberGrams,
    Value<double>? trainingCalories,
  }) {
    return DailyTargetSnapshotsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      goalMode: goalMode ?? this.goalMode,
      goalPace: goalPace ?? this.goalPace,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      trainingCalories: trainingCalories ?? this.trainingCalories,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (goalMode.present) {
      map['goal_mode'] = Variable<String>(
        $DailyTargetSnapshotsTable.$convertergoalMode.toSql(goalMode.value),
      );
    }
    if (goalPace.present) {
      map['goal_pace'] = Variable<String>(
        $DailyTargetSnapshotsTable.$convertergoalPace.toSql(goalPace.value),
      );
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbsGrams.present) {
      map['carbs_grams'] = Variable<double>(carbsGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (fiberGrams.present) {
      map['fiber_grams'] = Variable<double>(fiberGrams.value);
    }
    if (trainingCalories.present) {
      map['training_calories'] = Variable<double>(trainingCalories.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyTargetSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('goalMode: $goalMode, ')
          ..write('goalPace: $goalPace, ')
          ..write('calories: $calories, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('trainingCalories: $trainingCalories')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $GoalPeriodsTable goalPeriods = $GoalPeriodsTable(this);
  late final $FoodProductsTable foodProducts = $FoodProductsTable(this);
  late final $FoodLogEntriesTable foodLogEntries = $FoodLogEntriesTable(this);
  late final $FavoriteFoodsTable favoriteFoods = $FavoriteFoodsTable(this);
  late final $MealTemplatesTable mealTemplates = $MealTemplatesTable(this);
  late final $TrainingSessionsTable trainingSessions = $TrainingSessionsTable(
    this,
  );
  late final $WeightLogsTable weightLogs = $WeightLogsTable(this);
  late final $BodyMeasurementLogsTable bodyMeasurementLogs =
      $BodyMeasurementLogsTable(this);
  late final $DayStatusesTable dayStatuses = $DayStatusesTable(this);
  late final $DailyTargetSnapshotsTable dailyTargetSnapshots =
      $DailyTargetSnapshotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    goalPeriods,
    foodProducts,
    foodLogEntries,
    favoriteFoods,
    mealTemplates,
    trainingSessions,
    weightLogs,
    bodyMeasurementLogs,
    dayStatuses,
    dailyTargetSnapshots,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String name,
      required int age,
      required Sex sex,
      required double heightCm,
      required double currentWeightKg,
      Value<double?> targetWeightKg,
      Value<double?> estimatedBodyFatPercentage,
      required GoalMode goalMode,
      required GoalPace goalPace,
      required ActivityLevel activityLevel,
      required DateTime createdAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> age,
      Value<Sex> sex,
      Value<double> heightCm,
      Value<double> currentWeightKg,
      Value<double?> targetWeightKg,
      Value<double?> estimatedBodyFatPercentage,
      Value<GoalMode> goalMode,
      Value<GoalPace> goalPace,
      Value<ActivityLevel> activityLevel,
      Value<DateTime> createdAt,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GoalPeriodsTable, List<GoalPeriodRow>>
  _goalPeriodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalPeriods,
    aliasName: 'user_profiles__id__goal_periods__profile_id',
  );

  $$GoalPeriodsTableProcessedTableManager get goalPeriodsRefs {
    final manager = $$GoalPeriodsTableTableManager(
      $_db,
      $_db.goalPeriods,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalPeriodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex, Sex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedBodyFatPercentage => $composableBuilder(
    column: $table.estimatedBodyFatPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalMode, GoalMode, String> get goalMode =>
      $composableBuilder(
        column: $table.goalMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GoalPace, GoalPace, String> get goalPace =>
      $composableBuilder(
        column: $table.goalPace,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ActivityLevel, ActivityLevel, String>
  get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> goalPeriodsRefs(
    Expression<bool> Function($$GoalPeriodsTableFilterComposer f) f,
  ) {
    final $$GoalPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPeriods,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.goalPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedBodyFatPercentage => $composableBuilder(
    column: $table.estimatedBodyFatPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalMode => $composableBuilder(
    column: $table.goalMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalPace => $composableBuilder(
    column: $table.goalPace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get currentWeightKg => $composableBuilder(
    column: $table.currentWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get estimatedBodyFatPercentage => $composableBuilder(
    column: $table.estimatedBodyFatPercentage,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GoalMode, String> get goalMode =>
      $composableBuilder(column: $table.goalMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalPace, String> get goalPace =>
      $composableBuilder(column: $table.goalPace, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel, String> get activityLevel =>
      $composableBuilder(
        column: $table.activityLevel,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> goalPeriodsRefs<T extends Object>(
    Expression<T> Function($$GoalPeriodsTableAnnotationComposer a) f,
  ) {
    final $$GoalPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalPeriods,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfileRow, $$UserProfilesTableReferences),
          UserProfileRow,
          PrefetchHooks Function({bool goalPeriodsRefs})
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<Sex> sex = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> currentWeightKg = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<double?> estimatedBodyFatPercentage =
                    const Value.absent(),
                Value<GoalMode> goalMode = const Value.absent(),
                Value<GoalPace> goalPace = const Value.absent(),
                Value<ActivityLevel> activityLevel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                name: name,
                age: age,
                sex: sex,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                estimatedBodyFatPercentage: estimatedBodyFatPercentage,
                goalMode: goalMode,
                goalPace: goalPace,
                activityLevel: activityLevel,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int age,
                required Sex sex,
                required double heightCm,
                required double currentWeightKg,
                Value<double?> targetWeightKg = const Value.absent(),
                Value<double?> estimatedBodyFatPercentage =
                    const Value.absent(),
                required GoalMode goalMode,
                required GoalPace goalPace,
                required ActivityLevel activityLevel,
                required DateTime createdAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                name: name,
                age: age,
                sex: sex,
                heightCm: heightCm,
                currentWeightKg: currentWeightKg,
                targetWeightKg: targetWeightKg,
                estimatedBodyFatPercentage: estimatedBodyFatPercentage,
                goalMode: goalMode,
                goalPace: goalPace,
                activityLevel: activityLevel,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalPeriodsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (goalPeriodsRefs) db.goalPeriods],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (goalPeriodsRefs)
                    await $_getPrefetchedData<
                      UserProfileRow,
                      $UserProfilesTable,
                      GoalPeriodRow
                    >(
                      currentTable: table,
                      referencedTable: $$UserProfilesTableReferences
                          ._goalPeriodsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).goalPeriodsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.profileId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfileRow, $$UserProfilesTableReferences),
      UserProfileRow,
      PrefetchHooks Function({bool goalPeriodsRefs})
    >;
typedef $$GoalPeriodsTableCreateCompanionBuilder =
    GoalPeriodsCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      required DateTime startDate,
      required int durationWeeks,
      required GoalMode goalMode,
      required GoalPace goalPace,
      Value<bool> isActive,
      Value<DateTime?> completedAt,
      Value<double> calorieAdjustment,
      Value<DateTime?> lastCheckInDate,
    });
typedef $$GoalPeriodsTableUpdateCompanionBuilder =
    GoalPeriodsCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      Value<DateTime> startDate,
      Value<int> durationWeeks,
      Value<GoalMode> goalMode,
      Value<GoalPace> goalPace,
      Value<bool> isActive,
      Value<DateTime?> completedAt,
      Value<double> calorieAdjustment,
      Value<DateTime?> lastCheckInDate,
    });

final class $$GoalPeriodsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalPeriodsTable, GoalPeriodRow> {
  $$GoalPeriodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _profileIdTable(_$AppDatabase db) => db.userProfiles
      .createAlias('goal_periods__profile_id__user_profiles__id');

  $$UserProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalPeriodsTable> {
  $$GoalPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalMode, GoalMode, String> get goalMode =>
      $composableBuilder(
        column: $table.goalMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GoalPace, GoalPace, String> get goalPace =>
      $composableBuilder(
        column: $table.goalPace,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calorieAdjustment => $composableBuilder(
    column: $table.calorieAdjustment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckInDate => $composableBuilder(
    column: $table.lastCheckInDate,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get profileId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalPeriodsTable> {
  $$GoalPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalMode => $composableBuilder(
    column: $table.goalMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalPace => $composableBuilder(
    column: $table.goalPace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calorieAdjustment => $composableBuilder(
    column: $table.calorieAdjustment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckInDate => $composableBuilder(
    column: $table.lastCheckInDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get profileId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalPeriodsTable> {
  $$GoalPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GoalMode, String> get goalMode =>
      $composableBuilder(column: $table.goalMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalPace, String> get goalPace =>
      $composableBuilder(column: $table.goalPace, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calorieAdjustment => $composableBuilder(
    column: $table.calorieAdjustment,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckInDate => $composableBuilder(
    column: $table.lastCheckInDate,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get profileId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalPeriodsTable,
          GoalPeriodRow,
          $$GoalPeriodsTableFilterComposer,
          $$GoalPeriodsTableOrderingComposer,
          $$GoalPeriodsTableAnnotationComposer,
          $$GoalPeriodsTableCreateCompanionBuilder,
          $$GoalPeriodsTableUpdateCompanionBuilder,
          (GoalPeriodRow, $$GoalPeriodsTableReferences),
          GoalPeriodRow,
          PrefetchHooks Function({bool profileId})
        > {
  $$GoalPeriodsTableTableManager(_$AppDatabase db, $GoalPeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> durationWeeks = const Value.absent(),
                Value<GoalMode> goalMode = const Value.absent(),
                Value<GoalPace> goalPace = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double> calorieAdjustment = const Value.absent(),
                Value<DateTime?> lastCheckInDate = const Value.absent(),
              }) => GoalPeriodsCompanion(
                id: id,
                profileId: profileId,
                startDate: startDate,
                durationWeeks: durationWeeks,
                goalMode: goalMode,
                goalPace: goalPace,
                isActive: isActive,
                completedAt: completedAt,
                calorieAdjustment: calorieAdjustment,
                lastCheckInDate: lastCheckInDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                required DateTime startDate,
                required int durationWeeks,
                required GoalMode goalMode,
                required GoalPace goalPace,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<double> calorieAdjustment = const Value.absent(),
                Value<DateTime?> lastCheckInDate = const Value.absent(),
              }) => GoalPeriodsCompanion.insert(
                id: id,
                profileId: profileId,
                startDate: startDate,
                durationWeeks: durationWeeks,
                goalMode: goalMode,
                goalPace: goalPace,
                isActive: isActive,
                completedAt: completedAt,
                calorieAdjustment: calorieAdjustment,
                lastCheckInDate: lastCheckInDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$GoalPeriodsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$GoalPeriodsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalPeriodsTable,
      GoalPeriodRow,
      $$GoalPeriodsTableFilterComposer,
      $$GoalPeriodsTableOrderingComposer,
      $$GoalPeriodsTableAnnotationComposer,
      $$GoalPeriodsTableCreateCompanionBuilder,
      $$GoalPeriodsTableUpdateCompanionBuilder,
      (GoalPeriodRow, $$GoalPeriodsTableReferences),
      GoalPeriodRow,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$FoodProductsTableCreateCompanionBuilder =
    FoodProductsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> brand,
      Value<String?> barcode,
      required double caloriesPer100g,
      required double proteinPer100g,
      required double carbsPer100g,
      required double fatPer100g,
      required double fiberPer100g,
      required DateTime createdAt,
    });
typedef $$FoodProductsTableUpdateCompanionBuilder =
    FoodProductsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> brand,
      Value<String?> barcode,
      Value<double> caloriesPer100g,
      Value<double> proteinPer100g,
      Value<double> carbsPer100g,
      Value<double> fatPer100g,
      Value<double> fiberPer100g,
      Value<DateTime> createdAt,
    });

class $$FoodProductsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesPer100g => $composableBuilder(
    column: $table.caloriesPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesPer100g => $composableBuilder(
    column: $table.caloriesPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodProductsTable> {
  $$FoodProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get caloriesPer100g => $composableBuilder(
    column: $table.caloriesPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPer100g => $composableBuilder(
    column: $table.proteinPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPer100g => $composableBuilder(
    column: $table.carbsPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPer100g => $composableBuilder(
    column: $table.fatPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberPer100g => $composableBuilder(
    column: $table.fiberPer100g,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodProductsTable,
          FoodProductRow,
          $$FoodProductsTableFilterComposer,
          $$FoodProductsTableOrderingComposer,
          $$FoodProductsTableAnnotationComposer,
          $$FoodProductsTableCreateCompanionBuilder,
          $$FoodProductsTableUpdateCompanionBuilder,
          (
            FoodProductRow,
            BaseReferences<_$AppDatabase, $FoodProductsTable, FoodProductRow>,
          ),
          FoodProductRow,
          PrefetchHooks Function()
        > {
  $$FoodProductsTableTableManager(_$AppDatabase db, $FoodProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<double> caloriesPer100g = const Value.absent(),
                Value<double> proteinPer100g = const Value.absent(),
                Value<double> carbsPer100g = const Value.absent(),
                Value<double> fatPer100g = const Value.absent(),
                Value<double> fiberPer100g = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoodProductsCompanion(
                id: id,
                name: name,
                brand: brand,
                barcode: barcode,
                caloriesPer100g: caloriesPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required double caloriesPer100g,
                required double proteinPer100g,
                required double carbsPer100g,
                required double fatPer100g,
                required double fiberPer100g,
                required DateTime createdAt,
              }) => FoodProductsCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                barcode: barcode,
                caloriesPer100g: caloriesPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodProductsTable,
      FoodProductRow,
      $$FoodProductsTableFilterComposer,
      $$FoodProductsTableOrderingComposer,
      $$FoodProductsTableAnnotationComposer,
      $$FoodProductsTableCreateCompanionBuilder,
      $$FoodProductsTableUpdateCompanionBuilder,
      (
        FoodProductRow,
        BaseReferences<_$AppDatabase, $FoodProductsTable, FoodProductRow>,
      ),
      FoodProductRow,
      PrefetchHooks Function()
    >;
typedef $$FoodLogEntriesTableCreateCompanionBuilder =
    FoodLogEntriesCompanion Function({
      Value<int> id,
      required DateTime date,
      required MealCategory mealCategory,
      required String name,
      required double grams,
      required double calories,
      required double proteinGrams,
      required double carbsGrams,
      required double fatGrams,
      required double fiberGrams,
      Value<String?> note,
    });
typedef $$FoodLogEntriesTableUpdateCompanionBuilder =
    FoodLogEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<MealCategory> mealCategory,
      Value<String> name,
      Value<double> grams,
      Value<double> calories,
      Value<double> proteinGrams,
      Value<double> carbsGrams,
      Value<double> fatGrams,
      Value<double> fiberGrams,
      Value<String?> note,
    });

class $$FoodLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTable> {
  $$FoodLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MealCategory, MealCategory, String>
  get mealCategory => $composableBuilder(
    column: $table.mealCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTable> {
  $$FoodLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealCategory => $composableBuilder(
    column: $table.mealCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTable> {
  $$FoodLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealCategory, String> get mealCategory =>
      $composableBuilder(
        column: $table.mealCategory,
        builder: (column) => column,
      );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$FoodLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogEntriesTable,
          FoodLogEntryRow,
          $$FoodLogEntriesTableFilterComposer,
          $$FoodLogEntriesTableOrderingComposer,
          $$FoodLogEntriesTableAnnotationComposer,
          $$FoodLogEntriesTableCreateCompanionBuilder,
          $$FoodLogEntriesTableUpdateCompanionBuilder,
          (
            FoodLogEntryRow,
            BaseReferences<
              _$AppDatabase,
              $FoodLogEntriesTable,
              FoodLogEntryRow
            >,
          ),
          FoodLogEntryRow,
          PrefetchHooks Function()
        > {
  $$FoodLogEntriesTableTableManager(
    _$AppDatabase db,
    $FoodLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<MealCategory> mealCategory = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbsGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double> fiberGrams = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FoodLogEntriesCompanion(
                id: id,
                date: date,
                mealCategory: mealCategory,
                name: name,
                grams: grams,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required MealCategory mealCategory,
                required String name,
                required double grams,
                required double calories,
                required double proteinGrams,
                required double carbsGrams,
                required double fatGrams,
                required double fiberGrams,
                Value<String?> note = const Value.absent(),
              }) => FoodLogEntriesCompanion.insert(
                id: id,
                date: date,
                mealCategory: mealCategory,
                name: name,
                grams: grams,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogEntriesTable,
      FoodLogEntryRow,
      $$FoodLogEntriesTableFilterComposer,
      $$FoodLogEntriesTableOrderingComposer,
      $$FoodLogEntriesTableAnnotationComposer,
      $$FoodLogEntriesTableCreateCompanionBuilder,
      $$FoodLogEntriesTableUpdateCompanionBuilder,
      (
        FoodLogEntryRow,
        BaseReferences<_$AppDatabase, $FoodLogEntriesTable, FoodLogEntryRow>,
      ),
      FoodLogEntryRow,
      PrefetchHooks Function()
    >;
typedef $$FavoriteFoodsTableCreateCompanionBuilder =
    FavoriteFoodsCompanion Function({
      Value<int> id,
      required String name,
      required double grams,
      required double calories,
      required double proteinGrams,
      required double carbsGrams,
      required double fatGrams,
      required double fiberGrams,
    });
typedef $$FavoriteFoodsTableUpdateCompanionBuilder =
    FavoriteFoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> grams,
      Value<double> calories,
      Value<double> proteinGrams,
      Value<double> carbsGrams,
      Value<double> fatGrams,
      Value<double> fiberGrams,
    });

class $$FavoriteFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => column,
  );
}

class $$FavoriteFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteFoodsTable,
          FavoriteFoodRow,
          $$FavoriteFoodsTableFilterComposer,
          $$FavoriteFoodsTableOrderingComposer,
          $$FavoriteFoodsTableAnnotationComposer,
          $$FavoriteFoodsTableCreateCompanionBuilder,
          $$FavoriteFoodsTableUpdateCompanionBuilder,
          (
            FavoriteFoodRow,
            BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFoodRow>,
          ),
          FavoriteFoodRow,
          PrefetchHooks Function()
        > {
  $$FavoriteFoodsTableTableManager(_$AppDatabase db, $FavoriteFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbsGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double> fiberGrams = const Value.absent(),
              }) => FavoriteFoodsCompanion(
                id: id,
                name: name,
                grams: grams,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double grams,
                required double calories,
                required double proteinGrams,
                required double carbsGrams,
                required double fatGrams,
                required double fiberGrams,
              }) => FavoriteFoodsCompanion.insert(
                id: id,
                name: name,
                grams: grams,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteFoodsTable,
      FavoriteFoodRow,
      $$FavoriteFoodsTableFilterComposer,
      $$FavoriteFoodsTableOrderingComposer,
      $$FavoriteFoodsTableAnnotationComposer,
      $$FavoriteFoodsTableCreateCompanionBuilder,
      $$FavoriteFoodsTableUpdateCompanionBuilder,
      (
        FavoriteFoodRow,
        BaseReferences<_$AppDatabase, $FavoriteFoodsTable, FavoriteFoodRow>,
      ),
      FavoriteFoodRow,
      PrefetchHooks Function()
    >;
typedef $$MealTemplatesTableCreateCompanionBuilder =
    MealTemplatesCompanion Function({
      Value<int> id,
      required String name,
      required MealCategory category,
      required double calories,
      required double proteinGrams,
      required double carbsGrams,
      required double fatGrams,
      required double fiberGrams,
      required DateTime createdAt,
    });
typedef $$MealTemplatesTableUpdateCompanionBuilder =
    MealTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<MealCategory> category,
      Value<double> calories,
      Value<double> proteinGrams,
      Value<double> carbsGrams,
      Value<double> fatGrams,
      Value<double> fiberGrams,
      Value<DateTime> createdAt,
    });

class $$MealTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $MealTemplatesTable> {
  $$MealTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MealCategory, MealCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealTemplatesTable> {
  $$MealTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealTemplatesTable> {
  $$MealTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MealTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealTemplatesTable,
          MealTemplateRow,
          $$MealTemplatesTableFilterComposer,
          $$MealTemplatesTableOrderingComposer,
          $$MealTemplatesTableAnnotationComposer,
          $$MealTemplatesTableCreateCompanionBuilder,
          $$MealTemplatesTableUpdateCompanionBuilder,
          (
            MealTemplateRow,
            BaseReferences<_$AppDatabase, $MealTemplatesTable, MealTemplateRow>,
          ),
          MealTemplateRow,
          PrefetchHooks Function()
        > {
  $$MealTemplatesTableTableManager(_$AppDatabase db, $MealTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MealCategory> category = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbsGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double> fiberGrams = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MealTemplatesCompanion(
                id: id,
                name: name,
                category: category,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required MealCategory category,
                required double calories,
                required double proteinGrams,
                required double carbsGrams,
                required double fatGrams,
                required double fiberGrams,
                required DateTime createdAt,
              }) => MealTemplatesCompanion.insert(
                id: id,
                name: name,
                category: category,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealTemplatesTable,
      MealTemplateRow,
      $$MealTemplatesTableFilterComposer,
      $$MealTemplatesTableOrderingComposer,
      $$MealTemplatesTableAnnotationComposer,
      $$MealTemplatesTableCreateCompanionBuilder,
      $$MealTemplatesTableUpdateCompanionBuilder,
      (
        MealTemplateRow,
        BaseReferences<_$AppDatabase, $MealTemplatesTable, MealTemplateRow>,
      ),
      MealTemplateRow,
      PrefetchHooks Function()
    >;
typedef $$TrainingSessionsTableCreateCompanionBuilder =
    TrainingSessionsCompanion Function({
      Value<int> id,
      required DateTime date,
      required TrainingType type,
      required int durationMinutes,
      required int rpe,
      required double bodyWeightKg,
      required double estimatedCaloriesBurned,
      Value<String?> note,
    });
typedef $$TrainingSessionsTableUpdateCompanionBuilder =
    TrainingSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<TrainingType> type,
      Value<int> durationMinutes,
      Value<int> rpe,
      Value<double> bodyWeightKg,
      Value<double> estimatedCaloriesBurned,
      Value<String?> note,
    });

class $$TrainingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingSessionsTable> {
  $$TrainingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrainingType, TrainingType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyWeightKg => $composableBuilder(
    column: $table.bodyWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedCaloriesBurned => $composableBuilder(
    column: $table.estimatedCaloriesBurned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrainingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingSessionsTable> {
  $$TrainingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyWeightKg => $composableBuilder(
    column: $table.bodyWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedCaloriesBurned => $composableBuilder(
    column: $table.estimatedCaloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingSessionsTable> {
  $$TrainingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TrainingType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<double> get bodyWeightKg => $composableBuilder(
    column: $table.bodyWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get estimatedCaloriesBurned => $composableBuilder(
    column: $table.estimatedCaloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TrainingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingSessionsTable,
          TrainingSessionRow,
          $$TrainingSessionsTableFilterComposer,
          $$TrainingSessionsTableOrderingComposer,
          $$TrainingSessionsTableAnnotationComposer,
          $$TrainingSessionsTableCreateCompanionBuilder,
          $$TrainingSessionsTableUpdateCompanionBuilder,
          (
            TrainingSessionRow,
            BaseReferences<
              _$AppDatabase,
              $TrainingSessionsTable,
              TrainingSessionRow
            >,
          ),
          TrainingSessionRow,
          PrefetchHooks Function()
        > {
  $$TrainingSessionsTableTableManager(
    _$AppDatabase db,
    $TrainingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<TrainingType> type = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> rpe = const Value.absent(),
                Value<double> bodyWeightKg = const Value.absent(),
                Value<double> estimatedCaloriesBurned = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => TrainingSessionsCompanion(
                id: id,
                date: date,
                type: type,
                durationMinutes: durationMinutes,
                rpe: rpe,
                bodyWeightKg: bodyWeightKg,
                estimatedCaloriesBurned: estimatedCaloriesBurned,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required TrainingType type,
                required int durationMinutes,
                required int rpe,
                required double bodyWeightKg,
                required double estimatedCaloriesBurned,
                Value<String?> note = const Value.absent(),
              }) => TrainingSessionsCompanion.insert(
                id: id,
                date: date,
                type: type,
                durationMinutes: durationMinutes,
                rpe: rpe,
                bodyWeightKg: bodyWeightKg,
                estimatedCaloriesBurned: estimatedCaloriesBurned,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrainingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingSessionsTable,
      TrainingSessionRow,
      $$TrainingSessionsTableFilterComposer,
      $$TrainingSessionsTableOrderingComposer,
      $$TrainingSessionsTableAnnotationComposer,
      $$TrainingSessionsTableCreateCompanionBuilder,
      $$TrainingSessionsTableUpdateCompanionBuilder,
      (
        TrainingSessionRow,
        BaseReferences<
          _$AppDatabase,
          $TrainingSessionsTable,
          TrainingSessionRow
        >,
      ),
      TrainingSessionRow,
      PrefetchHooks Function()
    >;
typedef $$WeightLogsTableCreateCompanionBuilder =
    WeightLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required double weightKg,
      Value<String?> note,
    });
typedef $$WeightLogsTableUpdateCompanionBuilder =
    WeightLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> weightKg,
      Value<String?> note,
    });

class $$WeightLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WeightLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightLogsTable,
          WeightLogRow,
          $$WeightLogsTableFilterComposer,
          $$WeightLogsTableOrderingComposer,
          $$WeightLogsTableAnnotationComposer,
          $$WeightLogsTableCreateCompanionBuilder,
          $$WeightLogsTableUpdateCompanionBuilder,
          (
            WeightLogRow,
            BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLogRow>,
          ),
          WeightLogRow,
          PrefetchHooks Function()
        > {
  $$WeightLogsTableTableManager(_$AppDatabase db, $WeightLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => WeightLogsCompanion(
                id: id,
                date: date,
                weightKg: weightKg,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double weightKg,
                Value<String?> note = const Value.absent(),
              }) => WeightLogsCompanion.insert(
                id: id,
                date: date,
                weightKg: weightKg,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightLogsTable,
      WeightLogRow,
      $$WeightLogsTableFilterComposer,
      $$WeightLogsTableOrderingComposer,
      $$WeightLogsTableAnnotationComposer,
      $$WeightLogsTableCreateCompanionBuilder,
      $$WeightLogsTableUpdateCompanionBuilder,
      (
        WeightLogRow,
        BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLogRow>,
      ),
      WeightLogRow,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementLogsTableCreateCompanionBuilder =
    BodyMeasurementLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<double?> waistCm,
      Value<double?> chestCm,
      Value<double?> hipsCm,
      Value<double?> armCm,
      Value<double?> thighCm,
    });
typedef $$BodyMeasurementLogsTableUpdateCompanionBuilder =
    BodyMeasurementLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double?> waistCm,
      Value<double?> chestCm,
      Value<double?> hipsCm,
      Value<double?> armCm,
      Value<double?> thighCm,
    });

class $$BodyMeasurementLogsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementLogsTable> {
  $$BodyMeasurementLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thighCm => $composableBuilder(
    column: $table.thighCm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementLogsTable> {
  $$BodyMeasurementLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thighCm => $composableBuilder(
    column: $table.thighCm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementLogsTable> {
  $$BodyMeasurementLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get chestCm =>
      $composableBuilder(column: $table.chestCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<double> get armCm =>
      $composableBuilder(column: $table.armCm, builder: (column) => column);

  GeneratedColumn<double> get thighCm =>
      $composableBuilder(column: $table.thighCm, builder: (column) => column);
}

class $$BodyMeasurementLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementLogsTable,
          BodyMeasurementLogRow,
          $$BodyMeasurementLogsTableFilterComposer,
          $$BodyMeasurementLogsTableOrderingComposer,
          $$BodyMeasurementLogsTableAnnotationComposer,
          $$BodyMeasurementLogsTableCreateCompanionBuilder,
          $$BodyMeasurementLogsTableUpdateCompanionBuilder,
          (
            BodyMeasurementLogRow,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementLogsTable,
              BodyMeasurementLogRow
            >,
          ),
          BodyMeasurementLogRow,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementLogsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementLogsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BodyMeasurementLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> thighCm = const Value.absent(),
              }) => BodyMeasurementLogsCompanion(
                id: id,
                date: date,
                waistCm: waistCm,
                chestCm: chestCm,
                hipsCm: hipsCm,
                armCm: armCm,
                thighCm: thighCm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<double?> waistCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> thighCm = const Value.absent(),
              }) => BodyMeasurementLogsCompanion.insert(
                id: id,
                date: date,
                waistCm: waistCm,
                chestCm: chestCm,
                hipsCm: hipsCm,
                armCm: armCm,
                thighCm: thighCm,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementLogsTable,
      BodyMeasurementLogRow,
      $$BodyMeasurementLogsTableFilterComposer,
      $$BodyMeasurementLogsTableOrderingComposer,
      $$BodyMeasurementLogsTableAnnotationComposer,
      $$BodyMeasurementLogsTableCreateCompanionBuilder,
      $$BodyMeasurementLogsTableUpdateCompanionBuilder,
      (
        BodyMeasurementLogRow,
        BaseReferences<
          _$AppDatabase,
          $BodyMeasurementLogsTable,
          BodyMeasurementLogRow
        >,
      ),
      BodyMeasurementLogRow,
      PrefetchHooks Function()
    >;
typedef $$DayStatusesTableCreateCompanionBuilder =
    DayStatusesCompanion Function({
      Value<int> id,
      required DateTime date,
      required DayStatusType type,
    });
typedef $$DayStatusesTableUpdateCompanionBuilder =
    DayStatusesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<DayStatusType> type,
    });

class $$DayStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $DayStatusesTable> {
  $$DayStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DayStatusType, DayStatusType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$DayStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayStatusesTable> {
  $$DayStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayStatusesTable> {
  $$DayStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DayStatusType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$DayStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayStatusesTable,
          DayStatusRow,
          $$DayStatusesTableFilterComposer,
          $$DayStatusesTableOrderingComposer,
          $$DayStatusesTableAnnotationComposer,
          $$DayStatusesTableCreateCompanionBuilder,
          $$DayStatusesTableUpdateCompanionBuilder,
          (
            DayStatusRow,
            BaseReferences<_$AppDatabase, $DayStatusesTable, DayStatusRow>,
          ),
          DayStatusRow,
          PrefetchHooks Function()
        > {
  $$DayStatusesTableTableManager(_$AppDatabase db, $DayStatusesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayStatusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DayStatusType> type = const Value.absent(),
              }) => DayStatusesCompanion(id: id, date: date, type: type),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required DayStatusType type,
              }) => DayStatusesCompanion.insert(id: id, date: date, type: type),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayStatusesTable,
      DayStatusRow,
      $$DayStatusesTableFilterComposer,
      $$DayStatusesTableOrderingComposer,
      $$DayStatusesTableAnnotationComposer,
      $$DayStatusesTableCreateCompanionBuilder,
      $$DayStatusesTableUpdateCompanionBuilder,
      (
        DayStatusRow,
        BaseReferences<_$AppDatabase, $DayStatusesTable, DayStatusRow>,
      ),
      DayStatusRow,
      PrefetchHooks Function()
    >;
typedef $$DailyTargetSnapshotsTableCreateCompanionBuilder =
    DailyTargetSnapshotsCompanion Function({
      Value<int> id,
      required DateTime date,
      required GoalMode goalMode,
      required GoalPace goalPace,
      required double calories,
      required double proteinGrams,
      required double carbsGrams,
      required double fatGrams,
      required double fiberGrams,
      required double trainingCalories,
    });
typedef $$DailyTargetSnapshotsTableUpdateCompanionBuilder =
    DailyTargetSnapshotsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<GoalMode> goalMode,
      Value<GoalPace> goalPace,
      Value<double> calories,
      Value<double> proteinGrams,
      Value<double> carbsGrams,
      Value<double> fatGrams,
      Value<double> fiberGrams,
      Value<double> trainingCalories,
    });

class $$DailyTargetSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyTargetSnapshotsTable> {
  $$DailyTargetSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalMode, GoalMode, String> get goalMode =>
      $composableBuilder(
        column: $table.goalMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GoalPace, GoalPace, String> get goalPace =>
      $composableBuilder(
        column: $table.goalPace,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trainingCalories => $composableBuilder(
    column: $table.trainingCalories,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyTargetSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyTargetSnapshotsTable> {
  $$DailyTargetSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalMode => $composableBuilder(
    column: $table.goalMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalPace => $composableBuilder(
    column: $table.goalPace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trainingCalories => $composableBuilder(
    column: $table.trainingCalories,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyTargetSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyTargetSnapshotsTable> {
  $$DailyTargetSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalMode, String> get goalMode =>
      $composableBuilder(column: $table.goalMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalPace, String> get goalPace =>
      $composableBuilder(column: $table.goalPace, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get trainingCalories => $composableBuilder(
    column: $table.trainingCalories,
    builder: (column) => column,
  );
}

class $$DailyTargetSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyTargetSnapshotsTable,
          DailyTargetSnapshotRow,
          $$DailyTargetSnapshotsTableFilterComposer,
          $$DailyTargetSnapshotsTableOrderingComposer,
          $$DailyTargetSnapshotsTableAnnotationComposer,
          $$DailyTargetSnapshotsTableCreateCompanionBuilder,
          $$DailyTargetSnapshotsTableUpdateCompanionBuilder,
          (
            DailyTargetSnapshotRow,
            BaseReferences<
              _$AppDatabase,
              $DailyTargetSnapshotsTable,
              DailyTargetSnapshotRow
            >,
          ),
          DailyTargetSnapshotRow,
          PrefetchHooks Function()
        > {
  $$DailyTargetSnapshotsTableTableManager(
    _$AppDatabase db,
    $DailyTargetSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyTargetSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyTargetSnapshotsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyTargetSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<GoalMode> goalMode = const Value.absent(),
                Value<GoalPace> goalPace = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbsGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double> fiberGrams = const Value.absent(),
                Value<double> trainingCalories = const Value.absent(),
              }) => DailyTargetSnapshotsCompanion(
                id: id,
                date: date,
                goalMode: goalMode,
                goalPace: goalPace,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
                trainingCalories: trainingCalories,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required GoalMode goalMode,
                required GoalPace goalPace,
                required double calories,
                required double proteinGrams,
                required double carbsGrams,
                required double fatGrams,
                required double fiberGrams,
                required double trainingCalories,
              }) => DailyTargetSnapshotsCompanion.insert(
                id: id,
                date: date,
                goalMode: goalMode,
                goalPace: goalPace,
                calories: calories,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                fiberGrams: fiberGrams,
                trainingCalories: trainingCalories,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyTargetSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyTargetSnapshotsTable,
      DailyTargetSnapshotRow,
      $$DailyTargetSnapshotsTableFilterComposer,
      $$DailyTargetSnapshotsTableOrderingComposer,
      $$DailyTargetSnapshotsTableAnnotationComposer,
      $$DailyTargetSnapshotsTableCreateCompanionBuilder,
      $$DailyTargetSnapshotsTableUpdateCompanionBuilder,
      (
        DailyTargetSnapshotRow,
        BaseReferences<
          _$AppDatabase,
          $DailyTargetSnapshotsTable,
          DailyTargetSnapshotRow
        >,
      ),
      DailyTargetSnapshotRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$GoalPeriodsTableTableManager get goalPeriods =>
      $$GoalPeriodsTableTableManager(_db, _db.goalPeriods);
  $$FoodProductsTableTableManager get foodProducts =>
      $$FoodProductsTableTableManager(_db, _db.foodProducts);
  $$FoodLogEntriesTableTableManager get foodLogEntries =>
      $$FoodLogEntriesTableTableManager(_db, _db.foodLogEntries);
  $$FavoriteFoodsTableTableManager get favoriteFoods =>
      $$FavoriteFoodsTableTableManager(_db, _db.favoriteFoods);
  $$MealTemplatesTableTableManager get mealTemplates =>
      $$MealTemplatesTableTableManager(_db, _db.mealTemplates);
  $$TrainingSessionsTableTableManager get trainingSessions =>
      $$TrainingSessionsTableTableManager(_db, _db.trainingSessions);
  $$WeightLogsTableTableManager get weightLogs =>
      $$WeightLogsTableTableManager(_db, _db.weightLogs);
  $$BodyMeasurementLogsTableTableManager get bodyMeasurementLogs =>
      $$BodyMeasurementLogsTableTableManager(_db, _db.bodyMeasurementLogs);
  $$DayStatusesTableTableManager get dayStatuses =>
      $$DayStatusesTableTableManager(_db, _db.dayStatuses);
  $$DailyTargetSnapshotsTableTableManager get dailyTargetSnapshots =>
      $$DailyTargetSnapshotsTableTableManager(_db, _db.dailyTargetSnapshots);
}
