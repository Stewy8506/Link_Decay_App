// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LinksTable extends Links with TableInfo<$LinksTable, Link> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faviconUrlMeta = const VerificationMeta(
    'faviconUrl',
  );
  @override
  late final GeneratedColumn<String> faviconUrl = GeneratedColumn<String>(
    'favicon_url',
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
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LinkStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LinkStatus>($LinksTable.$converterstatus);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _snoozedSecondsMeta = const VerificationMeta(
    'snoozedSeconds',
  );
  @override
  late final GeneratedColumn<int> snoozedSeconds = GeneratedColumn<int>(
    'snoozed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    domain,
    faviconUrl,
    createdAt,
    snoozedUntil,
    status,
    tags,
    snoozedSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'links';
  @override
  VerificationContext validateIntegrity(
    Insertable<Link> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('favicon_url')) {
      context.handle(
        _faviconUrlMeta,
        faviconUrl.isAcceptableOrUnknown(data['favicon_url']!, _faviconUrlMeta),
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
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('snoozed_seconds')) {
      context.handle(
        _snoozedSecondsMeta,
        snoozedSeconds.isAcceptableOrUnknown(
          data['snoozed_seconds']!,
          _snoozedSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Link map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Link(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      faviconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favicon_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      status: $LinksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      snoozedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snoozed_seconds'],
      )!,
    );
  }

  @override
  $LinksTable createAlias(String alias) {
    return $LinksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LinkStatus, String, String> $converterstatus =
      const EnumNameConverter<LinkStatus>(LinkStatus.values);
}

class Link extends DataClass implements Insertable<Link> {
  final String id;
  final String url;
  final String? title;
  final String domain;
  final String? faviconUrl;
  final DateTime createdAt;
  final DateTime? snoozedUntil;
  final LinkStatus status;
  final String tags;
  final int snoozedSeconds;
  const Link({
    required this.id,
    required this.url,
    this.title,
    required this.domain,
    this.faviconUrl,
    required this.createdAt,
    this.snoozedUntil,
    required this.status,
    required this.tags,
    required this.snoozedSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['domain'] = Variable<String>(domain);
    if (!nullToAbsent || faviconUrl != null) {
      map['favicon_url'] = Variable<String>(faviconUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    {
      map['status'] = Variable<String>(
        $LinksTable.$converterstatus.toSql(status),
      );
    }
    map['tags'] = Variable<String>(tags);
    map['snoozed_seconds'] = Variable<int>(snoozedSeconds);
    return map;
  }

  LinksCompanion toCompanion(bool nullToAbsent) {
    return LinksCompanion(
      id: Value(id),
      url: Value(url),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      domain: Value(domain),
      faviconUrl: faviconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(faviconUrl),
      createdAt: Value(createdAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      status: Value(status),
      tags: Value(tags),
      snoozedSeconds: Value(snoozedSeconds),
    );
  }

  factory Link.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Link(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      domain: serializer.fromJson<String>(json['domain']),
      faviconUrl: serializer.fromJson<String?>(json['faviconUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      status: $LinksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      tags: serializer.fromJson<String>(json['tags']),
      snoozedSeconds: serializer.fromJson<int>(json['snoozedSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String?>(title),
      'domain': serializer.toJson<String>(domain),
      'faviconUrl': serializer.toJson<String?>(faviconUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'status': serializer.toJson<String>(
        $LinksTable.$converterstatus.toJson(status),
      ),
      'tags': serializer.toJson<String>(tags),
      'snoozedSeconds': serializer.toJson<int>(snoozedSeconds),
    };
  }

  Link copyWith({
    String? id,
    String? url,
    Value<String?> title = const Value.absent(),
    String? domain,
    Value<String?> faviconUrl = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> snoozedUntil = const Value.absent(),
    LinkStatus? status,
    String? tags,
    int? snoozedSeconds,
  }) => Link(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    domain: domain ?? this.domain,
    faviconUrl: faviconUrl.present ? faviconUrl.value : this.faviconUrl,
    createdAt: createdAt ?? this.createdAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    status: status ?? this.status,
    tags: tags ?? this.tags,
    snoozedSeconds: snoozedSeconds ?? this.snoozedSeconds,
  );
  Link copyWithCompanion(LinksCompanion data) {
    return Link(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      domain: data.domain.present ? data.domain.value : this.domain,
      faviconUrl: data.faviconUrl.present
          ? data.faviconUrl.value
          : this.faviconUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      status: data.status.present ? data.status.value : this.status,
      tags: data.tags.present ? data.tags.value : this.tags,
      snoozedSeconds: data.snoozedSeconds.present
          ? data.snoozedSeconds.value
          : this.snoozedSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Link(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('domain: $domain, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('status: $status, ')
          ..write('tags: $tags, ')
          ..write('snoozedSeconds: $snoozedSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    domain,
    faviconUrl,
    createdAt,
    snoozedUntil,
    status,
    tags,
    snoozedSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Link &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.domain == this.domain &&
          other.faviconUrl == this.faviconUrl &&
          other.createdAt == this.createdAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.status == this.status &&
          other.tags == this.tags &&
          other.snoozedSeconds == this.snoozedSeconds);
}

class LinksCompanion extends UpdateCompanion<Link> {
  final Value<String> id;
  final Value<String> url;
  final Value<String?> title;
  final Value<String> domain;
  final Value<String?> faviconUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime?> snoozedUntil;
  final Value<LinkStatus> status;
  final Value<String> tags;
  final Value<int> snoozedSeconds;
  final Value<int> rowid;
  const LinksCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.domain = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.status = const Value.absent(),
    this.tags = const Value.absent(),
    this.snoozedSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinksCompanion.insert({
    required String id,
    required String url,
    this.title = const Value.absent(),
    required String domain,
    this.faviconUrl = const Value.absent(),
    required DateTime createdAt,
    this.snoozedUntil = const Value.absent(),
    required LinkStatus status,
    this.tags = const Value.absent(),
    this.snoozedSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url),
       domain = Value(domain),
       createdAt = Value(createdAt),
       status = Value(status);
  static Insertable<Link> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? domain,
    Expression<String>? faviconUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? snoozedUntil,
    Expression<String>? status,
    Expression<String>? tags,
    Expression<int>? snoozedSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (domain != null) 'domain': domain,
      if (faviconUrl != null) 'favicon_url': faviconUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (status != null) 'status': status,
      if (tags != null) 'tags': tags,
      if (snoozedSeconds != null) 'snoozed_seconds': snoozedSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinksCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String?>? title,
    Value<String>? domain,
    Value<String?>? faviconUrl,
    Value<DateTime>? createdAt,
    Value<DateTime?>? snoozedUntil,
    Value<LinkStatus>? status,
    Value<String>? tags,
    Value<int>? snoozedSeconds,
    Value<int>? rowid,
  }) {
    return LinksCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      createdAt: createdAt ?? this.createdAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      snoozedSeconds: snoozedSeconds ?? this.snoozedSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (faviconUrl.present) {
      map['favicon_url'] = Variable<String>(faviconUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $LinksTable.$converterstatus.toSql(status.value),
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (snoozedSeconds.present) {
      map['snoozed_seconds'] = Variable<int>(snoozedSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinksCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('domain: $domain, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('status: $status, ')
          ..write('tags: $tags, ')
          ..write('snoozedSeconds: $snoozedSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _halfLifeDaysMeta = const VerificationMeta(
    'halfLifeDays',
  );
  @override
  late final GeneratedColumn<double> halfLifeDays = GeneratedColumn<double>(
    'half_life_days',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(7.0),
  );
  static const VerificationMeta _notificationThresholdMeta =
      const VerificationMeta('notificationThreshold');
  @override
  late final GeneratedColumn<double> notificationThreshold =
      GeneratedColumn<double>(
        'notification_threshold',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.25),
      );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDarkModeMeta = const VerificationMeta(
    'isDarkMode',
  );
  @override
  late final GeneratedColumn<bool> isDarkMode = GeneratedColumn<bool>(
    'is_dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dark_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halfLifeDays,
    notificationThreshold,
    notificationsEnabled,
    isDarkMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('half_life_days')) {
      context.handle(
        _halfLifeDaysMeta,
        halfLifeDays.isAcceptableOrUnknown(
          data['half_life_days']!,
          _halfLifeDaysMeta,
        ),
      );
    }
    if (data.containsKey('notification_threshold')) {
      context.handle(
        _notificationThresholdMeta,
        notificationThreshold.isAcceptableOrUnknown(
          data['notification_threshold']!,
          _notificationThresholdMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('is_dark_mode')) {
      context.handle(
        _isDarkModeMeta,
        isDarkMode.isAcceptableOrUnknown(
          data['is_dark_mode']!,
          _isDarkModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      halfLifeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}half_life_days'],
      )!,
      notificationThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}notification_threshold'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      isDarkMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dark_mode'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final double halfLifeDays;
  final double notificationThreshold;
  final bool notificationsEnabled;
  final bool isDarkMode;
  const AppSetting({
    required this.id,
    required this.halfLifeDays,
    required this.notificationThreshold,
    required this.notificationsEnabled,
    required this.isDarkMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['half_life_days'] = Variable<double>(halfLifeDays);
    map['notification_threshold'] = Variable<double>(notificationThreshold);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      halfLifeDays: Value(halfLifeDays),
      notificationThreshold: Value(notificationThreshold),
      notificationsEnabled: Value(notificationsEnabled),
      isDarkMode: Value(isDarkMode),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      halfLifeDays: serializer.fromJson<double>(json['halfLifeDays']),
      notificationThreshold: serializer.fromJson<double>(
        json['notificationThreshold'],
      ),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      isDarkMode: serializer.fromJson<bool>(json['isDarkMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'halfLifeDays': serializer.toJson<double>(halfLifeDays),
      'notificationThreshold': serializer.toJson<double>(notificationThreshold),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'isDarkMode': serializer.toJson<bool>(isDarkMode),
    };
  }

  AppSetting copyWith({
    int? id,
    double? halfLifeDays,
    double? notificationThreshold,
    bool? notificationsEnabled,
    bool? isDarkMode,
  }) => AppSetting(
    id: id ?? this.id,
    halfLifeDays: halfLifeDays ?? this.halfLifeDays,
    notificationThreshold: notificationThreshold ?? this.notificationThreshold,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    isDarkMode: isDarkMode ?? this.isDarkMode,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      halfLifeDays: data.halfLifeDays.present
          ? data.halfLifeDays.value
          : this.halfLifeDays,
      notificationThreshold: data.notificationThreshold.present
          ? data.notificationThreshold.value
          : this.notificationThreshold,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      isDarkMode: data.isDarkMode.present
          ? data.isDarkMode.value
          : this.isDarkMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('halfLifeDays: $halfLifeDays, ')
          ..write('notificationThreshold: $notificationThreshold, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('isDarkMode: $isDarkMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    halfLifeDays,
    notificationThreshold,
    notificationsEnabled,
    isDarkMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.halfLifeDays == this.halfLifeDays &&
          other.notificationThreshold == this.notificationThreshold &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.isDarkMode == this.isDarkMode);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<double> halfLifeDays;
  final Value<double> notificationThreshold;
  final Value<bool> notificationsEnabled;
  final Value<bool> isDarkMode;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.halfLifeDays = const Value.absent(),
    this.notificationThreshold = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.isDarkMode = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.halfLifeDays = const Value.absent(),
    this.notificationThreshold = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.isDarkMode = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<double>? halfLifeDays,
    Expression<double>? notificationThreshold,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? isDarkMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halfLifeDays != null) 'half_life_days': halfLifeDays,
      if (notificationThreshold != null)
        'notification_threshold': notificationThreshold,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<double>? halfLifeDays,
    Value<double>? notificationThreshold,
    Value<bool>? notificationsEnabled,
    Value<bool>? isDarkMode,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      halfLifeDays: halfLifeDays ?? this.halfLifeDays,
      notificationThreshold:
          notificationThreshold ?? this.notificationThreshold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (halfLifeDays.present) {
      map['half_life_days'] = Variable<double>(halfLifeDays.value);
    }
    if (notificationThreshold.present) {
      map['notification_threshold'] = Variable<double>(
        notificationThreshold.value,
      );
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (isDarkMode.present) {
      map['is_dark_mode'] = Variable<bool>(isDarkMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('halfLifeDays: $halfLifeDays, ')
          ..write('notificationThreshold: $notificationThreshold, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('isDarkMode: $isDarkMode')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LinksTable links = $LinksTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [links, appSettings];
}

typedef $$LinksTableCreateCompanionBuilder =
    LinksCompanion Function({
      required String id,
      required String url,
      Value<String?> title,
      required String domain,
      Value<String?> faviconUrl,
      required DateTime createdAt,
      Value<DateTime?> snoozedUntil,
      required LinkStatus status,
      Value<String> tags,
      Value<int> snoozedSeconds,
      Value<int> rowid,
    });
typedef $$LinksTableUpdateCompanionBuilder =
    LinksCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String?> title,
      Value<String> domain,
      Value<String?> faviconUrl,
      Value<DateTime> createdAt,
      Value<DateTime?> snoozedUntil,
      Value<LinkStatus> status,
      Value<String> tags,
      Value<int> snoozedSeconds,
      Value<int> rowid,
    });

class $$LinksTableFilterComposer extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LinkStatus, LinkStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozedSeconds => $composableBuilder(
    column: $table.snoozedSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinksTableOrderingComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozedSeconds => $composableBuilder(
    column: $table.snoozedSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LinkStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get snoozedSeconds => $composableBuilder(
    column: $table.snoozedSeconds,
    builder: (column) => column,
  );
}

class $$LinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinksTable,
          Link,
          $$LinksTableFilterComposer,
          $$LinksTableOrderingComposer,
          $$LinksTableAnnotationComposer,
          $$LinksTableCreateCompanionBuilder,
          $$LinksTableUpdateCompanionBuilder,
          (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
          Link,
          PrefetchHooks Function()
        > {
  $$LinksTableTableManager(_$AppDatabase db, $LinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String?> faviconUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<LinkStatus> status = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> snoozedSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinksCompanion(
                id: id,
                url: url,
                title: title,
                domain: domain,
                faviconUrl: faviconUrl,
                createdAt: createdAt,
                snoozedUntil: snoozedUntil,
                status: status,
                tags: tags,
                snoozedSeconds: snoozedSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                Value<String?> title = const Value.absent(),
                required String domain,
                Value<String?> faviconUrl = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> snoozedUntil = const Value.absent(),
                required LinkStatus status,
                Value<String> tags = const Value.absent(),
                Value<int> snoozedSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinksCompanion.insert(
                id: id,
                url: url,
                title: title,
                domain: domain,
                faviconUrl: faviconUrl,
                createdAt: createdAt,
                snoozedUntil: snoozedUntil,
                status: status,
                tags: tags,
                snoozedSeconds: snoozedSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinksTable,
      Link,
      $$LinksTableFilterComposer,
      $$LinksTableOrderingComposer,
      $$LinksTableAnnotationComposer,
      $$LinksTableCreateCompanionBuilder,
      $$LinksTableUpdateCompanionBuilder,
      (Link, BaseReferences<_$AppDatabase, $LinksTable, Link>),
      Link,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<double> halfLifeDays,
      Value<double> notificationThreshold,
      Value<bool> notificationsEnabled,
      Value<bool> isDarkMode,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<double> halfLifeDays,
      Value<double> notificationThreshold,
      Value<bool> notificationsEnabled,
      Value<bool> isDarkMode,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<double> get halfLifeDays => $composableBuilder(
    column: $table.halfLifeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get notificationThreshold => $composableBuilder(
    column: $table.notificationThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDarkMode => $composableBuilder(
    column: $table.isDarkMode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<double> get halfLifeDays => $composableBuilder(
    column: $table.halfLifeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get notificationThreshold => $composableBuilder(
    column: $table.notificationThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDarkMode => $composableBuilder(
    column: $table.isDarkMode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get halfLifeDays => $composableBuilder(
    column: $table.halfLifeDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get notificationThreshold => $composableBuilder(
    column: $table.notificationThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDarkMode => $composableBuilder(
    column: $table.isDarkMode,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> halfLifeDays = const Value.absent(),
                Value<double> notificationThreshold = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> isDarkMode = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                halfLifeDays: halfLifeDays,
                notificationThreshold: notificationThreshold,
                notificationsEnabled: notificationsEnabled,
                isDarkMode: isDarkMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> halfLifeDays = const Value.absent(),
                Value<double> notificationThreshold = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> isDarkMode = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                halfLifeDays: halfLifeDays,
                notificationThreshold: notificationThreshold,
                notificationsEnabled: notificationsEnabled,
                isDarkMode: isDarkMode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LinksTableTableManager get links =>
      $$LinksTableTableManager(_db, _db.links);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
