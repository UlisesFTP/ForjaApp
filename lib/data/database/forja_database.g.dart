// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forja_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Experience, String> experience =
      GeneratedColumn<String>(
        'experience',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Experience>($ProfilesTable.$converterexperience);
  @override
  late final GeneratedColumnWithTypeConverter<TrainingGoal, String> goal =
      GeneratedColumn<String>(
        'goal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TrainingGoal>($ProfilesTable.$convertergoal);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Energy, String> energy =
      GeneratedColumn<String>(
        'energy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Energy>($ProfilesTable.$converterenergy);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<String> lastReview = GeneratedColumn<String>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('barbell,dumbbell,machine,cable,bodyweight'),
  );
  static const VerificationMeta _trainingDaysMeta = const VerificationMeta(
    'trainingDays',
  );
  @override
  late final GeneratedColumn<String> trainingDays = GeneratedColumn<String>(
    'training_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('2,4,6'),
  );
  static const VerificationMeta _sessionMinutesMeta = const VerificationMeta(
    'sessionMinutes',
  );
  @override
  late final GeneratedColumn<int> sessionMinutes = GeneratedColumn<int>(
    'session_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _setupSkippedMeta = const VerificationMeta(
    'setupSkipped',
  );
  @override
  late final GeneratedColumn<bool> setupSkipped = GeneratedColumn<bool>(
    'setup_skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("setup_skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _setupStepMeta = const VerificationMeta(
    'setupStep',
  );
  @override
  late final GeneratedColumn<int> setupStep = GeneratedColumn<int>(
    'setup_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('kg'),
      ).withConverter<WeightUnit>($ProfilesTable.$converterweightUnit);
  static const VerificationMeta _reviewSnoozeUntilMeta = const VerificationMeta(
    'reviewSnoozeUntil',
  );
  @override
  late final GeneratedColumn<String> reviewSnoozeUntil =
      GeneratedColumn<String>(
        'review_snooze_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    experience,
    goal,
    weightKg,
    age,
    energy,
    note,
    onboarded,
    lastReview,
    equipment,
    trainingDays,
    sessionMinutes,
    setupSkipped,
    setupStep,
    weightUnit,
    reviewSnoozeUntil,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
    } else if (isInserting) {
      context.missing(_onboardedMeta);
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('training_days')) {
      context.handle(
        _trainingDaysMeta,
        trainingDays.isAcceptableOrUnknown(
          data['training_days']!,
          _trainingDaysMeta,
        ),
      );
    }
    if (data.containsKey('session_minutes')) {
      context.handle(
        _sessionMinutesMeta,
        sessionMinutes.isAcceptableOrUnknown(
          data['session_minutes']!,
          _sessionMinutesMeta,
        ),
      );
    }
    if (data.containsKey('setup_skipped')) {
      context.handle(
        _setupSkippedMeta,
        setupSkipped.isAcceptableOrUnknown(
          data['setup_skipped']!,
          _setupSkippedMeta,
        ),
      );
    }
    if (data.containsKey('setup_step')) {
      context.handle(
        _setupStepMeta,
        setupStep.isAcceptableOrUnknown(data['setup_step']!, _setupStepMeta),
      );
    }
    if (data.containsKey('review_snooze_until')) {
      context.handle(
        _reviewSnoozeUntilMeta,
        reviewSnoozeUntil.isAcceptableOrUnknown(
          data['review_snooze_until']!,
          _reviewSnoozeUntilMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      experience: $ProfilesTable.$converterexperience.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}experience'],
        )!,
      ),
      goal: $ProfilesTable.$convertergoal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      energy: $ProfilesTable.$converterenergy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}energy'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      onboarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarded'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_review'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      trainingDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_days'],
      )!,
      sessionMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_minutes'],
      )!,
      setupSkipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}setup_skipped'],
      )!,
      setupStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}setup_step'],
      )!,
      weightUnit: $ProfilesTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      reviewSnoozeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_snooze_until'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Experience, String, String> $converterexperience =
      const EnumNameConverter<Experience>(Experience.values);
  static JsonTypeConverter2<TrainingGoal, String, String> $convertergoal =
      const EnumNameConverter<TrainingGoal>(TrainingGoal.values);
  static JsonTypeConverter2<Energy, String, String> $converterenergy =
      const EnumNameConverter<Energy>(Energy.values);
  static JsonTypeConverter2<WeightUnit, String, String> $converterweightUnit =
      const EnumNameConverter<WeightUnit>(WeightUnit.values);
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final Experience experience;
  final TrainingGoal goal;
  final double? weightKg;
  final int? age;
  final Energy energy;
  final String note;
  final bool onboarded;
  final String? lastReview;
  final String equipment;
  final String trainingDays;
  final int sessionMinutes;
  final bool setupSkipped;
  final int setupStep;
  final WeightUnit weightUnit;
  final String? reviewSnoozeUntil;
  final DateTime updatedAt;
  const ProfileRow({
    required this.id,
    required this.experience,
    required this.goal,
    this.weightKg,
    this.age,
    required this.energy,
    required this.note,
    required this.onboarded,
    this.lastReview,
    required this.equipment,
    required this.trainingDays,
    required this.sessionMinutes,
    required this.setupSkipped,
    required this.setupStep,
    required this.weightUnit,
    this.reviewSnoozeUntil,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['experience'] = Variable<String>(
        $ProfilesTable.$converterexperience.toSql(experience),
      );
    }
    {
      map['goal'] = Variable<String>($ProfilesTable.$convertergoal.toSql(goal));
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    {
      map['energy'] = Variable<String>(
        $ProfilesTable.$converterenergy.toSql(energy),
      );
    }
    map['note'] = Variable<String>(note);
    map['onboarded'] = Variable<bool>(onboarded);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<String>(lastReview);
    }
    map['equipment'] = Variable<String>(equipment);
    map['training_days'] = Variable<String>(trainingDays);
    map['session_minutes'] = Variable<int>(sessionMinutes);
    map['setup_skipped'] = Variable<bool>(setupSkipped);
    map['setup_step'] = Variable<int>(setupStep);
    {
      map['weight_unit'] = Variable<String>(
        $ProfilesTable.$converterweightUnit.toSql(weightUnit),
      );
    }
    if (!nullToAbsent || reviewSnoozeUntil != null) {
      map['review_snooze_until'] = Variable<String>(reviewSnoozeUntil);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      experience: Value(experience),
      goal: Value(goal),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      energy: Value(energy),
      note: Value(note),
      onboarded: Value(onboarded),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
      equipment: Value(equipment),
      trainingDays: Value(trainingDays),
      sessionMinutes: Value(sessionMinutes),
      setupSkipped: Value(setupSkipped),
      setupStep: Value(setupStep),
      weightUnit: Value(weightUnit),
      reviewSnoozeUntil: reviewSnoozeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewSnoozeUntil),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      experience: $ProfilesTable.$converterexperience.fromJson(
        serializer.fromJson<String>(json['experience']),
      ),
      goal: $ProfilesTable.$convertergoal.fromJson(
        serializer.fromJson<String>(json['goal']),
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      age: serializer.fromJson<int?>(json['age']),
      energy: $ProfilesTable.$converterenergy.fromJson(
        serializer.fromJson<String>(json['energy']),
      ),
      note: serializer.fromJson<String>(json['note']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
      lastReview: serializer.fromJson<String?>(json['lastReview']),
      equipment: serializer.fromJson<String>(json['equipment']),
      trainingDays: serializer.fromJson<String>(json['trainingDays']),
      sessionMinutes: serializer.fromJson<int>(json['sessionMinutes']),
      setupSkipped: serializer.fromJson<bool>(json['setupSkipped']),
      setupStep: serializer.fromJson<int>(json['setupStep']),
      weightUnit: $ProfilesTable.$converterweightUnit.fromJson(
        serializer.fromJson<String>(json['weightUnit']),
      ),
      reviewSnoozeUntil: serializer.fromJson<String?>(
        json['reviewSnoozeUntil'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'experience': serializer.toJson<String>(
        $ProfilesTable.$converterexperience.toJson(experience),
      ),
      'goal': serializer.toJson<String>(
        $ProfilesTable.$convertergoal.toJson(goal),
      ),
      'weightKg': serializer.toJson<double?>(weightKg),
      'age': serializer.toJson<int?>(age),
      'energy': serializer.toJson<String>(
        $ProfilesTable.$converterenergy.toJson(energy),
      ),
      'note': serializer.toJson<String>(note),
      'onboarded': serializer.toJson<bool>(onboarded),
      'lastReview': serializer.toJson<String?>(lastReview),
      'equipment': serializer.toJson<String>(equipment),
      'trainingDays': serializer.toJson<String>(trainingDays),
      'sessionMinutes': serializer.toJson<int>(sessionMinutes),
      'setupSkipped': serializer.toJson<bool>(setupSkipped),
      'setupStep': serializer.toJson<int>(setupStep),
      'weightUnit': serializer.toJson<String>(
        $ProfilesTable.$converterweightUnit.toJson(weightUnit),
      ),
      'reviewSnoozeUntil': serializer.toJson<String?>(reviewSnoozeUntil),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileRow copyWith({
    int? id,
    Experience? experience,
    TrainingGoal? goal,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> age = const Value.absent(),
    Energy? energy,
    String? note,
    bool? onboarded,
    Value<String?> lastReview = const Value.absent(),
    String? equipment,
    String? trainingDays,
    int? sessionMinutes,
    bool? setupSkipped,
    int? setupStep,
    WeightUnit? weightUnit,
    Value<String?> reviewSnoozeUntil = const Value.absent(),
    DateTime? updatedAt,
  }) => ProfileRow(
    id: id ?? this.id,
    experience: experience ?? this.experience,
    goal: goal ?? this.goal,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    age: age.present ? age.value : this.age,
    energy: energy ?? this.energy,
    note: note ?? this.note,
    onboarded: onboarded ?? this.onboarded,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
    equipment: equipment ?? this.equipment,
    trainingDays: trainingDays ?? this.trainingDays,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    setupSkipped: setupSkipped ?? this.setupSkipped,
    setupStep: setupStep ?? this.setupStep,
    weightUnit: weightUnit ?? this.weightUnit,
    reviewSnoozeUntil: reviewSnoozeUntil.present
        ? reviewSnoozeUntil.value
        : this.reviewSnoozeUntil,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      experience: data.experience.present
          ? data.experience.value
          : this.experience,
      goal: data.goal.present ? data.goal.value : this.goal,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      age: data.age.present ? data.age.value : this.age,
      energy: data.energy.present ? data.energy.value : this.energy,
      note: data.note.present ? data.note.value : this.note,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      trainingDays: data.trainingDays.present
          ? data.trainingDays.value
          : this.trainingDays,
      sessionMinutes: data.sessionMinutes.present
          ? data.sessionMinutes.value
          : this.sessionMinutes,
      setupSkipped: data.setupSkipped.present
          ? data.setupSkipped.value
          : this.setupSkipped,
      setupStep: data.setupStep.present ? data.setupStep.value : this.setupStep,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      reviewSnoozeUntil: data.reviewSnoozeUntil.present
          ? data.reviewSnoozeUntil.value
          : this.reviewSnoozeUntil,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('experience: $experience, ')
          ..write('goal: $goal, ')
          ..write('weightKg: $weightKg, ')
          ..write('age: $age, ')
          ..write('energy: $energy, ')
          ..write('note: $note, ')
          ..write('onboarded: $onboarded, ')
          ..write('lastReview: $lastReview, ')
          ..write('equipment: $equipment, ')
          ..write('trainingDays: $trainingDays, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('setupSkipped: $setupSkipped, ')
          ..write('setupStep: $setupStep, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('reviewSnoozeUntil: $reviewSnoozeUntil, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    experience,
    goal,
    weightKg,
    age,
    energy,
    note,
    onboarded,
    lastReview,
    equipment,
    trainingDays,
    sessionMinutes,
    setupSkipped,
    setupStep,
    weightUnit,
    reviewSnoozeUntil,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.experience == this.experience &&
          other.goal == this.goal &&
          other.weightKg == this.weightKg &&
          other.age == this.age &&
          other.energy == this.energy &&
          other.note == this.note &&
          other.onboarded == this.onboarded &&
          other.lastReview == this.lastReview &&
          other.equipment == this.equipment &&
          other.trainingDays == this.trainingDays &&
          other.sessionMinutes == this.sessionMinutes &&
          other.setupSkipped == this.setupSkipped &&
          other.setupStep == this.setupStep &&
          other.weightUnit == this.weightUnit &&
          other.reviewSnoozeUntil == this.reviewSnoozeUntil &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<Experience> experience;
  final Value<TrainingGoal> goal;
  final Value<double?> weightKg;
  final Value<int?> age;
  final Value<Energy> energy;
  final Value<String> note;
  final Value<bool> onboarded;
  final Value<String?> lastReview;
  final Value<String> equipment;
  final Value<String> trainingDays;
  final Value<int> sessionMinutes;
  final Value<bool> setupSkipped;
  final Value<int> setupStep;
  final Value<WeightUnit> weightUnit;
  final Value<String?> reviewSnoozeUntil;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.experience = const Value.absent(),
    this.goal = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.age = const Value.absent(),
    this.energy = const Value.absent(),
    this.note = const Value.absent(),
    this.onboarded = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.equipment = const Value.absent(),
    this.trainingDays = const Value.absent(),
    this.sessionMinutes = const Value.absent(),
    this.setupSkipped = const Value.absent(),
    this.setupStep = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.reviewSnoozeUntil = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required Experience experience,
    required TrainingGoal goal,
    this.weightKg = const Value.absent(),
    this.age = const Value.absent(),
    required Energy energy,
    required String note,
    required bool onboarded,
    this.lastReview = const Value.absent(),
    this.equipment = const Value.absent(),
    this.trainingDays = const Value.absent(),
    this.sessionMinutes = const Value.absent(),
    this.setupSkipped = const Value.absent(),
    this.setupStep = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.reviewSnoozeUntil = const Value.absent(),
    required DateTime updatedAt,
  }) : experience = Value(experience),
       goal = Value(goal),
       energy = Value(energy),
       note = Value(note),
       onboarded = Value(onboarded),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? experience,
    Expression<String>? goal,
    Expression<double>? weightKg,
    Expression<int>? age,
    Expression<String>? energy,
    Expression<String>? note,
    Expression<bool>? onboarded,
    Expression<String>? lastReview,
    Expression<String>? equipment,
    Expression<String>? trainingDays,
    Expression<int>? sessionMinutes,
    Expression<bool>? setupSkipped,
    Expression<int>? setupStep,
    Expression<String>? weightUnit,
    Expression<String>? reviewSnoozeUntil,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (experience != null) 'experience': experience,
      if (goal != null) 'goal': goal,
      if (weightKg != null) 'weight_kg': weightKg,
      if (age != null) 'age': age,
      if (energy != null) 'energy': energy,
      if (note != null) 'note': note,
      if (onboarded != null) 'onboarded': onboarded,
      if (lastReview != null) 'last_review': lastReview,
      if (equipment != null) 'equipment': equipment,
      if (trainingDays != null) 'training_days': trainingDays,
      if (sessionMinutes != null) 'session_minutes': sessionMinutes,
      if (setupSkipped != null) 'setup_skipped': setupSkipped,
      if (setupStep != null) 'setup_step': setupStep,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (reviewSnoozeUntil != null) 'review_snooze_until': reviewSnoozeUntil,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<Experience>? experience,
    Value<TrainingGoal>? goal,
    Value<double?>? weightKg,
    Value<int?>? age,
    Value<Energy>? energy,
    Value<String>? note,
    Value<bool>? onboarded,
    Value<String?>? lastReview,
    Value<String>? equipment,
    Value<String>? trainingDays,
    Value<int>? sessionMinutes,
    Value<bool>? setupSkipped,
    Value<int>? setupStep,
    Value<WeightUnit>? weightUnit,
    Value<String?>? reviewSnoozeUntil,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      experience: experience ?? this.experience,
      goal: goal ?? this.goal,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      energy: energy ?? this.energy,
      note: note ?? this.note,
      onboarded: onboarded ?? this.onboarded,
      lastReview: lastReview ?? this.lastReview,
      equipment: equipment ?? this.equipment,
      trainingDays: trainingDays ?? this.trainingDays,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      setupSkipped: setupSkipped ?? this.setupSkipped,
      setupStep: setupStep ?? this.setupStep,
      weightUnit: weightUnit ?? this.weightUnit,
      reviewSnoozeUntil: reviewSnoozeUntil ?? this.reviewSnoozeUntil,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (experience.present) {
      map['experience'] = Variable<String>(
        $ProfilesTable.$converterexperience.toSql(experience.value),
      );
    }
    if (goal.present) {
      map['goal'] = Variable<String>(
        $ProfilesTable.$convertergoal.toSql(goal.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (energy.present) {
      map['energy'] = Variable<String>(
        $ProfilesTable.$converterenergy.toSql(energy.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<String>(lastReview.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (trainingDays.present) {
      map['training_days'] = Variable<String>(trainingDays.value);
    }
    if (sessionMinutes.present) {
      map['session_minutes'] = Variable<int>(sessionMinutes.value);
    }
    if (setupSkipped.present) {
      map['setup_skipped'] = Variable<bool>(setupSkipped.value);
    }
    if (setupStep.present) {
      map['setup_step'] = Variable<int>(setupStep.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $ProfilesTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (reviewSnoozeUntil.present) {
      map['review_snooze_until'] = Variable<String>(reviewSnoozeUntil.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('experience: $experience, ')
          ..write('goal: $goal, ')
          ..write('weightKg: $weightKg, ')
          ..write('age: $age, ')
          ..write('energy: $energy, ')
          ..write('note: $note, ')
          ..write('onboarded: $onboarded, ')
          ..write('lastReview: $lastReview, ')
          ..write('equipment: $equipment, ')
          ..write('trainingDays: $trainingDays, ')
          ..write('sessionMinutes: $sessionMinutes, ')
          ..write('setupSkipped: $setupSkipped, ')
          ..write('setupStep: $setupStep, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('reviewSnoozeUntil: $reviewSnoozeUntil, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProfileHistoryTable extends ProfileHistory
    with TableInfo<$ProfileHistoryTable, ProfileHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProfileChange, String> reason =
      GeneratedColumn<String>(
        'reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProfileChange>($ProfileHistoryTable.$converterreason);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesVersionMeta = const VerificationMeta(
    'rulesVersion',
  );
  @override
  late final GeneratedColumn<String> rulesVersion = GeneratedColumn<String>(
    'rules_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    recordedAt,
    reason,
    payload,
    rulesVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('rules_version')) {
      context.handle(
        _rulesVersionMeta,
        rulesVersion.isAcceptableOrUnknown(
          data['rules_version']!,
          _rulesVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      reason: $ProfileHistoryTable.$converterreason.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reason'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      rulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules_version'],
      ),
    );
  }

  @override
  $ProfileHistoryTable createAlias(String alias) {
    return $ProfileHistoryTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProfileChange, String, String> $converterreason =
      const EnumNameConverter<ProfileChange>(ProfileChange.values);
}

class ProfileHistoryRow extends DataClass
    implements Insertable<ProfileHistoryRow> {
  final String id;
  final int seq;
  final DateTime recordedAt;
  final ProfileChange reason;
  final String payload;
  final String? rulesVersion;
  const ProfileHistoryRow({
    required this.id,
    required this.seq,
    required this.recordedAt,
    required this.reason,
    required this.payload,
    this.rulesVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    {
      map['reason'] = Variable<String>(
        $ProfileHistoryTable.$converterreason.toSql(reason),
      );
    }
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || rulesVersion != null) {
      map['rules_version'] = Variable<String>(rulesVersion);
    }
    return map;
  }

  ProfileHistoryCompanion toCompanion(bool nullToAbsent) {
    return ProfileHistoryCompanion(
      id: Value(id),
      seq: Value(seq),
      recordedAt: Value(recordedAt),
      reason: Value(reason),
      payload: Value(payload),
      rulesVersion: rulesVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(rulesVersion),
    );
  }

  factory ProfileHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      reason: $ProfileHistoryTable.$converterreason.fromJson(
        serializer.fromJson<String>(json['reason']),
      ),
      payload: serializer.fromJson<String>(json['payload']),
      rulesVersion: serializer.fromJson<String?>(json['rulesVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'reason': serializer.toJson<String>(
        $ProfileHistoryTable.$converterreason.toJson(reason),
      ),
      'payload': serializer.toJson<String>(payload),
      'rulesVersion': serializer.toJson<String?>(rulesVersion),
    };
  }

  ProfileHistoryRow copyWith({
    String? id,
    int? seq,
    DateTime? recordedAt,
    ProfileChange? reason,
    String? payload,
    Value<String?> rulesVersion = const Value.absent(),
  }) => ProfileHistoryRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    recordedAt: recordedAt ?? this.recordedAt,
    reason: reason ?? this.reason,
    payload: payload ?? this.payload,
    rulesVersion: rulesVersion.present ? rulesVersion.value : this.rulesVersion,
  );
  ProfileHistoryRow copyWithCompanion(ProfileHistoryCompanion data) {
    return ProfileHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      payload: data.payload.present ? data.payload.value : this.payload,
      rulesVersion: data.rulesVersion.present
          ? data.rulesVersion.value
          : this.rulesVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileHistoryRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('reason: $reason, ')
          ..write('payload: $payload, ')
          ..write('rulesVersion: $rulesVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, seq, recordedAt, reason, payload, rulesVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileHistoryRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.recordedAt == this.recordedAt &&
          other.reason == this.reason &&
          other.payload == this.payload &&
          other.rulesVersion == this.rulesVersion);
}

class ProfileHistoryCompanion extends UpdateCompanion<ProfileHistoryRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<DateTime> recordedAt;
  final Value<ProfileChange> reason;
  final Value<String> payload;
  final Value<String?> rulesVersion;
  final Value<int> rowid;
  const ProfileHistoryCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.payload = const Value.absent(),
    this.rulesVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileHistoryCompanion.insert({
    required String id,
    required int seq,
    required DateTime recordedAt,
    required ProfileChange reason,
    required String payload,
    this.rulesVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       recordedAt = Value(recordedAt),
       reason = Value(reason),
       payload = Value(payload);
  static Insertable<ProfileHistoryRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<DateTime>? recordedAt,
    Expression<String>? reason,
    Expression<String>? payload,
    Expression<String>? rulesVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (reason != null) 'reason': reason,
      if (payload != null) 'payload': payload,
      if (rulesVersion != null) 'rules_version': rulesVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileHistoryCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<DateTime>? recordedAt,
    Value<ProfileChange>? reason,
    Value<String>? payload,
    Value<String?>? rulesVersion,
    Value<int>? rowid,
  }) {
    return ProfileHistoryCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      recordedAt: recordedAt ?? this.recordedAt,
      reason: reason ?? this.reason,
      payload: payload ?? this.payload,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(
        $ProfileHistoryTable.$converterreason.toSql(reason.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rulesVersion.present) {
      map['rules_version'] = Variable<String>(rulesVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileHistoryCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('reason: $reason, ')
          ..write('payload: $payload, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    check: () => ComparableExpr(hour).isBetweenValues(0, 23),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    check: () => ComparableExpr(minute).isBetweenValues(0, 59),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, enabled, hour, minute, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final bool enabled;
  final int hour;
  final int minute;
  final DateTime updatedAt;
  const ReminderRow({
    required this.id,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      enabled: Value(enabled),
      hour: Value(hour),
      minute: Value(minute),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReminderRow copyWith({
    int? id,
    bool? enabled,
    int? hour,
    int? minute,
    DateTime? updatedAt,
  }) => ReminderRow(
    id: id ?? this.id,
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, enabled, hour, minute, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.updatedAt == this.updatedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<bool> enabled;
  final Value<int> hour;
  final Value<int> minute;
  final Value<DateTime> updatedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required bool enabled,
    required int hour,
    required int minute,
    required DateTime updatedAt,
  }) : enabled = Value(enabled),
       hour = Value(hour),
       minute = Value(minute),
       updatedAt = Value(updatedAt);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<bool>? enabled,
    Value<int>? hour,
    Value<int>? minute,
    Value<DateTime>? updatedAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($WorkoutSessionsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<Feeling?, String> feeling =
      GeneratedColumn<String>(
        'feeling',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Feeling?>($WorkoutSessionsTable.$converterfeelingn);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionOrigin>($WorkoutSessionsTable.$converterorigin);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dateKey,
    routineId,
    status,
    feeling,
    note,
    origin,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      status: $WorkoutSessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      feeling: $WorkoutSessionsTable.$converterfeelingn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feeling'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      origin: $WorkoutSessionsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
  static JsonTypeConverter2<Feeling, String, String> $converterfeeling =
      const EnumNameConverter<Feeling>(Feeling.values);
  static JsonTypeConverter2<Feeling?, String?, String?> $converterfeelingn =
      JsonTypeConverter2.asNullable($converterfeeling);
  static JsonTypeConverter2<SessionOrigin, String, String> $converterorigin =
      const EnumNameConverter<SessionOrigin>(SessionOrigin.values);
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String dateKey;
  final String routineId;
  final SessionStatus status;
  final Feeling? feeling;
  final String note;
  final SessionOrigin origin;
  final DateTime? createdAt;
  final DateTime updatedAt;
  const SessionRow({
    required this.id,
    required this.dateKey,
    required this.routineId,
    required this.status,
    this.feeling,
    required this.note,
    required this.origin,
    this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_key'] = Variable<String>(dateKey);
    map['routine_id'] = Variable<String>(routineId);
    {
      map['status'] = Variable<String>(
        $WorkoutSessionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || feeling != null) {
      map['feeling'] = Variable<String>(
        $WorkoutSessionsTable.$converterfeelingn.toSql(feeling),
      );
    }
    map['note'] = Variable<String>(note);
    {
      map['origin'] = Variable<String>(
        $WorkoutSessionsTable.$converterorigin.toSql(origin),
      );
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      dateKey: Value(dateKey),
      routineId: Value(routineId),
      status: Value(status),
      feeling: feeling == null && nullToAbsent
          ? const Value.absent()
          : Value(feeling),
      note: Value(note),
      origin: Value(origin),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      routineId: serializer.fromJson<String>(json['routineId']),
      status: $WorkoutSessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      feeling: $WorkoutSessionsTable.$converterfeelingn.fromJson(
        serializer.fromJson<String?>(json['feeling']),
      ),
      note: serializer.fromJson<String>(json['note']),
      origin: $WorkoutSessionsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateKey': serializer.toJson<String>(dateKey),
      'routineId': serializer.toJson<String>(routineId),
      'status': serializer.toJson<String>(
        $WorkoutSessionsTable.$converterstatus.toJson(status),
      ),
      'feeling': serializer.toJson<String?>(
        $WorkoutSessionsTable.$converterfeelingn.toJson(feeling),
      ),
      'note': serializer.toJson<String>(note),
      'origin': serializer.toJson<String>(
        $WorkoutSessionsTable.$converterorigin.toJson(origin),
      ),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? dateKey,
    String? routineId,
    SessionStatus? status,
    Value<Feeling?> feeling = const Value.absent(),
    String? note,
    SessionOrigin? origin,
    Value<DateTime?> createdAt = const Value.absent(),
    DateTime? updatedAt,
  }) => SessionRow(
    id: id ?? this.id,
    dateKey: dateKey ?? this.dateKey,
    routineId: routineId ?? this.routineId,
    status: status ?? this.status,
    feeling: feeling.present ? feeling.value : this.feeling,
    note: note ?? this.note,
    origin: origin ?? this.origin,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      status: data.status.present ? data.status.value : this.status,
      feeling: data.feeling.present ? data.feeling.value : this.feeling,
      note: data.note.present ? data.note.value : this.note,
      origin: data.origin.present ? data.origin.value : this.origin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('routineId: $routineId, ')
          ..write('status: $status, ')
          ..write('feeling: $feeling, ')
          ..write('note: $note, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dateKey,
    routineId,
    status,
    feeling,
    note,
    origin,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.dateKey == this.dateKey &&
          other.routineId == this.routineId &&
          other.status == this.status &&
          other.feeling == this.feeling &&
          other.note == this.note &&
          other.origin == this.origin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkoutSessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> dateKey;
  final Value<String> routineId;
  final Value<SessionStatus> status;
  final Value<Feeling?> feeling;
  final Value<String> note;
  final Value<SessionOrigin> origin;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.routineId = const Value.absent(),
    this.status = const Value.absent(),
    this.feeling = const Value.absent(),
    this.note = const Value.absent(),
    this.origin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required String dateKey,
    required String routineId,
    required SessionStatus status,
    this.feeling = const Value.absent(),
    required String note,
    required SessionOrigin origin,
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dateKey = Value(dateKey),
       routineId = Value(routineId),
       status = Value(status),
       note = Value(note),
       origin = Value(origin),
       updatedAt = Value(updatedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? dateKey,
    Expression<String>? routineId,
    Expression<String>? status,
    Expression<String>? feeling,
    Expression<String>? note,
    Expression<String>? origin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateKey != null) 'date_key': dateKey,
      if (routineId != null) 'routine_id': routineId,
      if (status != null) 'status': status,
      if (feeling != null) 'feeling': feeling,
      if (note != null) 'note': note,
      if (origin != null) 'origin': origin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? dateKey,
    Value<String>? routineId,
    Value<SessionStatus>? status,
    Value<Feeling?>? feeling,
    Value<String>? note,
    Value<SessionOrigin>? origin,
    Value<DateTime?>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      routineId: routineId ?? this.routineId,
      status: status ?? this.status,
      feeling: feeling ?? this.feeling,
      note: note ?? this.note,
      origin: origin ?? this.origin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $WorkoutSessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (feeling.present) {
      map['feeling'] = Variable<String>(
        $WorkoutSessionsTable.$converterfeelingn.toSql(feeling.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $WorkoutSessionsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('routineId: $routineId, ')
          ..write('status: $status, ')
          ..write('feeling: $feeling, ')
          ..write('note: $note, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
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
    check: () => ComparableExpr(weightKg).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _skipReasonMeta = const VerificationMeta(
    'skipReason',
  );
  @override
  late final GeneratedColumn<String> skipReason = GeneratedColumn<String>(
    'skip_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TechniqueRating?, String>
  technique =
      GeneratedColumn<String>(
        'technique',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TechniqueRating?>(
        $SessionExercisesTable.$convertertechniquen,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    exerciseId,
    position,
    weightKg,
    completed,
    skipped,
    skipReason,
    technique,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('skip_reason')) {
      context.handle(
        _skipReasonMeta,
        skipReason.isAcceptableOrUnknown(data['skip_reason']!, _skipReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, exerciseId};
  @override
  SessionExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
      skipReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_reason'],
      ),
      technique: $SessionExercisesTable.$convertertechniquen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}technique'],
        ),
      ),
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TechniqueRating, String, String>
  $convertertechnique = const EnumNameConverter<TechniqueRating>(
    TechniqueRating.values,
  );
  static JsonTypeConverter2<TechniqueRating?, String?, String?>
  $convertertechniquen = JsonTypeConverter2.asNullable($convertertechnique);
}

class SessionExerciseRow extends DataClass
    implements Insertable<SessionExerciseRow> {
  final String sessionId;
  final String exerciseId;
  final int position;
  final double weightKg;
  final bool completed;
  final bool skipped;
  final String? skipReason;
  final TechniqueRating? technique;
  const SessionExerciseRow({
    required this.sessionId,
    required this.exerciseId,
    required this.position,
    required this.weightKg,
    required this.completed,
    required this.skipped,
    this.skipReason,
    this.technique,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    map['weight_kg'] = Variable<double>(weightKg);
    map['completed'] = Variable<bool>(completed);
    map['skipped'] = Variable<bool>(skipped);
    if (!nullToAbsent || skipReason != null) {
      map['skip_reason'] = Variable<String>(skipReason);
    }
    if (!nullToAbsent || technique != null) {
      map['technique'] = Variable<String>(
        $SessionExercisesTable.$convertertechniquen.toSql(technique),
      );
    }
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      weightKg: Value(weightKg),
      completed: Value(completed),
      skipped: Value(skipped),
      skipReason: skipReason == null && nullToAbsent
          ? const Value.absent()
          : Value(skipReason),
      technique: technique == null && nullToAbsent
          ? const Value.absent()
          : Value(technique),
    );
  }

  factory SessionExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      completed: serializer.fromJson<bool>(json['completed']),
      skipped: serializer.fromJson<bool>(json['skipped']),
      skipReason: serializer.fromJson<String?>(json['skipReason']),
      technique: $SessionExercisesTable.$convertertechniquen.fromJson(
        serializer.fromJson<String?>(json['technique']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'weightKg': serializer.toJson<double>(weightKg),
      'completed': serializer.toJson<bool>(completed),
      'skipped': serializer.toJson<bool>(skipped),
      'skipReason': serializer.toJson<String?>(skipReason),
      'technique': serializer.toJson<String?>(
        $SessionExercisesTable.$convertertechniquen.toJson(technique),
      ),
    };
  }

  SessionExerciseRow copyWith({
    String? sessionId,
    String? exerciseId,
    int? position,
    double? weightKg,
    bool? completed,
    bool? skipped,
    Value<String?> skipReason = const Value.absent(),
    Value<TechniqueRating?> technique = const Value.absent(),
  }) => SessionExerciseRow(
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    weightKg: weightKg ?? this.weightKg,
    completed: completed ?? this.completed,
    skipped: skipped ?? this.skipped,
    skipReason: skipReason.present ? skipReason.value : this.skipReason,
    technique: technique.present ? technique.value : this.technique,
  );
  SessionExerciseRow copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExerciseRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      completed: data.completed.present ? data.completed.value : this.completed,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      skipReason: data.skipReason.present
          ? data.skipReason.value
          : this.skipReason,
      technique: data.technique.present ? data.technique.value : this.technique,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseRow(')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('weightKg: $weightKg, ')
          ..write('completed: $completed, ')
          ..write('skipped: $skipped, ')
          ..write('skipReason: $skipReason, ')
          ..write('technique: $technique')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    exerciseId,
    position,
    weightKg,
    completed,
    skipped,
    skipReason,
    technique,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseRow &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.weightKg == this.weightKg &&
          other.completed == this.completed &&
          other.skipped == this.skipped &&
          other.skipReason == this.skipReason &&
          other.technique == this.technique);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExerciseRow> {
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<double> weightKg;
  final Value<bool> completed;
  final Value<bool> skipped;
  final Value<String?> skipReason;
  final Value<TechniqueRating?> technique;
  final Value<int> rowid;
  const SessionExercisesCompanion({
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.completed = const Value.absent(),
    this.skipped = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.technique = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    required String sessionId,
    required String exerciseId,
    required int position,
    required double weightKg,
    required bool completed,
    this.skipped = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.technique = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       position = Value(position),
       weightKg = Value(weightKg),
       completed = Value(completed);
  static Insertable<SessionExerciseRow> custom({
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<double>? weightKg,
    Expression<bool>? completed,
    Expression<bool>? skipped,
    Expression<String>? skipReason,
    Expression<String>? technique,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (weightKg != null) 'weight_kg': weightKg,
      if (completed != null) 'completed': completed,
      if (skipped != null) 'skipped': skipped,
      if (skipReason != null) 'skip_reason': skipReason,
      if (technique != null) 'technique': technique,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<double>? weightKg,
    Value<bool>? completed,
    Value<bool>? skipped,
    Value<String?>? skipReason,
    Value<TechniqueRating?>? technique,
    Value<int>? rowid,
  }) {
    return SessionExercisesCompanion(
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      weightKg: weightKg ?? this.weightKg,
      completed: completed ?? this.completed,
      skipped: skipped ?? this.skipped,
      skipReason: skipReason ?? this.skipReason,
      technique: technique ?? this.technique,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    if (skipReason.present) {
      map['skip_reason'] = Variable<String>(skipReason.value);
    }
    if (technique.present) {
      map['technique'] = Variable<String>(
        $SessionExercisesTable.$convertertechniquen.toSql(technique.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('weightKg: $weightKg, ')
          ..write('completed: $completed, ')
          ..write('skipped: $skipped, ')
          ..write('skipReason: $skipReason, ')
          ..write('technique: $technique, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarOverridesTable extends CalendarOverrides
    with TableInfo<$CalendarOverridesTable, OverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dateKey, routineId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<OverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey};
  @override
  OverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverrideRow(
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CalendarOverridesTable createAlias(String alias) {
    return $CalendarOverridesTable(attachedDatabase, alias);
  }
}

class OverrideRow extends DataClass implements Insertable<OverrideRow> {
  final String dateKey;
  final String? routineId;
  final DateTime updatedAt;
  const OverrideRow({
    required this.dateKey,
    this.routineId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    if (!nullToAbsent || routineId != null) {
      map['routine_id'] = Variable<String>(routineId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CalendarOverridesCompanion toCompanion(bool nullToAbsent) {
    return CalendarOverridesCompanion(
      dateKey: Value(dateKey),
      routineId: routineId == null && nullToAbsent
          ? const Value.absent()
          : Value(routineId),
      updatedAt: Value(updatedAt),
    );
  }

  factory OverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverrideRow(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      routineId: serializer.fromJson<String?>(json['routineId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'routineId': serializer.toJson<String?>(routineId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OverrideRow copyWith({
    String? dateKey,
    Value<String?> routineId = const Value.absent(),
    DateTime? updatedAt,
  }) => OverrideRow(
    dateKey: dateKey ?? this.dateKey,
    routineId: routineId.present ? routineId.value : this.routineId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OverrideRow copyWithCompanion(CalendarOverridesCompanion data) {
    return OverrideRow(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverrideRow(')
          ..write('dateKey: $dateKey, ')
          ..write('routineId: $routineId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateKey, routineId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OverrideRow &&
          other.dateKey == this.dateKey &&
          other.routineId == this.routineId &&
          other.updatedAt == this.updatedAt);
}

class CalendarOverridesCompanion extends UpdateCompanion<OverrideRow> {
  final Value<String> dateKey;
  final Value<String?> routineId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CalendarOverridesCompanion({
    this.dateKey = const Value.absent(),
    this.routineId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarOverridesCompanion.insert({
    required String dateKey,
    this.routineId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : dateKey = Value(dateKey),
       updatedAt = Value(updatedAt);
  static Insertable<OverrideRow> custom({
    Expression<String>? dateKey,
    Expression<String>? routineId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (routineId != null) 'routine_id': routineId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarOverridesCompanion copyWith({
    Value<String>? dateKey,
    Value<String?>? routineId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CalendarOverridesCompanion(
      dateKey: dateKey ?? this.dateKey,
      routineId: routineId ?? this.routineId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarOverridesCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('routineId: $routineId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CheckInsTable extends CheckIns
    with TableInfo<$CheckInsTable, CheckInRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckInsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CheckInPhase, String> phase =
      GeneratedColumn<String>(
        'phase',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('before'),
      ).withConverter<CheckInPhase>($CheckInsTable.$converterphase);
  @override
  late final GeneratedColumnWithTypeConverter<Feeling, String> feeling =
      GeneratedColumn<String>(
        'feeling',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Feeling>($CheckInsTable.$converterfeeling);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dateKey,
    phase,
    feeling,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'check_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckInRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dateKey, phase},
  ];
  @override
  CheckInRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckInRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      phase: $CheckInsTable.$converterphase.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}phase'],
        )!,
      ),
      feeling: $CheckInsTable.$converterfeeling.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feeling'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CheckInsTable createAlias(String alias) {
    return $CheckInsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CheckInPhase, String, String> $converterphase =
      const EnumNameConverter<CheckInPhase>(CheckInPhase.values);
  static JsonTypeConverter2<Feeling, String, String> $converterfeeling =
      const EnumNameConverter<Feeling>(Feeling.values);
}

class CheckInRow extends DataClass implements Insertable<CheckInRow> {
  final String id;
  final String dateKey;
  final CheckInPhase phase;
  final Feeling feeling;
  final String note;
  final DateTime? createdAt;
  final DateTime updatedAt;
  const CheckInRow({
    required this.id,
    required this.dateKey,
    required this.phase,
    required this.feeling,
    required this.note,
    this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_key'] = Variable<String>(dateKey);
    {
      map['phase'] = Variable<String>(
        $CheckInsTable.$converterphase.toSql(phase),
      );
    }
    {
      map['feeling'] = Variable<String>(
        $CheckInsTable.$converterfeeling.toSql(feeling),
      );
    }
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CheckInsCompanion toCompanion(bool nullToAbsent) {
    return CheckInsCompanion(
      id: Value(id),
      dateKey: Value(dateKey),
      phase: Value(phase),
      feeling: Value(feeling),
      note: Value(note),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CheckInRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckInRow(
      id: serializer.fromJson<String>(json['id']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      phase: $CheckInsTable.$converterphase.fromJson(
        serializer.fromJson<String>(json['phase']),
      ),
      feeling: $CheckInsTable.$converterfeeling.fromJson(
        serializer.fromJson<String>(json['feeling']),
      ),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateKey': serializer.toJson<String>(dateKey),
      'phase': serializer.toJson<String>(
        $CheckInsTable.$converterphase.toJson(phase),
      ),
      'feeling': serializer.toJson<String>(
        $CheckInsTable.$converterfeeling.toJson(feeling),
      ),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CheckInRow copyWith({
    String? id,
    String? dateKey,
    CheckInPhase? phase,
    Feeling? feeling,
    String? note,
    Value<DateTime?> createdAt = const Value.absent(),
    DateTime? updatedAt,
  }) => CheckInRow(
    id: id ?? this.id,
    dateKey: dateKey ?? this.dateKey,
    phase: phase ?? this.phase,
    feeling: feeling ?? this.feeling,
    note: note ?? this.note,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CheckInRow copyWithCompanion(CheckInsCompanion data) {
    return CheckInRow(
      id: data.id.present ? data.id.value : this.id,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      phase: data.phase.present ? data.phase.value : this.phase,
      feeling: data.feeling.present ? data.feeling.value : this.feeling,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRow(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('phase: $phase, ')
          ..write('feeling: $feeling, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dateKey, phase, feeling, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckInRow &&
          other.id == this.id &&
          other.dateKey == this.dateKey &&
          other.phase == this.phase &&
          other.feeling == this.feeling &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CheckInsCompanion extends UpdateCompanion<CheckInRow> {
  final Value<String> id;
  final Value<String> dateKey;
  final Value<CheckInPhase> phase;
  final Value<Feeling> feeling;
  final Value<String> note;
  final Value<DateTime?> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CheckInsCompanion({
    this.id = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.phase = const Value.absent(),
    this.feeling = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckInsCompanion.insert({
    required String id,
    required String dateKey,
    this.phase = const Value.absent(),
    required Feeling feeling,
    required String note,
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dateKey = Value(dateKey),
       feeling = Value(feeling),
       note = Value(note),
       updatedAt = Value(updatedAt);
  static Insertable<CheckInRow> custom({
    Expression<String>? id,
    Expression<String>? dateKey,
    Expression<String>? phase,
    Expression<String>? feeling,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateKey != null) 'date_key': dateKey,
      if (phase != null) 'phase': phase,
      if (feeling != null) 'feeling': feeling,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckInsCompanion copyWith({
    Value<String>? id,
    Value<String>? dateKey,
    Value<CheckInPhase>? phase,
    Value<Feeling>? feeling,
    Value<String>? note,
    Value<DateTime?>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CheckInsCompanion(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      phase: phase ?? this.phase,
      feeling: feeling ?? this.feeling,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(
        $CheckInsTable.$converterphase.toSql(phase.value),
      );
    }
    if (feeling.present) {
      map['feeling'] = Variable<String>(
        $CheckInsTable.$converterfeeling.toSql(feeling.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckInsCompanion(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('phase: $phase, ')
          ..write('feeling: $feeling, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodEntriesTable extends FoodEntries
    with TableInfo<$FoodEntriesTable, FoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    check: () => ComparableExpr(calories).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portionMeta = const VerificationMeta(
    'portion',
  );
  @override
  late final GeneratedColumn<double> portion = GeneratedColumn<double>(
    'portion',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CaloriesSource, String>
  caloriesSource = GeneratedColumn<String>(
    'calories_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  ).withConverter<CaloriesSource>($FoodEntriesTable.$convertercaloriesSource);
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    dateKey,
    name,
    calories,
    createdAt,
    portion,
    unit,
    proteinG,
    carbsG,
    fatG,
    caloriesSource,
    recipeId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('portion')) {
      context.handle(
        _portionMeta,
        portion.isAcceptableOrUnknown(data['portion']!, _portionMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      portion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}portion'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
      caloriesSource: $FoodEntriesTable.$convertercaloriesSource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}calories_source'],
        )!,
      ),
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      ),
    );
  }

  @override
  $FoodEntriesTable createAlias(String alias) {
    return $FoodEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CaloriesSource, String, String>
  $convertercaloriesSource = const EnumNameConverter<CaloriesSource>(
    CaloriesSource.values,
  );
}

class FoodRow extends DataClass implements Insertable<FoodRow> {
  final String id;
  final int seq;
  final String dateKey;
  final String name;
  final int calories;
  final DateTime? createdAt;
  final double? portion;
  final String? unit;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final CaloriesSource caloriesSource;
  final String? recipeId;
  const FoodRow({
    required this.id,
    required this.seq,
    required this.dateKey,
    required this.name,
    required this.calories,
    this.createdAt,
    this.portion,
    this.unit,
    this.proteinG,
    this.carbsG,
    this.fatG,
    required this.caloriesSource,
    this.recipeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['date_key'] = Variable<String>(dateKey);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<int>(calories);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || portion != null) {
      map['portion'] = Variable<double>(portion);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<double>(carbsG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    {
      map['calories_source'] = Variable<String>(
        $FoodEntriesTable.$convertercaloriesSource.toSql(caloriesSource),
      );
    }
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    return map;
  }

  FoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return FoodEntriesCompanion(
      id: Value(id),
      seq: Value(seq),
      dateKey: Value(dateKey),
      name: Value(name),
      calories: Value(calories),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      portion: portion == null && nullToAbsent
          ? const Value.absent()
          : Value(portion),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      caloriesSource: Value(caloriesSource),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
    );
  }

  factory FoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<int>(json['calories']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      portion: serializer.fromJson<double?>(json['portion']),
      unit: serializer.fromJson<String?>(json['unit']),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      carbsG: serializer.fromJson<double?>(json['carbsG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
      caloriesSource: $FoodEntriesTable.$convertercaloriesSource.fromJson(
        serializer.fromJson<String>(json['caloriesSource']),
      ),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'dateKey': serializer.toJson<String>(dateKey),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<int>(calories),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'portion': serializer.toJson<double?>(portion),
      'unit': serializer.toJson<String?>(unit),
      'proteinG': serializer.toJson<double?>(proteinG),
      'carbsG': serializer.toJson<double?>(carbsG),
      'fatG': serializer.toJson<double?>(fatG),
      'caloriesSource': serializer.toJson<String>(
        $FoodEntriesTable.$convertercaloriesSource.toJson(caloriesSource),
      ),
      'recipeId': serializer.toJson<String?>(recipeId),
    };
  }

  FoodRow copyWith({
    String? id,
    int? seq,
    String? dateKey,
    String? name,
    int? calories,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<double?> portion = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> carbsG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
    CaloriesSource? caloriesSource,
    Value<String?> recipeId = const Value.absent(),
  }) => FoodRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    dateKey: dateKey ?? this.dateKey,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    portion: portion.present ? portion.value : this.portion,
    unit: unit.present ? unit.value : this.unit,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    fatG: fatG.present ? fatG.value : this.fatG,
    caloriesSource: caloriesSource ?? this.caloriesSource,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
  );
  FoodRow copyWithCompanion(FoodEntriesCompanion data) {
    return FoodRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      portion: data.portion.present ? data.portion.value : this.portion,
      unit: data.unit.present ? data.unit.value : this.unit,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      caloriesSource: data.caloriesSource.present
          ? data.caloriesSource.value
          : this.caloriesSource,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('dateKey: $dateKey, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('createdAt: $createdAt, ')
          ..write('portion: $portion, ')
          ..write('unit: $unit, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('caloriesSource: $caloriesSource, ')
          ..write('recipeId: $recipeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    dateKey,
    name,
    calories,
    createdAt,
    portion,
    unit,
    proteinG,
    carbsG,
    fatG,
    caloriesSource,
    recipeId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.dateKey == this.dateKey &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.createdAt == this.createdAt &&
          other.portion == this.portion &&
          other.unit == this.unit &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.caloriesSource == this.caloriesSource &&
          other.recipeId == this.recipeId);
}

class FoodEntriesCompanion extends UpdateCompanion<FoodRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> dateKey;
  final Value<String> name;
  final Value<int> calories;
  final Value<DateTime?> createdAt;
  final Value<double?> portion;
  final Value<String?> unit;
  final Value<double?> proteinG;
  final Value<double?> carbsG;
  final Value<double?> fatG;
  final Value<CaloriesSource> caloriesSource;
  final Value<String?> recipeId;
  final Value<int> rowid;
  const FoodEntriesCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.portion = const Value.absent(),
    this.unit = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.caloriesSource = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodEntriesCompanion.insert({
    required String id,
    required int seq,
    required String dateKey,
    required String name,
    required int calories,
    this.createdAt = const Value.absent(),
    this.portion = const Value.absent(),
    this.unit = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.caloriesSource = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       dateKey = Value(dateKey),
       name = Value(name),
       calories = Value(calories);
  static Insertable<FoodRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? dateKey,
    Expression<String>? name,
    Expression<int>? calories,
    Expression<DateTime>? createdAt,
    Expression<double>? portion,
    Expression<String>? unit,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<String>? caloriesSource,
    Expression<String>? recipeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (dateKey != null) 'date_key': dateKey,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (createdAt != null) 'created_at': createdAt,
      if (portion != null) 'portion': portion,
      if (unit != null) 'unit': unit,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (caloriesSource != null) 'calories_source': caloriesSource,
      if (recipeId != null) 'recipe_id': recipeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? dateKey,
    Value<String>? name,
    Value<int>? calories,
    Value<DateTime?>? createdAt,
    Value<double?>? portion,
    Value<String?>? unit,
    Value<double?>? proteinG,
    Value<double?>? carbsG,
    Value<double?>? fatG,
    Value<CaloriesSource>? caloriesSource,
    Value<String?>? recipeId,
    Value<int>? rowid,
  }) {
    return FoodEntriesCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      dateKey: dateKey ?? this.dateKey,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      createdAt: createdAt ?? this.createdAt,
      portion: portion ?? this.portion,
      unit: unit ?? this.unit,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      caloriesSource: caloriesSource ?? this.caloriesSource,
      recipeId: recipeId ?? this.recipeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (portion.present) {
      map['portion'] = Variable<double>(portion.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (caloriesSource.present) {
      map['calories_source'] = Variable<String>(
        $FoodEntriesTable.$convertercaloriesSource.toSql(caloriesSource.value),
      );
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('dateKey: $dateKey, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('createdAt: $createdAt, ')
          ..write('portion: $portion, ')
          ..write('unit: $unit, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('caloriesSource: $caloriesSource, ')
          ..write('recipeId: $recipeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LegacyImportsTable extends LegacyImports
    with TableInfo<$LegacyImportsTable, LegacyImportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegacyImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LegacyImportStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LegacyImportStatus>($LegacyImportsTable.$converterstatus);
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionCountMeta = const VerificationMeta(
    'sessionCount',
  );
  @override
  late final GeneratedColumn<int> sessionCount = GeneratedColumn<int>(
    'session_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overrideCountMeta = const VerificationMeta(
    'overrideCount',
  );
  @override
  late final GeneratedColumn<int> overrideCount = GeneratedColumn<int>(
    'override_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInCountMeta = const VerificationMeta(
    'checkInCount',
  );
  @override
  late final GeneratedColumn<int> checkInCount = GeneratedColumn<int>(
    'check_in_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodCountMeta = const VerificationMeta(
    'foodCount',
  );
  @override
  late final GeneratedColumn<int> foodCount = GeneratedColumn<int>(
    'food_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    status,
    importedAt,
    sessionCount,
    overrideCount,
    checkInCount,
    foodCount,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legacy_imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<LegacyImportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('session_count')) {
      context.handle(
        _sessionCountMeta,
        sessionCount.isAcceptableOrUnknown(
          data['session_count']!,
          _sessionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionCountMeta);
    }
    if (data.containsKey('override_count')) {
      context.handle(
        _overrideCountMeta,
        overrideCount.isAcceptableOrUnknown(
          data['override_count']!,
          _overrideCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overrideCountMeta);
    }
    if (data.containsKey('check_in_count')) {
      context.handle(
        _checkInCountMeta,
        checkInCount.isAcceptableOrUnknown(
          data['check_in_count']!,
          _checkInCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInCountMeta);
    }
    if (data.containsKey('food_count')) {
      context.handle(
        _foodCountMeta,
        foodCount.isAcceptableOrUnknown(data['food_count']!, _foodCountMeta),
      );
    } else if (isInserting) {
      context.missing(_foodCountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source};
  @override
  LegacyImportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LegacyImportRow(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: $LegacyImportsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      sessionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_count'],
      )!,
      overrideCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}override_count'],
      )!,
      checkInCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}check_in_count'],
      )!,
      foodCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_count'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $LegacyImportsTable createAlias(String alias) {
    return $LegacyImportsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LegacyImportStatus, String, String>
  $converterstatus = const EnumNameConverter<LegacyImportStatus>(
    LegacyImportStatus.values,
  );
}

class LegacyImportRow extends DataClass implements Insertable<LegacyImportRow> {
  final String source;
  final LegacyImportStatus status;
  final DateTime importedAt;
  final int sessionCount;
  final int overrideCount;
  final int checkInCount;
  final int foodCount;
  final String notes;
  const LegacyImportRow({
    required this.source,
    required this.status,
    required this.importedAt,
    required this.sessionCount,
    required this.overrideCount,
    required this.checkInCount,
    required this.foodCount,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    {
      map['status'] = Variable<String>(
        $LegacyImportsTable.$converterstatus.toSql(status),
      );
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['session_count'] = Variable<int>(sessionCount);
    map['override_count'] = Variable<int>(overrideCount);
    map['check_in_count'] = Variable<int>(checkInCount);
    map['food_count'] = Variable<int>(foodCount);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  LegacyImportsCompanion toCompanion(bool nullToAbsent) {
    return LegacyImportsCompanion(
      source: Value(source),
      status: Value(status),
      importedAt: Value(importedAt),
      sessionCount: Value(sessionCount),
      overrideCount: Value(overrideCount),
      checkInCount: Value(checkInCount),
      foodCount: Value(foodCount),
      notes: Value(notes),
    );
  }

  factory LegacyImportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LegacyImportRow(
      source: serializer.fromJson<String>(json['source']),
      status: $LegacyImportsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      sessionCount: serializer.fromJson<int>(json['sessionCount']),
      overrideCount: serializer.fromJson<int>(json['overrideCount']),
      checkInCount: serializer.fromJson<int>(json['checkInCount']),
      foodCount: serializer.fromJson<int>(json['foodCount']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(
        $LegacyImportsTable.$converterstatus.toJson(status),
      ),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'sessionCount': serializer.toJson<int>(sessionCount),
      'overrideCount': serializer.toJson<int>(overrideCount),
      'checkInCount': serializer.toJson<int>(checkInCount),
      'foodCount': serializer.toJson<int>(foodCount),
      'notes': serializer.toJson<String>(notes),
    };
  }

  LegacyImportRow copyWith({
    String? source,
    LegacyImportStatus? status,
    DateTime? importedAt,
    int? sessionCount,
    int? overrideCount,
    int? checkInCount,
    int? foodCount,
    String? notes,
  }) => LegacyImportRow(
    source: source ?? this.source,
    status: status ?? this.status,
    importedAt: importedAt ?? this.importedAt,
    sessionCount: sessionCount ?? this.sessionCount,
    overrideCount: overrideCount ?? this.overrideCount,
    checkInCount: checkInCount ?? this.checkInCount,
    foodCount: foodCount ?? this.foodCount,
    notes: notes ?? this.notes,
  );
  LegacyImportRow copyWithCompanion(LegacyImportsCompanion data) {
    return LegacyImportRow(
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      sessionCount: data.sessionCount.present
          ? data.sessionCount.value
          : this.sessionCount,
      overrideCount: data.overrideCount.present
          ? data.overrideCount.value
          : this.overrideCount,
      checkInCount: data.checkInCount.present
          ? data.checkInCount.value
          : this.checkInCount,
      foodCount: data.foodCount.present ? data.foodCount.value : this.foodCount,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LegacyImportRow(')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('importedAt: $importedAt, ')
          ..write('sessionCount: $sessionCount, ')
          ..write('overrideCount: $overrideCount, ')
          ..write('checkInCount: $checkInCount, ')
          ..write('foodCount: $foodCount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    status,
    importedAt,
    sessionCount,
    overrideCount,
    checkInCount,
    foodCount,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegacyImportRow &&
          other.source == this.source &&
          other.status == this.status &&
          other.importedAt == this.importedAt &&
          other.sessionCount == this.sessionCount &&
          other.overrideCount == this.overrideCount &&
          other.checkInCount == this.checkInCount &&
          other.foodCount == this.foodCount &&
          other.notes == this.notes);
}

class LegacyImportsCompanion extends UpdateCompanion<LegacyImportRow> {
  final Value<String> source;
  final Value<LegacyImportStatus> status;
  final Value<DateTime> importedAt;
  final Value<int> sessionCount;
  final Value<int> overrideCount;
  final Value<int> checkInCount;
  final Value<int> foodCount;
  final Value<String> notes;
  final Value<int> rowid;
  const LegacyImportsCompanion({
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.sessionCount = const Value.absent(),
    this.overrideCount = const Value.absent(),
    this.checkInCount = const Value.absent(),
    this.foodCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LegacyImportsCompanion.insert({
    required String source,
    required LegacyImportStatus status,
    required DateTime importedAt,
    required int sessionCount,
    required int overrideCount,
    required int checkInCount,
    required int foodCount,
    required String notes,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       status = Value(status),
       importedAt = Value(importedAt),
       sessionCount = Value(sessionCount),
       overrideCount = Value(overrideCount),
       checkInCount = Value(checkInCount),
       foodCount = Value(foodCount),
       notes = Value(notes);
  static Insertable<LegacyImportRow> custom({
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? importedAt,
    Expression<int>? sessionCount,
    Expression<int>? overrideCount,
    Expression<int>? checkInCount,
    Expression<int>? foodCount,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (importedAt != null) 'imported_at': importedAt,
      if (sessionCount != null) 'session_count': sessionCount,
      if (overrideCount != null) 'override_count': overrideCount,
      if (checkInCount != null) 'check_in_count': checkInCount,
      if (foodCount != null) 'food_count': foodCount,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LegacyImportsCompanion copyWith({
    Value<String>? source,
    Value<LegacyImportStatus>? status,
    Value<DateTime>? importedAt,
    Value<int>? sessionCount,
    Value<int>? overrideCount,
    Value<int>? checkInCount,
    Value<int>? foodCount,
    Value<String>? notes,
    Value<int>? rowid,
  }) {
    return LegacyImportsCompanion(
      source: source ?? this.source,
      status: status ?? this.status,
      importedAt: importedAt ?? this.importedAt,
      sessionCount: sessionCount ?? this.sessionCount,
      overrideCount: overrideCount ?? this.overrideCount,
      checkInCount: checkInCount ?? this.checkInCount,
      foodCount: foodCount ?? this.foodCount,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $LegacyImportsTable.$converterstatus.toSql(status.value),
      );
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (sessionCount.present) {
      map['session_count'] = Variable<int>(sessionCount.value);
    }
    if (overrideCount.present) {
      map['override_count'] = Variable<int>(overrideCount.value);
    }
    if (checkInCount.present) {
      map['check_in_count'] = Variable<int>(checkInCount.value);
    }
    if (foodCount.present) {
      map['food_count'] = Variable<int>(foodCount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegacyImportsCompanion(')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('importedAt: $importedAt, ')
          ..write('sessionCount: $sessionCount, ')
          ..write('overrideCount: $overrideCount, ')
          ..write('checkInCount: $checkInCount, ')
          ..write('foodCount: $foodCount, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanVersionsTable extends PlanVersions
    with TableInfo<$PlanVersionsTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlanStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlanStatus>($PlanVersionsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<PlanSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlanSource>($PlanVersionsTable.$convertersource);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acceptedAt = GeneratedColumn<DateTime>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    status,
    source,
    name,
    effectiveFrom,
    createdAt,
    acceptedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
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
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      status: $PlanVersionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      source: $PlanVersionsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}accepted_at'],
      ),
    );
  }

  @override
  $PlanVersionsTable createAlias(String alias) {
    return $PlanVersionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlanStatus, String, String> $converterstatus =
      const EnumNameConverter<PlanStatus>(PlanStatus.values);
  static JsonTypeConverter2<PlanSource, String, String> $convertersource =
      const EnumNameConverter<PlanSource>(PlanSource.values);
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String id;
  final int seq;
  final PlanStatus status;
  final PlanSource source;
  final String name;
  final String? effectiveFrom;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  const PlanRow({
    required this.id,
    required this.seq,
    required this.status,
    required this.source,
    required this.name,
    this.effectiveFrom,
    required this.createdAt,
    this.acceptedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    {
      map['status'] = Variable<String>(
        $PlanVersionsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['source'] = Variable<String>(
        $PlanVersionsTable.$convertersource.toSql(source),
      );
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || effectiveFrom != null) {
      map['effective_from'] = Variable<String>(effectiveFrom);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt);
    }
    return map;
  }

  PlanVersionsCompanion toCompanion(bool nullToAbsent) {
    return PlanVersionsCompanion(
      id: Value(id),
      seq: Value(seq),
      status: Value(status),
      source: Value(source),
      name: Value(name),
      effectiveFrom: effectiveFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveFrom),
      createdAt: Value(createdAt),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      status: $PlanVersionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      source: $PlanVersionsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      name: serializer.fromJson<String>(json['name']),
      effectiveFrom: serializer.fromJson<String?>(json['effectiveFrom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      acceptedAt: serializer.fromJson<DateTime?>(json['acceptedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'status': serializer.toJson<String>(
        $PlanVersionsTable.$converterstatus.toJson(status),
      ),
      'source': serializer.toJson<String>(
        $PlanVersionsTable.$convertersource.toJson(source),
      ),
      'name': serializer.toJson<String>(name),
      'effectiveFrom': serializer.toJson<String?>(effectiveFrom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'acceptedAt': serializer.toJson<DateTime?>(acceptedAt),
    };
  }

  PlanRow copyWith({
    String? id,
    int? seq,
    PlanStatus? status,
    PlanSource? source,
    String? name,
    Value<String?> effectiveFrom = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> acceptedAt = const Value.absent(),
  }) => PlanRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    status: status ?? this.status,
    source: source ?? this.source,
    name: name ?? this.name,
    effectiveFrom: effectiveFrom.present
        ? effectiveFrom.value
        : this.effectiveFrom,
    createdAt: createdAt ?? this.createdAt,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
  );
  PlanRow copyWithCompanion(PlanVersionsCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      status: data.status.present ? data.status.value : this.status,
      source: data.source.present ? data.source.value : this.source,
      name: data.name.present ? data.name.value : this.name,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('createdAt: $createdAt, ')
          ..write('acceptedAt: $acceptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    status,
    source,
    name,
    effectiveFrom,
    createdAt,
    acceptedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.status == this.status &&
          other.source == this.source &&
          other.name == this.name &&
          other.effectiveFrom == this.effectiveFrom &&
          other.createdAt == this.createdAt &&
          other.acceptedAt == this.acceptedAt);
}

class PlanVersionsCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<PlanStatus> status;
  final Value<PlanSource> source;
  final Value<String> name;
  final Value<String?> effectiveFrom;
  final Value<DateTime> createdAt;
  final Value<DateTime?> acceptedAt;
  final Value<int> rowid;
  const PlanVersionsCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.status = const Value.absent(),
    this.source = const Value.absent(),
    this.name = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanVersionsCompanion.insert({
    required String id,
    required int seq,
    required PlanStatus status,
    required PlanSource source,
    required String name,
    this.effectiveFrom = const Value.absent(),
    required DateTime createdAt,
    this.acceptedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       status = Value(status),
       source = Value(source),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlanRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? status,
    Expression<String>? source,
    Expression<String>? name,
    Expression<String>? effectiveFrom,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? acceptedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (status != null) 'status': status,
      if (source != null) 'source': source,
      if (name != null) 'name': name,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (createdAt != null) 'created_at': createdAt,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanVersionsCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<PlanStatus>? status,
    Value<PlanSource>? source,
    Value<String>? name,
    Value<String?>? effectiveFrom,
    Value<DateTime>? createdAt,
    Value<DateTime?>? acceptedAt,
    Value<int>? rowid,
  }) {
    return PlanVersionsCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      status: status ?? this.status,
      source: source ?? this.source,
      name: name ?? this.name,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PlanVersionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $PlanVersionsTable.$convertersource.toSql(source.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanVersionsCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('status: $status, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('createdAt: $createdAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanRoutinesTable extends PlanRoutines
    with TableInfo<$PlanRoutinesTable, PlanRoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanRoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_versions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    check: () => ComparableExpr(weekday).isBetweenValues(1, 7),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warmupMeta = const VerificationMeta('warmup');
  @override
  late final GeneratedColumn<String> warmup = GeneratedColumn<String>(
    'warmup',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    weekday,
    name,
    focus,
    warmup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    if (data.containsKey('warmup')) {
      context.handle(
        _warmupMeta,
        warmup.isAcceptableOrUnknown(data['warmup']!, _warmupMeta),
      );
    } else if (isInserting) {
      context.missing(_warmupMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {planId, weekday},
  ];
  @override
  PlanRoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      )!,
      warmup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warmup'],
      )!,
    );
  }

  @override
  $PlanRoutinesTable createAlias(String alias) {
    return $PlanRoutinesTable(attachedDatabase, alias);
  }
}

class PlanRoutineRow extends DataClass implements Insertable<PlanRoutineRow> {
  final String id;
  final String planId;
  final int weekday;
  final String name;
  final String focus;
  final String warmup;
  const PlanRoutineRow({
    required this.id,
    required this.planId,
    required this.weekday,
    required this.name,
    required this.focus,
    required this.warmup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['weekday'] = Variable<int>(weekday);
    map['name'] = Variable<String>(name);
    map['focus'] = Variable<String>(focus);
    map['warmup'] = Variable<String>(warmup);
    return map;
  }

  PlanRoutinesCompanion toCompanion(bool nullToAbsent) {
    return PlanRoutinesCompanion(
      id: Value(id),
      planId: Value(planId),
      weekday: Value(weekday),
      name: Value(name),
      focus: Value(focus),
      warmup: Value(warmup),
    );
  }

  factory PlanRoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRoutineRow(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      weekday: serializer.fromJson<int>(json['weekday']),
      name: serializer.fromJson<String>(json['name']),
      focus: serializer.fromJson<String>(json['focus']),
      warmup: serializer.fromJson<String>(json['warmup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'weekday': serializer.toJson<int>(weekday),
      'name': serializer.toJson<String>(name),
      'focus': serializer.toJson<String>(focus),
      'warmup': serializer.toJson<String>(warmup),
    };
  }

  PlanRoutineRow copyWith({
    String? id,
    String? planId,
    int? weekday,
    String? name,
    String? focus,
    String? warmup,
  }) => PlanRoutineRow(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    weekday: weekday ?? this.weekday,
    name: name ?? this.name,
    focus: focus ?? this.focus,
    warmup: warmup ?? this.warmup,
  );
  PlanRoutineRow copyWithCompanion(PlanRoutinesCompanion data) {
    return PlanRoutineRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      name: data.name.present ? data.name.value : this.name,
      focus: data.focus.present ? data.focus.value : this.focus,
      warmup: data.warmup.present ? data.warmup.value : this.warmup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRoutineRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('weekday: $weekday, ')
          ..write('name: $name, ')
          ..write('focus: $focus, ')
          ..write('warmup: $warmup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, weekday, name, focus, warmup);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRoutineRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.weekday == this.weekday &&
          other.name == this.name &&
          other.focus == this.focus &&
          other.warmup == this.warmup);
}

class PlanRoutinesCompanion extends UpdateCompanion<PlanRoutineRow> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> weekday;
  final Value<String> name;
  final Value<String> focus;
  final Value<String> warmup;
  final Value<int> rowid;
  const PlanRoutinesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.name = const Value.absent(),
    this.focus = const Value.absent(),
    this.warmup = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanRoutinesCompanion.insert({
    required String id,
    required String planId,
    required int weekday,
    required String name,
    required String focus,
    required String warmup,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       weekday = Value(weekday),
       name = Value(name),
       focus = Value(focus),
       warmup = Value(warmup);
  static Insertable<PlanRoutineRow> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? weekday,
    Expression<String>? name,
    Expression<String>? focus,
    Expression<String>? warmup,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (weekday != null) 'weekday': weekday,
      if (name != null) 'name': name,
      if (focus != null) 'focus': focus,
      if (warmup != null) 'warmup': warmup,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanRoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? weekday,
    Value<String>? name,
    Value<String>? focus,
    Value<String>? warmup,
    Value<int>? rowid,
  }) {
    return PlanRoutinesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      weekday: weekday ?? this.weekday,
      name: name ?? this.name,
      focus: focus ?? this.focus,
      warmup: warmup ?? this.warmup,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (warmup.present) {
      map['warmup'] = Variable<String>(warmup.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('weekday: $weekday, ')
          ..write('name: $name, ')
          ..write('focus: $focus, ')
          ..write('warmup: $warmup, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanRoutineExercisesTable extends PlanRoutineExercises
    with TableInfo<$PlanRoutineExercisesTable, PlanExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanRoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumn<int> sets = GeneratedColumn<int>(
    'sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMinMeta = const VerificationMeta(
    'repsMin',
  );
  @override
  late final GeneratedColumn<int> repsMin = GeneratedColumn<int>(
    'reps_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMaxMeta = const VerificationMeta(
    'repsMax',
  );
  @override
  late final GeneratedColumn<int> repsMax = GeneratedColumn<int>(
    'reps_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
    'rir',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incrementKgMeta = const VerificationMeta(
    'incrementKg',
  );
  @override
  late final GeneratedColumn<double> incrementKg = GeneratedColumn<double>(
    'increment_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceWeightKgMeta = const VerificationMeta(
    'referenceWeightKg',
  );
  @override
  late final GeneratedColumn<double> referenceWeightKg =
      GeneratedColumn<double>(
        'reference_weight_kg',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    routineId,
    position,
    exerciseId,
    sets,
    repsMin,
    repsMax,
    rir,
    restSeconds,
    incrementKg,
    referenceWeightKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_routine_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sets')) {
      context.handle(
        _setsMeta,
        sets.isAcceptableOrUnknown(data['sets']!, _setsMeta),
      );
    } else if (isInserting) {
      context.missing(_setsMeta);
    }
    if (data.containsKey('reps_min')) {
      context.handle(
        _repsMinMeta,
        repsMin.isAcceptableOrUnknown(data['reps_min']!, _repsMinMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMinMeta);
    }
    if (data.containsKey('reps_max')) {
      context.handle(
        _repsMaxMeta,
        repsMax.isAcceptableOrUnknown(data['reps_max']!, _repsMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMaxMeta);
    }
    if (data.containsKey('rir')) {
      context.handle(
        _rirMeta,
        rir.isAcceptableOrUnknown(data['rir']!, _rirMeta),
      );
    } else if (isInserting) {
      context.missing(_rirMeta);
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restSecondsMeta);
    }
    if (data.containsKey('increment_kg')) {
      context.handle(
        _incrementKgMeta,
        incrementKg.isAcceptableOrUnknown(
          data['increment_kg']!,
          _incrementKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_incrementKgMeta);
    }
    if (data.containsKey('reference_weight_kg')) {
      context.handle(
        _referenceWeightKgMeta,
        referenceWeightKg.isAcceptableOrUnknown(
          data['reference_weight_kg']!,
          _referenceWeightKgMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {routineId, position};
  @override
  PlanExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanExerciseRow(
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      sets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets'],
      )!,
      repsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_min'],
      )!,
      repsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps_max'],
      )!,
      rir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rir'],
      )!,
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
      incrementKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}increment_kg'],
      )!,
      referenceWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_weight_kg'],
      ),
    );
  }

  @override
  $PlanRoutineExercisesTable createAlias(String alias) {
    return $PlanRoutineExercisesTable(attachedDatabase, alias);
  }
}

class PlanExerciseRow extends DataClass implements Insertable<PlanExerciseRow> {
  final String routineId;
  final int position;
  final String exerciseId;
  final int sets;
  final int repsMin;
  final int repsMax;
  final int rir;
  final int restSeconds;
  final double incrementKg;
  final double? referenceWeightKg;
  const PlanExerciseRow({
    required this.routineId,
    required this.position,
    required this.exerciseId,
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.rir,
    required this.restSeconds,
    required this.incrementKg,
    this.referenceWeightKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['routine_id'] = Variable<String>(routineId);
    map['position'] = Variable<int>(position);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['sets'] = Variable<int>(sets);
    map['reps_min'] = Variable<int>(repsMin);
    map['reps_max'] = Variable<int>(repsMax);
    map['rir'] = Variable<int>(rir);
    map['rest_seconds'] = Variable<int>(restSeconds);
    map['increment_kg'] = Variable<double>(incrementKg);
    if (!nullToAbsent || referenceWeightKg != null) {
      map['reference_weight_kg'] = Variable<double>(referenceWeightKg);
    }
    return map;
  }

  PlanRoutineExercisesCompanion toCompanion(bool nullToAbsent) {
    return PlanRoutineExercisesCompanion(
      routineId: Value(routineId),
      position: Value(position),
      exerciseId: Value(exerciseId),
      sets: Value(sets),
      repsMin: Value(repsMin),
      repsMax: Value(repsMax),
      rir: Value(rir),
      restSeconds: Value(restSeconds),
      incrementKg: Value(incrementKg),
      referenceWeightKg: referenceWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceWeightKg),
    );
  }

  factory PlanExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanExerciseRow(
      routineId: serializer.fromJson<String>(json['routineId']),
      position: serializer.fromJson<int>(json['position']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      sets: serializer.fromJson<int>(json['sets']),
      repsMin: serializer.fromJson<int>(json['repsMin']),
      repsMax: serializer.fromJson<int>(json['repsMax']),
      rir: serializer.fromJson<int>(json['rir']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
      incrementKg: serializer.fromJson<double>(json['incrementKg']),
      referenceWeightKg: serializer.fromJson<double?>(
        json['referenceWeightKg'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'routineId': serializer.toJson<String>(routineId),
      'position': serializer.toJson<int>(position),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'sets': serializer.toJson<int>(sets),
      'repsMin': serializer.toJson<int>(repsMin),
      'repsMax': serializer.toJson<int>(repsMax),
      'rir': serializer.toJson<int>(rir),
      'restSeconds': serializer.toJson<int>(restSeconds),
      'incrementKg': serializer.toJson<double>(incrementKg),
      'referenceWeightKg': serializer.toJson<double?>(referenceWeightKg),
    };
  }

  PlanExerciseRow copyWith({
    String? routineId,
    int? position,
    String? exerciseId,
    int? sets,
    int? repsMin,
    int? repsMax,
    int? rir,
    int? restSeconds,
    double? incrementKg,
    Value<double?> referenceWeightKg = const Value.absent(),
  }) => PlanExerciseRow(
    routineId: routineId ?? this.routineId,
    position: position ?? this.position,
    exerciseId: exerciseId ?? this.exerciseId,
    sets: sets ?? this.sets,
    repsMin: repsMin ?? this.repsMin,
    repsMax: repsMax ?? this.repsMax,
    rir: rir ?? this.rir,
    restSeconds: restSeconds ?? this.restSeconds,
    incrementKg: incrementKg ?? this.incrementKg,
    referenceWeightKg: referenceWeightKg.present
        ? referenceWeightKg.value
        : this.referenceWeightKg,
  );
  PlanExerciseRow copyWithCompanion(PlanRoutineExercisesCompanion data) {
    return PlanExerciseRow(
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      position: data.position.present ? data.position.value : this.position,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      sets: data.sets.present ? data.sets.value : this.sets,
      repsMin: data.repsMin.present ? data.repsMin.value : this.repsMin,
      repsMax: data.repsMax.present ? data.repsMax.value : this.repsMax,
      rir: data.rir.present ? data.rir.value : this.rir,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      incrementKg: data.incrementKg.present
          ? data.incrementKg.value
          : this.incrementKg,
      referenceWeightKg: data.referenceWeightKg.present
          ? data.referenceWeightKg.value
          : this.referenceWeightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanExerciseRow(')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('repsMin: $repsMin, ')
          ..write('repsMax: $repsMax, ')
          ..write('rir: $rir, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('incrementKg: $incrementKg, ')
          ..write('referenceWeightKg: $referenceWeightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    routineId,
    position,
    exerciseId,
    sets,
    repsMin,
    repsMax,
    rir,
    restSeconds,
    incrementKg,
    referenceWeightKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanExerciseRow &&
          other.routineId == this.routineId &&
          other.position == this.position &&
          other.exerciseId == this.exerciseId &&
          other.sets == this.sets &&
          other.repsMin == this.repsMin &&
          other.repsMax == this.repsMax &&
          other.rir == this.rir &&
          other.restSeconds == this.restSeconds &&
          other.incrementKg == this.incrementKg &&
          other.referenceWeightKg == this.referenceWeightKg);
}

class PlanRoutineExercisesCompanion extends UpdateCompanion<PlanExerciseRow> {
  final Value<String> routineId;
  final Value<int> position;
  final Value<String> exerciseId;
  final Value<int> sets;
  final Value<int> repsMin;
  final Value<int> repsMax;
  final Value<int> rir;
  final Value<int> restSeconds;
  final Value<double> incrementKg;
  final Value<double?> referenceWeightKg;
  final Value<int> rowid;
  const PlanRoutineExercisesCompanion({
    this.routineId = const Value.absent(),
    this.position = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sets = const Value.absent(),
    this.repsMin = const Value.absent(),
    this.repsMax = const Value.absent(),
    this.rir = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.incrementKg = const Value.absent(),
    this.referenceWeightKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanRoutineExercisesCompanion.insert({
    required String routineId,
    required int position,
    required String exerciseId,
    required int sets,
    required int repsMin,
    required int repsMax,
    required int rir,
    required int restSeconds,
    required double incrementKg,
    this.referenceWeightKg = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : routineId = Value(routineId),
       position = Value(position),
       exerciseId = Value(exerciseId),
       sets = Value(sets),
       repsMin = Value(repsMin),
       repsMax = Value(repsMax),
       rir = Value(rir),
       restSeconds = Value(restSeconds),
       incrementKg = Value(incrementKg);
  static Insertable<PlanExerciseRow> custom({
    Expression<String>? routineId,
    Expression<int>? position,
    Expression<String>? exerciseId,
    Expression<int>? sets,
    Expression<int>? repsMin,
    Expression<int>? repsMax,
    Expression<int>? rir,
    Expression<int>? restSeconds,
    Expression<double>? incrementKg,
    Expression<double>? referenceWeightKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (routineId != null) 'routine_id': routineId,
      if (position != null) 'position': position,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sets != null) 'sets': sets,
      if (repsMin != null) 'reps_min': repsMin,
      if (repsMax != null) 'reps_max': repsMax,
      if (rir != null) 'rir': rir,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (incrementKg != null) 'increment_kg': incrementKg,
      if (referenceWeightKg != null) 'reference_weight_kg': referenceWeightKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanRoutineExercisesCompanion copyWith({
    Value<String>? routineId,
    Value<int>? position,
    Value<String>? exerciseId,
    Value<int>? sets,
    Value<int>? repsMin,
    Value<int>? repsMax,
    Value<int>? rir,
    Value<int>? restSeconds,
    Value<double>? incrementKg,
    Value<double?>? referenceWeightKg,
    Value<int>? rowid,
  }) {
    return PlanRoutineExercisesCompanion(
      routineId: routineId ?? this.routineId,
      position: position ?? this.position,
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      repsMin: repsMin ?? this.repsMin,
      repsMax: repsMax ?? this.repsMax,
      rir: rir ?? this.rir,
      restSeconds: restSeconds ?? this.restSeconds,
      incrementKg: incrementKg ?? this.incrementKg,
      referenceWeightKg: referenceWeightKg ?? this.referenceWeightKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (sets.present) {
      map['sets'] = Variable<int>(sets.value);
    }
    if (repsMin.present) {
      map['reps_min'] = Variable<int>(repsMin.value);
    }
    if (repsMax.present) {
      map['reps_max'] = Variable<int>(repsMax.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (incrementKg.present) {
      map['increment_kg'] = Variable<double>(incrementKg.value);
    }
    if (referenceWeightKg.present) {
      map['reference_weight_kg'] = Variable<double>(referenceWeightKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanRoutineExercisesCompanion(')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sets: $sets, ')
          ..write('repsMin: $repsMin, ')
          ..write('repsMax: $repsMax, ')
          ..write('rir: $rir, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('incrementKg: $incrementKg, ')
          ..write('referenceWeightKg: $referenceWeightKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetLogsTable extends SetLogs with TableInfo<$SetLogsTable, SetLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SetKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SetKind>($SetLogsTable.$converterkind);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    check: () => ComparableExpr(number).isBiggerOrEqualValue(1),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SetStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SetStatus>($SetLogsTable.$converterstatus);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    check: () => ComparableExpr(weightKg).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    check: () => ComparableExpr(reps).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
    'rir',
    aliasedName,
    true,
    check: () => ComparableExpr(rir).isBetweenValues(0, 10),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skipReasonMeta = const VerificationMeta(
    'skipReason',
  );
  @override
  late final GeneratedColumn<String> skipReason = GeneratedColumn<String>(
    'skip_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    position,
    kind,
    number,
    status,
    weightKg,
    reps,
    rir,
    skipReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('rir')) {
      context.handle(
        _rirMeta,
        rir.isAcceptableOrUnknown(data['rir']!, _rirMeta),
      );
    }
    if (data.containsKey('skip_reason')) {
      context.handle(
        _skipReasonMeta,
        skipReason.isAcceptableOrUnknown(data['skip_reason']!, _skipReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, exerciseId, position},
  ];
  @override
  SetLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: $SetLogsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      status: $SetLogsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      rir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rir'],
      ),
      skipReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_reason'],
      ),
    );
  }

  @override
  $SetLogsTable createAlias(String alias) {
    return $SetLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SetKind, String, String> $converterkind =
      const EnumNameConverter<SetKind>(SetKind.values);
  static JsonTypeConverter2<SetStatus, String, String> $converterstatus =
      const EnumNameConverter<SetStatus>(SetStatus.values);
}

class SetLogRow extends DataClass implements Insertable<SetLogRow> {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int position;
  final SetKind kind;
  final int number;
  final SetStatus status;
  final double? weightKg;
  final int? reps;
  final int? rir;
  final String? skipReason;
  const SetLogRow({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.position,
    required this.kind,
    required this.number,
    required this.status,
    this.weightKg,
    this.reps,
    this.rir,
    this.skipReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    {
      map['kind'] = Variable<String>($SetLogsTable.$converterkind.toSql(kind));
    }
    map['number'] = Variable<int>(number);
    {
      map['status'] = Variable<String>(
        $SetLogsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    if (!nullToAbsent || skipReason != null) {
      map['skip_reason'] = Variable<String>(skipReason);
    }
    return map;
  }

  SetLogsCompanion toCompanion(bool nullToAbsent) {
    return SetLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      kind: Value(kind),
      number: Value(number),
      status: Value(status),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      skipReason: skipReason == null && nullToAbsent
          ? const Value.absent()
          : Value(skipReason),
    );
  }

  factory SetLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetLogRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      kind: $SetLogsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      number: serializer.fromJson<int>(json['number']),
      status: $SetLogsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      rir: serializer.fromJson<int?>(json['rir']),
      skipReason: serializer.fromJson<String?>(json['skipReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<String>(
        $SetLogsTable.$converterkind.toJson(kind),
      ),
      'number': serializer.toJson<int>(number),
      'status': serializer.toJson<String>(
        $SetLogsTable.$converterstatus.toJson(status),
      ),
      'weightKg': serializer.toJson<double?>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'rir': serializer.toJson<int?>(rir),
      'skipReason': serializer.toJson<String?>(skipReason),
    };
  }

  SetLogRow copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? position,
    SetKind? kind,
    int? number,
    SetStatus? status,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> rir = const Value.absent(),
    Value<String?> skipReason = const Value.absent(),
  }) => SetLogRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    number: number ?? this.number,
    status: status ?? this.status,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    reps: reps.present ? reps.value : this.reps,
    rir: rir.present ? rir.value : this.rir,
    skipReason: skipReason.present ? skipReason.value : this.skipReason,
  );
  SetLogRow copyWithCompanion(SetLogsCompanion data) {
    return SetLogRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      number: data.number.present ? data.number.value : this.number,
      status: data.status.present ? data.status.value : this.status,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      rir: data.rir.present ? data.rir.value : this.rir,
      skipReason: data.skipReason.present
          ? data.skipReason.value
          : this.skipReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetLogRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('status: $status, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('rir: $rir, ')
          ..write('skipReason: $skipReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    position,
    kind,
    number,
    status,
    weightKg,
    reps,
    rir,
    skipReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetLogRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.number == this.number &&
          other.status == this.status &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.rir == this.rir &&
          other.skipReason == this.skipReason);
}

class SetLogsCompanion extends UpdateCompanion<SetLogRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<SetKind> kind;
  final Value<int> number;
  final Value<SetStatus> status;
  final Value<double?> weightKg;
  final Value<int?> reps;
  final Value<int?> rir;
  final Value<String?> skipReason;
  final Value<int> rowid;
  const SetLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.number = const Value.absent(),
    this.status = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.rir = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetLogsCompanion.insert({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int position,
    required SetKind kind,
    required int number,
    required SetStatus status,
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.rir = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       position = Value(position),
       kind = Value(kind),
       number = Value(number),
       status = Value(status);
  static Insertable<SetLogRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<String>? kind,
    Expression<int>? number,
    Expression<String>? status,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? rir,
    Expression<String>? skipReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (number != null) 'number': number,
      if (status != null) 'status': status,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (rir != null) 'rir': rir,
      if (skipReason != null) 'skip_reason': skipReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<SetKind>? kind,
    Value<int>? number,
    Value<SetStatus>? status,
    Value<double?>? weightKg,
    Value<int?>? reps,
    Value<int?>? rir,
    Value<String?>? skipReason,
    Value<int>? rowid,
  }) {
    return SetLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      number: number ?? this.number,
      status: status ?? this.status,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      skipReason: skipReason ?? this.skipReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SetLogsTable.$converterkind.toSql(kind.value),
      );
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SetLogsTable.$converterstatus.toSql(status.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (skipReason.present) {
      map['skip_reason'] = Variable<String>(skipReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('status: $status, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('rir: $rir, ')
          ..write('skipReason: $skipReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionEventsTable extends SessionEvents
    with TableInfo<$SessionEventsTable, SessionEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionEventKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionEventKind>($SessionEventsTable.$converterkind);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, seq, dateKey, kind, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      kind: $SessionEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $SessionEventsTable createAlias(String alias) {
    return $SessionEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionEventKind, String, String> $converterkind =
      const EnumNameConverter<SessionEventKind>(SessionEventKind.values);
}

class SessionEventRow extends DataClass implements Insertable<SessionEventRow> {
  final String id;
  final int seq;
  final String dateKey;
  final SessionEventKind kind;
  final DateTime at;
  const SessionEventRow({
    required this.id,
    required this.seq,
    required this.dateKey,
    required this.kind,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['date_key'] = Variable<String>(dateKey);
    {
      map['kind'] = Variable<String>(
        $SessionEventsTable.$converterkind.toSql(kind),
      );
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  SessionEventsCompanion toCompanion(bool nullToAbsent) {
    return SessionEventsCompanion(
      id: Value(id),
      seq: Value(seq),
      dateKey: Value(dateKey),
      kind: Value(kind),
      at: Value(at),
    );
  }

  factory SessionEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEventRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      kind: $SessionEventsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'dateKey': serializer.toJson<String>(dateKey),
      'kind': serializer.toJson<String>(
        $SessionEventsTable.$converterkind.toJson(kind),
      ),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  SessionEventRow copyWith({
    String? id,
    int? seq,
    String? dateKey,
    SessionEventKind? kind,
    DateTime? at,
  }) => SessionEventRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    dateKey: dateKey ?? this.dateKey,
    kind: kind ?? this.kind,
    at: at ?? this.at,
  );
  SessionEventRow copyWithCompanion(SessionEventsCompanion data) {
    return SessionEventRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      kind: data.kind.present ? data.kind.value : this.kind,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEventRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('dateKey: $dateKey, ')
          ..write('kind: $kind, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seq, dateKey, kind, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEventRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.dateKey == this.dateKey &&
          other.kind == this.kind &&
          other.at == this.at);
}

class SessionEventsCompanion extends UpdateCompanion<SessionEventRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> dateKey;
  final Value<SessionEventKind> kind;
  final Value<DateTime> at;
  final Value<int> rowid;
  const SessionEventsCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionEventsCompanion.insert({
    required String id,
    required int seq,
    required String dateKey,
    required SessionEventKind kind,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       dateKey = Value(dateKey),
       kind = Value(kind),
       at = Value(at);
  static Insertable<SessionEventRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? dateKey,
    Expression<String>? kind,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (dateKey != null) 'date_key': dateKey,
      if (kind != null) 'kind': kind,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? dateKey,
    Value<SessionEventKind>? kind,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return SessionEventsCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      dateKey: dateKey ?? this.dateKey,
      kind: kind ?? this.kind,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SessionEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionEventsCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('dateKey: $dateKey, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReschedulesTable extends Reschedules
    with TableInfo<$ReschedulesTable, RescheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReschedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceDateMeta = const VerificationMeta(
    'sourceDate',
  );
  @override
  late final GeneratedColumn<String> sourceDate = GeneratedColumn<String>(
    'source_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<String> targetDate = GeneratedColumn<String>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RescheduleKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RescheduleKind>($ReschedulesTable.$converterkind);
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
  static const VerificationMeta _undoneAtMeta = const VerificationMeta(
    'undoneAt',
  );
  @override
  late final GeneratedColumn<DateTime> undoneAt = GeneratedColumn<DateTime>(
    'undone_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    sourceDate,
    targetDate,
    kind,
    createdAt,
    undoneAt,
    parentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reschedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RescheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('source_date')) {
      context.handle(
        _sourceDateMeta,
        sourceDate.isAcceptableOrUnknown(data['source_date']!, _sourceDateMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceDateMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('undone_at')) {
      context.handle(
        _undoneAtMeta,
        undoneAt.isAcceptableOrUnknown(data['undone_at']!, _undoneAtMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RescheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RescheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      sourceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_date'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_date'],
      )!,
      kind: $ReschedulesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      undoneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}undone_at'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $ReschedulesTable createAlias(String alias) {
    return $ReschedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RescheduleKind, String, String> $converterkind =
      const EnumNameConverter<RescheduleKind>(RescheduleKind.values);
}

class RescheduleRow extends DataClass implements Insertable<RescheduleRow> {
  final String id;
  final int seq;
  final String sourceDate;
  final String targetDate;
  final RescheduleKind kind;
  final DateTime createdAt;
  final DateTime? undoneAt;
  final String? parentId;
  const RescheduleRow({
    required this.id,
    required this.seq,
    required this.sourceDate,
    required this.targetDate,
    required this.kind,
    required this.createdAt,
    this.undoneAt,
    this.parentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['source_date'] = Variable<String>(sourceDate);
    map['target_date'] = Variable<String>(targetDate);
    {
      map['kind'] = Variable<String>(
        $ReschedulesTable.$converterkind.toSql(kind),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || undoneAt != null) {
      map['undone_at'] = Variable<DateTime>(undoneAt);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  ReschedulesCompanion toCompanion(bool nullToAbsent) {
    return ReschedulesCompanion(
      id: Value(id),
      seq: Value(seq),
      sourceDate: Value(sourceDate),
      targetDate: Value(targetDate),
      kind: Value(kind),
      createdAt: Value(createdAt),
      undoneAt: undoneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(undoneAt),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory RescheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RescheduleRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      sourceDate: serializer.fromJson<String>(json['sourceDate']),
      targetDate: serializer.fromJson<String>(json['targetDate']),
      kind: $ReschedulesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      undoneAt: serializer.fromJson<DateTime?>(json['undoneAt']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'sourceDate': serializer.toJson<String>(sourceDate),
      'targetDate': serializer.toJson<String>(targetDate),
      'kind': serializer.toJson<String>(
        $ReschedulesTable.$converterkind.toJson(kind),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'undoneAt': serializer.toJson<DateTime?>(undoneAt),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  RescheduleRow copyWith({
    String? id,
    int? seq,
    String? sourceDate,
    String? targetDate,
    RescheduleKind? kind,
    DateTime? createdAt,
    Value<DateTime?> undoneAt = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
  }) => RescheduleRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    sourceDate: sourceDate ?? this.sourceDate,
    targetDate: targetDate ?? this.targetDate,
    kind: kind ?? this.kind,
    createdAt: createdAt ?? this.createdAt,
    undoneAt: undoneAt.present ? undoneAt.value : this.undoneAt,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  RescheduleRow copyWithCompanion(ReschedulesCompanion data) {
    return RescheduleRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      sourceDate: data.sourceDate.present
          ? data.sourceDate.value
          : this.sourceDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      undoneAt: data.undoneAt.present ? data.undoneAt.value : this.undoneAt,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RescheduleRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('sourceDate: $sourceDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('undoneAt: $undoneAt, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    sourceDate,
    targetDate,
    kind,
    createdAt,
    undoneAt,
    parentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RescheduleRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.sourceDate == this.sourceDate &&
          other.targetDate == this.targetDate &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt &&
          other.undoneAt == this.undoneAt &&
          other.parentId == this.parentId);
}

class ReschedulesCompanion extends UpdateCompanion<RescheduleRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> sourceDate;
  final Value<String> targetDate;
  final Value<RescheduleKind> kind;
  final Value<DateTime> createdAt;
  final Value<DateTime?> undoneAt;
  final Value<String?> parentId;
  final Value<int> rowid;
  const ReschedulesCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.sourceDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.undoneAt = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReschedulesCompanion.insert({
    required String id,
    required int seq,
    required String sourceDate,
    required String targetDate,
    required RescheduleKind kind,
    required DateTime createdAt,
    this.undoneAt = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       sourceDate = Value(sourceDate),
       targetDate = Value(targetDate),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<RescheduleRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? sourceDate,
    Expression<String>? targetDate,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? undoneAt,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (sourceDate != null) 'source_date': sourceDate,
      if (targetDate != null) 'target_date': targetDate,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (undoneAt != null) 'undone_at': undoneAt,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReschedulesCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? sourceDate,
    Value<String>? targetDate,
    Value<RescheduleKind>? kind,
    Value<DateTime>? createdAt,
    Value<DateTime?>? undoneAt,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return ReschedulesCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      sourceDate: sourceDate ?? this.sourceDate,
      targetDate: targetDate ?? this.targetDate,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      undoneAt: undoneAt ?? this.undoneAt,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (sourceDate.present) {
      map['source_date'] = Variable<String>(sourceDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(targetDate.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ReschedulesTable.$converterkind.toSql(kind.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (undoneAt.present) {
      map['undone_at'] = Variable<DateTime>(undoneAt.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReschedulesCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('sourceDate: $sourceDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('undoneAt: $undoneAt, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionAdjustmentsTable extends SessionAdjustments
    with TableInfo<$SessionAdjustmentsTable, AdjustmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedMeta = const VerificationMeta(
    'applied',
  );
  @override
  late final GeneratedColumn<bool> applied = GeneratedColumn<bool>(
    'applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("applied" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dateKey, applied, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdjustmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('applied')) {
      context.handle(
        _appliedMeta,
        applied.isAcceptableOrUnknown(data['applied']!, _appliedMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey};
  @override
  AdjustmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdjustmentRow(
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      applied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}applied'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionAdjustmentsTable createAlias(String alias) {
    return $SessionAdjustmentsTable(attachedDatabase, alias);
  }
}

class AdjustmentRow extends DataClass implements Insertable<AdjustmentRow> {
  final String dateKey;
  final bool applied;
  final DateTime updatedAt;
  const AdjustmentRow({
    required this.dateKey,
    required this.applied,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    map['applied'] = Variable<bool>(applied);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return SessionAdjustmentsCompanion(
      dateKey: Value(dateKey),
      applied: Value(applied),
      updatedAt: Value(updatedAt),
    );
  }

  factory AdjustmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdjustmentRow(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      applied: serializer.fromJson<bool>(json['applied']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'applied': serializer.toJson<bool>(applied),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AdjustmentRow copyWith({
    String? dateKey,
    bool? applied,
    DateTime? updatedAt,
  }) => AdjustmentRow(
    dateKey: dateKey ?? this.dateKey,
    applied: applied ?? this.applied,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AdjustmentRow copyWithCompanion(SessionAdjustmentsCompanion data) {
    return AdjustmentRow(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      applied: data.applied.present ? data.applied.value : this.applied,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentRow(')
          ..write('dateKey: $dateKey, ')
          ..write('applied: $applied, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateKey, applied, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdjustmentRow &&
          other.dateKey == this.dateKey &&
          other.applied == this.applied &&
          other.updatedAt == this.updatedAt);
}

class SessionAdjustmentsCompanion extends UpdateCompanion<AdjustmentRow> {
  final Value<String> dateKey;
  final Value<bool> applied;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionAdjustmentsCompanion({
    this.dateKey = const Value.absent(),
    this.applied = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionAdjustmentsCompanion.insert({
    required String dateKey,
    required bool applied,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : dateKey = Value(dateKey),
       applied = Value(applied),
       updatedAt = Value(updatedAt);
  static Insertable<AdjustmentRow> custom({
    Expression<String>? dateKey,
    Expression<bool>? applied,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (applied != null) 'applied': applied,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionAdjustmentsCompanion copyWith({
    Value<String>? dateKey,
    Value<bool>? applied,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionAdjustmentsCompanion(
      dateKey: dateKey ?? this.dateKey,
      applied: applied ?? this.applied,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (applied.present) {
      map['applied'] = Variable<bool>(applied.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionAdjustmentsCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('applied: $applied, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProgressionDecisionsTable extends ProgressionDecisions
    with TableInfo<$ProgressionDecisionsTable, ProgressionDecisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressionDecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<String> ruleVersion = GeneratedColumn<String>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProgressionKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProgressionKind>(
        $ProgressionDecisionsTable.$converterkind,
      );
  static const VerificationMeta _basedOnMeta = const VerificationMeta(
    'basedOn',
  );
  @override
  late final GeneratedColumn<String> basedOn = GeneratedColumn<String>(
    'based_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DecisionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DecisionStatus>(
        $ProgressionDecisionsTable.$converterstatus,
      );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromKgMeta = const VerificationMeta('fromKg');
  @override
  late final GeneratedColumn<double> fromKg = GeneratedColumn<double>(
    'from_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toKgMeta = const VerificationMeta('toKg');
  @override
  late final GeneratedColumn<double> toKg = GeneratedColumn<double>(
    'to_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    exerciseId,
    ruleVersion,
    kind,
    basedOn,
    status,
    decidedAt,
    fromKg,
    toKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progression_decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgressionDecisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('based_on')) {
      context.handle(
        _basedOnMeta,
        basedOn.isAcceptableOrUnknown(data['based_on']!, _basedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_basedOnMeta);
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    if (data.containsKey('from_kg')) {
      context.handle(
        _fromKgMeta,
        fromKg.isAcceptableOrUnknown(data['from_kg']!, _fromKgMeta),
      );
    }
    if (data.containsKey('to_kg')) {
      context.handle(
        _toKgMeta,
        toKg.isAcceptableOrUnknown(data['to_kg']!, _toKgMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {exerciseId, basedOn, ruleVersion},
  ];
  @override
  ProgressionDecisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressionDecisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_version'],
      )!,
      kind: $ProgressionDecisionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      basedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}based_on'],
      )!,
      status: $ProgressionDecisionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      )!,
      fromKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}from_kg'],
      ),
      toKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}to_kg'],
      ),
    );
  }

  @override
  $ProgressionDecisionsTable createAlias(String alias) {
    return $ProgressionDecisionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProgressionKind, String, String> $converterkind =
      const EnumNameConverter<ProgressionKind>(ProgressionKind.values);
  static JsonTypeConverter2<DecisionStatus, String, String> $converterstatus =
      const EnumNameConverter<DecisionStatus>(DecisionStatus.values);
}

class ProgressionDecisionRow extends DataClass
    implements Insertable<ProgressionDecisionRow> {
  final String id;
  final int seq;
  final String exerciseId;
  final String ruleVersion;
  final ProgressionKind kind;
  final String basedOn;
  final DecisionStatus status;
  final DateTime decidedAt;
  final double? fromKg;
  final double? toKg;
  const ProgressionDecisionRow({
    required this.id,
    required this.seq,
    required this.exerciseId,
    required this.ruleVersion,
    required this.kind,
    required this.basedOn,
    required this.status,
    required this.decidedAt,
    this.fromKg,
    this.toKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['rule_version'] = Variable<String>(ruleVersion);
    {
      map['kind'] = Variable<String>(
        $ProgressionDecisionsTable.$converterkind.toSql(kind),
      );
    }
    map['based_on'] = Variable<String>(basedOn);
    {
      map['status'] = Variable<String>(
        $ProgressionDecisionsTable.$converterstatus.toSql(status),
      );
    }
    map['decided_at'] = Variable<DateTime>(decidedAt);
    if (!nullToAbsent || fromKg != null) {
      map['from_kg'] = Variable<double>(fromKg);
    }
    if (!nullToAbsent || toKg != null) {
      map['to_kg'] = Variable<double>(toKg);
    }
    return map;
  }

  ProgressionDecisionsCompanion toCompanion(bool nullToAbsent) {
    return ProgressionDecisionsCompanion(
      id: Value(id),
      seq: Value(seq),
      exerciseId: Value(exerciseId),
      ruleVersion: Value(ruleVersion),
      kind: Value(kind),
      basedOn: Value(basedOn),
      status: Value(status),
      decidedAt: Value(decidedAt),
      fromKg: fromKg == null && nullToAbsent
          ? const Value.absent()
          : Value(fromKg),
      toKg: toKg == null && nullToAbsent ? const Value.absent() : Value(toKg),
    );
  }

  factory ProgressionDecisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressionDecisionRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      ruleVersion: serializer.fromJson<String>(json['ruleVersion']),
      kind: $ProgressionDecisionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      basedOn: serializer.fromJson<String>(json['basedOn']),
      status: $ProgressionDecisionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
      fromKg: serializer.fromJson<double?>(json['fromKg']),
      toKg: serializer.fromJson<double?>(json['toKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'ruleVersion': serializer.toJson<String>(ruleVersion),
      'kind': serializer.toJson<String>(
        $ProgressionDecisionsTable.$converterkind.toJson(kind),
      ),
      'basedOn': serializer.toJson<String>(basedOn),
      'status': serializer.toJson<String>(
        $ProgressionDecisionsTable.$converterstatus.toJson(status),
      ),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
      'fromKg': serializer.toJson<double?>(fromKg),
      'toKg': serializer.toJson<double?>(toKg),
    };
  }

  ProgressionDecisionRow copyWith({
    String? id,
    int? seq,
    String? exerciseId,
    String? ruleVersion,
    ProgressionKind? kind,
    String? basedOn,
    DecisionStatus? status,
    DateTime? decidedAt,
    Value<double?> fromKg = const Value.absent(),
    Value<double?> toKg = const Value.absent(),
  }) => ProgressionDecisionRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    exerciseId: exerciseId ?? this.exerciseId,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    kind: kind ?? this.kind,
    basedOn: basedOn ?? this.basedOn,
    status: status ?? this.status,
    decidedAt: decidedAt ?? this.decidedAt,
    fromKg: fromKg.present ? fromKg.value : this.fromKg,
    toKg: toKg.present ? toKg.value : this.toKg,
  );
  ProgressionDecisionRow copyWithCompanion(ProgressionDecisionsCompanion data) {
    return ProgressionDecisionRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      kind: data.kind.present ? data.kind.value : this.kind,
      basedOn: data.basedOn.present ? data.basedOn.value : this.basedOn,
      status: data.status.present ? data.status.value : this.status,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
      fromKg: data.fromKg.present ? data.fromKg.value : this.fromKg,
      toKg: data.toKg.present ? data.toKg.value : this.toKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgressionDecisionRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('kind: $kind, ')
          ..write('basedOn: $basedOn, ')
          ..write('status: $status, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('fromKg: $fromKg, ')
          ..write('toKg: $toKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    exerciseId,
    ruleVersion,
    kind,
    basedOn,
    status,
    decidedAt,
    fromKg,
    toKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressionDecisionRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.exerciseId == this.exerciseId &&
          other.ruleVersion == this.ruleVersion &&
          other.kind == this.kind &&
          other.basedOn == this.basedOn &&
          other.status == this.status &&
          other.decidedAt == this.decidedAt &&
          other.fromKg == this.fromKg &&
          other.toKg == this.toKg);
}

class ProgressionDecisionsCompanion
    extends UpdateCompanion<ProgressionDecisionRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> exerciseId;
  final Value<String> ruleVersion;
  final Value<ProgressionKind> kind;
  final Value<String> basedOn;
  final Value<DecisionStatus> status;
  final Value<DateTime> decidedAt;
  final Value<double?> fromKg;
  final Value<double?> toKg;
  final Value<int> rowid;
  const ProgressionDecisionsCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.kind = const Value.absent(),
    this.basedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.fromKg = const Value.absent(),
    this.toKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProgressionDecisionsCompanion.insert({
    required String id,
    required int seq,
    required String exerciseId,
    required String ruleVersion,
    required ProgressionKind kind,
    required String basedOn,
    required DecisionStatus status,
    required DateTime decidedAt,
    this.fromKg = const Value.absent(),
    this.toKg = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       exerciseId = Value(exerciseId),
       ruleVersion = Value(ruleVersion),
       kind = Value(kind),
       basedOn = Value(basedOn),
       status = Value(status),
       decidedAt = Value(decidedAt);
  static Insertable<ProgressionDecisionRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? exerciseId,
    Expression<String>? ruleVersion,
    Expression<String>? kind,
    Expression<String>? basedOn,
    Expression<String>? status,
    Expression<DateTime>? decidedAt,
    Expression<double>? fromKg,
    Expression<double>? toKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (kind != null) 'kind': kind,
      if (basedOn != null) 'based_on': basedOn,
      if (status != null) 'status': status,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (fromKg != null) 'from_kg': fromKg,
      if (toKg != null) 'to_kg': toKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProgressionDecisionsCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? exerciseId,
    Value<String>? ruleVersion,
    Value<ProgressionKind>? kind,
    Value<String>? basedOn,
    Value<DecisionStatus>? status,
    Value<DateTime>? decidedAt,
    Value<double?>? fromKg,
    Value<double?>? toKg,
    Value<int>? rowid,
  }) {
    return ProgressionDecisionsCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      exerciseId: exerciseId ?? this.exerciseId,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      kind: kind ?? this.kind,
      basedOn: basedOn ?? this.basedOn,
      status: status ?? this.status,
      decidedAt: decidedAt ?? this.decidedAt,
      fromKg: fromKg ?? this.fromKg,
      toKg: toKg ?? this.toKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<String>(ruleVersion.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ProgressionDecisionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (basedOn.present) {
      map['based_on'] = Variable<String>(basedOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ProgressionDecisionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (fromKg.present) {
      map['from_kg'] = Variable<double>(fromKg.value);
    }
    if (toKg.present) {
      map['to_kg'] = Variable<double>(toKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressionDecisionsCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('kind: $kind, ')
          ..write('basedOn: $basedOn, ')
          ..write('status: $status, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('fromKg: $fromKg, ')
          ..write('toKg: $toKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlyReviewsTable extends MonthlyReviews
    with TableInfo<$MonthlyReviewsTable, MonthlyReviewRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _reviewedOnMeta = const VerificationMeta(
    'reviewedOn',
  );
  @override
  late final GeneratedColumn<String> reviewedOn = GeneratedColumn<String>(
    'reviewed_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReviewOutcome, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReviewOutcome>($MonthlyReviewsTable.$converteroutcome);
  static const VerificationMeta _rulesVersionMeta = const VerificationMeta(
    'rulesVersion',
  );
  @override
  late final GeneratedColumn<String> rulesVersion = GeneratedColumn<String>(
    'rules_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionsDoneMeta = const VerificationMeta(
    'sessionsDone',
  );
  @override
  late final GeneratedColumn<int> sessionsDone = GeneratedColumn<int>(
    'sessions_done',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionsDueMeta = const VerificationMeta(
    'sessionsDue',
  );
  @override
  late final GeneratedColumn<int> sessionsDue = GeneratedColumn<int>(
    'sessions_due',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposalMeta = const VerificationMeta(
    'proposal',
  );
  @override
  late final GeneratedColumn<String> proposal = GeneratedColumn<String>(
    'proposal',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    seq,
    reviewedOn,
    outcome,
    rulesVersion,
    sessionsDone,
    sessionsDue,
    answers,
    proposal,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyReviewRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('reviewed_on')) {
      context.handle(
        _reviewedOnMeta,
        reviewedOn.isAcceptableOrUnknown(data['reviewed_on']!, _reviewedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedOnMeta);
    }
    if (data.containsKey('rules_version')) {
      context.handle(
        _rulesVersionMeta,
        rulesVersion.isAcceptableOrUnknown(
          data['rules_version']!,
          _rulesVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rulesVersionMeta);
    }
    if (data.containsKey('sessions_done')) {
      context.handle(
        _sessionsDoneMeta,
        sessionsDone.isAcceptableOrUnknown(
          data['sessions_done']!,
          _sessionsDoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionsDoneMeta);
    }
    if (data.containsKey('sessions_due')) {
      context.handle(
        _sessionsDueMeta,
        sessionsDue.isAcceptableOrUnknown(
          data['sessions_due']!,
          _sessionsDueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionsDueMeta);
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    } else if (isInserting) {
      context.missing(_answersMeta);
    }
    if (data.containsKey('proposal')) {
      context.handle(
        _proposalMeta,
        proposal.isAcceptableOrUnknown(data['proposal']!, _proposalMeta),
      );
    } else if (isInserting) {
      context.missing(_proposalMeta);
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
  MonthlyReviewRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyReviewRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      reviewedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_on'],
      )!,
      outcome: $MonthlyReviewsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      rulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules_version'],
      )!,
      sessionsDone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_done'],
      )!,
      sessionsDue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_due'],
      )!,
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
      proposal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposal'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MonthlyReviewsTable createAlias(String alias) {
    return $MonthlyReviewsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReviewOutcome, String, String> $converteroutcome =
      const EnumNameConverter<ReviewOutcome>(ReviewOutcome.values);
}

class MonthlyReviewRow extends DataClass
    implements Insertable<MonthlyReviewRow> {
  final String id;
  final int seq;
  final String reviewedOn;
  final ReviewOutcome outcome;
  final String rulesVersion;
  final int sessionsDone;
  final int sessionsDue;
  final String answers;
  final String proposal;
  final DateTime createdAt;
  const MonthlyReviewRow({
    required this.id,
    required this.seq,
    required this.reviewedOn,
    required this.outcome,
    required this.rulesVersion,
    required this.sessionsDone,
    required this.sessionsDue,
    required this.answers,
    required this.proposal,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['reviewed_on'] = Variable<String>(reviewedOn);
    {
      map['outcome'] = Variable<String>(
        $MonthlyReviewsTable.$converteroutcome.toSql(outcome),
      );
    }
    map['rules_version'] = Variable<String>(rulesVersion);
    map['sessions_done'] = Variable<int>(sessionsDone);
    map['sessions_due'] = Variable<int>(sessionsDue);
    map['answers'] = Variable<String>(answers);
    map['proposal'] = Variable<String>(proposal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MonthlyReviewsCompanion toCompanion(bool nullToAbsent) {
    return MonthlyReviewsCompanion(
      id: Value(id),
      seq: Value(seq),
      reviewedOn: Value(reviewedOn),
      outcome: Value(outcome),
      rulesVersion: Value(rulesVersion),
      sessionsDone: Value(sessionsDone),
      sessionsDue: Value(sessionsDue),
      answers: Value(answers),
      proposal: Value(proposal),
      createdAt: Value(createdAt),
    );
  }

  factory MonthlyReviewRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyReviewRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      reviewedOn: serializer.fromJson<String>(json['reviewedOn']),
      outcome: $MonthlyReviewsTable.$converteroutcome.fromJson(
        serializer.fromJson<String>(json['outcome']),
      ),
      rulesVersion: serializer.fromJson<String>(json['rulesVersion']),
      sessionsDone: serializer.fromJson<int>(json['sessionsDone']),
      sessionsDue: serializer.fromJson<int>(json['sessionsDue']),
      answers: serializer.fromJson<String>(json['answers']),
      proposal: serializer.fromJson<String>(json['proposal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'reviewedOn': serializer.toJson<String>(reviewedOn),
      'outcome': serializer.toJson<String>(
        $MonthlyReviewsTable.$converteroutcome.toJson(outcome),
      ),
      'rulesVersion': serializer.toJson<String>(rulesVersion),
      'sessionsDone': serializer.toJson<int>(sessionsDone),
      'sessionsDue': serializer.toJson<int>(sessionsDue),
      'answers': serializer.toJson<String>(answers),
      'proposal': serializer.toJson<String>(proposal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MonthlyReviewRow copyWith({
    String? id,
    int? seq,
    String? reviewedOn,
    ReviewOutcome? outcome,
    String? rulesVersion,
    int? sessionsDone,
    int? sessionsDue,
    String? answers,
    String? proposal,
    DateTime? createdAt,
  }) => MonthlyReviewRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    reviewedOn: reviewedOn ?? this.reviewedOn,
    outcome: outcome ?? this.outcome,
    rulesVersion: rulesVersion ?? this.rulesVersion,
    sessionsDone: sessionsDone ?? this.sessionsDone,
    sessionsDue: sessionsDue ?? this.sessionsDue,
    answers: answers ?? this.answers,
    proposal: proposal ?? this.proposal,
    createdAt: createdAt ?? this.createdAt,
  );
  MonthlyReviewRow copyWithCompanion(MonthlyReviewsCompanion data) {
    return MonthlyReviewRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      reviewedOn: data.reviewedOn.present
          ? data.reviewedOn.value
          : this.reviewedOn,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      rulesVersion: data.rulesVersion.present
          ? data.rulesVersion.value
          : this.rulesVersion,
      sessionsDone: data.sessionsDone.present
          ? data.sessionsDone.value
          : this.sessionsDone,
      sessionsDue: data.sessionsDue.present
          ? data.sessionsDue.value
          : this.sessionsDue,
      answers: data.answers.present ? data.answers.value : this.answers,
      proposal: data.proposal.present ? data.proposal.value : this.proposal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyReviewRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('reviewedOn: $reviewedOn, ')
          ..write('outcome: $outcome, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('sessionsDone: $sessionsDone, ')
          ..write('sessionsDue: $sessionsDue, ')
          ..write('answers: $answers, ')
          ..write('proposal: $proposal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    reviewedOn,
    outcome,
    rulesVersion,
    sessionsDone,
    sessionsDue,
    answers,
    proposal,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyReviewRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.reviewedOn == this.reviewedOn &&
          other.outcome == this.outcome &&
          other.rulesVersion == this.rulesVersion &&
          other.sessionsDone == this.sessionsDone &&
          other.sessionsDue == this.sessionsDue &&
          other.answers == this.answers &&
          other.proposal == this.proposal &&
          other.createdAt == this.createdAt);
}

class MonthlyReviewsCompanion extends UpdateCompanion<MonthlyReviewRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> reviewedOn;
  final Value<ReviewOutcome> outcome;
  final Value<String> rulesVersion;
  final Value<int> sessionsDone;
  final Value<int> sessionsDue;
  final Value<String> answers;
  final Value<String> proposal;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MonthlyReviewsCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.reviewedOn = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rulesVersion = const Value.absent(),
    this.sessionsDone = const Value.absent(),
    this.sessionsDue = const Value.absent(),
    this.answers = const Value.absent(),
    this.proposal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyReviewsCompanion.insert({
    required String id,
    required int seq,
    required String reviewedOn,
    required ReviewOutcome outcome,
    required String rulesVersion,
    required int sessionsDone,
    required int sessionsDue,
    required String answers,
    required String proposal,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       reviewedOn = Value(reviewedOn),
       outcome = Value(outcome),
       rulesVersion = Value(rulesVersion),
       sessionsDone = Value(sessionsDone),
       sessionsDue = Value(sessionsDue),
       answers = Value(answers),
       proposal = Value(proposal),
       createdAt = Value(createdAt);
  static Insertable<MonthlyReviewRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? reviewedOn,
    Expression<String>? outcome,
    Expression<String>? rulesVersion,
    Expression<int>? sessionsDone,
    Expression<int>? sessionsDue,
    Expression<String>? answers,
    Expression<String>? proposal,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (reviewedOn != null) 'reviewed_on': reviewedOn,
      if (outcome != null) 'outcome': outcome,
      if (rulesVersion != null) 'rules_version': rulesVersion,
      if (sessionsDone != null) 'sessions_done': sessionsDone,
      if (sessionsDue != null) 'sessions_due': sessionsDue,
      if (answers != null) 'answers': answers,
      if (proposal != null) 'proposal': proposal,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyReviewsCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? reviewedOn,
    Value<ReviewOutcome>? outcome,
    Value<String>? rulesVersion,
    Value<int>? sessionsDone,
    Value<int>? sessionsDue,
    Value<String>? answers,
    Value<String>? proposal,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MonthlyReviewsCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      reviewedOn: reviewedOn ?? this.reviewedOn,
      outcome: outcome ?? this.outcome,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      sessionsDone: sessionsDone ?? this.sessionsDone,
      sessionsDue: sessionsDue ?? this.sessionsDue,
      answers: answers ?? this.answers,
      proposal: proposal ?? this.proposal,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (reviewedOn.present) {
      map['reviewed_on'] = Variable<String>(reviewedOn.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $MonthlyReviewsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (rulesVersion.present) {
      map['rules_version'] = Variable<String>(rulesVersion.value);
    }
    if (sessionsDone.present) {
      map['sessions_done'] = Variable<int>(sessionsDone.value);
    }
    if (sessionsDue.present) {
      map['sessions_due'] = Variable<int>(sessionsDue.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (proposal.present) {
      map['proposal'] = Variable<String>(proposal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyReviewsCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('reviewedOn: $reviewedOn, ')
          ..write('outcome: $outcome, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('sessionsDone: $sessionsDone, ')
          ..write('sessionsDue: $sessionsDue, ')
          ..write('answers: $answers, ')
          ..write('proposal: $proposal, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardioSessionsTable extends CardioSessions
    with TableInfo<$CardioSessionsTable, CardioSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardioSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CardioActivity, String> activity =
      GeneratedColumn<String>(
        'activity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CardioActivity>($CardioSessionsTable.$converteractivity);
  static const VerificationMeta _targetMinutesMeta = const VerificationMeta(
    'targetMinutes',
  );
  @override
  late final GeneratedColumn<int> targetMinutes = GeneratedColumn<int>(
    'target_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CardioStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CardioStatus>($CardioSessionsTable.$converterstatus);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Feeling?, String> feedback =
      GeneratedColumn<String>(
        'feedback',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Feeling?>($CardioSessionsTable.$converterfeedbackn);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationCorrectedMeta = const VerificationMeta(
    'durationCorrected',
  );
  @override
  late final GeneratedColumn<bool> durationCorrected = GeneratedColumn<bool>(
    'duration_corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duration_corrected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    activity,
    targetMinutes,
    status,
    startedAt,
    finishedAt,
    feedback,
    note,
    durationCorrected,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cardio_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardioSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('target_minutes')) {
      context.handle(
        _targetMinutesMeta,
        targetMinutes.isAcceptableOrUnknown(
          data['target_minutes']!,
          _targetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('duration_corrected')) {
      context.handle(
        _durationCorrectedMeta,
        durationCorrected.isAcceptableOrUnknown(
          data['duration_corrected']!,
          _durationCorrectedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardioSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardioSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      activity: $CardioSessionsTable.$converteractivity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity'],
        )!,
      ),
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      ),
      status: $CardioSessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      feedback: $CardioSessionsTable.$converterfeedbackn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feedback'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      durationCorrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duration_corrected'],
      )!,
    );
  }

  @override
  $CardioSessionsTable createAlias(String alias) {
    return $CardioSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CardioActivity, String, String> $converteractivity =
      const EnumNameConverter<CardioActivity>(CardioActivity.values);
  static JsonTypeConverter2<CardioStatus, String, String> $converterstatus =
      const EnumNameConverter<CardioStatus>(CardioStatus.values);
  static JsonTypeConverter2<Feeling, String, String> $converterfeedback =
      const EnumNameConverter<Feeling>(Feeling.values);
  static JsonTypeConverter2<Feeling?, String?, String?> $converterfeedbackn =
      JsonTypeConverter2.asNullable($converterfeedback);
}

class CardioSessionRow extends DataClass
    implements Insertable<CardioSessionRow> {
  final String id;
  final int seq;
  final CardioActivity activity;
  final int? targetMinutes;
  final CardioStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Feeling? feedback;
  final String note;
  final bool durationCorrected;
  const CardioSessionRow({
    required this.id,
    required this.seq,
    required this.activity,
    this.targetMinutes,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.feedback,
    required this.note,
    required this.durationCorrected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    {
      map['activity'] = Variable<String>(
        $CardioSessionsTable.$converteractivity.toSql(activity),
      );
    }
    if (!nullToAbsent || targetMinutes != null) {
      map['target_minutes'] = Variable<int>(targetMinutes);
    }
    {
      map['status'] = Variable<String>(
        $CardioSessionsTable.$converterstatus.toSql(status),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(
        $CardioSessionsTable.$converterfeedbackn.toSql(feedback),
      );
    }
    map['note'] = Variable<String>(note);
    map['duration_corrected'] = Variable<bool>(durationCorrected);
    return map;
  }

  CardioSessionsCompanion toCompanion(bool nullToAbsent) {
    return CardioSessionsCompanion(
      id: Value(id),
      seq: Value(seq),
      activity: Value(activity),
      targetMinutes: targetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMinutes),
      status: Value(status),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
      note: Value(note),
      durationCorrected: Value(durationCorrected),
    );
  }

  factory CardioSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardioSessionRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      activity: $CardioSessionsTable.$converteractivity.fromJson(
        serializer.fromJson<String>(json['activity']),
      ),
      targetMinutes: serializer.fromJson<int?>(json['targetMinutes']),
      status: $CardioSessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      feedback: $CardioSessionsTable.$converterfeedbackn.fromJson(
        serializer.fromJson<String?>(json['feedback']),
      ),
      note: serializer.fromJson<String>(json['note']),
      durationCorrected: serializer.fromJson<bool>(json['durationCorrected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'activity': serializer.toJson<String>(
        $CardioSessionsTable.$converteractivity.toJson(activity),
      ),
      'targetMinutes': serializer.toJson<int?>(targetMinutes),
      'status': serializer.toJson<String>(
        $CardioSessionsTable.$converterstatus.toJson(status),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'feedback': serializer.toJson<String?>(
        $CardioSessionsTable.$converterfeedbackn.toJson(feedback),
      ),
      'note': serializer.toJson<String>(note),
      'durationCorrected': serializer.toJson<bool>(durationCorrected),
    };
  }

  CardioSessionRow copyWith({
    String? id,
    int? seq,
    CardioActivity? activity,
    Value<int?> targetMinutes = const Value.absent(),
    CardioStatus? status,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<Feeling?> feedback = const Value.absent(),
    String? note,
    bool? durationCorrected,
  }) => CardioSessionRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    activity: activity ?? this.activity,
    targetMinutes: targetMinutes.present
        ? targetMinutes.value
        : this.targetMinutes,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    feedback: feedback.present ? feedback.value : this.feedback,
    note: note ?? this.note,
    durationCorrected: durationCorrected ?? this.durationCorrected,
  );
  CardioSessionRow copyWithCompanion(CardioSessionsCompanion data) {
    return CardioSessionRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      activity: data.activity.present ? data.activity.value : this.activity,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      note: data.note.present ? data.note.value : this.note,
      durationCorrected: data.durationCorrected.present
          ? data.durationCorrected.value
          : this.durationCorrected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardioSessionRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('activity: $activity, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('feedback: $feedback, ')
          ..write('note: $note, ')
          ..write('durationCorrected: $durationCorrected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    activity,
    targetMinutes,
    status,
    startedAt,
    finishedAt,
    feedback,
    note,
    durationCorrected,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardioSessionRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.activity == this.activity &&
          other.targetMinutes == this.targetMinutes &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.feedback == this.feedback &&
          other.note == this.note &&
          other.durationCorrected == this.durationCorrected);
}

class CardioSessionsCompanion extends UpdateCompanion<CardioSessionRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<CardioActivity> activity;
  final Value<int?> targetMinutes;
  final Value<CardioStatus> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<Feeling?> feedback;
  final Value<String> note;
  final Value<bool> durationCorrected;
  final Value<int> rowid;
  const CardioSessionsCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.activity = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.feedback = const Value.absent(),
    this.note = const Value.absent(),
    this.durationCorrected = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardioSessionsCompanion.insert({
    required String id,
    required int seq,
    required CardioActivity activity,
    this.targetMinutes = const Value.absent(),
    required CardioStatus status,
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.feedback = const Value.absent(),
    required String note,
    this.durationCorrected = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       activity = Value(activity),
       status = Value(status),
       startedAt = Value(startedAt),
       note = Value(note);
  static Insertable<CardioSessionRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? activity,
    Expression<int>? targetMinutes,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? feedback,
    Expression<String>? note,
    Expression<bool>? durationCorrected,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (activity != null) 'activity': activity,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (feedback != null) 'feedback': feedback,
      if (note != null) 'note': note,
      if (durationCorrected != null) 'duration_corrected': durationCorrected,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardioSessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<CardioActivity>? activity,
    Value<int?>? targetMinutes,
    Value<CardioStatus>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<Feeling?>? feedback,
    Value<String>? note,
    Value<bool>? durationCorrected,
    Value<int>? rowid,
  }) {
    return CardioSessionsCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      activity: activity ?? this.activity,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      feedback: feedback ?? this.feedback,
      note: note ?? this.note,
      durationCorrected: durationCorrected ?? this.durationCorrected,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (activity.present) {
      map['activity'] = Variable<String>(
        $CardioSessionsTable.$converteractivity.toSql(activity.value),
      );
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CardioSessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(
        $CardioSessionsTable.$converterfeedbackn.toSql(feedback.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (durationCorrected.present) {
      map['duration_corrected'] = Variable<bool>(durationCorrected.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardioSessionsCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('activity: $activity, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('feedback: $feedback, ')
          ..write('note: $note, ')
          ..write('durationCorrected: $durationCorrected, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardioSegmentsTable extends CardioSegments
    with TableInfo<$CardioSegmentsTable, CardioSegmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardioSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cardio_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CardioIntensity, String>
  intensity = GeneratedColumn<String>(
    'intensity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CardioIntensity>($CardioSegmentsTable.$converterintensity);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    check: () => ComparableExpr(weightKg).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    position,
    startedAt,
    endedAt,
    intensity,
    weightKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cardio_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardioSegmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, position},
  ];
  @override
  CardioSegmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardioSegmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      intensity: $CardioSegmentsTable.$converterintensity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}intensity'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
    );
  }

  @override
  $CardioSegmentsTable createAlias(String alias) {
    return $CardioSegmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CardioIntensity, String, String>
  $converterintensity = const EnumNameConverter<CardioIntensity>(
    CardioIntensity.values,
  );
}

class CardioSegmentRow extends DataClass
    implements Insertable<CardioSegmentRow> {
  final String id;
  final String sessionId;
  final int position;
  final DateTime startedAt;
  final DateTime? endedAt;
  final CardioIntensity intensity;
  final double? weightKg;
  const CardioSegmentRow({
    required this.id,
    required this.sessionId,
    required this.position,
    required this.startedAt,
    this.endedAt,
    required this.intensity,
    this.weightKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['position'] = Variable<int>(position);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    {
      map['intensity'] = Variable<String>(
        $CardioSegmentsTable.$converterintensity.toSql(intensity),
      );
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    return map;
  }

  CardioSegmentsCompanion toCompanion(bool nullToAbsent) {
    return CardioSegmentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      position: Value(position),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      intensity: Value(intensity),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
    );
  }

  factory CardioSegmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardioSegmentRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      position: serializer.fromJson<int>(json['position']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      intensity: $CardioSegmentsTable.$converterintensity.fromJson(
        serializer.fromJson<String>(json['intensity']),
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'position': serializer.toJson<int>(position),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'intensity': serializer.toJson<String>(
        $CardioSegmentsTable.$converterintensity.toJson(intensity),
      ),
      'weightKg': serializer.toJson<double?>(weightKg),
    };
  }

  CardioSegmentRow copyWith({
    String? id,
    String? sessionId,
    int? position,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    CardioIntensity? intensity,
    Value<double?> weightKg = const Value.absent(),
  }) => CardioSegmentRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    intensity: intensity ?? this.intensity,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
  );
  CardioSegmentRow copyWithCompanion(CardioSegmentsCompanion data) {
    return CardioSegmentRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardioSegmentRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('intensity: $intensity, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    position,
    startedAt,
    endedAt,
    intensity,
    weightKg,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardioSegmentRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.intensity == this.intensity &&
          other.weightKg == this.weightKg);
}

class CardioSegmentsCompanion extends UpdateCompanion<CardioSegmentRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> position;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<CardioIntensity> intensity;
  final Value<double?> weightKg;
  final Value<int> rowid;
  const CardioSegmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.intensity = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardioSegmentsCompanion.insert({
    required String id,
    required String sessionId,
    required int position,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required CardioIntensity intensity,
    this.weightKg = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       position = Value(position),
       startedAt = Value(startedAt),
       intensity = Value(intensity);
  static Insertable<CardioSegmentRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? position,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? intensity,
    Expression<double>? weightKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (intensity != null) 'intensity': intensity,
      if (weightKg != null) 'weight_kg': weightKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardioSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? position,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<CardioIntensity>? intensity,
    Value<double?>? weightKg,
    Value<int>? rowid,
  }) {
    return CardioSegmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      intensity: intensity ?? this.intensity,
      weightKg: weightKg ?? this.weightKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<String>(
        $CardioSegmentsTable.$converterintensity.toSql(intensity.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardioSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('intensity: $intensity, ')
          ..write('weightKg: $weightKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodFavoritesTable extends FoodFavorites
    with TableInfo<$FoodFavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    check: () => ComparableExpr(calories).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portionMeta = const VerificationMeta(
    'portion',
  );
  @override
  late final GeneratedColumn<double> portion = GeneratedColumn<double>(
    'portion',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seq,
    name,
    calories,
    portion,
    unit,
    proteinG,
    carbsG,
    fatG,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
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
    if (data.containsKey('portion')) {
      context.handle(
        _portionMeta,
        portion.isAcceptableOrUnknown(data['portion']!, _portionMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      portion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}portion'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
    );
  }

  @override
  $FoodFavoritesTable createAlias(String alias) {
    return $FoodFavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final String id;
  final int seq;
  final String name;
  final int calories;
  final double? portion;
  final String? unit;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  const FavoriteRow({
    required this.id,
    required this.seq,
    required this.name,
    required this.calories,
    this.portion,
    this.unit,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['name'] = Variable<String>(name);
    map['calories'] = Variable<int>(calories);
    if (!nullToAbsent || portion != null) {
      map['portion'] = Variable<double>(portion);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<double>(carbsG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    return map;
  }

  FoodFavoritesCompanion toCompanion(bool nullToAbsent) {
    return FoodFavoritesCompanion(
      id: Value(id),
      seq: Value(seq),
      name: Value(name),
      calories: Value(calories),
      portion: portion == null && nullToAbsent
          ? const Value.absent()
          : Value(portion),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      name: serializer.fromJson<String>(json['name']),
      calories: serializer.fromJson<int>(json['calories']),
      portion: serializer.fromJson<double?>(json['portion']),
      unit: serializer.fromJson<String?>(json['unit']),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      carbsG: serializer.fromJson<double?>(json['carbsG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'name': serializer.toJson<String>(name),
      'calories': serializer.toJson<int>(calories),
      'portion': serializer.toJson<double?>(portion),
      'unit': serializer.toJson<String?>(unit),
      'proteinG': serializer.toJson<double?>(proteinG),
      'carbsG': serializer.toJson<double?>(carbsG),
      'fatG': serializer.toJson<double?>(fatG),
    };
  }

  FavoriteRow copyWith({
    String? id,
    int? seq,
    String? name,
    int? calories,
    Value<double?> portion = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> carbsG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
  }) => FavoriteRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    portion: portion.present ? portion.value : this.portion,
    unit: unit.present ? unit.value : this.unit,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    fatG: fatG.present ? fatG.value : this.fatG,
  );
  FavoriteRow copyWithCompanion(FoodFavoritesCompanion data) {
    return FavoriteRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      name: data.name.present ? data.name.value : this.name,
      calories: data.calories.present ? data.calories.value : this.calories,
      portion: data.portion.present ? data.portion.value : this.portion,
      unit: data.unit.present ? data.unit.value : this.unit,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('portion: $portion, ')
          ..write('unit: $unit, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seq,
    name,
    calories,
    portion,
    unit,
    proteinG,
    carbsG,
    fatG,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.name == this.name &&
          other.calories == this.calories &&
          other.portion == this.portion &&
          other.unit == this.unit &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG);
}

class FoodFavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> name;
  final Value<int> calories;
  final Value<double?> portion;
  final Value<String?> unit;
  final Value<double?> proteinG;
  final Value<double?> carbsG;
  final Value<double?> fatG;
  final Value<int> rowid;
  const FoodFavoritesCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.name = const Value.absent(),
    this.calories = const Value.absent(),
    this.portion = const Value.absent(),
    this.unit = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodFavoritesCompanion.insert({
    required String id,
    required int seq,
    required String name,
    required int calories,
    this.portion = const Value.absent(),
    this.unit = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       name = Value(name),
       calories = Value(calories);
  static Insertable<FavoriteRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? name,
    Expression<int>? calories,
    Expression<double>? portion,
    Expression<String>? unit,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (name != null) 'name': name,
      if (calories != null) 'calories': calories,
      if (portion != null) 'portion': portion,
      if (unit != null) 'unit': unit,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodFavoritesCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? name,
    Value<int>? calories,
    Value<double?>? portion,
    Value<String?>? unit,
    Value<double?>? proteinG,
    Value<double?>? carbsG,
    Value<double?>? fatG,
    Value<int>? rowid,
  }) {
    return FoodFavoritesCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      portion: portion ?? this.portion,
      unit: unit ?? this.unit,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (portion.present) {
      map['portion'] = Variable<double>(portion.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodFavoritesCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('name: $name, ')
          ..write('calories: $calories, ')
          ..write('portion: $portion, ')
          ..write('unit: $unit, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, RecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<double> servings = GeneratedColumn<double>(
    'servings',
    aliasedName,
    false,
    check: () => ComparableExpr(servings).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allergensMeta = const VerificationMeta(
    'allergens',
  );
  @override
  late final GeneratedColumn<String> allergens = GeneratedColumn<String>(
    'allergens',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    seq,
    name,
    servings,
    notes,
    tags,
    allergens,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    } else if (isInserting) {
      context.missing(_servingsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('allergens')) {
      context.handle(
        _allergensMeta,
        allergens.isAcceptableOrUnknown(data['allergens']!, _allergensMeta),
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
  RecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}servings'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      allergens: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergens'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class RecipeRow extends DataClass implements Insertable<RecipeRow> {
  final String id;
  final int seq;
  final String name;
  final double servings;
  final String notes;
  final String tags;
  final String? allergens;
  final DateTime createdAt;
  const RecipeRow({
    required this.id,
    required this.seq,
    required this.name,
    required this.servings,
    required this.notes,
    required this.tags,
    this.allergens,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seq'] = Variable<int>(seq);
    map['name'] = Variable<String>(name);
    map['servings'] = Variable<double>(servings);
    map['notes'] = Variable<String>(notes);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || allergens != null) {
      map['allergens'] = Variable<String>(allergens);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      seq: Value(seq),
      name: Value(name),
      servings: Value(servings),
      notes: Value(notes),
      tags: Value(tags),
      allergens: allergens == null && nullToAbsent
          ? const Value.absent()
          : Value(allergens),
      createdAt: Value(createdAt),
    );
  }

  factory RecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeRow(
      id: serializer.fromJson<String>(json['id']),
      seq: serializer.fromJson<int>(json['seq']),
      name: serializer.fromJson<String>(json['name']),
      servings: serializer.fromJson<double>(json['servings']),
      notes: serializer.fromJson<String>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      allergens: serializer.fromJson<String?>(json['allergens']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seq': serializer.toJson<int>(seq),
      'name': serializer.toJson<String>(name),
      'servings': serializer.toJson<double>(servings),
      'notes': serializer.toJson<String>(notes),
      'tags': serializer.toJson<String>(tags),
      'allergens': serializer.toJson<String?>(allergens),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecipeRow copyWith({
    String? id,
    int? seq,
    String? name,
    double? servings,
    String? notes,
    String? tags,
    Value<String?> allergens = const Value.absent(),
    DateTime? createdAt,
  }) => RecipeRow(
    id: id ?? this.id,
    seq: seq ?? this.seq,
    name: name ?? this.name,
    servings: servings ?? this.servings,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    allergens: allergens.present ? allergens.value : this.allergens,
    createdAt: createdAt ?? this.createdAt,
  );
  RecipeRow copyWithCompanion(RecipesCompanion data) {
    return RecipeRow(
      id: data.id.present ? data.id.value : this.id,
      seq: data.seq.present ? data.seq.value : this.seq,
      name: data.name.present ? data.name.value : this.name,
      servings: data.servings.present ? data.servings.value : this.servings,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      allergens: data.allergens.present ? data.allergens.value : this.allergens,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeRow(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('name: $name, ')
          ..write('servings: $servings, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('allergens: $allergens, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, seq, name, servings, notes, tags, allergens, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeRow &&
          other.id == this.id &&
          other.seq == this.seq &&
          other.name == this.name &&
          other.servings == this.servings &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.allergens == this.allergens &&
          other.createdAt == this.createdAt);
}

class RecipesCompanion extends UpdateCompanion<RecipeRow> {
  final Value<String> id;
  final Value<int> seq;
  final Value<String> name;
  final Value<double> servings;
  final Value<String> notes;
  final Value<String> tags;
  final Value<String?> allergens;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.seq = const Value.absent(),
    this.name = const Value.absent(),
    this.servings = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.allergens = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required int seq,
    required String name,
    required double servings,
    required String notes,
    required String tags,
    this.allergens = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seq = Value(seq),
       name = Value(name),
       servings = Value(servings),
       notes = Value(notes),
       tags = Value(tags),
       createdAt = Value(createdAt);
  static Insertable<RecipeRow> custom({
    Expression<String>? id,
    Expression<int>? seq,
    Expression<String>? name,
    Expression<double>? servings,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<String>? allergens,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seq != null) 'seq': seq,
      if (name != null) 'name': name,
      if (servings != null) 'servings': servings,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (allergens != null) 'allergens': allergens,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<int>? seq,
    Value<String>? name,
    Value<double>? servings,
    Value<String>? notes,
    Value<String>? tags,
    Value<String?>? allergens,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      seq: seq ?? this.seq,
      name: name ?? this.name,
      servings: servings ?? this.servings,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      allergens: allergens ?? this.allergens,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (servings.present) {
      map['servings'] = Variable<double>(servings.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (allergens.present) {
      map['allergens'] = Variable<String>(allergens.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('seq: $seq, ')
          ..write('name: $name, ')
          ..write('servings: $servings, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('allergens: $allergens, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, IngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    check: () => ComparableExpr(position).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    recipeId,
    position,
    name,
    quantity,
    unit,
    calories,
    proteinG,
    carbsG,
    fatG,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recipeId, position};
  @override
  IngredientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientRow(
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class IngredientRow extends DataClass implements Insertable<IngredientRow> {
  final String recipeId;
  final int position;
  final String name;
  final double? quantity;
  final String? unit;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  const IngredientRow({
    required this.recipeId,
    required this.position,
    required this.name,
    this.quantity,
    this.unit,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<double>(carbsG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      recipeId: Value(recipeId),
      position: Value(position),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
    );
  }

  factory IngredientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientRow(
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      calories: serializer.fromJson<int?>(json['calories']),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      carbsG: serializer.fromJson<double?>(json['carbsG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'calories': serializer.toJson<int?>(calories),
      'proteinG': serializer.toJson<double?>(proteinG),
      'carbsG': serializer.toJson<double?>(carbsG),
      'fatG': serializer.toJson<double?>(fatG),
    };
  }

  IngredientRow copyWith({
    String? recipeId,
    int? position,
    String? name,
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<int?> calories = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> carbsG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
  }) => IngredientRow(
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    name: name ?? this.name,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    calories: calories.present ? calories.value : this.calories,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    fatG: fatG.present ? fatG.value : this.fatG,
  );
  IngredientRow copyWithCompanion(RecipeIngredientsCompanion data) {
    return IngredientRow(
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      calories: data.calories.present ? data.calories.value : this.calories,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientRow(')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recipeId,
    position,
    name,
    quantity,
    unit,
    calories,
    proteinG,
    carbsG,
    fatG,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientRow &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.calories == this.calories &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG);
}

class RecipeIngredientsCompanion extends UpdateCompanion<IngredientRow> {
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<int?> calories;
  final Value<double?> proteinG;
  final Value<double?> carbsG;
  final Value<double?> fatG;
  final Value<int> rowid;
  const RecipeIngredientsCompanion({
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    required String recipeId,
    required int position,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.calories = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recipeId = Value(recipeId),
       position = Value(position),
       name = Value(name);
  static Insertable<IngredientRow> custom({
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? calories,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? name,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<int?>? calories,
    Value<double?>? proteinG,
    Value<double?>? carbsG,
    Value<double?>? fatG,
    Value<int>? rowid,
  }) {
    return RecipeIngredientsCompanion(
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionGoalsTableTable extends NutritionGoalsTable
    with TableInfo<$NutritionGoalsTableTable, GoalsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionGoalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kcal,
    proteinG,
    carbsG,
    fatG,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      ),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NutritionGoalsTableTable createAlias(String alias) {
    return $NutritionGoalsTableTable(attachedDatabase, alias);
  }
}

class GoalsRow extends DataClass implements Insertable<GoalsRow> {
  final int id;
  final int? kcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final DateTime updatedAt;
  const GoalsRow({
    required this.id,
    this.kcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<int>(kcal);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<double>(proteinG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<double>(carbsG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<double>(fatG);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NutritionGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return NutritionGoalsTableCompanion(
      id: Value(id),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      carbsG: carbsG == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalsRow(
      id: serializer.fromJson<int>(json['id']),
      kcal: serializer.fromJson<int?>(json['kcal']),
      proteinG: serializer.fromJson<double?>(json['proteinG']),
      carbsG: serializer.fromJson<double?>(json['carbsG']),
      fatG: serializer.fromJson<double?>(json['fatG']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kcal': serializer.toJson<int?>(kcal),
      'proteinG': serializer.toJson<double?>(proteinG),
      'carbsG': serializer.toJson<double?>(carbsG),
      'fatG': serializer.toJson<double?>(fatG),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalsRow copyWith({
    int? id,
    Value<int?> kcal = const Value.absent(),
    Value<double?> proteinG = const Value.absent(),
    Value<double?> carbsG = const Value.absent(),
    Value<double?> fatG = const Value.absent(),
    DateTime? updatedAt,
  }) => GoalsRow(
    id: id ?? this.id,
    kcal: kcal.present ? kcal.value : this.kcal,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    fatG: fatG.present ? fatG.value : this.fatG,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GoalsRow copyWithCompanion(NutritionGoalsTableCompanion data) {
    return GoalsRow(
      id: data.id.present ? data.id.value : this.id,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalsRow(')
          ..write('id: $id, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kcal, proteinG, carbsG, fatG, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalsRow &&
          other.id == this.id &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.carbsG == this.carbsG &&
          other.fatG == this.fatG &&
          other.updatedAt == this.updatedAt);
}

class NutritionGoalsTableCompanion extends UpdateCompanion<GoalsRow> {
  final Value<int> id;
  final Value<int?> kcal;
  final Value<double?> proteinG;
  final Value<double?> carbsG;
  final Value<double?> fatG;
  final Value<DateTime> updatedAt;
  const NutritionGoalsTableCompanion({
    this.id = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NutritionGoalsTableCompanion.insert({
    this.id = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.fatG = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<GoalsRow> custom({
    Expression<int>? id,
    Expression<int>? kcal,
    Expression<double>? proteinG,
    Expression<double>? carbsG,
    Expression<double>? fatG,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NutritionGoalsTableCompanion copyWith({
    Value<int>? id,
    Value<int?>? kcal,
    Value<double?>? proteinG,
    Value<double?>? carbsG,
    Value<double?>? fatG,
    Value<DateTime>? updatedAt,
  }) {
    return NutritionGoalsTableCompanion(
      id: id ?? this.id,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('carbsG: $carbsG, ')
          ..write('fatG: $fatG, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$ForjaDatabase extends GeneratedDatabase {
  _$ForjaDatabase(QueryExecutor e) : super(e);
  $ForjaDatabaseManager get managers => $ForjaDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProfileHistoryTable profileHistory = $ProfileHistoryTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(
    this,
  );
  late final $CalendarOverridesTable calendarOverrides =
      $CalendarOverridesTable(this);
  late final $CheckInsTable checkIns = $CheckInsTable(this);
  late final $FoodEntriesTable foodEntries = $FoodEntriesTable(this);
  late final $LegacyImportsTable legacyImports = $LegacyImportsTable(this);
  late final $PlanVersionsTable planVersions = $PlanVersionsTable(this);
  late final $PlanRoutinesTable planRoutines = $PlanRoutinesTable(this);
  late final $PlanRoutineExercisesTable planRoutineExercises =
      $PlanRoutineExercisesTable(this);
  late final $SetLogsTable setLogs = $SetLogsTable(this);
  late final $SessionEventsTable sessionEvents = $SessionEventsTable(this);
  late final $ReschedulesTable reschedules = $ReschedulesTable(this);
  late final $SessionAdjustmentsTable sessionAdjustments =
      $SessionAdjustmentsTable(this);
  late final $ProgressionDecisionsTable progressionDecisions =
      $ProgressionDecisionsTable(this);
  late final $MonthlyReviewsTable monthlyReviews = $MonthlyReviewsTable(this);
  late final $CardioSessionsTable cardioSessions = $CardioSessionsTable(this);
  late final $CardioSegmentsTable cardioSegments = $CardioSegmentsTable(this);
  late final $FoodFavoritesTable foodFavorites = $FoodFavoritesTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $NutritionGoalsTableTable nutritionGoalsTable =
      $NutritionGoalsTableTable(this);
  late final Index sessionExercisesExercise = Index(
    'session_exercises_exercise',
    'CREATE INDEX session_exercises_exercise ON session_exercises (exercise_id)',
  );
  late final Index foodEntriesDateKey = Index(
    'food_entries_date_key',
    'CREATE INDEX food_entries_date_key ON food_entries (date_key)',
  );
  late final Index setLogsExercise = Index(
    'set_logs_exercise',
    'CREATE INDEX set_logs_exercise ON set_logs (session_id, exercise_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    profileHistory,
    reminders,
    workoutSessions,
    sessionExercises,
    calendarOverrides,
    checkIns,
    foodEntries,
    legacyImports,
    planVersions,
    planRoutines,
    planRoutineExercises,
    setLogs,
    sessionEvents,
    reschedules,
    sessionAdjustments,
    progressionDecisions,
    monthlyReviews,
    cardioSessions,
    cardioSegments,
    foodFavorites,
    recipes,
    recipeIngredients,
    nutritionGoalsTable,
    sessionExercisesExercise,
    foodEntriesDateKey,
    setLogsExercise,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_versions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_routines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_routine_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('set_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cardio_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cardio_segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_ingredients', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required Experience experience,
  required TrainingGoal goal,
  Value<double?> weightKg,
  Value<int?> age,
  required Energy energy,
  required String note,
  required bool onboarded,
  Value<String?> lastReview,
  Value<String> equipment,
  Value<String> trainingDays,
  Value<int> sessionMinutes,
  Value<bool> setupSkipped,
  Value<int> setupStep,
  Value<WeightUnit> weightUnit,
  Value<String?> reviewSnoozeUntil,
  required DateTime updatedAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<Experience> experience,
  Value<TrainingGoal> goal,
  Value<double?> weightKg,
  Value<int?> age,
  Value<Energy> energy,
  Value<String> note,
  Value<bool> onboarded,
  Value<String?> lastReview,
  Value<String> equipment,
  Value<String> trainingDays,
  Value<int> sessionMinutes,
  Value<bool> setupSkipped,
  Value<int> setupStep,
  Value<WeightUnit> weightUnit,
  Value<String?> reviewSnoozeUntil,
  Value<DateTime> updatedAt,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$ForjaDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Experience, Experience, String>
  get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TrainingGoal, TrainingGoal, String> get goal =>
      $composableBuilder(
        column: $table.goal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Energy, Energy, String> get energy =>
      $composableBuilder(
        column: $table.energy,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainingDays => $composableBuilder(
    column: $table.trainingDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get setupSkipped => $composableBuilder(
    column: $table.setupSkipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setupStep => $composableBuilder(
    column: $table.setupStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String>
  get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reviewSnoozeUntil => $composableBuilder(
    column: $table.reviewSnoozeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get experience => $composableBuilder(
    column: $table.experience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainingDays => $composableBuilder(
    column: $table.trainingDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get setupSkipped => $composableBuilder(
    column: $table.setupSkipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setupStep => $composableBuilder(
    column: $table.setupStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewSnoozeUntil => $composableBuilder(
    column: $table.reviewSnoozeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Experience, String> get experience =>
      $composableBuilder(
        column: $table.experience,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TrainingGoal, String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Energy, String> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);

  GeneratedColumn<String> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get trainingDays => $composableBuilder(
    column: $table.trainingDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionMinutes => $composableBuilder(
    column: $table.sessionMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get setupSkipped => $composableBuilder(
    column: $table.setupSkipped,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setupStep =>
      $composableBuilder(column: $table.setupStep, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reviewSnoozeUntil => $composableBuilder(
    column: $table.reviewSnoozeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$ForjaDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$ForjaDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Experience> experience = const Value.absent(),
                Value<TrainingGoal> goal = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<Energy> energy = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
                Value<String?> lastReview = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> trainingDays = const Value.absent(),
                Value<int> sessionMinutes = const Value.absent(),
                Value<bool> setupSkipped = const Value.absent(),
                Value<int> setupStep = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<String?> reviewSnoozeUntil = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                experience: experience,
                goal: goal,
                weightKg: weightKg,
                age: age,
                energy: energy,
                note: note,
                onboarded: onboarded,
                lastReview: lastReview,
                equipment: equipment,
                trainingDays: trainingDays,
                sessionMinutes: sessionMinutes,
                setupSkipped: setupSkipped,
                setupStep: setupStep,
                weightUnit: weightUnit,
                reviewSnoozeUntil: reviewSnoozeUntil,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Experience experience,
                required TrainingGoal goal,
                Value<double?> weightKg = const Value.absent(),
                Value<int?> age = const Value.absent(),
                required Energy energy,
                required String note,
                required bool onboarded,
                Value<String?> lastReview = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> trainingDays = const Value.absent(),
                Value<int> sessionMinutes = const Value.absent(),
                Value<bool> setupSkipped = const Value.absent(),
                Value<int> setupStep = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<String?> reviewSnoozeUntil = const Value.absent(),
                required DateTime updatedAt,
              }) => ProfilesCompanion.insert(
                id: id,
                experience: experience,
                goal: goal,
                weightKg: weightKg,
                age: age,
                energy: energy,
                note: note,
                onboarded: onboarded,
                lastReview: lastReview,
                equipment: equipment,
                trainingDays: trainingDays,
                sessionMinutes: sessionMinutes,
                setupSkipped: setupSkipped,
                setupStep: setupStep,
                weightUnit: weightUnit,
                reviewSnoozeUntil: reviewSnoozeUntil,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$ForjaDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$ForjaDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ProfileHistoryTableCreateCompanionBuilder =
    ProfileHistoryCompanion Function({
      required String id,
      required int seq,
      required DateTime recordedAt,
      required ProfileChange reason,
      required String payload,
      Value<String?> rulesVersion,
      Value<int> rowid,
    });
typedef $$ProfileHistoryTableUpdateCompanionBuilder =
    ProfileHistoryCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<DateTime> recordedAt,
      Value<ProfileChange> reason,
      Value<String> payload,
      Value<String?> rulesVersion,
      Value<int> rowid,
    });

class $$ProfileHistoryTableFilterComposer
    extends Composer<_$ForjaDatabase, $ProfileHistoryTable> {
  $$ProfileHistoryTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProfileChange, ProfileChange, String>
  get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileHistoryTableOrderingComposer
    extends Composer<_$ForjaDatabase, $ProfileHistoryTable> {
  $$ProfileHistoryTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileHistoryTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $ProfileHistoryTable> {
  $$ProfileHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProfileChange, String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => column,
  );
}

class $$ProfileHistoryTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $ProfileHistoryTable,
          ProfileHistoryRow,
          $$ProfileHistoryTableFilterComposer,
          $$ProfileHistoryTableOrderingComposer,
          $$ProfileHistoryTableAnnotationComposer,
          $$ProfileHistoryTableCreateCompanionBuilder,
          $$ProfileHistoryTableUpdateCompanionBuilder,
          (
            ProfileHistoryRow,
            BaseReferences<
              _$ForjaDatabase,
              $ProfileHistoryTable,
              ProfileHistoryRow
            >,
          ),
          ProfileHistoryRow,
          PrefetchHooks Function()
        > {
  $$ProfileHistoryTableTableManager(
    _$ForjaDatabase db,
    $ProfileHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<ProfileChange> reason = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> rulesVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileHistoryCompanion(
                id: id,
                seq: seq,
                recordedAt: recordedAt,
                reason: reason,
                payload: payload,
                rulesVersion: rulesVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required DateTime recordedAt,
                required ProfileChange reason,
                required String payload,
                Value<String?> rulesVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileHistoryCompanion.insert(
                id: id,
                seq: seq,
                recordedAt: recordedAt,
                reason: reason,
                payload: payload,
                rulesVersion: rulesVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileHistoryTable, ProfileHistoryRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $ProfileHistoryTable,
                    ProfileHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $ProfileHistoryTable,
      ProfileHistoryRow,
      $$ProfileHistoryTableFilterComposer,
      $$ProfileHistoryTableOrderingComposer,
      $$ProfileHistoryTableAnnotationComposer,
      $$ProfileHistoryTableCreateCompanionBuilder,
      $$ProfileHistoryTableUpdateCompanionBuilder,
      (
        ProfileHistoryRow,
        BaseReferences<
          _$ForjaDatabase,
          $ProfileHistoryTable,
          ProfileHistoryRow
        >,
      ),
      ProfileHistoryRow,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required bool enabled,
  required int hour,
  required int minute,
  required DateTime updatedAt,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<bool> enabled,
  Value<int> hour,
  Value<int> minute,
  Value<DateTime> updatedAt,
});

class $$RemindersTableFilterComposer
    extends Composer<_$ForjaDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$ForjaDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$ForjaDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$ForjaDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                enabled: enabled,
                hour: hour,
                minute: minute,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required bool enabled,
                required int hour,
                required int minute,
                required DateTime updatedAt,
              }) => RemindersCompanion.insert(
                id: id,
                enabled: enabled,
                hour: hour,
                minute: minute,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, ReminderRow>(table),
                  BaseReferences<_$ForjaDatabase, $RemindersTable, ReminderRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$ForjaDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      required String dateKey,
      required String routineId,
      required SessionStatus status,
      Value<Feeling?> feeling,
      required String note,
      required SessionOrigin origin,
      Value<DateTime?> createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<String> dateKey,
      Value<String> routineId,
      Value<SessionStatus> status,
      Value<Feeling?> feeling,
      Value<String> note,
      Value<SessionOrigin> origin,
      Value<DateTime?> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WorkoutSessionsTableReferences
    extends BaseReferences<_$ForjaDatabase, $WorkoutSessionsTable, SessionRow> {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExerciseRow>>
  _sessionExercisesRefsTable(_$ForjaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionExercises,
        aliasName: 'workout_sessions__id__session_exercises__session_id',
      );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SetLogsTable, List<SetLogRow>> _setLogsRefsTable(
    _$ForjaDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.setLogs,
    aliasName: 'workout_sessions__id__set_logs__session_id',
  );

  $$SetLogsTableProcessedTableManager get setLogsRefs {
    final manager = $$SetLogsTableTableManager(
      $_db,
      $_db.setLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_setLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$ForjaDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
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

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Feeling?, Feeling, String> get feeling =>
      $composableBuilder(
        column: $table.feeling,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionOrigin, SessionOrigin, String>
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> setLogsRefs(
    Expression<bool> Function($$SetLogsTableFilterComposer f) f,
  ) {
    final $$SetLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetLogsTableFilterComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeling => $composableBuilder(
    column: $table.feeling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Feeling?, String> get feeling =>
      $composableBuilder(column: $table.feeling, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> setLogsRefs<T extends Object>(
    Expression<T> Function($$SetLogsTableAnnotationComposer a) f,
  ) {
    final $$SetLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.setLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.setLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $WorkoutSessionsTable,
          SessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (SessionRow, $$WorkoutSessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool sessionExercisesRefs, bool setLogsRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$ForjaDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<Feeling?> feeling = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<SessionOrigin> origin = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                dateKey: dateKey,
                routineId: routineId,
                status: status,
                feeling: feeling,
                note: note,
                origin: origin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dateKey,
                required String routineId,
                required SessionStatus status,
                Value<Feeling?> feeling = const Value.absent(),
                required String note,
                required SessionOrigin origin,
                Value<DateTime?> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                dateKey: dateKey,
                routineId: routineId,
                status: status,
                feeling: feeling,
                note: note,
                origin: origin,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, SessionRow>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionExercisesRefs = false, setLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionExercisesRefs) db.sessionExercises,
                    if (setLogsRefs) db.setLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $WorkoutSessionsTable,
                          SessionExerciseRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutSessionsTableReferences
                              ._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (setLogsRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $WorkoutSessionsTable,
                          SetLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutSessionsTableReferences
                              ._setLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).setLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $WorkoutSessionsTable,
      SessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (SessionRow, $$WorkoutSessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool sessionExercisesRefs, bool setLogsRefs})
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      required String sessionId,
      required String exerciseId,
      required int position,
      required double weightKg,
      required bool completed,
      Value<bool> skipped,
      Value<String?> skipReason,
      Value<TechniqueRating?> technique,
      Value<int> rowid,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<String> sessionId,
      Value<String> exerciseId,
      Value<int> position,
      Value<double> weightKg,
      Value<bool> completed,
      Value<bool> skipped,
      Value<String?> skipReason,
      Value<TechniqueRating?> technique,
      Value<int> rowid,
    });

final class $$SessionExercisesTableReferences
    extends
        BaseReferences<
          _$ForjaDatabase,
          $SessionExercisesTable,
          SessionExerciseRow
        > {
  $$SessionExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$ForjaDatabase db) => db
      .workoutSessions
      .createAlias('session_exercises__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionExercisesTableFilterComposer
    extends Composer<_$ForjaDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TechniqueRating?, TechniqueRating, String>
  get technique => $composableBuilder(
    column: $table.technique,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technique => $composableBuilder(
    column: $table.technique,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumn<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TechniqueRating?, String> get technique =>
      $composableBuilder(column: $table.technique, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $SessionExercisesTable,
          SessionExerciseRow,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (SessionExerciseRow, $$SessionExercisesTableReferences),
          SessionExerciseRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionExercisesTableTableManager(
    _$ForjaDatabase db,
    $SessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<TechniqueRating?> technique = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion(
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                weightKg: weightKg,
                completed: completed,
                skipped: skipped,
                skipReason: skipReason,
                technique: technique,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String exerciseId,
                required int position,
                required double weightKg,
                required bool completed,
                Value<bool> skipped = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<TechniqueRating?> technique = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                weightKg: weightKg,
                completed: completed,
                skipped: skipped,
                skipReason: skipReason,
                technique: technique,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionExercisesTable, SessionExerciseRow>(
                    table,
                  ),
                  $$SessionExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionExercisesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionExercisesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
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

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $SessionExercisesTable,
      SessionExerciseRow,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (SessionExerciseRow, $$SessionExercisesTableReferences),
      SessionExerciseRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$CalendarOverridesTableCreateCompanionBuilder =
    CalendarOverridesCompanion Function({
      required String dateKey,
      Value<String?> routineId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CalendarOverridesTableUpdateCompanionBuilder =
    CalendarOverridesCompanion Function({
      Value<String> dateKey,
      Value<String?> routineId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CalendarOverridesTableFilterComposer
    extends Composer<_$ForjaDatabase, $CalendarOverridesTable> {
  $$CalendarOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarOverridesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $CalendarOverridesTable> {
  $$CalendarOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarOverridesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $CalendarOverridesTable> {
  $$CalendarOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<String> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CalendarOverridesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $CalendarOverridesTable,
          OverrideRow,
          $$CalendarOverridesTableFilterComposer,
          $$CalendarOverridesTableOrderingComposer,
          $$CalendarOverridesTableAnnotationComposer,
          $$CalendarOverridesTableCreateCompanionBuilder,
          $$CalendarOverridesTableUpdateCompanionBuilder,
          (
            OverrideRow,
            BaseReferences<
              _$ForjaDatabase,
              $CalendarOverridesTable,
              OverrideRow
            >,
          ),
          OverrideRow,
          PrefetchHooks Function()
        > {
  $$CalendarOverridesTableTableManager(
    _$ForjaDatabase db,
    $CalendarOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> dateKey = const Value.absent(),
                Value<String?> routineId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarOverridesCompanion(
                dateKey: dateKey,
                routineId: routineId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dateKey,
                Value<String?> routineId = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CalendarOverridesCompanion.insert(
                dateKey: dateKey,
                routineId: routineId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CalendarOverridesTable, OverrideRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $CalendarOverridesTable,
                    OverrideRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $CalendarOverridesTable,
      OverrideRow,
      $$CalendarOverridesTableFilterComposer,
      $$CalendarOverridesTableOrderingComposer,
      $$CalendarOverridesTableAnnotationComposer,
      $$CalendarOverridesTableCreateCompanionBuilder,
      $$CalendarOverridesTableUpdateCompanionBuilder,
      (
        OverrideRow,
        BaseReferences<_$ForjaDatabase, $CalendarOverridesTable, OverrideRow>,
      ),
      OverrideRow,
      PrefetchHooks Function()
    >;
typedef $$CheckInsTableCreateCompanionBuilder = CheckInsCompanion Function({
  required String id,
  required String dateKey,
  Value<CheckInPhase> phase,
  required Feeling feeling,
  required String note,
  Value<DateTime?> createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CheckInsTableUpdateCompanionBuilder = CheckInsCompanion Function({
  Value<String> id,
  Value<String> dateKey,
  Value<CheckInPhase> phase,
  Value<Feeling> feeling,
  Value<String> note,
  Value<DateTime?> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CheckInsTableFilterComposer
    extends Composer<_$ForjaDatabase, $CheckInsTable> {
  $$CheckInsTableFilterComposer({
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

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CheckInPhase, CheckInPhase, String>
  get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Feeling, Feeling, String> get feeling =>
      $composableBuilder(
        column: $table.feeling,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckInsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $CheckInsTable> {
  $$CheckInsTableOrderingComposer({
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

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeling => $composableBuilder(
    column: $table.feeling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckInsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $CheckInsTable> {
  $$CheckInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CheckInPhase, String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Feeling, String> get feeling =>
      $composableBuilder(column: $table.feeling, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CheckInsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $CheckInsTable,
          CheckInRow,
          $$CheckInsTableFilterComposer,
          $$CheckInsTableOrderingComposer,
          $$CheckInsTableAnnotationComposer,
          $$CheckInsTableCreateCompanionBuilder,
          $$CheckInsTableUpdateCompanionBuilder,
          (
            CheckInRow,
            BaseReferences<_$ForjaDatabase, $CheckInsTable, CheckInRow>,
          ),
          CheckInRow,
          PrefetchHooks Function()
        > {
  $$CheckInsTableTableManager(_$ForjaDatabase db, $CheckInsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<CheckInPhase> phase = const Value.absent(),
                Value<Feeling> feeling = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckInsCompanion(
                id: id,
                dateKey: dateKey,
                phase: phase,
                feeling: feeling,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dateKey,
                Value<CheckInPhase> phase = const Value.absent(),
                required Feeling feeling,
                required String note,
                Value<DateTime?> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CheckInsCompanion.insert(
                id: id,
                dateKey: dateKey,
                phase: phase,
                feeling: feeling,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckInsTable, CheckInRow>(table),
                  BaseReferences<_$ForjaDatabase, $CheckInsTable, CheckInRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $CheckInsTable,
      CheckInRow,
      $$CheckInsTableFilterComposer,
      $$CheckInsTableOrderingComposer,
      $$CheckInsTableAnnotationComposer,
      $$CheckInsTableCreateCompanionBuilder,
      $$CheckInsTableUpdateCompanionBuilder,
      (CheckInRow, BaseReferences<_$ForjaDatabase, $CheckInsTable, CheckInRow>),
      CheckInRow,
      PrefetchHooks Function()
    >;
typedef $$FoodEntriesTableCreateCompanionBuilder =
    FoodEntriesCompanion Function({
      required String id,
      required int seq,
      required String dateKey,
      required String name,
      required int calories,
      Value<DateTime?> createdAt,
      Value<double?> portion,
      Value<String?> unit,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<CaloriesSource> caloriesSource,
      Value<String?> recipeId,
      Value<int> rowid,
    });
typedef $$FoodEntriesTableUpdateCompanionBuilder =
    FoodEntriesCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<String> dateKey,
      Value<String> name,
      Value<int> calories,
      Value<DateTime?> createdAt,
      Value<double?> portion,
      Value<String?> unit,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<CaloriesSource> caloriesSource,
      Value<String?> recipeId,
      Value<int> rowid,
    });

class $$FoodEntriesTableFilterComposer
    extends Composer<_$ForjaDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get portion => $composableBuilder(
    column: $table.portion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CaloriesSource, CaloriesSource, String>
  get caloriesSource => $composableBuilder(
    column: $table.caloriesSource,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodEntriesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get portion => $composableBuilder(
    column: $table.portion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caloriesSource => $composableBuilder(
    column: $table.caloriesSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodEntriesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $FoodEntriesTable> {
  $$FoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get portion =>
      $composableBuilder(column: $table.portion, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CaloriesSource, String> get caloriesSource =>
      $composableBuilder(
        column: $table.caloriesSource,
        builder: (column) => column,
      );

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);
}

class $$FoodEntriesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $FoodEntriesTable,
          FoodRow,
          $$FoodEntriesTableFilterComposer,
          $$FoodEntriesTableOrderingComposer,
          $$FoodEntriesTableAnnotationComposer,
          $$FoodEntriesTableCreateCompanionBuilder,
          $$FoodEntriesTableUpdateCompanionBuilder,
          (
            FoodRow,
            BaseReferences<_$ForjaDatabase, $FoodEntriesTable, FoodRow>,
          ),
          FoodRow,
          PrefetchHooks Function()
        > {
  $$FoodEntriesTableTableManager(_$ForjaDatabase db, $FoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<double?> portion = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<CaloriesSource> caloriesSource = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodEntriesCompanion(
                id: id,
                seq: seq,
                dateKey: dateKey,
                name: name,
                calories: calories,
                createdAt: createdAt,
                portion: portion,
                unit: unit,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                caloriesSource: caloriesSource,
                recipeId: recipeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String dateKey,
                required String name,
                required int calories,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<double?> portion = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<CaloriesSource> caloriesSource = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodEntriesCompanion.insert(
                id: id,
                seq: seq,
                dateKey: dateKey,
                name: name,
                calories: calories,
                createdAt: createdAt,
                portion: portion,
                unit: unit,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                caloriesSource: caloriesSource,
                recipeId: recipeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodEntriesTable, FoodRow>(table),
                  BaseReferences<_$ForjaDatabase, $FoodEntriesTable, FoodRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $FoodEntriesTable,
      FoodRow,
      $$FoodEntriesTableFilterComposer,
      $$FoodEntriesTableOrderingComposer,
      $$FoodEntriesTableAnnotationComposer,
      $$FoodEntriesTableCreateCompanionBuilder,
      $$FoodEntriesTableUpdateCompanionBuilder,
      (FoodRow, BaseReferences<_$ForjaDatabase, $FoodEntriesTable, FoodRow>),
      FoodRow,
      PrefetchHooks Function()
    >;
typedef $$LegacyImportsTableCreateCompanionBuilder =
    LegacyImportsCompanion Function({
      required String source,
      required LegacyImportStatus status,
      required DateTime importedAt,
      required int sessionCount,
      required int overrideCount,
      required int checkInCount,
      required int foodCount,
      required String notes,
      Value<int> rowid,
    });
typedef $$LegacyImportsTableUpdateCompanionBuilder =
    LegacyImportsCompanion Function({
      Value<String> source,
      Value<LegacyImportStatus> status,
      Value<DateTime> importedAt,
      Value<int> sessionCount,
      Value<int> overrideCount,
      Value<int> checkInCount,
      Value<int> foodCount,
      Value<String> notes,
      Value<int> rowid,
    });

class $$LegacyImportsTableFilterComposer
    extends Composer<_$ForjaDatabase, $LegacyImportsTable> {
  $$LegacyImportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LegacyImportStatus, LegacyImportStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overrideCount => $composableBuilder(
    column: $table.overrideCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foodCount => $composableBuilder(
    column: $table.foodCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LegacyImportsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $LegacyImportsTable> {
  $$LegacyImportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overrideCount => $composableBuilder(
    column: $table.overrideCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foodCount => $composableBuilder(
    column: $table.foodCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LegacyImportsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $LegacyImportsTable> {
  $$LegacyImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LegacyImportStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionCount => $composableBuilder(
    column: $table.sessionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overrideCount => $composableBuilder(
    column: $table.overrideCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get checkInCount => $composableBuilder(
    column: $table.checkInCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get foodCount =>
      $composableBuilder(column: $table.foodCount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LegacyImportsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $LegacyImportsTable,
          LegacyImportRow,
          $$LegacyImportsTableFilterComposer,
          $$LegacyImportsTableOrderingComposer,
          $$LegacyImportsTableAnnotationComposer,
          $$LegacyImportsTableCreateCompanionBuilder,
          $$LegacyImportsTableUpdateCompanionBuilder,
          (
            LegacyImportRow,
            BaseReferences<
              _$ForjaDatabase,
              $LegacyImportsTable,
              LegacyImportRow
            >,
          ),
          LegacyImportRow,
          PrefetchHooks Function()
        > {
  $$LegacyImportsTableTableManager(
    _$ForjaDatabase db,
    $LegacyImportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LegacyImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LegacyImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LegacyImportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<LegacyImportStatus> status = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> sessionCount = const Value.absent(),
                Value<int> overrideCount = const Value.absent(),
                Value<int> checkInCount = const Value.absent(),
                Value<int> foodCount = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LegacyImportsCompanion(
                source: source,
                status: status,
                importedAt: importedAt,
                sessionCount: sessionCount,
                overrideCount: overrideCount,
                checkInCount: checkInCount,
                foodCount: foodCount,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required LegacyImportStatus status,
                required DateTime importedAt,
                required int sessionCount,
                required int overrideCount,
                required int checkInCount,
                required int foodCount,
                required String notes,
                Value<int> rowid = const Value.absent(),
              }) => LegacyImportsCompanion.insert(
                source: source,
                status: status,
                importedAt: importedAt,
                sessionCount: sessionCount,
                overrideCount: overrideCount,
                checkInCount: checkInCount,
                foodCount: foodCount,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LegacyImportsTable, LegacyImportRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $LegacyImportsTable,
                    LegacyImportRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LegacyImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $LegacyImportsTable,
      LegacyImportRow,
      $$LegacyImportsTableFilterComposer,
      $$LegacyImportsTableOrderingComposer,
      $$LegacyImportsTableAnnotationComposer,
      $$LegacyImportsTableCreateCompanionBuilder,
      $$LegacyImportsTableUpdateCompanionBuilder,
      (
        LegacyImportRow,
        BaseReferences<_$ForjaDatabase, $LegacyImportsTable, LegacyImportRow>,
      ),
      LegacyImportRow,
      PrefetchHooks Function()
    >;
typedef $$PlanVersionsTableCreateCompanionBuilder =
    PlanVersionsCompanion Function({
      required String id,
      required int seq,
      required PlanStatus status,
      required PlanSource source,
      required String name,
      Value<String?> effectiveFrom,
      required DateTime createdAt,
      Value<DateTime?> acceptedAt,
      Value<int> rowid,
    });
typedef $$PlanVersionsTableUpdateCompanionBuilder =
    PlanVersionsCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<PlanStatus> status,
      Value<PlanSource> source,
      Value<String> name,
      Value<String?> effectiveFrom,
      Value<DateTime> createdAt,
      Value<DateTime?> acceptedAt,
      Value<int> rowid,
    });

final class $$PlanVersionsTableReferences
    extends BaseReferences<_$ForjaDatabase, $PlanVersionsTable, PlanRow> {
  $$PlanVersionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlanRoutinesTable, List<PlanRoutineRow>>
  _planRoutinesRefsTable(_$ForjaDatabase db) => MultiTypedResultKey.fromTable(
    db.planRoutines,
    aliasName: 'plan_versions__id__plan_routines__plan_id',
  );

  $$PlanRoutinesTableProcessedTableManager get planRoutinesRefs {
    final manager = $$PlanRoutinesTableTableManager(
      $_db,
      $_db.planRoutines,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_planRoutinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanVersionsTableFilterComposer
    extends Composer<_$ForjaDatabase, $PlanVersionsTable> {
  $$PlanVersionsTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlanStatus, PlanStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PlanSource, PlanSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> planRoutinesRefs(
    Expression<bool> Function($$PlanRoutinesTableFilterComposer f) f,
  ) {
    final $$PlanRoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planRoutines,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRoutinesTableFilterComposer(
            $db: $db,
            $table: $db.planRoutines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanVersionsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $PlanVersionsTable> {
  $$PlanVersionsTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanVersionsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $PlanVersionsTable> {
  $$PlanVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlanStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlanSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  Expression<T> planRoutinesRefs<T extends Object>(
    Expression<T> Function($$PlanRoutinesTableAnnotationComposer a) f,
  ) {
    final $$PlanRoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planRoutines,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.planRoutines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanVersionsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $PlanVersionsTable,
          PlanRow,
          $$PlanVersionsTableFilterComposer,
          $$PlanVersionsTableOrderingComposer,
          $$PlanVersionsTableAnnotationComposer,
          $$PlanVersionsTableCreateCompanionBuilder,
          $$PlanVersionsTableUpdateCompanionBuilder,
          (PlanRow, $$PlanVersionsTableReferences),
          PlanRow,
          PrefetchHooks Function({bool planRoutinesRefs})
        > {
  $$PlanVersionsTableTableManager(_$ForjaDatabase db, $PlanVersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<PlanStatus> status = const Value.absent(),
                Value<PlanSource> source = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> effectiveFrom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanVersionsCompanion(
                id: id,
                seq: seq,
                status: status,
                source: source,
                name: name,
                effectiveFrom: effectiveFrom,
                createdAt: createdAt,
                acceptedAt: acceptedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required PlanStatus status,
                required PlanSource source,
                required String name,
                Value<String?> effectiveFrom = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanVersionsCompanion.insert(
                id: id,
                seq: seq,
                status: status,
                source: source,
                name: name,
                effectiveFrom: effectiveFrom,
                createdAt: createdAt,
                acceptedAt: acceptedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanVersionsTable, PlanRow>(table),
                  $$PlanVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planRoutinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (planRoutinesRefs) db.planRoutines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planRoutinesRefs)
                    await $_getPrefetchedData<
                      PlanRow,
                      $PlanVersionsTable,
                      PlanRoutineRow
                    >(
                      currentTable: table,
                      referencedTable: $$PlanVersionsTableReferences
                          ._planRoutinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlanVersionsTableReferences(
                            db,
                            table,
                            p0,
                          ).planRoutinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlanVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $PlanVersionsTable,
      PlanRow,
      $$PlanVersionsTableFilterComposer,
      $$PlanVersionsTableOrderingComposer,
      $$PlanVersionsTableAnnotationComposer,
      $$PlanVersionsTableCreateCompanionBuilder,
      $$PlanVersionsTableUpdateCompanionBuilder,
      (PlanRow, $$PlanVersionsTableReferences),
      PlanRow,
      PrefetchHooks Function({bool planRoutinesRefs})
    >;
typedef $$PlanRoutinesTableCreateCompanionBuilder =
    PlanRoutinesCompanion Function({
      required String id,
      required String planId,
      required int weekday,
      required String name,
      required String focus,
      required String warmup,
      Value<int> rowid,
    });
typedef $$PlanRoutinesTableUpdateCompanionBuilder =
    PlanRoutinesCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> weekday,
      Value<String> name,
      Value<String> focus,
      Value<String> warmup,
      Value<int> rowid,
    });

final class $$PlanRoutinesTableReferences
    extends
        BaseReferences<_$ForjaDatabase, $PlanRoutinesTable, PlanRoutineRow> {
  $$PlanRoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlanVersionsTable _planIdTable(_$ForjaDatabase db) =>
      db.planVersions.createAlias('plan_routines__plan_id__plan_versions__id');

  $$PlanVersionsTableProcessedTableManager get planId {
    final $_column = $_itemColumn<String>('plan_id')!;

    final manager = $$PlanVersionsTableTableManager(
      $_db,
      $_db.planVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlanRoutineExercisesTable, List<PlanExerciseRow>>
  _planRoutineExercisesRefsTable(_$ForjaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.planRoutineExercises,
        aliasName: 'plan_routines__id__plan_routine_exercises__routine_id',
      );

  $$PlanRoutineExercisesTableProcessedTableManager
  get planRoutineExercisesRefs {
    final manager = $$PlanRoutineExercisesTableTableManager(
      $_db,
      $_db.planRoutineExercises,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _planRoutineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanRoutinesTableFilterComposer
    extends Composer<_$ForjaDatabase, $PlanRoutinesTable> {
  $$PlanRoutinesTableFilterComposer({
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

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warmup => $composableBuilder(
    column: $table.warmup,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanVersionsTableFilterComposer get planId {
    final $$PlanVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.planVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanVersionsTableFilterComposer(
            $db: $db,
            $table: $db.planVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planRoutineExercisesRefs(
    Expression<bool> Function($$PlanRoutineExercisesTableFilterComposer f) f,
  ) {
    final $$PlanRoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planRoutineExercises,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.planRoutineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanRoutinesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $PlanRoutinesTable> {
  $$PlanRoutinesTableOrderingComposer({
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

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warmup => $composableBuilder(
    column: $table.warmup,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanVersionsTableOrderingComposer get planId {
    final $$PlanVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.planVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.planVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanRoutinesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $PlanRoutinesTable> {
  $$PlanRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<String> get warmup =>
      $composableBuilder(column: $table.warmup, builder: (column) => column);

  $$PlanVersionsTableAnnotationComposer get planId {
    final $$PlanVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.planVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.planVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planRoutineExercisesRefs<T extends Object>(
    Expression<T> Function($$PlanRoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$PlanRoutineExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.planRoutineExercises,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlanRoutineExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.planRoutineExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlanRoutinesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $PlanRoutinesTable,
          PlanRoutineRow,
          $$PlanRoutinesTableFilterComposer,
          $$PlanRoutinesTableOrderingComposer,
          $$PlanRoutinesTableAnnotationComposer,
          $$PlanRoutinesTableCreateCompanionBuilder,
          $$PlanRoutinesTableUpdateCompanionBuilder,
          (PlanRoutineRow, $$PlanRoutinesTableReferences),
          PlanRoutineRow,
          PrefetchHooks Function({bool planId, bool planRoutineExercisesRefs})
        > {
  $$PlanRoutinesTableTableManager(_$ForjaDatabase db, $PlanRoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanRoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanRoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanRoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> focus = const Value.absent(),
                Value<String> warmup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanRoutinesCompanion(
                id: id,
                planId: planId,
                weekday: weekday,
                name: name,
                focus: focus,
                warmup: warmup,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int weekday,
                required String name,
                required String focus,
                required String warmup,
                Value<int> rowid = const Value.absent(),
              }) => PlanRoutinesCompanion.insert(
                id: id,
                planId: planId,
                weekday: weekday,
                name: name,
                focus: focus,
                warmup: warmup,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanRoutinesTable, PlanRoutineRow>(table),
                  $$PlanRoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({planId = false, planRoutineExercisesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planRoutineExercisesRefs) db.planRoutineExercises,
                  ],
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
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $$PlanRoutinesTableReferences
                                ._planIdTable(db),
                            referencedColumn: $$PlanRoutinesTableReferences
                                ._planIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planRoutineExercisesRefs)
                        await $_getPrefetchedData<
                          PlanRoutineRow,
                          $PlanRoutinesTable,
                          PlanExerciseRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlanRoutinesTableReferences
                              ._planRoutineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanRoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).planRoutineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlanRoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $PlanRoutinesTable,
      PlanRoutineRow,
      $$PlanRoutinesTableFilterComposer,
      $$PlanRoutinesTableOrderingComposer,
      $$PlanRoutinesTableAnnotationComposer,
      $$PlanRoutinesTableCreateCompanionBuilder,
      $$PlanRoutinesTableUpdateCompanionBuilder,
      (PlanRoutineRow, $$PlanRoutinesTableReferences),
      PlanRoutineRow,
      PrefetchHooks Function({bool planId, bool planRoutineExercisesRefs})
    >;
typedef $$PlanRoutineExercisesTableCreateCompanionBuilder =
    PlanRoutineExercisesCompanion Function({
      required String routineId,
      required int position,
      required String exerciseId,
      required int sets,
      required int repsMin,
      required int repsMax,
      required int rir,
      required int restSeconds,
      required double incrementKg,
      Value<double?> referenceWeightKg,
      Value<int> rowid,
    });
typedef $$PlanRoutineExercisesTableUpdateCompanionBuilder =
    PlanRoutineExercisesCompanion Function({
      Value<String> routineId,
      Value<int> position,
      Value<String> exerciseId,
      Value<int> sets,
      Value<int> repsMin,
      Value<int> repsMax,
      Value<int> rir,
      Value<int> restSeconds,
      Value<double> incrementKg,
      Value<double?> referenceWeightKg,
      Value<int> rowid,
    });

final class $$PlanRoutineExercisesTableReferences
    extends
        BaseReferences<
          _$ForjaDatabase,
          $PlanRoutineExercisesTable,
          PlanExerciseRow
        > {
  $$PlanRoutineExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlanRoutinesTable _routineIdTable(_$ForjaDatabase db) => db
      .planRoutines
      .createAlias('plan_routine_exercises__routine_id__plan_routines__id');

  $$PlanRoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$PlanRoutinesTableTableManager(
      $_db,
      $_db.planRoutines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanRoutineExercisesTableFilterComposer
    extends Composer<_$ForjaDatabase, $PlanRoutineExercisesTable> {
  $$PlanRoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repsMin => $composableBuilder(
    column: $table.repsMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repsMax => $composableBuilder(
    column: $table.repsMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get incrementKg => $composableBuilder(
    column: $table.incrementKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceWeightKg => $composableBuilder(
    column: $table.referenceWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanRoutinesTableFilterComposer get routineId {
    final $$PlanRoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.planRoutines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRoutinesTableFilterComposer(
            $db: $db,
            $table: $db.planRoutines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanRoutineExercisesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $PlanRoutineExercisesTable> {
  $$PlanRoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repsMin => $composableBuilder(
    column: $table.repsMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repsMax => $composableBuilder(
    column: $table.repsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get incrementKg => $composableBuilder(
    column: $table.incrementKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceWeightKg => $composableBuilder(
    column: $table.referenceWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanRoutinesTableOrderingComposer get routineId {
    final $$PlanRoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.planRoutines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.planRoutines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanRoutineExercisesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $PlanRoutineExercisesTable> {
  $$PlanRoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumn<int> get repsMin =>
      $composableBuilder(column: $table.repsMin, builder: (column) => column);

  GeneratedColumn<int> get repsMax =>
      $composableBuilder(column: $table.repsMax, builder: (column) => column);

  GeneratedColumn<int> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get incrementKg => $composableBuilder(
    column: $table.incrementKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceWeightKg => $composableBuilder(
    column: $table.referenceWeightKg,
    builder: (column) => column,
  );

  $$PlanRoutinesTableAnnotationComposer get routineId {
    final $$PlanRoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.planRoutines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.planRoutines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanRoutineExercisesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $PlanRoutineExercisesTable,
          PlanExerciseRow,
          $$PlanRoutineExercisesTableFilterComposer,
          $$PlanRoutineExercisesTableOrderingComposer,
          $$PlanRoutineExercisesTableAnnotationComposer,
          $$PlanRoutineExercisesTableCreateCompanionBuilder,
          $$PlanRoutineExercisesTableUpdateCompanionBuilder,
          (PlanExerciseRow, $$PlanRoutineExercisesTableReferences),
          PlanExerciseRow,
          PrefetchHooks Function({bool routineId})
        > {
  $$PlanRoutineExercisesTableTableManager(
    _$ForjaDatabase db,
    $PlanRoutineExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanRoutineExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanRoutineExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlanRoutineExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> routineId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> sets = const Value.absent(),
                Value<int> repsMin = const Value.absent(),
                Value<int> repsMax = const Value.absent(),
                Value<int> rir = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<double> incrementKg = const Value.absent(),
                Value<double?> referenceWeightKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanRoutineExercisesCompanion(
                routineId: routineId,
                position: position,
                exerciseId: exerciseId,
                sets: sets,
                repsMin: repsMin,
                repsMax: repsMax,
                rir: rir,
                restSeconds: restSeconds,
                incrementKg: incrementKg,
                referenceWeightKg: referenceWeightKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String routineId,
                required int position,
                required String exerciseId,
                required int sets,
                required int repsMin,
                required int repsMax,
                required int rir,
                required int restSeconds,
                required double incrementKg,
                Value<double?> referenceWeightKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanRoutineExercisesCompanion.insert(
                routineId: routineId,
                position: position,
                exerciseId: exerciseId,
                sets: sets,
                repsMin: repsMin,
                repsMax: repsMax,
                rir: rir,
                restSeconds: restSeconds,
                incrementKg: incrementKg,
                referenceWeightKg: referenceWeightKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanRoutineExercisesTable, PlanExerciseRow>(
                    table,
                  ),
                  $$PlanRoutineExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false}) {
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
                    if (routineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineId,
                        referencedTable: $$PlanRoutineExercisesTableReferences
                            ._routineIdTable(db),
                        referencedColumn: $$PlanRoutineExercisesTableReferences
                            ._routineIdTable(db)
                            .id,
                      ) as T;
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

typedef $$PlanRoutineExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $PlanRoutineExercisesTable,
      PlanExerciseRow,
      $$PlanRoutineExercisesTableFilterComposer,
      $$PlanRoutineExercisesTableOrderingComposer,
      $$PlanRoutineExercisesTableAnnotationComposer,
      $$PlanRoutineExercisesTableCreateCompanionBuilder,
      $$PlanRoutineExercisesTableUpdateCompanionBuilder,
      (PlanExerciseRow, $$PlanRoutineExercisesTableReferences),
      PlanExerciseRow,
      PrefetchHooks Function({bool routineId})
    >;
typedef $$SetLogsTableCreateCompanionBuilder = SetLogsCompanion Function({
  required String id,
  required String sessionId,
  required String exerciseId,
  required int position,
  required SetKind kind,
  required int number,
  required SetStatus status,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> rir,
  Value<String?> skipReason,
  Value<int> rowid,
});
typedef $$SetLogsTableUpdateCompanionBuilder = SetLogsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> exerciseId,
  Value<int> position,
  Value<SetKind> kind,
  Value<int> number,
  Value<SetStatus> status,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> rir,
  Value<String?> skipReason,
  Value<int> rowid,
});

final class $$SetLogsTableReferences
    extends BaseReferences<_$ForjaDatabase, $SetLogsTable, SetLogRow> {
  $$SetLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$ForjaDatabase db) => db
      .workoutSessions
      .createAlias('set_logs__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SetLogsTableFilterComposer
    extends Composer<_$ForjaDatabase, $SetLogsTable> {
  $$SetLogsTableFilterComposer({
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

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SetKind, SetKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SetStatus, SetStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $SetLogsTable> {
  $$SetLogsTableOrderingComposer({
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

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $SetLogsTable> {
  $$SetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SetKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SetStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => column,
  );

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetLogsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $SetLogsTable,
          SetLogRow,
          $$SetLogsTableFilterComposer,
          $$SetLogsTableOrderingComposer,
          $$SetLogsTableAnnotationComposer,
          $$SetLogsTableCreateCompanionBuilder,
          $$SetLogsTableUpdateCompanionBuilder,
          (SetLogRow, $$SetLogsTableReferences),
          SetLogRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SetLogsTableTableManager(_$ForjaDatabase db, $SetLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<SetKind> kind = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<SetStatus> status = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetLogsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                kind: kind,
                number: number,
                status: status,
                weightKg: weightKg,
                reps: reps,
                rir: rir,
                skipReason: skipReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String exerciseId,
                required int position,
                required SetKind kind,
                required int number,
                required SetStatus status,
                Value<double?> weightKg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                position: position,
                kind: kind,
                number: number,
                status: status,
                weightKg: weightKg,
                reps: reps,
                rir: rir,
                skipReason: skipReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetLogsTable, SetLogRow>(table),
                  $$SetLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SetLogsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SetLogsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
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

typedef $$SetLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $SetLogsTable,
      SetLogRow,
      $$SetLogsTableFilterComposer,
      $$SetLogsTableOrderingComposer,
      $$SetLogsTableAnnotationComposer,
      $$SetLogsTableCreateCompanionBuilder,
      $$SetLogsTableUpdateCompanionBuilder,
      (SetLogRow, $$SetLogsTableReferences),
      SetLogRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SessionEventsTableCreateCompanionBuilder =
    SessionEventsCompanion Function({
      required String id,
      required int seq,
      required String dateKey,
      required SessionEventKind kind,
      required DateTime at,
      Value<int> rowid,
    });
typedef $$SessionEventsTableUpdateCompanionBuilder =
    SessionEventsCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<String> dateKey,
      Value<SessionEventKind> kind,
      Value<DateTime> at,
      Value<int> rowid,
    });

class $$SessionEventsTableFilterComposer
    extends Composer<_$ForjaDatabase, $SessionEventsTable> {
  $$SessionEventsTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionEventKind, SessionEventKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionEventsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $SessionEventsTable> {
  $$SessionEventsTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionEventsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $SessionEventsTable> {
  $$SessionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionEventKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$SessionEventsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $SessionEventsTable,
          SessionEventRow,
          $$SessionEventsTableFilterComposer,
          $$SessionEventsTableOrderingComposer,
          $$SessionEventsTableAnnotationComposer,
          $$SessionEventsTableCreateCompanionBuilder,
          $$SessionEventsTableUpdateCompanionBuilder,
          (
            SessionEventRow,
            BaseReferences<
              _$ForjaDatabase,
              $SessionEventsTable,
              SessionEventRow
            >,
          ),
          SessionEventRow,
          PrefetchHooks Function()
        > {
  $$SessionEventsTableTableManager(
    _$ForjaDatabase db,
    $SessionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<SessionEventKind> kind = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEventsCompanion(
                id: id,
                seq: seq,
                dateKey: dateKey,
                kind: kind,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String dateKey,
                required SessionEventKind kind,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => SessionEventsCompanion.insert(
                id: id,
                seq: seq,
                dateKey: dateKey,
                kind: kind,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionEventsTable, SessionEventRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $SessionEventsTable,
                    SessionEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $SessionEventsTable,
      SessionEventRow,
      $$SessionEventsTableFilterComposer,
      $$SessionEventsTableOrderingComposer,
      $$SessionEventsTableAnnotationComposer,
      $$SessionEventsTableCreateCompanionBuilder,
      $$SessionEventsTableUpdateCompanionBuilder,
      (
        SessionEventRow,
        BaseReferences<_$ForjaDatabase, $SessionEventsTable, SessionEventRow>,
      ),
      SessionEventRow,
      PrefetchHooks Function()
    >;
typedef $$ReschedulesTableCreateCompanionBuilder =
    ReschedulesCompanion Function({
      required String id,
      required int seq,
      required String sourceDate,
      required String targetDate,
      required RescheduleKind kind,
      required DateTime createdAt,
      Value<DateTime?> undoneAt,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$ReschedulesTableUpdateCompanionBuilder =
    ReschedulesCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<String> sourceDate,
      Value<String> targetDate,
      Value<RescheduleKind> kind,
      Value<DateTime> createdAt,
      Value<DateTime?> undoneAt,
      Value<String?> parentId,
      Value<int> rowid,
    });

class $$ReschedulesTableFilterComposer
    extends Composer<_$ForjaDatabase, $ReschedulesTable> {
  $$ReschedulesTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDate => $composableBuilder(
    column: $table.sourceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RescheduleKind, RescheduleKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get undoneAt => $composableBuilder(
    column: $table.undoneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReschedulesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $ReschedulesTable> {
  $$ReschedulesTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDate => $composableBuilder(
    column: $table.sourceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get undoneAt => $composableBuilder(
    column: $table.undoneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReschedulesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $ReschedulesTable> {
  $$ReschedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get sourceDate => $composableBuilder(
    column: $table.sourceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RescheduleKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get undoneAt =>
      $composableBuilder(column: $table.undoneAt, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$ReschedulesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $ReschedulesTable,
          RescheduleRow,
          $$ReschedulesTableFilterComposer,
          $$ReschedulesTableOrderingComposer,
          $$ReschedulesTableAnnotationComposer,
          $$ReschedulesTableCreateCompanionBuilder,
          $$ReschedulesTableUpdateCompanionBuilder,
          (
            RescheduleRow,
            BaseReferences<_$ForjaDatabase, $ReschedulesTable, RescheduleRow>,
          ),
          RescheduleRow,
          PrefetchHooks Function()
        > {
  $$ReschedulesTableTableManager(_$ForjaDatabase db, $ReschedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReschedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReschedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReschedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> sourceDate = const Value.absent(),
                Value<String> targetDate = const Value.absent(),
                Value<RescheduleKind> kind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> undoneAt = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReschedulesCompanion(
                id: id,
                seq: seq,
                sourceDate: sourceDate,
                targetDate: targetDate,
                kind: kind,
                createdAt: createdAt,
                undoneAt: undoneAt,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String sourceDate,
                required String targetDate,
                required RescheduleKind kind,
                required DateTime createdAt,
                Value<DateTime?> undoneAt = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReschedulesCompanion.insert(
                id: id,
                seq: seq,
                sourceDate: sourceDate,
                targetDate: targetDate,
                kind: kind,
                createdAt: createdAt,
                undoneAt: undoneAt,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReschedulesTable, RescheduleRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $ReschedulesTable,
                    RescheduleRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReschedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $ReschedulesTable,
      RescheduleRow,
      $$ReschedulesTableFilterComposer,
      $$ReschedulesTableOrderingComposer,
      $$ReschedulesTableAnnotationComposer,
      $$ReschedulesTableCreateCompanionBuilder,
      $$ReschedulesTableUpdateCompanionBuilder,
      (
        RescheduleRow,
        BaseReferences<_$ForjaDatabase, $ReschedulesTable, RescheduleRow>,
      ),
      RescheduleRow,
      PrefetchHooks Function()
    >;
typedef $$SessionAdjustmentsTableCreateCompanionBuilder =
    SessionAdjustmentsCompanion Function({
      required String dateKey,
      required bool applied,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionAdjustmentsTableUpdateCompanionBuilder =
    SessionAdjustmentsCompanion Function({
      Value<String> dateKey,
      Value<bool> applied,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionAdjustmentsTableFilterComposer
    extends Composer<_$ForjaDatabase, $SessionAdjustmentsTable> {
  $$SessionAdjustmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get applied => $composableBuilder(
    column: $table.applied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionAdjustmentsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $SessionAdjustmentsTable> {
  $$SessionAdjustmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get applied => $composableBuilder(
    column: $table.applied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionAdjustmentsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $SessionAdjustmentsTable> {
  $$SessionAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<bool> get applied =>
      $composableBuilder(column: $table.applied, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $SessionAdjustmentsTable,
          AdjustmentRow,
          $$SessionAdjustmentsTableFilterComposer,
          $$SessionAdjustmentsTableOrderingComposer,
          $$SessionAdjustmentsTableAnnotationComposer,
          $$SessionAdjustmentsTableCreateCompanionBuilder,
          $$SessionAdjustmentsTableUpdateCompanionBuilder,
          (
            AdjustmentRow,
            BaseReferences<
              _$ForjaDatabase,
              $SessionAdjustmentsTable,
              AdjustmentRow
            >,
          ),
          AdjustmentRow,
          PrefetchHooks Function()
        > {
  $$SessionAdjustmentsTableTableManager(
    _$ForjaDatabase db,
    $SessionAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionAdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionAdjustmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> dateKey = const Value.absent(),
                Value<bool> applied = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionAdjustmentsCompanion(
                dateKey: dateKey,
                applied: applied,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dateKey,
                required bool applied,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionAdjustmentsCompanion.insert(
                dateKey: dateKey,
                applied: applied,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionAdjustmentsTable, AdjustmentRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $SessionAdjustmentsTable,
                    AdjustmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $SessionAdjustmentsTable,
      AdjustmentRow,
      $$SessionAdjustmentsTableFilterComposer,
      $$SessionAdjustmentsTableOrderingComposer,
      $$SessionAdjustmentsTableAnnotationComposer,
      $$SessionAdjustmentsTableCreateCompanionBuilder,
      $$SessionAdjustmentsTableUpdateCompanionBuilder,
      (
        AdjustmentRow,
        BaseReferences<
          _$ForjaDatabase,
          $SessionAdjustmentsTable,
          AdjustmentRow
        >,
      ),
      AdjustmentRow,
      PrefetchHooks Function()
    >;
typedef $$ProgressionDecisionsTableCreateCompanionBuilder =
    ProgressionDecisionsCompanion Function({
      required String id,
      required int seq,
      required String exerciseId,
      required String ruleVersion,
      required ProgressionKind kind,
      required String basedOn,
      required DecisionStatus status,
      required DateTime decidedAt,
      Value<double?> fromKg,
      Value<double?> toKg,
      Value<int> rowid,
    });
typedef $$ProgressionDecisionsTableUpdateCompanionBuilder =
    ProgressionDecisionsCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<String> exerciseId,
      Value<String> ruleVersion,
      Value<ProgressionKind> kind,
      Value<String> basedOn,
      Value<DecisionStatus> status,
      Value<DateTime> decidedAt,
      Value<double?> fromKg,
      Value<double?> toKg,
      Value<int> rowid,
    });

class $$ProgressionDecisionsTableFilterComposer
    extends Composer<_$ForjaDatabase, $ProgressionDecisionsTable> {
  $$ProgressionDecisionsTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProgressionKind, ProgressionKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get basedOn => $composableBuilder(
    column: $table.basedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DecisionStatus, DecisionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fromKg => $composableBuilder(
    column: $table.fromKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get toKg => $composableBuilder(
    column: $table.toKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProgressionDecisionsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $ProgressionDecisionsTable> {
  $$ProgressionDecisionsTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basedOn => $composableBuilder(
    column: $table.basedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fromKg => $composableBuilder(
    column: $table.fromKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get toKg => $composableBuilder(
    column: $table.toKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgressionDecisionsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $ProgressionDecisionsTable> {
  $$ProgressionDecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProgressionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get basedOn =>
      $composableBuilder(column: $table.basedOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DecisionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);

  GeneratedColumn<double> get fromKg =>
      $composableBuilder(column: $table.fromKg, builder: (column) => column);

  GeneratedColumn<double> get toKg =>
      $composableBuilder(column: $table.toKg, builder: (column) => column);
}

class $$ProgressionDecisionsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $ProgressionDecisionsTable,
          ProgressionDecisionRow,
          $$ProgressionDecisionsTableFilterComposer,
          $$ProgressionDecisionsTableOrderingComposer,
          $$ProgressionDecisionsTableAnnotationComposer,
          $$ProgressionDecisionsTableCreateCompanionBuilder,
          $$ProgressionDecisionsTableUpdateCompanionBuilder,
          (
            ProgressionDecisionRow,
            BaseReferences<
              _$ForjaDatabase,
              $ProgressionDecisionsTable,
              ProgressionDecisionRow
            >,
          ),
          ProgressionDecisionRow,
          PrefetchHooks Function()
        > {
  $$ProgressionDecisionsTableTableManager(
    _$ForjaDatabase db,
    $ProgressionDecisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgressionDecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgressionDecisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProgressionDecisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> ruleVersion = const Value.absent(),
                Value<ProgressionKind> kind = const Value.absent(),
                Value<String> basedOn = const Value.absent(),
                Value<DecisionStatus> status = const Value.absent(),
                Value<DateTime> decidedAt = const Value.absent(),
                Value<double?> fromKg = const Value.absent(),
                Value<double?> toKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressionDecisionsCompanion(
                id: id,
                seq: seq,
                exerciseId: exerciseId,
                ruleVersion: ruleVersion,
                kind: kind,
                basedOn: basedOn,
                status: status,
                decidedAt: decidedAt,
                fromKg: fromKg,
                toKg: toKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String exerciseId,
                required String ruleVersion,
                required ProgressionKind kind,
                required String basedOn,
                required DecisionStatus status,
                required DateTime decidedAt,
                Value<double?> fromKg = const Value.absent(),
                Value<double?> toKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProgressionDecisionsCompanion.insert(
                id: id,
                seq: seq,
                exerciseId: exerciseId,
                ruleVersion: ruleVersion,
                kind: kind,
                basedOn: basedOn,
                status: status,
                decidedAt: decidedAt,
                fromKg: fromKg,
                toKg: toKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ProgressionDecisionsTable,
                    ProgressionDecisionRow
                  >(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $ProgressionDecisionsTable,
                    ProgressionDecisionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProgressionDecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $ProgressionDecisionsTable,
      ProgressionDecisionRow,
      $$ProgressionDecisionsTableFilterComposer,
      $$ProgressionDecisionsTableOrderingComposer,
      $$ProgressionDecisionsTableAnnotationComposer,
      $$ProgressionDecisionsTableCreateCompanionBuilder,
      $$ProgressionDecisionsTableUpdateCompanionBuilder,
      (
        ProgressionDecisionRow,
        BaseReferences<
          _$ForjaDatabase,
          $ProgressionDecisionsTable,
          ProgressionDecisionRow
        >,
      ),
      ProgressionDecisionRow,
      PrefetchHooks Function()
    >;
typedef $$MonthlyReviewsTableCreateCompanionBuilder =
    MonthlyReviewsCompanion Function({
      required String id,
      required int seq,
      required String reviewedOn,
      required ReviewOutcome outcome,
      required String rulesVersion,
      required int sessionsDone,
      required int sessionsDue,
      required String answers,
      required String proposal,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MonthlyReviewsTableUpdateCompanionBuilder =
    MonthlyReviewsCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<String> reviewedOn,
      Value<ReviewOutcome> outcome,
      Value<String> rulesVersion,
      Value<int> sessionsDone,
      Value<int> sessionsDue,
      Value<String> answers,
      Value<String> proposal,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MonthlyReviewsTableFilterComposer
    extends Composer<_$ForjaDatabase, $MonthlyReviewsTable> {
  $$MonthlyReviewsTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedOn => $composableBuilder(
    column: $table.reviewedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewOutcome, ReviewOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionsDone => $composableBuilder(
    column: $table.sessionsDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionsDue => $composableBuilder(
    column: $table.sessionsDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposal => $composableBuilder(
    column: $table.proposal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthlyReviewsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $MonthlyReviewsTable> {
  $$MonthlyReviewsTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedOn => $composableBuilder(
    column: $table.reviewedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionsDone => $composableBuilder(
    column: $table.sessionsDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionsDue => $composableBuilder(
    column: $table.sessionsDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposal => $composableBuilder(
    column: $table.proposal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlyReviewsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $MonthlyReviewsTable> {
  $$MonthlyReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get reviewedOn => $composableBuilder(
    column: $table.reviewedOn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReviewOutcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionsDone => $composableBuilder(
    column: $table.sessionsDone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionsDue => $composableBuilder(
    column: $table.sessionsDue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);

  GeneratedColumn<String> get proposal =>
      $composableBuilder(column: $table.proposal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MonthlyReviewsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $MonthlyReviewsTable,
          MonthlyReviewRow,
          $$MonthlyReviewsTableFilterComposer,
          $$MonthlyReviewsTableOrderingComposer,
          $$MonthlyReviewsTableAnnotationComposer,
          $$MonthlyReviewsTableCreateCompanionBuilder,
          $$MonthlyReviewsTableUpdateCompanionBuilder,
          (
            MonthlyReviewRow,
            BaseReferences<
              _$ForjaDatabase,
              $MonthlyReviewsTable,
              MonthlyReviewRow
            >,
          ),
          MonthlyReviewRow,
          PrefetchHooks Function()
        > {
  $$MonthlyReviewsTableTableManager(
    _$ForjaDatabase db,
    $MonthlyReviewsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> reviewedOn = const Value.absent(),
                Value<ReviewOutcome> outcome = const Value.absent(),
                Value<String> rulesVersion = const Value.absent(),
                Value<int> sessionsDone = const Value.absent(),
                Value<int> sessionsDue = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<String> proposal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlyReviewsCompanion(
                id: id,
                seq: seq,
                reviewedOn: reviewedOn,
                outcome: outcome,
                rulesVersion: rulesVersion,
                sessionsDone: sessionsDone,
                sessionsDue: sessionsDue,
                answers: answers,
                proposal: proposal,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String reviewedOn,
                required ReviewOutcome outcome,
                required String rulesVersion,
                required int sessionsDone,
                required int sessionsDue,
                required String answers,
                required String proposal,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MonthlyReviewsCompanion.insert(
                id: id,
                seq: seq,
                reviewedOn: reviewedOn,
                outcome: outcome,
                rulesVersion: rulesVersion,
                sessionsDone: sessionsDone,
                sessionsDue: sessionsDue,
                answers: answers,
                proposal: proposal,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonthlyReviewsTable, MonthlyReviewRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $MonthlyReviewsTable,
                    MonthlyReviewRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthlyReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $MonthlyReviewsTable,
      MonthlyReviewRow,
      $$MonthlyReviewsTableFilterComposer,
      $$MonthlyReviewsTableOrderingComposer,
      $$MonthlyReviewsTableAnnotationComposer,
      $$MonthlyReviewsTableCreateCompanionBuilder,
      $$MonthlyReviewsTableUpdateCompanionBuilder,
      (
        MonthlyReviewRow,
        BaseReferences<_$ForjaDatabase, $MonthlyReviewsTable, MonthlyReviewRow>,
      ),
      MonthlyReviewRow,
      PrefetchHooks Function()
    >;
typedef $$CardioSessionsTableCreateCompanionBuilder =
    CardioSessionsCompanion Function({
      required String id,
      required int seq,
      required CardioActivity activity,
      Value<int?> targetMinutes,
      required CardioStatus status,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<Feeling?> feedback,
      required String note,
      Value<bool> durationCorrected,
      Value<int> rowid,
    });
typedef $$CardioSessionsTableUpdateCompanionBuilder =
    CardioSessionsCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<CardioActivity> activity,
      Value<int?> targetMinutes,
      Value<CardioStatus> status,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<Feeling?> feedback,
      Value<String> note,
      Value<bool> durationCorrected,
      Value<int> rowid,
    });

final class $$CardioSessionsTableReferences
    extends
        BaseReferences<
          _$ForjaDatabase,
          $CardioSessionsTable,
          CardioSessionRow
        > {
  $$CardioSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CardioSegmentsTable, List<CardioSegmentRow>>
  _cardioSegmentsRefsTable(_$ForjaDatabase db) => MultiTypedResultKey.fromTable(
    db.cardioSegments,
    aliasName: 'cardio_sessions__id__cardio_segments__session_id',
  );

  $$CardioSegmentsTableProcessedTableManager get cardioSegmentsRefs {
    final manager = $$CardioSegmentsTableTableManager(
      $_db,
      $_db.cardioSegments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardioSegmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardioSessionsTableFilterComposer
    extends Composer<_$ForjaDatabase, $CardioSessionsTable> {
  $$CardioSessionsTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CardioActivity, CardioActivity, String>
  get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CardioStatus, CardioStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Feeling?, Feeling, String> get feedback =>
      $composableBuilder(
        column: $table.feedback,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get durationCorrected => $composableBuilder(
    column: $table.durationCorrected,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardioSegmentsRefs(
    Expression<bool> Function($$CardioSegmentsTableFilterComposer f) f,
  ) {
    final $$CardioSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.cardioSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardioSessionsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $CardioSessionsTable> {
  $$CardioSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get durationCorrected => $composableBuilder(
    column: $table.durationCorrected,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardioSessionsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $CardioSessionsTable> {
  $$CardioSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardioActivity, String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CardioStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Feeling?, String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get durationCorrected => $composableBuilder(
    column: $table.durationCorrected,
    builder: (column) => column,
  );

  Expression<T> cardioSegmentsRefs<T extends Object>(
    Expression<T> Function($$CardioSegmentsTableAnnotationComposer a) f,
  ) {
    final $$CardioSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardioSessionsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $CardioSessionsTable,
          CardioSessionRow,
          $$CardioSessionsTableFilterComposer,
          $$CardioSessionsTableOrderingComposer,
          $$CardioSessionsTableAnnotationComposer,
          $$CardioSessionsTableCreateCompanionBuilder,
          $$CardioSessionsTableUpdateCompanionBuilder,
          (CardioSessionRow, $$CardioSessionsTableReferences),
          CardioSessionRow,
          PrefetchHooks Function({bool cardioSegmentsRefs})
        > {
  $$CardioSessionsTableTableManager(
    _$ForjaDatabase db,
    $CardioSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardioSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardioSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardioSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<CardioActivity> activity = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<CardioStatus> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<Feeling?> feedback = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> durationCorrected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardioSessionsCompanion(
                id: id,
                seq: seq,
                activity: activity,
                targetMinutes: targetMinutes,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                feedback: feedback,
                note: note,
                durationCorrected: durationCorrected,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required CardioActivity activity,
                Value<int?> targetMinutes = const Value.absent(),
                required CardioStatus status,
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<Feeling?> feedback = const Value.absent(),
                required String note,
                Value<bool> durationCorrected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardioSessionsCompanion.insert(
                id: id,
                seq: seq,
                activity: activity,
                targetMinutes: targetMinutes,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                feedback: feedback,
                note: note,
                durationCorrected: durationCorrected,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardioSessionsTable, CardioSessionRow>(table),
                  $$CardioSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardioSegmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cardioSegmentsRefs) db.cardioSegments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardioSegmentsRefs)
                    await $_getPrefetchedData<
                      CardioSessionRow,
                      $CardioSessionsTable,
                      CardioSegmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$CardioSessionsTableReferences
                          ._cardioSegmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardioSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).cardioSegmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardioSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $CardioSessionsTable,
      CardioSessionRow,
      $$CardioSessionsTableFilterComposer,
      $$CardioSessionsTableOrderingComposer,
      $$CardioSessionsTableAnnotationComposer,
      $$CardioSessionsTableCreateCompanionBuilder,
      $$CardioSessionsTableUpdateCompanionBuilder,
      (CardioSessionRow, $$CardioSessionsTableReferences),
      CardioSessionRow,
      PrefetchHooks Function({bool cardioSegmentsRefs})
    >;
typedef $$CardioSegmentsTableCreateCompanionBuilder =
    CardioSegmentsCompanion Function({
      required String id,
      required String sessionId,
      required int position,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required CardioIntensity intensity,
      Value<double?> weightKg,
      Value<int> rowid,
    });
typedef $$CardioSegmentsTableUpdateCompanionBuilder =
    CardioSegmentsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> position,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<CardioIntensity> intensity,
      Value<double?> weightKg,
      Value<int> rowid,
    });

final class $$CardioSegmentsTableReferences
    extends
        BaseReferences<
          _$ForjaDatabase,
          $CardioSegmentsTable,
          CardioSegmentRow
        > {
  $$CardioSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardioSessionsTable _sessionIdTable(_$ForjaDatabase db) => db
      .cardioSessions
      .createAlias('cardio_segments__session_id__cardio_sessions__id');

  $$CardioSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$CardioSessionsTableTableManager(
      $_db,
      $_db.cardioSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardioSegmentsTableFilterComposer
    extends Composer<_$ForjaDatabase, $CardioSegmentsTable> {
  $$CardioSegmentsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CardioIntensity, CardioIntensity, String>
  get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  $$CardioSessionsTableFilterComposer get sessionId {
    final $$CardioSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.cardioSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSessionsTableFilterComposer(
            $db: $db,
            $table: $db.cardioSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioSegmentsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $CardioSegmentsTable> {
  $$CardioSegmentsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardioSessionsTableOrderingComposer get sessionId {
    final $$CardioSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.cardioSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardioSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioSegmentsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $CardioSegmentsTable> {
  $$CardioSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardioIntensity, String> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  $$CardioSessionsTableAnnotationComposer get sessionId {
    final $$CardioSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.cardioSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioSegmentsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $CardioSegmentsTable,
          CardioSegmentRow,
          $$CardioSegmentsTableFilterComposer,
          $$CardioSegmentsTableOrderingComposer,
          $$CardioSegmentsTableAnnotationComposer,
          $$CardioSegmentsTableCreateCompanionBuilder,
          $$CardioSegmentsTableUpdateCompanionBuilder,
          (CardioSegmentRow, $$CardioSegmentsTableReferences),
          CardioSegmentRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$CardioSegmentsTableTableManager(
    _$ForjaDatabase db,
    $CardioSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardioSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardioSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardioSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<CardioIntensity> intensity = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardioSegmentsCompanion(
                id: id,
                sessionId: sessionId,
                position: position,
                startedAt: startedAt,
                endedAt: endedAt,
                intensity: intensity,
                weightKg: weightKg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int position,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required CardioIntensity intensity,
                Value<double?> weightKg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardioSegmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                position: position,
                startedAt: startedAt,
                endedAt: endedAt,
                intensity: intensity,
                weightKg: weightKg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardioSegmentsTable, CardioSegmentRow>(table),
                  $$CardioSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$CardioSegmentsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$CardioSegmentsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CardioSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $CardioSegmentsTable,
      CardioSegmentRow,
      $$CardioSegmentsTableFilterComposer,
      $$CardioSegmentsTableOrderingComposer,
      $$CardioSegmentsTableAnnotationComposer,
      $$CardioSegmentsTableCreateCompanionBuilder,
      $$CardioSegmentsTableUpdateCompanionBuilder,
      (CardioSegmentRow, $$CardioSegmentsTableReferences),
      CardioSegmentRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$FoodFavoritesTableCreateCompanionBuilder =
    FoodFavoritesCompanion Function({
      required String id,
      required int seq,
      required String name,
      required int calories,
      Value<double?> portion,
      Value<String?> unit,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<int> rowid,
    });
typedef $$FoodFavoritesTableUpdateCompanionBuilder =
    FoodFavoritesCompanion Function({
      Value<String> id,
      Value<int> seq,
      Value<String> name,
      Value<int> calories,
      Value<double?> portion,
      Value<String?> unit,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<int> rowid,
    });

class $$FoodFavoritesTableFilterComposer
    extends Composer<_$ForjaDatabase, $FoodFavoritesTable> {
  $$FoodFavoritesTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get portion => $composableBuilder(
    column: $table.portion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodFavoritesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $FoodFavoritesTable> {
  $$FoodFavoritesTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get portion => $composableBuilder(
    column: $table.portion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodFavoritesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $FoodFavoritesTable> {
  $$FoodFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get portion =>
      $composableBuilder(column: $table.portion, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);
}

class $$FoodFavoritesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $FoodFavoritesTable,
          FavoriteRow,
          $$FoodFavoritesTableFilterComposer,
          $$FoodFavoritesTableOrderingComposer,
          $$FoodFavoritesTableAnnotationComposer,
          $$FoodFavoritesTableCreateCompanionBuilder,
          $$FoodFavoritesTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$ForjaDatabase, $FoodFavoritesTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FoodFavoritesTableTableManager(
    _$ForjaDatabase db,
    $FoodFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodFavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<double?> portion = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodFavoritesCompanion(
                id: id,
                seq: seq,
                name: name,
                calories: calories,
                portion: portion,
                unit: unit,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String name,
                required int calories,
                Value<double?> portion = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodFavoritesCompanion.insert(
                id: id,
                seq: seq,
                name: name,
                calories: calories,
                portion: portion,
                unit: unit,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodFavoritesTable, FavoriteRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $FoodFavoritesTable,
                    FavoriteRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $FoodFavoritesTable,
      FavoriteRow,
      $$FoodFavoritesTableFilterComposer,
      $$FoodFavoritesTableOrderingComposer,
      $$FoodFavoritesTableAnnotationComposer,
      $$FoodFavoritesTableCreateCompanionBuilder,
      $$FoodFavoritesTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$ForjaDatabase, $FoodFavoritesTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required int seq,
  required String name,
  required double servings,
  required String notes,
  required String tags,
  Value<String?> allergens,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<int> seq,
  Value<String> name,
  Value<double> servings,
  Value<String> notes,
  Value<String> tags,
  Value<String?> allergens,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$RecipesTableReferences
    extends BaseReferences<_$ForjaDatabase, $RecipesTable, RecipeRow> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeIngredientsTable, List<IngredientRow>>
  _recipeIngredientsRefsTable(_$ForjaDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: 'recipes__id__recipe_ingredients__recipe_id',
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager = $$RecipeIngredientsTableTableManager(
      $_db,
      $_db.recipeIngredients,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$ForjaDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergens => $composableBuilder(
    column: $table.allergens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$ForjaDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergens => $composableBuilder(
    column: $table.allergens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get allergens =>
      $composableBuilder(column: $table.allergens, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.recipeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $RecipesTable,
          RecipeRow,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (RecipeRow, $$RecipesTableReferences),
          RecipeRow,
          PrefetchHooks Function({bool recipeIngredientsRefs})
        > {
  $$RecipesTableTableManager(_$ForjaDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> servings = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String?> allergens = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                seq: seq,
                name: name,
                servings: servings,
                notes: notes,
                tags: tags,
                allergens: allergens,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int seq,
                required String name,
                required double servings,
                required String notes,
                required String tags,
                Value<String?> allergens = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                seq: seq,
                name: name,
                servings: servings,
                notes: notes,
                tags: tags,
                allergens: allergens,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipesTable, RecipeRow>(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeIngredientsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recipeIngredientsRefs) db.recipeIngredients,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recipeIngredientsRefs)
                    await $_getPrefetchedData<
                      RecipeRow,
                      $RecipesTable,
                      IngredientRow
                    >(
                      currentTable: table,
                      referencedTable: $$RecipesTableReferences
                          ._recipeIngredientsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RecipesTableReferences(
                        db,
                        table,
                        p0,
                      ).recipeIngredientsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.recipeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $RecipesTable,
      RecipeRow,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (RecipeRow, $$RecipesTableReferences),
      RecipeRow,
      PrefetchHooks Function({bool recipeIngredientsRefs})
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      required String recipeId,
      required int position,
      required String name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<int?> calories,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<int> rowid,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<String> recipeId,
      Value<int> position,
      Value<String> name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<int?> calories,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<int> rowid,
    });

final class $$RecipeIngredientsTableReferences
    extends
        BaseReferences<
          _$ForjaDatabase,
          $RecipeIngredientsTable,
          IngredientRow
        > {
  $$RecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$ForjaDatabase db) =>
      db.recipes.createAlias('recipe_ingredients__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$ForjaDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$ForjaDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $RecipeIngredientsTable,
          IngredientRow,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (IngredientRow, $$RecipeIngredientsTableReferences),
          IngredientRow,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeIngredientsTableTableManager(
    _$ForjaDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                recipeId: recipeId,
                position: position,
                name: name,
                quantity: quantity,
                unit: unit,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recipeId,
                required int position,
                required String name,
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                recipeId: recipeId,
                position: position,
                name: name,
                quantity: quantity,
                unit: unit,
                calories: calories,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipeIngredientsTable, IngredientRow>(table),
                  $$RecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
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
                    if (recipeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recipeId,
                        referencedTable: $$RecipeIngredientsTableReferences
                            ._recipeIdTable(db),
                        referencedColumn: $$RecipeIngredientsTableReferences
                            ._recipeIdTable(db)
                            .id,
                      ) as T;
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

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $RecipeIngredientsTable,
      IngredientRow,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (IngredientRow, $$RecipeIngredientsTableReferences),
      IngredientRow,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$NutritionGoalsTableTableCreateCompanionBuilder =
    NutritionGoalsTableCompanion Function({
      Value<int> id,
      Value<int?> kcal,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      required DateTime updatedAt,
    });
typedef $$NutritionGoalsTableTableUpdateCompanionBuilder =
    NutritionGoalsTableCompanion Function({
      Value<int> id,
      Value<int?> kcal,
      Value<double?> proteinG,
      Value<double?> carbsG,
      Value<double?> fatG,
      Value<DateTime> updatedAt,
    });

class $$NutritionGoalsTableTableFilterComposer
    extends Composer<_$ForjaDatabase, $NutritionGoalsTableTable> {
  $$NutritionGoalsTableTableFilterComposer({
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

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionGoalsTableTableOrderingComposer
    extends Composer<_$ForjaDatabase, $NutritionGoalsTableTable> {
  $$NutritionGoalsTableTableOrderingComposer({
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

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionGoalsTableTableAnnotationComposer
    extends Composer<_$ForjaDatabase, $NutritionGoalsTableTable> {
  $$NutritionGoalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NutritionGoalsTableTableTableManager
    extends
        RootTableManager<
          _$ForjaDatabase,
          $NutritionGoalsTableTable,
          GoalsRow,
          $$NutritionGoalsTableTableFilterComposer,
          $$NutritionGoalsTableTableOrderingComposer,
          $$NutritionGoalsTableTableAnnotationComposer,
          $$NutritionGoalsTableTableCreateCompanionBuilder,
          $$NutritionGoalsTableTableUpdateCompanionBuilder,
          (
            GoalsRow,
            BaseReferences<
              _$ForjaDatabase,
              $NutritionGoalsTableTable,
              GoalsRow
            >,
          ),
          GoalsRow,
          PrefetchHooks Function()
        > {
  $$NutritionGoalsTableTableTableManager(
    _$ForjaDatabase db,
    $NutritionGoalsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionGoalsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NutritionGoalsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> kcal = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NutritionGoalsTableCompanion(
                id: id,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> kcal = const Value.absent(),
                Value<double?> proteinG = const Value.absent(),
                Value<double?> carbsG = const Value.absent(),
                Value<double?> fatG = const Value.absent(),
                required DateTime updatedAt,
              }) => NutritionGoalsTableCompanion.insert(
                id: id,
                kcal: kcal,
                proteinG: proteinG,
                carbsG: carbsG,
                fatG: fatG,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionGoalsTableTable, GoalsRow>(table),
                  BaseReferences<
                    _$ForjaDatabase,
                    $NutritionGoalsTableTable,
                    GoalsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionGoalsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ForjaDatabase,
      $NutritionGoalsTableTable,
      GoalsRow,
      $$NutritionGoalsTableTableFilterComposer,
      $$NutritionGoalsTableTableOrderingComposer,
      $$NutritionGoalsTableTableAnnotationComposer,
      $$NutritionGoalsTableTableCreateCompanionBuilder,
      $$NutritionGoalsTableTableUpdateCompanionBuilder,
      (
        GoalsRow,
        BaseReferences<_$ForjaDatabase, $NutritionGoalsTableTable, GoalsRow>,
      ),
      GoalsRow,
      PrefetchHooks Function()
    >;

class $ForjaDatabaseManager {
  final _$ForjaDatabase _db;
  $ForjaDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ProfileHistoryTableTableManager get profileHistory =>
      $$ProfileHistoryTableTableManager(_db, _db.profileHistory);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$CalendarOverridesTableTableManager get calendarOverrides =>
      $$CalendarOverridesTableTableManager(_db, _db.calendarOverrides);
  $$CheckInsTableTableManager get checkIns =>
      $$CheckInsTableTableManager(_db, _db.checkIns);
  $$FoodEntriesTableTableManager get foodEntries =>
      $$FoodEntriesTableTableManager(_db, _db.foodEntries);
  $$LegacyImportsTableTableManager get legacyImports =>
      $$LegacyImportsTableTableManager(_db, _db.legacyImports);
  $$PlanVersionsTableTableManager get planVersions =>
      $$PlanVersionsTableTableManager(_db, _db.planVersions);
  $$PlanRoutinesTableTableManager get planRoutines =>
      $$PlanRoutinesTableTableManager(_db, _db.planRoutines);
  $$PlanRoutineExercisesTableTableManager get planRoutineExercises =>
      $$PlanRoutineExercisesTableTableManager(_db, _db.planRoutineExercises);
  $$SetLogsTableTableManager get setLogs =>
      $$SetLogsTableTableManager(_db, _db.setLogs);
  $$SessionEventsTableTableManager get sessionEvents =>
      $$SessionEventsTableTableManager(_db, _db.sessionEvents);
  $$ReschedulesTableTableManager get reschedules =>
      $$ReschedulesTableTableManager(_db, _db.reschedules);
  $$SessionAdjustmentsTableTableManager get sessionAdjustments =>
      $$SessionAdjustmentsTableTableManager(_db, _db.sessionAdjustments);
  $$ProgressionDecisionsTableTableManager get progressionDecisions =>
      $$ProgressionDecisionsTableTableManager(_db, _db.progressionDecisions);
  $$MonthlyReviewsTableTableManager get monthlyReviews =>
      $$MonthlyReviewsTableTableManager(_db, _db.monthlyReviews);
  $$CardioSessionsTableTableManager get cardioSessions =>
      $$CardioSessionsTableTableManager(_db, _db.cardioSessions);
  $$CardioSegmentsTableTableManager get cardioSegments =>
      $$CardioSegmentsTableTableManager(_db, _db.cardioSegments);
  $$FoodFavoritesTableTableManager get foodFavorites =>
      $$FoodFavoritesTableTableManager(_db, _db.foodFavorites);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$NutritionGoalsTableTableTableManager get nutritionGoalsTable =>
      $$NutritionGoalsTableTableTableManager(_db, _db.nutritionGoalsTable);
}
