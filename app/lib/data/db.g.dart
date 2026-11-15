// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plotMeta = const VerificationMeta('plot');
  @override
  late final GeneratedColumn<String> plot = GeneratedColumn<String>(
    'plot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _repeatMaskMeta = const VerificationMeta(
    'repeatMask',
  );
  @override
  late final GeneratedColumn<int> repeatMask = GeneratedColumn<int>(
    'repeat_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cropMeta = const VerificationMeta('crop');
  @override
  late final GeneratedColumn<String> crop = GeneratedColumn<String>(
    'crop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdDayMeta = const VerificationMeta(
    'createdDay',
  );
  @override
  late final GeneratedColumn<String> createdDay = GeneratedColumn<String>(
    'created_day',
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
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    plot,
    kind,
    targetMinutes,
    repeatMask,
    crop,
    slot,
    createdDay,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
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
    if (data.containsKey('plot')) {
      context.handle(
        _plotMeta,
        plot.isAcceptableOrUnknown(data['plot']!, _plotMeta),
      );
    } else if (isInserting) {
      context.missing(_plotMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
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
    if (data.containsKey('repeat_mask')) {
      context.handle(
        _repeatMaskMeta,
        repeatMask.isAcceptableOrUnknown(data['repeat_mask']!, _repeatMaskMeta),
      );
    }
    if (data.containsKey('crop')) {
      context.handle(
        _cropMeta,
        crop.isAcceptableOrUnknown(data['crop']!, _cropMeta),
      );
    } else if (isInserting) {
      context.missing(_cropMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('created_day')) {
      context.handle(
        _createdDayMeta,
        createdDay.isAcceptableOrUnknown(data['created_day']!, _createdDayMeta),
      );
    } else if (isInserting) {
      context.missing(_createdDayMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      plot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      ),
      repeatMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_mask'],
      )!,
      crop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      createdDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String plot;
  final String kind;
  final int? targetMinutes;
  final int repeatMask;
  final String crop;
  final int slot;
  final String createdDay;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const Task({
    required this.id,
    required this.title,
    required this.plot,
    required this.kind,
    this.targetMinutes,
    required this.repeatMask,
    required this.crop,
    required this.slot,
    required this.createdDay,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['plot'] = Variable<String>(plot);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || targetMinutes != null) {
      map['target_minutes'] = Variable<int>(targetMinutes);
    }
    map['repeat_mask'] = Variable<int>(repeatMask);
    map['crop'] = Variable<String>(crop);
    map['slot'] = Variable<int>(slot);
    map['created_day'] = Variable<String>(createdDay);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      plot: Value(plot),
      kind: Value(kind),
      targetMinutes: targetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMinutes),
      repeatMask: Value(repeatMask),
      crop: Value(crop),
      slot: Value(slot),
      createdDay: Value(createdDay),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      plot: serializer.fromJson<String>(json['plot']),
      kind: serializer.fromJson<String>(json['kind']),
      targetMinutes: serializer.fromJson<int?>(json['targetMinutes']),
      repeatMask: serializer.fromJson<int>(json['repeatMask']),
      crop: serializer.fromJson<String>(json['crop']),
      slot: serializer.fromJson<int>(json['slot']),
      createdDay: serializer.fromJson<String>(json['createdDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'plot': serializer.toJson<String>(plot),
      'kind': serializer.toJson<String>(kind),
      'targetMinutes': serializer.toJson<int?>(targetMinutes),
      'repeatMask': serializer.toJson<int>(repeatMask),
      'crop': serializer.toJson<String>(crop),
      'slot': serializer.toJson<int>(slot),
      'createdDay': serializer.toJson<String>(createdDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? plot,
    String? kind,
    Value<int?> targetMinutes = const Value.absent(),
    int? repeatMask,
    String? crop,
    int? slot,
    String? createdDay,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    plot: plot ?? this.plot,
    kind: kind ?? this.kind,
    targetMinutes: targetMinutes.present
        ? targetMinutes.value
        : this.targetMinutes,
    repeatMask: repeatMask ?? this.repeatMask,
    crop: crop ?? this.crop,
    slot: slot ?? this.slot,
    createdDay: createdDay ?? this.createdDay,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      plot: data.plot.present ? data.plot.value : this.plot,
      kind: data.kind.present ? data.kind.value : this.kind,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
      repeatMask: data.repeatMask.present
          ? data.repeatMask.value
          : this.repeatMask,
      crop: data.crop.present ? data.crop.value : this.crop,
      slot: data.slot.present ? data.slot.value : this.slot,
      createdDay: data.createdDay.present
          ? data.createdDay.value
          : this.createdDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('plot: $plot, ')
          ..write('kind: $kind, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('repeatMask: $repeatMask, ')
          ..write('crop: $crop, ')
          ..write('slot: $slot, ')
          ..write('createdDay: $createdDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    plot,
    kind,
    targetMinutes,
    repeatMask,
    crop,
    slot,
    createdDay,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.plot == this.plot &&
          other.kind == this.kind &&
          other.targetMinutes == this.targetMinutes &&
          other.repeatMask == this.repeatMask &&
          other.crop == this.crop &&
          other.slot == this.slot &&
          other.createdDay == this.createdDay &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> plot;
  final Value<String> kind;
  final Value<int?> targetMinutes;
  final Value<int> repeatMask;
  final Value<String> crop;
  final Value<int> slot;
  final Value<String> createdDay;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.plot = const Value.absent(),
    this.kind = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.repeatMask = const Value.absent(),
    this.crop = const Value.absent(),
    this.slot = const Value.absent(),
    this.createdDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    required String plot,
    required String kind,
    this.targetMinutes = const Value.absent(),
    this.repeatMask = const Value.absent(),
    required String crop,
    required int slot,
    required String createdDay,
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       plot = Value(plot),
       kind = Value(kind),
       crop = Value(crop),
       slot = Value(slot),
       createdDay = Value(createdDay),
       createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? plot,
    Expression<String>? kind,
    Expression<int>? targetMinutes,
    Expression<int>? repeatMask,
    Expression<String>? crop,
    Expression<int>? slot,
    Expression<String>? createdDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (plot != null) 'plot': plot,
      if (kind != null) 'kind': kind,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
      if (repeatMask != null) 'repeat_mask': repeatMask,
      if (crop != null) 'crop': crop,
      if (slot != null) 'slot': slot,
      if (createdDay != null) 'created_day': createdDay,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? plot,
    Value<String>? kind,
    Value<int?>? targetMinutes,
    Value<int>? repeatMask,
    Value<String>? crop,
    Value<int>? slot,
    Value<String>? createdDay,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      plot: plot ?? this.plot,
      kind: kind ?? this.kind,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      repeatMask: repeatMask ?? this.repeatMask,
      crop: crop ?? this.crop,
      slot: slot ?? this.slot,
      createdDay: createdDay ?? this.createdDay,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
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
    if (plot.present) {
      map['plot'] = Variable<String>(plot.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    if (repeatMask.present) {
      map['repeat_mask'] = Variable<int>(repeatMask.value);
    }
    if (crop.present) {
      map['crop'] = Variable<String>(crop.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (createdDay.present) {
      map['created_day'] = Variable<String>(createdDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('plot: $plot, ')
          ..write('kind: $kind, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('repeatMask: $repeatMask, ')
          ..write('crop: $crop, ')
          ..write('slot: $slot, ')
          ..write('createdDay: $createdDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, Completion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ripenedAtMeta = const VerificationMeta(
    'ripenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> ripenedAt = GeneratedColumn<DateTime>(
    'ripened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _harvestedAtMeta = const VerificationMeta(
    'harvestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> harvestedAt = GeneratedColumn<DateTime>(
    'harvested_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    day,
    method,
    minutes,
    ripenedAt,
    harvestedAt,
    coins,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Completion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('ripened_at')) {
      context.handle(
        _ripenedAtMeta,
        ripenedAt.isAcceptableOrUnknown(data['ripened_at']!, _ripenedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_ripenedAtMeta);
    }
    if (data.containsKey('harvested_at')) {
      context.handle(
        _harvestedAtMeta,
        harvestedAt.isAcceptableOrUnknown(
          data['harvested_at']!,
          _harvestedAtMeta,
        ),
      );
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {taskId, day},
  ];
  @override
  Completion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Completion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      ripenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ripened_at'],
      )!,
      harvestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}harvested_at'],
      ),
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class Completion extends DataClass implements Insertable<Completion> {
  final String id;
  final String taskId;
  final String day;
  final String method;
  final int minutes;
  final DateTime ripenedAt;
  final DateTime? harvestedAt;
  final int coins;
  const Completion({
    required this.id,
    required this.taskId,
    required this.day,
    required this.method,
    required this.minutes,
    required this.ripenedAt,
    this.harvestedAt,
    required this.coins,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['day'] = Variable<String>(day);
    map['method'] = Variable<String>(method);
    map['minutes'] = Variable<int>(minutes);
    map['ripened_at'] = Variable<DateTime>(ripenedAt);
    if (!nullToAbsent || harvestedAt != null) {
      map['harvested_at'] = Variable<DateTime>(harvestedAt);
    }
    map['coins'] = Variable<int>(coins);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      day: Value(day),
      method: Value(method),
      minutes: Value(minutes),
      ripenedAt: Value(ripenedAt),
      harvestedAt: harvestedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(harvestedAt),
      coins: Value(coins),
    );
  }

  factory Completion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Completion(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      day: serializer.fromJson<String>(json['day']),
      method: serializer.fromJson<String>(json['method']),
      minutes: serializer.fromJson<int>(json['minutes']),
      ripenedAt: serializer.fromJson<DateTime>(json['ripenedAt']),
      harvestedAt: serializer.fromJson<DateTime?>(json['harvestedAt']),
      coins: serializer.fromJson<int>(json['coins']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'day': serializer.toJson<String>(day),
      'method': serializer.toJson<String>(method),
      'minutes': serializer.toJson<int>(minutes),
      'ripenedAt': serializer.toJson<DateTime>(ripenedAt),
      'harvestedAt': serializer.toJson<DateTime?>(harvestedAt),
      'coins': serializer.toJson<int>(coins),
    };
  }

  Completion copyWith({
    String? id,
    String? taskId,
    String? day,
    String? method,
    int? minutes,
    DateTime? ripenedAt,
    Value<DateTime?> harvestedAt = const Value.absent(),
    int? coins,
  }) => Completion(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    day: day ?? this.day,
    method: method ?? this.method,
    minutes: minutes ?? this.minutes,
    ripenedAt: ripenedAt ?? this.ripenedAt,
    harvestedAt: harvestedAt.present ? harvestedAt.value : this.harvestedAt,
    coins: coins ?? this.coins,
  );
  Completion copyWithCompanion(CompletionsCompanion data) {
    return Completion(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      day: data.day.present ? data.day.value : this.day,
      method: data.method.present ? data.method.value : this.method,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      ripenedAt: data.ripenedAt.present ? data.ripenedAt.value : this.ripenedAt,
      harvestedAt: data.harvestedAt.present
          ? data.harvestedAt.value
          : this.harvestedAt,
      coins: data.coins.present ? data.coins.value : this.coins,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Completion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('day: $day, ')
          ..write('method: $method, ')
          ..write('minutes: $minutes, ')
          ..write('ripenedAt: $ripenedAt, ')
          ..write('harvestedAt: $harvestedAt, ')
          ..write('coins: $coins')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    day,
    method,
    minutes,
    ripenedAt,
    harvestedAt,
    coins,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Completion &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.day == this.day &&
          other.method == this.method &&
          other.minutes == this.minutes &&
          other.ripenedAt == this.ripenedAt &&
          other.harvestedAt == this.harvestedAt &&
          other.coins == this.coins);
}

class CompletionsCompanion extends UpdateCompanion<Completion> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> day;
  final Value<String> method;
  final Value<int> minutes;
  final Value<DateTime> ripenedAt;
  final Value<DateTime?> harvestedAt;
  final Value<int> coins;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.day = const Value.absent(),
    this.method = const Value.absent(),
    this.minutes = const Value.absent(),
    this.ripenedAt = const Value.absent(),
    this.harvestedAt = const Value.absent(),
    this.coins = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String id,
    required String taskId,
    required String day,
    required String method,
    this.minutes = const Value.absent(),
    required DateTime ripenedAt,
    this.harvestedAt = const Value.absent(),
    this.coins = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       day = Value(day),
       method = Value(method),
       ripenedAt = Value(ripenedAt);
  static Insertable<Completion> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? day,
    Expression<String>? method,
    Expression<int>? minutes,
    Expression<DateTime>? ripenedAt,
    Expression<DateTime>? harvestedAt,
    Expression<int>? coins,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (day != null) 'day': day,
      if (method != null) 'method': method,
      if (minutes != null) 'minutes': minutes,
      if (ripenedAt != null) 'ripened_at': ripenedAt,
      if (harvestedAt != null) 'harvested_at': harvestedAt,
      if (coins != null) 'coins': coins,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? day,
    Value<String>? method,
    Value<int>? minutes,
    Value<DateTime>? ripenedAt,
    Value<DateTime?>? harvestedAt,
    Value<int>? coins,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      day: day ?? this.day,
      method: method ?? this.method,
      minutes: minutes ?? this.minutes,
      ripenedAt: ripenedAt ?? this.ripenedAt,
      harvestedAt: harvestedAt ?? this.harvestedAt,
      coins: coins ?? this.coins,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (ripenedAt.present) {
      map['ripened_at'] = Variable<DateTime>(ripenedAt.value);
    }
    if (harvestedAt.present) {
      map['harvested_at'] = Variable<DateTime>(harvestedAt.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('day: $day, ')
          ..write('method: $method, ')
          ..write('minutes: $minutes, ')
          ..write('ripenedAt: $ripenedAt, ')
          ..write('harvestedAt: $harvestedAt, ')
          ..write('coins: $coins, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _plannedSecMeta = const VerificationMeta(
    'plannedSec',
  );
  @override
  late final GeneratedColumn<int> plannedSec = GeneratedColumn<int>(
    'planned_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accumulatedSecMeta = const VerificationMeta(
    'accumulatedSec',
  );
  @override
  late final GeneratedColumn<int> accumulatedSec = GeneratedColumn<int>(
    'accumulated_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suspiciousMeta = const VerificationMeta(
    'suspicious',
  );
  @override
  late final GeneratedColumn<bool> suspicious = GeneratedColumn<bool>(
    'suspicious',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("suspicious" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    day,
    startedAt,
    plannedSec,
    accumulatedSec,
    status,
    suspicious,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('planned_sec')) {
      context.handle(
        _plannedSecMeta,
        plannedSec.isAcceptableOrUnknown(data['planned_sec']!, _plannedSecMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedSecMeta);
    }
    if (data.containsKey('accumulated_sec')) {
      context.handle(
        _accumulatedSecMeta,
        accumulatedSec.isAcceptableOrUnknown(
          data['accumulated_sec']!,
          _accumulatedSecMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('suspicious')) {
      context.handle(
        _suspiciousMeta,
        suspicious.isAcceptableOrUnknown(data['suspicious']!, _suspiciousMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      plannedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_sec'],
      )!,
      accumulatedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accumulated_sec'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      suspicious: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}suspicious'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final String id;
  final String taskId;
  final String day;
  final DateTime startedAt;
  final int plannedSec;
  final int accumulatedSec;
  final String status;
  final bool suspicious;
  final DateTime? endedAt;
  const FocusSession({
    required this.id,
    required this.taskId,
    required this.day,
    required this.startedAt,
    required this.plannedSec,
    required this.accumulatedSec,
    required this.status,
    required this.suspicious,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['day'] = Variable<String>(day);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['planned_sec'] = Variable<int>(plannedSec);
    map['accumulated_sec'] = Variable<int>(accumulatedSec);
    map['status'] = Variable<String>(status);
    map['suspicious'] = Variable<bool>(suspicious);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      day: Value(day),
      startedAt: Value(startedAt),
      plannedSec: Value(plannedSec),
      accumulatedSec: Value(accumulatedSec),
      status: Value(status),
      suspicious: Value(suspicious),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      day: serializer.fromJson<String>(json['day']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      plannedSec: serializer.fromJson<int>(json['plannedSec']),
      accumulatedSec: serializer.fromJson<int>(json['accumulatedSec']),
      status: serializer.fromJson<String>(json['status']),
      suspicious: serializer.fromJson<bool>(json['suspicious']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'day': serializer.toJson<String>(day),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'plannedSec': serializer.toJson<int>(plannedSec),
      'accumulatedSec': serializer.toJson<int>(accumulatedSec),
      'status': serializer.toJson<String>(status),
      'suspicious': serializer.toJson<bool>(suspicious),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  FocusSession copyWith({
    String? id,
    String? taskId,
    String? day,
    DateTime? startedAt,
    int? plannedSec,
    int? accumulatedSec,
    String? status,
    bool? suspicious,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => FocusSession(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    day: day ?? this.day,
    startedAt: startedAt ?? this.startedAt,
    plannedSec: plannedSec ?? this.plannedSec,
    accumulatedSec: accumulatedSec ?? this.accumulatedSec,
    status: status ?? this.status,
    suspicious: suspicious ?? this.suspicious,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      day: data.day.present ? data.day.value : this.day,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      plannedSec: data.plannedSec.present
          ? data.plannedSec.value
          : this.plannedSec,
      accumulatedSec: data.accumulatedSec.present
          ? data.accumulatedSec.value
          : this.accumulatedSec,
      status: data.status.present ? data.status.value : this.status,
      suspicious: data.suspicious.present
          ? data.suspicious.value
          : this.suspicious,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('day: $day, ')
          ..write('startedAt: $startedAt, ')
          ..write('plannedSec: $plannedSec, ')
          ..write('accumulatedSec: $accumulatedSec, ')
          ..write('status: $status, ')
          ..write('suspicious: $suspicious, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    day,
    startedAt,
    plannedSec,
    accumulatedSec,
    status,
    suspicious,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.day == this.day &&
          other.startedAt == this.startedAt &&
          other.plannedSec == this.plannedSec &&
          other.accumulatedSec == this.accumulatedSec &&
          other.status == this.status &&
          other.suspicious == this.suspicious &&
          other.endedAt == this.endedAt);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> day;
  final Value<DateTime> startedAt;
  final Value<int> plannedSec;
  final Value<int> accumulatedSec;
  final Value<String> status;
  final Value<bool> suspicious;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.day = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.plannedSec = const Value.absent(),
    this.accumulatedSec = const Value.absent(),
    this.status = const Value.absent(),
    this.suspicious = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    required String id,
    required String taskId,
    required String day,
    required DateTime startedAt,
    required int plannedSec,
    this.accumulatedSec = const Value.absent(),
    required String status,
    this.suspicious = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       day = Value(day),
       startedAt = Value(startedAt),
       plannedSec = Value(plannedSec),
       status = Value(status);
  static Insertable<FocusSession> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? day,
    Expression<DateTime>? startedAt,
    Expression<int>? plannedSec,
    Expression<int>? accumulatedSec,
    Expression<String>? status,
    Expression<bool>? suspicious,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (day != null) 'day': day,
      if (startedAt != null) 'started_at': startedAt,
      if (plannedSec != null) 'planned_sec': plannedSec,
      if (accumulatedSec != null) 'accumulated_sec': accumulatedSec,
      if (status != null) 'status': status,
      if (suspicious != null) 'suspicious': suspicious,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? day,
    Value<DateTime>? startedAt,
    Value<int>? plannedSec,
    Value<int>? accumulatedSec,
    Value<String>? status,
    Value<bool>? suspicious,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      day: day ?? this.day,
      startedAt: startedAt ?? this.startedAt,
      plannedSec: plannedSec ?? this.plannedSec,
      accumulatedSec: accumulatedSec ?? this.accumulatedSec,
      status: status ?? this.status,
      suspicious: suspicious ?? this.suspicious,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (plannedSec.present) {
      map['planned_sec'] = Variable<int>(plannedSec.value);
    }
    if (accumulatedSec.present) {
      map['accumulated_sec'] = Variable<int>(accumulatedSec.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (suspicious.present) {
      map['suspicious'] = Variable<bool>(suspicious.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('day: $day, ')
          ..write('startedAt: $startedAt, ')
          ..write('plannedSec: $plannedSec, ')
          ..write('accumulatedSec: $accumulatedSec, ')
          ..write('status: $status, ')
          ..write('suspicious: $suspicious, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JournalTable extends Journal with TableInfo<$JournalTable, JournalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [day, mood, note, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  JournalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalData(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JournalTable createAlias(String alias) {
    return $JournalTable(attachedDatabase, alias);
  }
}

class JournalData extends DataClass implements Insertable<JournalData> {
  final String day;
  final int? mood;
  final String? note;
  final DateTime updatedAt;
  const JournalData({
    required this.day,
    this.mood,
    this.note,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JournalCompanion toCompanion(bool nullToAbsent) {
    return JournalCompanion(
      day: Value(day),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
    );
  }

  factory JournalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalData(
      day: serializer.fromJson<String>(json['day']),
      mood: serializer.fromJson<int?>(json['mood']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'mood': serializer.toJson<int?>(mood),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JournalData copyWith({
    String? day,
    Value<int?> mood = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
  }) => JournalData(
    day: day ?? this.day,
    mood: mood.present ? mood.value : this.mood,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JournalData copyWithCompanion(JournalCompanion data) {
    return JournalData(
      day: data.day.present ? data.day.value : this.day,
      mood: data.mood.present ? data.mood.value : this.mood,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalData(')
          ..write('day: $day, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, mood, note, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalData &&
          other.day == this.day &&
          other.mood == this.mood &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt);
}

class JournalCompanion extends UpdateCompanion<JournalData> {
  final Value<String> day;
  final Value<int?> mood;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const JournalCompanion({
    this.day = const Value.absent(),
    this.mood = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JournalCompanion.insert({
    required String day,
    this.mood = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       updatedAt = Value(updatedAt);
  static Insertable<JournalData> custom({
    Expression<String>? day,
    Expression<int>? mood,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (mood != null) 'mood': mood,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JournalCompanion copyWith({
    Value<String>? day,
    Value<int?>? mood,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return JournalCompanion(
      day: day ?? this.day,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('JournalCompanion(')
          ..write('day: $day, ')
          ..write('mood: $mood, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _placedSpotMeta = const VerificationMeta(
    'placedSpot',
  );
  @override
  late final GeneratedColumn<int> placedSpot = GeneratedColumn<int>(
    'placed_spot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, qty, placedSpot];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('placed_spot')) {
      context.handle(
        _placedSpotMeta,
        placedSpot.isAcceptableOrUnknown(data['placed_spot']!, _placedSpotMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  InventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryData(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      placedSpot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}placed_spot'],
      ),
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryData extends DataClass implements Insertable<InventoryData> {
  final String itemId;
  final int qty;
  final int? placedSpot;
  const InventoryData({
    required this.itemId,
    required this.qty,
    this.placedSpot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['qty'] = Variable<int>(qty);
    if (!nullToAbsent || placedSpot != null) {
      map['placed_spot'] = Variable<int>(placedSpot);
    }
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      itemId: Value(itemId),
      qty: Value(qty),
      placedSpot: placedSpot == null && nullToAbsent
          ? const Value.absent()
          : Value(placedSpot),
    );
  }

  factory InventoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryData(
      itemId: serializer.fromJson<String>(json['itemId']),
      qty: serializer.fromJson<int>(json['qty']),
      placedSpot: serializer.fromJson<int?>(json['placedSpot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'qty': serializer.toJson<int>(qty),
      'placedSpot': serializer.toJson<int?>(placedSpot),
    };
  }

  InventoryData copyWith({
    String? itemId,
    int? qty,
    Value<int?> placedSpot = const Value.absent(),
  }) => InventoryData(
    itemId: itemId ?? this.itemId,
    qty: qty ?? this.qty,
    placedSpot: placedSpot.present ? placedSpot.value : this.placedSpot,
  );
  InventoryData copyWithCompanion(InventoryCompanion data) {
    return InventoryData(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      qty: data.qty.present ? data.qty.value : this.qty,
      placedSpot: data.placedSpot.present
          ? data.placedSpot.value
          : this.placedSpot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryData(')
          ..write('itemId: $itemId, ')
          ..write('qty: $qty, ')
          ..write('placedSpot: $placedSpot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, qty, placedSpot);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryData &&
          other.itemId == this.itemId &&
          other.qty == this.qty &&
          other.placedSpot == this.placedSpot);
}

class InventoryCompanion extends UpdateCompanion<InventoryData> {
  final Value<String> itemId;
  final Value<int> qty;
  final Value<int?> placedSpot;
  final Value<int> rowid;
  const InventoryCompanion({
    this.itemId = const Value.absent(),
    this.qty = const Value.absent(),
    this.placedSpot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({
    required String itemId,
    this.qty = const Value.absent(),
    this.placedSpot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId);
  static Insertable<InventoryData> custom({
    Expression<String>? itemId,
    Expression<int>? qty,
    Expression<int>? placedSpot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (qty != null) 'qty': qty,
      if (placedSpot != null) 'placed_spot': placedSpot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith({
    Value<String>? itemId,
    Value<int>? qty,
    Value<int?>? placedSpot,
    Value<int>? rowid,
  }) {
    return InventoryCompanion(
      itemId: itemId ?? this.itemId,
      qty: qty ?? this.qty,
      placedSpot: placedSpot ?? this.placedSpot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (placedSpot.present) {
      map['placed_spot'] = Variable<int>(placedSpot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('itemId: $itemId, ')
          ..write('qty: $qty, ')
          ..write('placedSpot: $placedSpot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoinLedgerTable extends CoinLedger
    with TableInfo<$CoinLedgerTable, CoinLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoinLedgerTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
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
    delta,
    reason,
    refId,
    day,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coin_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoinLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
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
  CoinLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoinLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CoinLedgerTable createAlias(String alias) {
    return $CoinLedgerTable(attachedDatabase, alias);
  }
}

class CoinLedgerData extends DataClass implements Insertable<CoinLedgerData> {
  final int id;
  final int delta;
  final String reason;
  final String? refId;
  final String day;
  final DateTime createdAt;
  const CoinLedgerData({
    required this.id,
    required this.delta,
    required this.reason,
    this.refId,
    required this.day,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delta'] = Variable<int>(delta);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    map['day'] = Variable<String>(day);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CoinLedgerCompanion toCompanion(bool nullToAbsent) {
    return CoinLedgerCompanion(
      id: Value(id),
      delta: Value(delta),
      reason: Value(reason),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
      day: Value(day),
      createdAt: Value(createdAt),
    );
  }

  factory CoinLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoinLedgerData(
      id: serializer.fromJson<int>(json['id']),
      delta: serializer.fromJson<int>(json['delta']),
      reason: serializer.fromJson<String>(json['reason']),
      refId: serializer.fromJson<String?>(json['refId']),
      day: serializer.fromJson<String>(json['day']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'delta': serializer.toJson<int>(delta),
      'reason': serializer.toJson<String>(reason),
      'refId': serializer.toJson<String?>(refId),
      'day': serializer.toJson<String>(day),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CoinLedgerData copyWith({
    int? id,
    int? delta,
    String? reason,
    Value<String?> refId = const Value.absent(),
    String? day,
    DateTime? createdAt,
  }) => CoinLedgerData(
    id: id ?? this.id,
    delta: delta ?? this.delta,
    reason: reason ?? this.reason,
    refId: refId.present ? refId.value : this.refId,
    day: day ?? this.day,
    createdAt: createdAt ?? this.createdAt,
  );
  CoinLedgerData copyWithCompanion(CoinLedgerCompanion data) {
    return CoinLedgerData(
      id: data.id.present ? data.id.value : this.id,
      delta: data.delta.present ? data.delta.value : this.delta,
      reason: data.reason.present ? data.reason.value : this.reason,
      refId: data.refId.present ? data.refId.value : this.refId,
      day: data.day.present ? data.day.value : this.day,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoinLedgerData(')
          ..write('id: $id, ')
          ..write('delta: $delta, ')
          ..write('reason: $reason, ')
          ..write('refId: $refId, ')
          ..write('day: $day, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, delta, reason, refId, day, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoinLedgerData &&
          other.id == this.id &&
          other.delta == this.delta &&
          other.reason == this.reason &&
          other.refId == this.refId &&
          other.day == this.day &&
          other.createdAt == this.createdAt);
}

class CoinLedgerCompanion extends UpdateCompanion<CoinLedgerData> {
  final Value<int> id;
  final Value<int> delta;
  final Value<String> reason;
  final Value<String?> refId;
  final Value<String> day;
  final Value<DateTime> createdAt;
  const CoinLedgerCompanion({
    this.id = const Value.absent(),
    this.delta = const Value.absent(),
    this.reason = const Value.absent(),
    this.refId = const Value.absent(),
    this.day = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CoinLedgerCompanion.insert({
    this.id = const Value.absent(),
    required int delta,
    required String reason,
    this.refId = const Value.absent(),
    required String day,
    required DateTime createdAt,
  }) : delta = Value(delta),
       reason = Value(reason),
       day = Value(day),
       createdAt = Value(createdAt);
  static Insertable<CoinLedgerData> custom({
    Expression<int>? id,
    Expression<int>? delta,
    Expression<String>? reason,
    Expression<String>? refId,
    Expression<String>? day,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (delta != null) 'delta': delta,
      if (reason != null) 'reason': reason,
      if (refId != null) 'ref_id': refId,
      if (day != null) 'day': day,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CoinLedgerCompanion copyWith({
    Value<int>? id,
    Value<int>? delta,
    Value<String>? reason,
    Value<String?>? refId,
    Value<String>? day,
    Value<DateTime>? createdAt,
  }) {
    return CoinLedgerCompanion(
      id: id ?? this.id,
      delta: delta ?? this.delta,
      reason: reason ?? this.reason,
      refId: refId ?? this.refId,
      day: day ?? this.day,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoinLedgerCompanion(')
          ..write('id: $id, ')
          ..write('delta: $delta, ')
          ..write('reason: $reason, ')
          ..write('refId: $refId, ')
          ..write('day: $day, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CultivaDb extends GeneratedDatabase {
  _$CultivaDb(QueryExecutor e) : super(e);
  $CultivaDbManager get managers => $CultivaDbManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $JournalTable journal = $JournalTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $CoinLedgerTable coinLedger = $CoinLedgerTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index completionsDay = Index(
    'completions_day',
    'CREATE INDEX completions_day ON completions (day)',
  );
  late final Index focusTaskDay = Index(
    'focus_task_day',
    'CREATE INDEX focus_task_day ON focus_sessions (task_id, day)',
  );
  late final Index ledgerDay = Index(
    'ledger_day',
    'CREATE INDEX ledger_day ON coin_ledger (day)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    completions,
    focusSessions,
    journal,
    inventory,
    coinLedger,
    settings,
    completionsDay,
    focusTaskDay,
    ledgerDay,
  ];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  required String plot,
  required String kind,
  Value<int?> targetMinutes,
  Value<int> repeatMask,
  required String crop,
  required int slot,
  required String createdDay,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> plot,
  Value<String> kind,
  Value<int?> targetMinutes,
  Value<int> repeatMask,
  Value<String> crop,
  Value<int> slot,
  Value<String> createdDay,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$CultivaDb, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompletionsTable, List<Completion>>
  _completionsRefsTable(_$CultivaDb db) => MultiTypedResultKey.fromTable(
    db.completions,
    aliasName: 'tasks__id__completions__task_id',
  );

  $$CompletionsTableProcessedTableManager get completionsRefs {
    final manager = $$CompletionsTableTableManager(
      $_db,
      $_db.completions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_completionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$CultivaDb db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'tasks__id__focus_sessions__task_id',
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$CultivaDb, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatMask => $composableBuilder(
    column: $table.repeatMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get crop => $composableBuilder(
    column: $table.crop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdDay => $composableBuilder(
    column: $table.createdDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> completionsRefs(
    Expression<bool> Function($$CompletionsTableFilterComposer f) f,
  ) {
    final $$CompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionsTableFilterComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer extends Composer<_$CultivaDb, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatMask => $composableBuilder(
    column: $table.repeatMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crop => $composableBuilder(
    column: $table.crop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdDay => $composableBuilder(
    column: $table.createdDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$CultivaDb, $TasksTable> {
  $$TasksTableAnnotationComposer({
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

  GeneratedColumn<String> get plot =>
      $composableBuilder(column: $table.plot, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatMask => $composableBuilder(
    column: $table.repeatMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get crop =>
      $composableBuilder(column: $table.crop, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get createdDay => $composableBuilder(
    column: $table.createdDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> completionsRefs<T extends Object>(
    Expression<T> Function($$CompletionsTableAnnotationComposer a) f,
  ) {
    final $$CompletionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionsTableAnnotationComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool completionsRefs, bool focusSessionsRefs})
        > {
  $$TasksTableTableManager(_$CultivaDb db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> plot = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<int> repeatMask = const Value.absent(),
                Value<String> crop = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<String> createdDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                plot: plot,
                kind: kind,
                targetMinutes: targetMinutes,
                repeatMask: repeatMask,
                crop: crop,
                slot: slot,
                createdDay: createdDay,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String plot,
                required String kind,
                Value<int?> targetMinutes = const Value.absent(),
                Value<int> repeatMask = const Value.absent(),
                required String crop,
                required int slot,
                required String createdDay,
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                plot: plot,
                kind: kind,
                targetMinutes: targetMinutes,
                repeatMask: repeatMask,
                crop: crop,
                slot: slot,
                createdDay: createdDay,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({completionsRefs = false, focusSessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (completionsRefs) db.completions,
                    if (focusSessionsRefs) db.focusSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (completionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Task,
                          $TasksTable,
                          Completion,
                          $CompletionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._completionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).completionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'task_id',
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Task,
                          $TasksTable,
                          FocusSession,
                          $FocusSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'task_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool completionsRefs, bool focusSessionsRefs})
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      required String id,
      required String taskId,
      required String day,
      required String method,
      Value<int> minutes,
      required DateTime ripenedAt,
      Value<DateTime?> harvestedAt,
      Value<int> coins,
      Value<int> rowid,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> day,
      Value<String> method,
      Value<int> minutes,
      Value<DateTime> ripenedAt,
      Value<DateTime?> harvestedAt,
      Value<int> coins,
      Value<int> rowid,
    });

final class $$CompletionsTableReferences
    extends BaseReferences<_$CultivaDb, $CompletionsTable, Completion> {
  $$CompletionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$CultivaDb db) =>
      db.tasks.createAlias('completions__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompletionsTableFilterComposer
    extends Composer<_$CultivaDb, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
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

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ripenedAt => $composableBuilder(
    column: $table.ripenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get harvestedAt => $composableBuilder(
    column: $table.harvestedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$CultivaDb, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
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

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ripenedAt => $composableBuilder(
    column: $table.ripenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get harvestedAt => $composableBuilder(
    column: $table.harvestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$CultivaDb, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<DateTime> get ripenedAt =>
      $composableBuilder(column: $table.ripenedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get harvestedAt => $composableBuilder(
    column: $table.harvestedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $CompletionsTable,
          Completion,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (Completion, $$CompletionsTableReferences),
          Completion,
          PrefetchHooks Function({bool taskId})
        > {
  $$CompletionsTableTableManager(_$CultivaDb db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<DateTime> ripenedAt = const Value.absent(),
                Value<DateTime?> harvestedAt = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                taskId: taskId,
                day: day,
                method: method,
                minutes: minutes,
                ripenedAt: ripenedAt,
                harvestedAt: harvestedAt,
                coins: coins,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String day,
                required String method,
                Value<int> minutes = const Value.absent(),
                required DateTime ripenedAt,
                Value<DateTime?> harvestedAt = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                id: id,
                taskId: taskId,
                day: day,
                method: method,
                minutes: minutes,
                ripenedAt: ripenedAt,
                harvestedAt: harvestedAt,
                coins: coins,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionsTable, Completion>(table),
                  $$CompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$CompletionsTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$CompletionsTableReferences
                            ._taskIdTable(db)
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

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $CompletionsTable,
      Completion,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (Completion, $$CompletionsTableReferences),
      Completion,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      required String id,
      required String taskId,
      required String day,
      required DateTime startedAt,
      required int plannedSec,
      Value<int> accumulatedSec,
      required String status,
      Value<bool> suspicious,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> day,
      Value<DateTime> startedAt,
      Value<int> plannedSec,
      Value<int> accumulatedSec,
      Value<String> status,
      Value<bool> suspicious,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

final class $$FocusSessionsTableReferences
    extends BaseReferences<_$CultivaDb, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$CultivaDb db) =>
      db.tasks.createAlias('focus_sessions__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$CultivaDb, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
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

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSec => $composableBuilder(
    column: $table.plannedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accumulatedSec => $composableBuilder(
    column: $table.accumulatedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get suspicious => $composableBuilder(
    column: $table.suspicious,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$CultivaDb, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSec => $composableBuilder(
    column: $table.plannedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accumulatedSec => $composableBuilder(
    column: $table.accumulatedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get suspicious => $composableBuilder(
    column: $table.suspicious,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$CultivaDb, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get plannedSec => $composableBuilder(
    column: $table.plannedSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accumulatedSec => $composableBuilder(
    column: $table.accumulatedSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get suspicious => $composableBuilder(
    column: $table.suspicious,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({bool taskId})
        > {
  $$FocusSessionsTableTableManager(_$CultivaDb db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> plannedSec = const Value.absent(),
                Value<int> accumulatedSec = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> suspicious = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                taskId: taskId,
                day: day,
                startedAt: startedAt,
                plannedSec: plannedSec,
                accumulatedSec: accumulatedSec,
                status: status,
                suspicious: suspicious,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String day,
                required DateTime startedAt,
                required int plannedSec,
                Value<int> accumulatedSec = const Value.absent(),
                required String status,
                Value<bool> suspicious = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                taskId: taskId,
                day: day,
                startedAt: startedAt,
                plannedSec: plannedSec,
                accumulatedSec: accumulatedSec,
                status: status,
                suspicious: suspicious,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusSessionsTable, FocusSession>(table),
                  $$FocusSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
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
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$FocusSessionsTableReferences
                            ._taskIdTable(db),
                        referencedColumn: $$FocusSessionsTableReferences
                            ._taskIdTable(db)
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

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$JournalTableCreateCompanionBuilder = JournalCompanion Function({
  required String day,
  Value<int?> mood,
  Value<String?> note,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$JournalTableUpdateCompanionBuilder = JournalCompanion Function({
  Value<String> day,
  Value<int?> mood,
  Value<String?> note,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$JournalTableFilterComposer
    extends Composer<_$CultivaDb, $JournalTable> {
  $$JournalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JournalTableOrderingComposer
    extends Composer<_$CultivaDb, $JournalTable> {
  $$JournalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JournalTableAnnotationComposer
    extends Composer<_$CultivaDb, $JournalTable> {
  $$JournalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JournalTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $JournalTable,
          JournalData,
          $$JournalTableFilterComposer,
          $$JournalTableOrderingComposer,
          $$JournalTableAnnotationComposer,
          $$JournalTableCreateCompanionBuilder,
          $$JournalTableUpdateCompanionBuilder,
          (
            JournalData,
            BaseReferences<_$CultivaDb, $JournalTable, JournalData>,
          ),
          JournalData,
          PrefetchHooks Function()
        > {
  $$JournalTableTableManager(_$CultivaDb db, $JournalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JournalCompanion(
                day: day,
                mood: mood,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                Value<int?> mood = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => JournalCompanion.insert(
                day: day,
                mood: mood,
                note: note,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JournalTable, JournalData>(table),
                  BaseReferences<_$CultivaDb, $JournalTable, JournalData>(
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

typedef $$JournalTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $JournalTable,
      JournalData,
      $$JournalTableFilterComposer,
      $$JournalTableOrderingComposer,
      $$JournalTableAnnotationComposer,
      $$JournalTableCreateCompanionBuilder,
      $$JournalTableUpdateCompanionBuilder,
      (JournalData, BaseReferences<_$CultivaDb, $JournalTable, JournalData>),
      JournalData,
      PrefetchHooks Function()
    >;
typedef $$InventoryTableCreateCompanionBuilder = InventoryCompanion Function({
  required String itemId,
  Value<int> qty,
  Value<int?> placedSpot,
  Value<int> rowid,
});
typedef $$InventoryTableUpdateCompanionBuilder = InventoryCompanion Function({
  Value<String> itemId,
  Value<int> qty,
  Value<int?> placedSpot,
  Value<int> rowid,
});

class $$InventoryTableFilterComposer
    extends Composer<_$CultivaDb, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placedSpot => $composableBuilder(
    column: $table.placedSpot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryTableOrderingComposer
    extends Composer<_$CultivaDb, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placedSpot => $composableBuilder(
    column: $table.placedSpot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$CultivaDb, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get placedSpot => $composableBuilder(
    column: $table.placedSpot,
    builder: (column) => column,
  );
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $InventoryTable,
          InventoryData,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (
            InventoryData,
            BaseReferences<_$CultivaDb, $InventoryTable, InventoryData>,
          ),
          InventoryData,
          PrefetchHooks Function()
        > {
  $$InventoryTableTableManager(_$CultivaDb db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int?> placedSpot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion(
                itemId: itemId,
                qty: qty,
                placedSpot: placedSpot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                Value<int> qty = const Value.absent(),
                Value<int?> placedSpot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion.insert(
                itemId: itemId,
                qty: qty,
                placedSpot: placedSpot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryTable, InventoryData>(table),
                  BaseReferences<_$CultivaDb, $InventoryTable, InventoryData>(
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

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $InventoryTable,
      InventoryData,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (
        InventoryData,
        BaseReferences<_$CultivaDb, $InventoryTable, InventoryData>,
      ),
      InventoryData,
      PrefetchHooks Function()
    >;
typedef $$CoinLedgerTableCreateCompanionBuilder = CoinLedgerCompanion Function({
  Value<int> id,
  required int delta,
  required String reason,
  Value<String?> refId,
  required String day,
  required DateTime createdAt,
});
typedef $$CoinLedgerTableUpdateCompanionBuilder = CoinLedgerCompanion Function({
  Value<int> id,
  Value<int> delta,
  Value<String> reason,
  Value<String?> refId,
  Value<String> day,
  Value<DateTime> createdAt,
});

class $$CoinLedgerTableFilterComposer
    extends Composer<_$CultivaDb, $CoinLedgerTable> {
  $$CoinLedgerTableFilterComposer({
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

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoinLedgerTableOrderingComposer
    extends Composer<_$CultivaDb, $CoinLedgerTable> {
  $$CoinLedgerTableOrderingComposer({
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

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoinLedgerTableAnnotationComposer
    extends Composer<_$CultivaDb, $CoinLedgerTable> {
  $$CoinLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CoinLedgerTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $CoinLedgerTable,
          CoinLedgerData,
          $$CoinLedgerTableFilterComposer,
          $$CoinLedgerTableOrderingComposer,
          $$CoinLedgerTableAnnotationComposer,
          $$CoinLedgerTableCreateCompanionBuilder,
          $$CoinLedgerTableUpdateCompanionBuilder,
          (
            CoinLedgerData,
            BaseReferences<_$CultivaDb, $CoinLedgerTable, CoinLedgerData>,
          ),
          CoinLedgerData,
          PrefetchHooks Function()
        > {
  $$CoinLedgerTableTableManager(_$CultivaDb db, $CoinLedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoinLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoinLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoinLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CoinLedgerCompanion(
                id: id,
                delta: delta,
                reason: reason,
                refId: refId,
                day: day,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int delta,
                required String reason,
                Value<String?> refId = const Value.absent(),
                required String day,
                required DateTime createdAt,
              }) => CoinLedgerCompanion.insert(
                id: id,
                delta: delta,
                reason: reason,
                refId: refId,
                day: day,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoinLedgerTable, CoinLedgerData>(table),
                  BaseReferences<_$CultivaDb, $CoinLedgerTable, CoinLedgerData>(
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

typedef $$CoinLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $CoinLedgerTable,
      CoinLedgerData,
      $$CoinLedgerTableFilterComposer,
      $$CoinLedgerTableOrderingComposer,
      $$CoinLedgerTableAnnotationComposer,
      $$CoinLedgerTableCreateCompanionBuilder,
      $$CoinLedgerTableUpdateCompanionBuilder,
      (
        CoinLedgerData,
        BaseReferences<_$CultivaDb, $CoinLedgerTable, CoinLedgerData>,
      ),
      CoinLedgerData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$CultivaDb, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$CultivaDb, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$CultivaDb, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$CultivaDb,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$CultivaDb, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$CultivaDb db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$CultivaDb, $SettingsTable, Setting>(
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

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$CultivaDb,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$CultivaDb, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $CultivaDbManager {
  final _$CultivaDb _db;
  $CultivaDbManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$JournalTableTableManager get journal =>
      $$JournalTableTableManager(_db, _db.journal);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$CoinLedgerTableTableManager get coinLedger =>
      $$CoinLedgerTableTableManager(_db, _db.coinLedger);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
