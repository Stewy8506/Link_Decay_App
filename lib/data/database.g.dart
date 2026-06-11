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
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ogImageUrlMeta = const VerificationMeta(
    'ogImageUrl',
  );
  @override
  late final GeneratedColumn<String> ogImageUrl = GeneratedColumn<String>(
    'og_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedReadMinutesMeta =
      const VerificationMeta('estimatedReadMinutes');
  @override
  late final GeneratedColumn<int> estimatedReadMinutes = GeneratedColumn<int>(
    'estimated_read_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _customHalfLifeDaysMeta =
      const VerificationMeta('customHalfLifeDays');
  @override
  late final GeneratedColumn<double> customHalfLifeDays =
      GeneratedColumn<double>(
        'custom_half_life_days',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isDeadMeta = const VerificationMeta('isDead');
  @override
  late final GeneratedColumn<bool> isDead = GeneratedColumn<bool>(
    'is_dead',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dead" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    collectionId,
    notes,
    ogImageUrl,
    estimatedReadMinutes,
    readAt,
    archivedAt,
    customHalfLifeDays,
    isDead,
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
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('og_image_url')) {
      context.handle(
        _ogImageUrlMeta,
        ogImageUrl.isAcceptableOrUnknown(
          data['og_image_url']!,
          _ogImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('estimated_read_minutes')) {
      context.handle(
        _estimatedReadMinutesMeta,
        estimatedReadMinutes.isAcceptableOrUnknown(
          data['estimated_read_minutes']!,
          _estimatedReadMinutesMeta,
        ),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('custom_half_life_days')) {
      context.handle(
        _customHalfLifeDaysMeta,
        customHalfLifeDays.isAcceptableOrUnknown(
          data['custom_half_life_days']!,
          _customHalfLifeDaysMeta,
        ),
      );
    }
    if (data.containsKey('is_dead')) {
      context.handle(
        _isDeadMeta,
        isDead.isAcceptableOrUnknown(data['is_dead']!, _isDeadMeta),
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
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      ogImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}og_image_url'],
      ),
      estimatedReadMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_read_minutes'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      customHalfLifeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}custom_half_life_days'],
      ),
      isDead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dead'],
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
  final String? collectionId;
  final String? notes;
  final String? ogImageUrl;
  final int? estimatedReadMinutes;
  final DateTime? readAt;
  final DateTime? archivedAt;
  final double? customHalfLifeDays;
  final bool isDead;
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
    this.collectionId,
    this.notes,
    this.ogImageUrl,
    this.estimatedReadMinutes,
    this.readAt,
    this.archivedAt,
    this.customHalfLifeDays,
    required this.isDead,
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
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || ogImageUrl != null) {
      map['og_image_url'] = Variable<String>(ogImageUrl);
    }
    if (!nullToAbsent || estimatedReadMinutes != null) {
      map['estimated_read_minutes'] = Variable<int>(estimatedReadMinutes);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || customHalfLifeDays != null) {
      map['custom_half_life_days'] = Variable<double>(customHalfLifeDays);
    }
    map['is_dead'] = Variable<bool>(isDead);
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
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      ogImageUrl: ogImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ogImageUrl),
      estimatedReadMinutes: estimatedReadMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedReadMinutes),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      customHalfLifeDays: customHalfLifeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(customHalfLifeDays),
      isDead: Value(isDead),
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
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      notes: serializer.fromJson<String?>(json['notes']),
      ogImageUrl: serializer.fromJson<String?>(json['ogImageUrl']),
      estimatedReadMinutes: serializer.fromJson<int?>(
        json['estimatedReadMinutes'],
      ),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      customHalfLifeDays: serializer.fromJson<double?>(
        json['customHalfLifeDays'],
      ),
      isDead: serializer.fromJson<bool>(json['isDead']),
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
      'collectionId': serializer.toJson<String?>(collectionId),
      'notes': serializer.toJson<String?>(notes),
      'ogImageUrl': serializer.toJson<String?>(ogImageUrl),
      'estimatedReadMinutes': serializer.toJson<int?>(estimatedReadMinutes),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'customHalfLifeDays': serializer.toJson<double?>(customHalfLifeDays),
      'isDead': serializer.toJson<bool>(isDead),
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
    Value<String?> collectionId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> ogImageUrl = const Value.absent(),
    Value<int?> estimatedReadMinutes = const Value.absent(),
    Value<DateTime?> readAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<double?> customHalfLifeDays = const Value.absent(),
    bool? isDead,
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
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    notes: notes.present ? notes.value : this.notes,
    ogImageUrl: ogImageUrl.present ? ogImageUrl.value : this.ogImageUrl,
    estimatedReadMinutes: estimatedReadMinutes.present
        ? estimatedReadMinutes.value
        : this.estimatedReadMinutes,
    readAt: readAt.present ? readAt.value : this.readAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    customHalfLifeDays: customHalfLifeDays.present
        ? customHalfLifeDays.value
        : this.customHalfLifeDays,
    isDead: isDead ?? this.isDead,
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
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      notes: data.notes.present ? data.notes.value : this.notes,
      ogImageUrl: data.ogImageUrl.present
          ? data.ogImageUrl.value
          : this.ogImageUrl,
      estimatedReadMinutes: data.estimatedReadMinutes.present
          ? data.estimatedReadMinutes.value
          : this.estimatedReadMinutes,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      customHalfLifeDays: data.customHalfLifeDays.present
          ? data.customHalfLifeDays.value
          : this.customHalfLifeDays,
      isDead: data.isDead.present ? data.isDead.value : this.isDead,
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
          ..write('snoozedSeconds: $snoozedSeconds, ')
          ..write('collectionId: $collectionId, ')
          ..write('notes: $notes, ')
          ..write('ogImageUrl: $ogImageUrl, ')
          ..write('estimatedReadMinutes: $estimatedReadMinutes, ')
          ..write('readAt: $readAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('customHalfLifeDays: $customHalfLifeDays, ')
          ..write('isDead: $isDead')
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
    collectionId,
    notes,
    ogImageUrl,
    estimatedReadMinutes,
    readAt,
    archivedAt,
    customHalfLifeDays,
    isDead,
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
          other.snoozedSeconds == this.snoozedSeconds &&
          other.collectionId == this.collectionId &&
          other.notes == this.notes &&
          other.ogImageUrl == this.ogImageUrl &&
          other.estimatedReadMinutes == this.estimatedReadMinutes &&
          other.readAt == this.readAt &&
          other.archivedAt == this.archivedAt &&
          other.customHalfLifeDays == this.customHalfLifeDays &&
          other.isDead == this.isDead);
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
  final Value<String?> collectionId;
  final Value<String?> notes;
  final Value<String?> ogImageUrl;
  final Value<int?> estimatedReadMinutes;
  final Value<DateTime?> readAt;
  final Value<DateTime?> archivedAt;
  final Value<double?> customHalfLifeDays;
  final Value<bool> isDead;
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
    this.collectionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.ogImageUrl = const Value.absent(),
    this.estimatedReadMinutes = const Value.absent(),
    this.readAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.customHalfLifeDays = const Value.absent(),
    this.isDead = const Value.absent(),
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
    this.collectionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.ogImageUrl = const Value.absent(),
    this.estimatedReadMinutes = const Value.absent(),
    this.readAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.customHalfLifeDays = const Value.absent(),
    this.isDead = const Value.absent(),
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
    Expression<String>? collectionId,
    Expression<String>? notes,
    Expression<String>? ogImageUrl,
    Expression<int>? estimatedReadMinutes,
    Expression<DateTime>? readAt,
    Expression<DateTime>? archivedAt,
    Expression<double>? customHalfLifeDays,
    Expression<bool>? isDead,
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
      if (collectionId != null) 'collection_id': collectionId,
      if (notes != null) 'notes': notes,
      if (ogImageUrl != null) 'og_image_url': ogImageUrl,
      if (estimatedReadMinutes != null)
        'estimated_read_minutes': estimatedReadMinutes,
      if (readAt != null) 'read_at': readAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (customHalfLifeDays != null)
        'custom_half_life_days': customHalfLifeDays,
      if (isDead != null) 'is_dead': isDead,
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
    Value<String?>? collectionId,
    Value<String?>? notes,
    Value<String?>? ogImageUrl,
    Value<int?>? estimatedReadMinutes,
    Value<DateTime?>? readAt,
    Value<DateTime?>? archivedAt,
    Value<double?>? customHalfLifeDays,
    Value<bool>? isDead,
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
      collectionId: collectionId ?? this.collectionId,
      notes: notes ?? this.notes,
      ogImageUrl: ogImageUrl ?? this.ogImageUrl,
      estimatedReadMinutes: estimatedReadMinutes ?? this.estimatedReadMinutes,
      readAt: readAt ?? this.readAt,
      archivedAt: archivedAt ?? this.archivedAt,
      customHalfLifeDays: customHalfLifeDays ?? this.customHalfLifeDays,
      isDead: isDead ?? this.isDead,
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
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (ogImageUrl.present) {
      map['og_image_url'] = Variable<String>(ogImageUrl.value);
    }
    if (estimatedReadMinutes.present) {
      map['estimated_read_minutes'] = Variable<int>(estimatedReadMinutes.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (customHalfLifeDays.present) {
      map['custom_half_life_days'] = Variable<double>(customHalfLifeDays.value);
    }
    if (isDead.present) {
      map['is_dead'] = Variable<bool>(isDead.value);
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
          ..write('collectionId: $collectionId, ')
          ..write('notes: $notes, ')
          ..write('ogImageUrl: $ogImageUrl, ')
          ..write('estimatedReadMinutes: $estimatedReadMinutes, ')
          ..write('readAt: $readAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('customHalfLifeDays: $customHalfLifeDays, ')
          ..write('isDead: $isDead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, createdAt, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;
  final String? emoji;
  final DateTime createdAt;
  final int sortOrder;
  const Collection({
    required this.id,
    required this.name,
    this.emoji,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    Value<String?> emoji = const Value.absent(),
    DateTime? createdAt,
    int? sortOrder,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji.present ? emoji.value : this.emoji,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, createdAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.emoji = const Value.absent(),
    required DateTime createdAt,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? emoji,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFiltersTable extends CustomFilters
    with TableInfo<$CustomFiltersTable, CustomFilter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFiltersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('list'),
  );
  static const VerificationMeta _minFreshnessMeta = const VerificationMeta(
    'minFreshness',
  );
  @override
  late final GeneratedColumn<double> minFreshness = GeneratedColumn<double>(
    'min_freshness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxFreshnessMeta = const VerificationMeta(
    'maxFreshness',
  );
  @override
  late final GeneratedColumn<double> maxFreshness = GeneratedColumn<double>(
    'max_freshness',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionsMeta = const VerificationMeta(
    'collections',
  );
  @override
  late final GeneratedColumn<String> collections = GeneratedColumn<String>(
    'collections',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _domainsMeta = const VerificationMeta(
    'domains',
  );
  @override
  late final GeneratedColumn<String> domains = GeneratedColumn<String>(
    'domains',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minReadTimeMeta = const VerificationMeta(
    'minReadTime',
  );
  @override
  late final GeneratedColumn<int> minReadTime = GeneratedColumn<int>(
    'min_read_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxReadTimeMeta = const VerificationMeta(
    'maxReadTime',
  );
  @override
  late final GeneratedColumn<int> maxReadTime = GeneratedColumn<int>(
    'max_read_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozeFilterMeta = const VerificationMeta(
    'snoozeFilter',
  );
  @override
  late final GeneratedColumn<String> snoozeFilter = GeneratedColumn<String>(
    'snooze_filter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortFieldMeta = const VerificationMeta(
    'sortField',
  );
  @override
  late final GeneratedColumn<String> sortField = GeneratedColumn<String>(
    'sort_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('freshness_asc'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    minFreshness,
    maxFreshness,
    tags,
    collections,
    domains,
    minReadTime,
    maxReadTime,
    snoozeFilter,
    sortField,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_filters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFilter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('min_freshness')) {
      context.handle(
        _minFreshnessMeta,
        minFreshness.isAcceptableOrUnknown(
          data['min_freshness']!,
          _minFreshnessMeta,
        ),
      );
    }
    if (data.containsKey('max_freshness')) {
      context.handle(
        _maxFreshnessMeta,
        maxFreshness.isAcceptableOrUnknown(
          data['max_freshness']!,
          _maxFreshnessMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('collections')) {
      context.handle(
        _collectionsMeta,
        collections.isAcceptableOrUnknown(
          data['collections']!,
          _collectionsMeta,
        ),
      );
    }
    if (data.containsKey('domains')) {
      context.handle(
        _domainsMeta,
        domains.isAcceptableOrUnknown(data['domains']!, _domainsMeta),
      );
    }
    if (data.containsKey('min_read_time')) {
      context.handle(
        _minReadTimeMeta,
        minReadTime.isAcceptableOrUnknown(
          data['min_read_time']!,
          _minReadTimeMeta,
        ),
      );
    }
    if (data.containsKey('max_read_time')) {
      context.handle(
        _maxReadTimeMeta,
        maxReadTime.isAcceptableOrUnknown(
          data['max_read_time']!,
          _maxReadTimeMeta,
        ),
      );
    }
    if (data.containsKey('snooze_filter')) {
      context.handle(
        _snoozeFilterMeta,
        snoozeFilter.isAcceptableOrUnknown(
          data['snooze_filter']!,
          _snoozeFilterMeta,
        ),
      );
    }
    if (data.containsKey('sort_field')) {
      context.handle(
        _sortFieldMeta,
        sortField.isAcceptableOrUnknown(data['sort_field']!, _sortFieldMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomFilter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFilter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      minFreshness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_freshness'],
      ),
      maxFreshness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_freshness'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      collections: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collections'],
      ),
      domains: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domains'],
      ),
      minReadTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_read_time'],
      ),
      maxReadTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_read_time'],
      ),
      snoozeFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snooze_filter'],
      ),
      sortField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_field'],
      )!,
    );
  }

  @override
  $CustomFiltersTable createAlias(String alias) {
    return $CustomFiltersTable(attachedDatabase, alias);
  }
}

class CustomFilter extends DataClass implements Insertable<CustomFilter> {
  final String id;
  final String name;
  final String icon;
  final double? minFreshness;
  final double? maxFreshness;
  final String? tags;
  final String? collections;
  final String? domains;
  final int? minReadTime;
  final int? maxReadTime;
  final String? snoozeFilter;
  final String sortField;
  const CustomFilter({
    required this.id,
    required this.name,
    required this.icon,
    this.minFreshness,
    this.maxFreshness,
    this.tags,
    this.collections,
    this.domains,
    this.minReadTime,
    this.maxReadTime,
    this.snoozeFilter,
    required this.sortField,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || minFreshness != null) {
      map['min_freshness'] = Variable<double>(minFreshness);
    }
    if (!nullToAbsent || maxFreshness != null) {
      map['max_freshness'] = Variable<double>(maxFreshness);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || collections != null) {
      map['collections'] = Variable<String>(collections);
    }
    if (!nullToAbsent || domains != null) {
      map['domains'] = Variable<String>(domains);
    }
    if (!nullToAbsent || minReadTime != null) {
      map['min_read_time'] = Variable<int>(minReadTime);
    }
    if (!nullToAbsent || maxReadTime != null) {
      map['max_read_time'] = Variable<int>(maxReadTime);
    }
    if (!nullToAbsent || snoozeFilter != null) {
      map['snooze_filter'] = Variable<String>(snoozeFilter);
    }
    map['sort_field'] = Variable<String>(sortField);
    return map;
  }

  CustomFiltersCompanion toCompanion(bool nullToAbsent) {
    return CustomFiltersCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      minFreshness: minFreshness == null && nullToAbsent
          ? const Value.absent()
          : Value(minFreshness),
      maxFreshness: maxFreshness == null && nullToAbsent
          ? const Value.absent()
          : Value(maxFreshness),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      collections: collections == null && nullToAbsent
          ? const Value.absent()
          : Value(collections),
      domains: domains == null && nullToAbsent
          ? const Value.absent()
          : Value(domains),
      minReadTime: minReadTime == null && nullToAbsent
          ? const Value.absent()
          : Value(minReadTime),
      maxReadTime: maxReadTime == null && nullToAbsent
          ? const Value.absent()
          : Value(maxReadTime),
      snoozeFilter: snoozeFilter == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozeFilter),
      sortField: Value(sortField),
    );
  }

  factory CustomFilter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFilter(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      minFreshness: serializer.fromJson<double?>(json['minFreshness']),
      maxFreshness: serializer.fromJson<double?>(json['maxFreshness']),
      tags: serializer.fromJson<String?>(json['tags']),
      collections: serializer.fromJson<String?>(json['collections']),
      domains: serializer.fromJson<String?>(json['domains']),
      minReadTime: serializer.fromJson<int?>(json['minReadTime']),
      maxReadTime: serializer.fromJson<int?>(json['maxReadTime']),
      snoozeFilter: serializer.fromJson<String?>(json['snoozeFilter']),
      sortField: serializer.fromJson<String>(json['sortField']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'minFreshness': serializer.toJson<double?>(minFreshness),
      'maxFreshness': serializer.toJson<double?>(maxFreshness),
      'tags': serializer.toJson<String?>(tags),
      'collections': serializer.toJson<String?>(collections),
      'domains': serializer.toJson<String?>(domains),
      'minReadTime': serializer.toJson<int?>(minReadTime),
      'maxReadTime': serializer.toJson<int?>(maxReadTime),
      'snoozeFilter': serializer.toJson<String?>(snoozeFilter),
      'sortField': serializer.toJson<String>(sortField),
    };
  }

  CustomFilter copyWith({
    String? id,
    String? name,
    String? icon,
    Value<double?> minFreshness = const Value.absent(),
    Value<double?> maxFreshness = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> collections = const Value.absent(),
    Value<String?> domains = const Value.absent(),
    Value<int?> minReadTime = const Value.absent(),
    Value<int?> maxReadTime = const Value.absent(),
    Value<String?> snoozeFilter = const Value.absent(),
    String? sortField,
  }) => CustomFilter(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    minFreshness: minFreshness.present ? minFreshness.value : this.minFreshness,
    maxFreshness: maxFreshness.present ? maxFreshness.value : this.maxFreshness,
    tags: tags.present ? tags.value : this.tags,
    collections: collections.present ? collections.value : this.collections,
    domains: domains.present ? domains.value : this.domains,
    minReadTime: minReadTime.present ? minReadTime.value : this.minReadTime,
    maxReadTime: maxReadTime.present ? maxReadTime.value : this.maxReadTime,
    snoozeFilter: snoozeFilter.present ? snoozeFilter.value : this.snoozeFilter,
    sortField: sortField ?? this.sortField,
  );
  CustomFilter copyWithCompanion(CustomFiltersCompanion data) {
    return CustomFilter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      minFreshness: data.minFreshness.present
          ? data.minFreshness.value
          : this.minFreshness,
      maxFreshness: data.maxFreshness.present
          ? data.maxFreshness.value
          : this.maxFreshness,
      tags: data.tags.present ? data.tags.value : this.tags,
      collections: data.collections.present
          ? data.collections.value
          : this.collections,
      domains: data.domains.present ? data.domains.value : this.domains,
      minReadTime: data.minReadTime.present
          ? data.minReadTime.value
          : this.minReadTime,
      maxReadTime: data.maxReadTime.present
          ? data.maxReadTime.value
          : this.maxReadTime,
      snoozeFilter: data.snoozeFilter.present
          ? data.snoozeFilter.value
          : this.snoozeFilter,
      sortField: data.sortField.present ? data.sortField.value : this.sortField,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFilter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('minFreshness: $minFreshness, ')
          ..write('maxFreshness: $maxFreshness, ')
          ..write('tags: $tags, ')
          ..write('collections: $collections, ')
          ..write('domains: $domains, ')
          ..write('minReadTime: $minReadTime, ')
          ..write('maxReadTime: $maxReadTime, ')
          ..write('snoozeFilter: $snoozeFilter, ')
          ..write('sortField: $sortField')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    minFreshness,
    maxFreshness,
    tags,
    collections,
    domains,
    minReadTime,
    maxReadTime,
    snoozeFilter,
    sortField,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFilter &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.minFreshness == this.minFreshness &&
          other.maxFreshness == this.maxFreshness &&
          other.tags == this.tags &&
          other.collections == this.collections &&
          other.domains == this.domains &&
          other.minReadTime == this.minReadTime &&
          other.maxReadTime == this.maxReadTime &&
          other.snoozeFilter == this.snoozeFilter &&
          other.sortField == this.sortField);
}

class CustomFiltersCompanion extends UpdateCompanion<CustomFilter> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<double?> minFreshness;
  final Value<double?> maxFreshness;
  final Value<String?> tags;
  final Value<String?> collections;
  final Value<String?> domains;
  final Value<int?> minReadTime;
  final Value<int?> maxReadTime;
  final Value<String?> snoozeFilter;
  final Value<String> sortField;
  final Value<int> rowid;
  const CustomFiltersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.minFreshness = const Value.absent(),
    this.maxFreshness = const Value.absent(),
    this.tags = const Value.absent(),
    this.collections = const Value.absent(),
    this.domains = const Value.absent(),
    this.minReadTime = const Value.absent(),
    this.maxReadTime = const Value.absent(),
    this.snoozeFilter = const Value.absent(),
    this.sortField = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFiltersCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.minFreshness = const Value.absent(),
    this.maxFreshness = const Value.absent(),
    this.tags = const Value.absent(),
    this.collections = const Value.absent(),
    this.domains = const Value.absent(),
    this.minReadTime = const Value.absent(),
    this.maxReadTime = const Value.absent(),
    this.snoozeFilter = const Value.absent(),
    this.sortField = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CustomFilter> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<double>? minFreshness,
    Expression<double>? maxFreshness,
    Expression<String>? tags,
    Expression<String>? collections,
    Expression<String>? domains,
    Expression<int>? minReadTime,
    Expression<int>? maxReadTime,
    Expression<String>? snoozeFilter,
    Expression<String>? sortField,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (minFreshness != null) 'min_freshness': minFreshness,
      if (maxFreshness != null) 'max_freshness': maxFreshness,
      if (tags != null) 'tags': tags,
      if (collections != null) 'collections': collections,
      if (domains != null) 'domains': domains,
      if (minReadTime != null) 'min_read_time': minReadTime,
      if (maxReadTime != null) 'max_read_time': maxReadTime,
      if (snoozeFilter != null) 'snooze_filter': snoozeFilter,
      if (sortField != null) 'sort_field': sortField,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFiltersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<double?>? minFreshness,
    Value<double?>? maxFreshness,
    Value<String?>? tags,
    Value<String?>? collections,
    Value<String?>? domains,
    Value<int?>? minReadTime,
    Value<int?>? maxReadTime,
    Value<String?>? snoozeFilter,
    Value<String>? sortField,
    Value<int>? rowid,
  }) {
    return CustomFiltersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      minFreshness: minFreshness ?? this.minFreshness,
      maxFreshness: maxFreshness ?? this.maxFreshness,
      tags: tags ?? this.tags,
      collections: collections ?? this.collections,
      domains: domains ?? this.domains,
      minReadTime: minReadTime ?? this.minReadTime,
      maxReadTime: maxReadTime ?? this.maxReadTime,
      snoozeFilter: snoozeFilter ?? this.snoozeFilter,
      sortField: sortField ?? this.sortField,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (minFreshness.present) {
      map['min_freshness'] = Variable<double>(minFreshness.value);
    }
    if (maxFreshness.present) {
      map['max_freshness'] = Variable<double>(maxFreshness.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (collections.present) {
      map['collections'] = Variable<String>(collections.value);
    }
    if (domains.present) {
      map['domains'] = Variable<String>(domains.value);
    }
    if (minReadTime.present) {
      map['min_read_time'] = Variable<int>(minReadTime.value);
    }
    if (maxReadTime.present) {
      map['max_read_time'] = Variable<int>(maxReadTime.value);
    }
    if (snoozeFilter.present) {
      map['snooze_filter'] = Variable<String>(snoozeFilter.value);
    }
    if (sortField.present) {
      map['sort_field'] = Variable<String>(sortField.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFiltersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('minFreshness: $minFreshness, ')
          ..write('maxFreshness: $maxFreshness, ')
          ..write('tags: $tags, ')
          ..write('collections: $collections, ')
          ..write('domains: $domains, ')
          ..write('minReadTime: $minReadTime, ')
          ..write('maxReadTime: $maxReadTime, ')
          ..write('snoozeFilter: $snoozeFilter, ')
          ..write('sortField: $sortField, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinkHighlightsTable extends LinkHighlights
    with TableInfo<$LinkHighlightsTable, LinkHighlight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinkHighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkIdMeta = const VerificationMeta('linkId');
  @override
  late final GeneratedColumn<String> linkId = GeneratedColumn<String>(
    'link_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
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
  List<GeneratedColumn> get $columns => [id, linkId, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'link_highlights';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinkHighlight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('link_id')) {
      context.handle(
        _linkIdMeta,
        linkId.isAcceptableOrUnknown(data['link_id']!, _linkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_linkIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
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
  LinkHighlight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkHighlight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      linkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LinkHighlightsTable createAlias(String alias) {
    return $LinkHighlightsTable(attachedDatabase, alias);
  }
}

class LinkHighlight extends DataClass implements Insertable<LinkHighlight> {
  final String id;
  final String linkId;
  final String content;
  final DateTime createdAt;
  const LinkHighlight({
    required this.id,
    required this.linkId,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['link_id'] = Variable<String>(linkId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LinkHighlightsCompanion toCompanion(bool nullToAbsent) {
    return LinkHighlightsCompanion(
      id: Value(id),
      linkId: Value(linkId),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory LinkHighlight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkHighlight(
      id: serializer.fromJson<String>(json['id']),
      linkId: serializer.fromJson<String>(json['linkId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'linkId': serializer.toJson<String>(linkId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LinkHighlight copyWith({
    String? id,
    String? linkId,
    String? content,
    DateTime? createdAt,
  }) => LinkHighlight(
    id: id ?? this.id,
    linkId: linkId ?? this.linkId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  LinkHighlight copyWithCompanion(LinkHighlightsCompanion data) {
    return LinkHighlight(
      id: data.id.present ? data.id.value : this.id,
      linkId: data.linkId.present ? data.linkId.value : this.linkId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkHighlight(')
          ..write('id: $id, ')
          ..write('linkId: $linkId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, linkId, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkHighlight &&
          other.id == this.id &&
          other.linkId == this.linkId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class LinkHighlightsCompanion extends UpdateCompanion<LinkHighlight> {
  final Value<String> id;
  final Value<String> linkId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LinkHighlightsCompanion({
    this.id = const Value.absent(),
    this.linkId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinkHighlightsCompanion.insert({
    required String id,
    required String linkId,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       linkId = Value(linkId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<LinkHighlight> custom({
    Expression<String>? id,
    Expression<String>? linkId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (linkId != null) 'link_id': linkId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinkHighlightsCompanion copyWith({
    Value<String>? id,
    Value<String>? linkId,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LinkHighlightsCompanion(
      id: id ?? this.id,
      linkId: linkId ?? this.linkId,
      content: content ?? this.content,
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
    if (linkId.present) {
      map['link_id'] = Variable<String>(linkId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
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
    return (StringBuffer('LinkHighlightsCompanion(')
          ..write('id: $id, ')
          ..write('linkId: $linkId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _themePaletteMeta = const VerificationMeta(
    'themePalette',
  );
  @override
  late final GeneratedColumn<String> themePalette = GeneratedColumn<String>(
    'theme_palette',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('warm_stone'),
  );
  static const VerificationMeta _swipeLeftActionMeta = const VerificationMeta(
    'swipeLeftAction',
  );
  @override
  late final GeneratedColumn<String> swipeLeftAction = GeneratedColumn<String>(
    'swipe_left_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('archive'),
  );
  static const VerificationMeta _swipeRightActionMeta = const VerificationMeta(
    'swipeRightAction',
  );
  @override
  late final GeneratedColumn<String> swipeRightAction = GeneratedColumn<String>(
    'swipe_right_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('read'),
  );
  static const VerificationMeta _domainHalfLifeOverridesMeta =
      const VerificationMeta('domainHalfLifeOverrides');
  @override
  late final GeneratedColumn<String> domainHalfLifeOverrides =
      GeneratedColumn<String>(
        'domain_half_life_overrides',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tagHalfLifeOverridesMeta =
      const VerificationMeta('tagHalfLifeOverrides');
  @override
  late final GeneratedColumn<String> tagHalfLifeOverrides =
      GeneratedColumn<String>(
        'tag_half_life_overrides',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dailyReadingGoalMeta = const VerificationMeta(
    'dailyReadingGoal',
  );
  @override
  late final GeneratedColumn<int> dailyReadingGoal = GeneratedColumn<int>(
    'daily_reading_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _snoozePresetsMeta = const VerificationMeta(
    'snoozePresets',
  );
  @override
  late final GeneratedColumn<String> snoozePresets = GeneratedColumn<String>(
    'snooze_presets',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[1, 3, 7]'),
  );
  static const VerificationMeta _fontFamilyMeta = const VerificationMeta(
    'fontFamily',
  );
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
    'font_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('inter'),
  );
  static const VerificationMeta _customAccentColorMeta = const VerificationMeta(
    'customAccentColor',
  );
  @override
  late final GeneratedColumn<String> customAccentColor =
      GeneratedColumn<String>(
        'custom_accent_color',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customBgColorMeta = const VerificationMeta(
    'customBgColor',
  );
  @override
  late final GeneratedColumn<String> customBgColor = GeneratedColumn<String>(
    'custom_bg_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decayCurveTypeMeta = const VerificationMeta(
    'decayCurveType',
  );
  @override
  late final GeneratedColumn<String> decayCurveType = GeneratedColumn<String>(
    'decay_curve_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('exponential'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    halfLifeDays,
    notificationThreshold,
    notificationsEnabled,
    isDarkMode,
    themePalette,
    swipeLeftAction,
    swipeRightAction,
    domainHalfLifeOverrides,
    tagHalfLifeOverrides,
    dailyReadingGoal,
    snoozePresets,
    fontFamily,
    customAccentColor,
    customBgColor,
    decayCurveType,
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
    if (data.containsKey('theme_palette')) {
      context.handle(
        _themePaletteMeta,
        themePalette.isAcceptableOrUnknown(
          data['theme_palette']!,
          _themePaletteMeta,
        ),
      );
    }
    if (data.containsKey('swipe_left_action')) {
      context.handle(
        _swipeLeftActionMeta,
        swipeLeftAction.isAcceptableOrUnknown(
          data['swipe_left_action']!,
          _swipeLeftActionMeta,
        ),
      );
    }
    if (data.containsKey('swipe_right_action')) {
      context.handle(
        _swipeRightActionMeta,
        swipeRightAction.isAcceptableOrUnknown(
          data['swipe_right_action']!,
          _swipeRightActionMeta,
        ),
      );
    }
    if (data.containsKey('domain_half_life_overrides')) {
      context.handle(
        _domainHalfLifeOverridesMeta,
        domainHalfLifeOverrides.isAcceptableOrUnknown(
          data['domain_half_life_overrides']!,
          _domainHalfLifeOverridesMeta,
        ),
      );
    }
    if (data.containsKey('tag_half_life_overrides')) {
      context.handle(
        _tagHalfLifeOverridesMeta,
        tagHalfLifeOverrides.isAcceptableOrUnknown(
          data['tag_half_life_overrides']!,
          _tagHalfLifeOverridesMeta,
        ),
      );
    }
    if (data.containsKey('daily_reading_goal')) {
      context.handle(
        _dailyReadingGoalMeta,
        dailyReadingGoal.isAcceptableOrUnknown(
          data['daily_reading_goal']!,
          _dailyReadingGoalMeta,
        ),
      );
    }
    if (data.containsKey('snooze_presets')) {
      context.handle(
        _snoozePresetsMeta,
        snoozePresets.isAcceptableOrUnknown(
          data['snooze_presets']!,
          _snoozePresetsMeta,
        ),
      );
    }
    if (data.containsKey('font_family')) {
      context.handle(
        _fontFamilyMeta,
        fontFamily.isAcceptableOrUnknown(data['font_family']!, _fontFamilyMeta),
      );
    }
    if (data.containsKey('custom_accent_color')) {
      context.handle(
        _customAccentColorMeta,
        customAccentColor.isAcceptableOrUnknown(
          data['custom_accent_color']!,
          _customAccentColorMeta,
        ),
      );
    }
    if (data.containsKey('custom_bg_color')) {
      context.handle(
        _customBgColorMeta,
        customBgColor.isAcceptableOrUnknown(
          data['custom_bg_color']!,
          _customBgColorMeta,
        ),
      );
    }
    if (data.containsKey('decay_curve_type')) {
      context.handle(
        _decayCurveTypeMeta,
        decayCurveType.isAcceptableOrUnknown(
          data['decay_curve_type']!,
          _decayCurveTypeMeta,
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
      themePalette: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_palette'],
      )!,
      swipeLeftAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}swipe_left_action'],
      )!,
      swipeRightAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}swipe_right_action'],
      )!,
      domainHalfLifeOverrides: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain_half_life_overrides'],
      ),
      tagHalfLifeOverrides: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_half_life_overrides'],
      ),
      dailyReadingGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_reading_goal'],
      )!,
      snoozePresets: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snooze_presets'],
      )!,
      fontFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}font_family'],
      )!,
      customAccentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_accent_color'],
      ),
      customBgColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_bg_color'],
      ),
      decayCurveType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decay_curve_type'],
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
  final String themePalette;
  final String swipeLeftAction;
  final String swipeRightAction;
  final String? domainHalfLifeOverrides;
  final String? tagHalfLifeOverrides;
  final int dailyReadingGoal;
  final String snoozePresets;
  final String fontFamily;
  final String? customAccentColor;
  final String? customBgColor;
  final String decayCurveType;
  const AppSetting({
    required this.id,
    required this.halfLifeDays,
    required this.notificationThreshold,
    required this.notificationsEnabled,
    required this.isDarkMode,
    required this.themePalette,
    required this.swipeLeftAction,
    required this.swipeRightAction,
    this.domainHalfLifeOverrides,
    this.tagHalfLifeOverrides,
    required this.dailyReadingGoal,
    required this.snoozePresets,
    required this.fontFamily,
    this.customAccentColor,
    this.customBgColor,
    required this.decayCurveType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['half_life_days'] = Variable<double>(halfLifeDays);
    map['notification_threshold'] = Variable<double>(notificationThreshold);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    map['theme_palette'] = Variable<String>(themePalette);
    map['swipe_left_action'] = Variable<String>(swipeLeftAction);
    map['swipe_right_action'] = Variable<String>(swipeRightAction);
    if (!nullToAbsent || domainHalfLifeOverrides != null) {
      map['domain_half_life_overrides'] = Variable<String>(
        domainHalfLifeOverrides,
      );
    }
    if (!nullToAbsent || tagHalfLifeOverrides != null) {
      map['tag_half_life_overrides'] = Variable<String>(tagHalfLifeOverrides);
    }
    map['daily_reading_goal'] = Variable<int>(dailyReadingGoal);
    map['snooze_presets'] = Variable<String>(snoozePresets);
    map['font_family'] = Variable<String>(fontFamily);
    if (!nullToAbsent || customAccentColor != null) {
      map['custom_accent_color'] = Variable<String>(customAccentColor);
    }
    if (!nullToAbsent || customBgColor != null) {
      map['custom_bg_color'] = Variable<String>(customBgColor);
    }
    map['decay_curve_type'] = Variable<String>(decayCurveType);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      halfLifeDays: Value(halfLifeDays),
      notificationThreshold: Value(notificationThreshold),
      notificationsEnabled: Value(notificationsEnabled),
      isDarkMode: Value(isDarkMode),
      themePalette: Value(themePalette),
      swipeLeftAction: Value(swipeLeftAction),
      swipeRightAction: Value(swipeRightAction),
      domainHalfLifeOverrides: domainHalfLifeOverrides == null && nullToAbsent
          ? const Value.absent()
          : Value(domainHalfLifeOverrides),
      tagHalfLifeOverrides: tagHalfLifeOverrides == null && nullToAbsent
          ? const Value.absent()
          : Value(tagHalfLifeOverrides),
      dailyReadingGoal: Value(dailyReadingGoal),
      snoozePresets: Value(snoozePresets),
      fontFamily: Value(fontFamily),
      customAccentColor: customAccentColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customAccentColor),
      customBgColor: customBgColor == null && nullToAbsent
          ? const Value.absent()
          : Value(customBgColor),
      decayCurveType: Value(decayCurveType),
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
      themePalette: serializer.fromJson<String>(json['themePalette']),
      swipeLeftAction: serializer.fromJson<String>(json['swipeLeftAction']),
      swipeRightAction: serializer.fromJson<String>(json['swipeRightAction']),
      domainHalfLifeOverrides: serializer.fromJson<String?>(
        json['domainHalfLifeOverrides'],
      ),
      tagHalfLifeOverrides: serializer.fromJson<String?>(
        json['tagHalfLifeOverrides'],
      ),
      dailyReadingGoal: serializer.fromJson<int>(json['dailyReadingGoal']),
      snoozePresets: serializer.fromJson<String>(json['snoozePresets']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      customAccentColor: serializer.fromJson<String?>(
        json['customAccentColor'],
      ),
      customBgColor: serializer.fromJson<String?>(json['customBgColor']),
      decayCurveType: serializer.fromJson<String>(json['decayCurveType']),
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
      'themePalette': serializer.toJson<String>(themePalette),
      'swipeLeftAction': serializer.toJson<String>(swipeLeftAction),
      'swipeRightAction': serializer.toJson<String>(swipeRightAction),
      'domainHalfLifeOverrides': serializer.toJson<String?>(
        domainHalfLifeOverrides,
      ),
      'tagHalfLifeOverrides': serializer.toJson<String?>(tagHalfLifeOverrides),
      'dailyReadingGoal': serializer.toJson<int>(dailyReadingGoal),
      'snoozePresets': serializer.toJson<String>(snoozePresets),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'customAccentColor': serializer.toJson<String?>(customAccentColor),
      'customBgColor': serializer.toJson<String?>(customBgColor),
      'decayCurveType': serializer.toJson<String>(decayCurveType),
    };
  }

  AppSetting copyWith({
    int? id,
    double? halfLifeDays,
    double? notificationThreshold,
    bool? notificationsEnabled,
    bool? isDarkMode,
    String? themePalette,
    String? swipeLeftAction,
    String? swipeRightAction,
    Value<String?> domainHalfLifeOverrides = const Value.absent(),
    Value<String?> tagHalfLifeOverrides = const Value.absent(),
    int? dailyReadingGoal,
    String? snoozePresets,
    String? fontFamily,
    Value<String?> customAccentColor = const Value.absent(),
    Value<String?> customBgColor = const Value.absent(),
    String? decayCurveType,
  }) => AppSetting(
    id: id ?? this.id,
    halfLifeDays: halfLifeDays ?? this.halfLifeDays,
    notificationThreshold: notificationThreshold ?? this.notificationThreshold,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    isDarkMode: isDarkMode ?? this.isDarkMode,
    themePalette: themePalette ?? this.themePalette,
    swipeLeftAction: swipeLeftAction ?? this.swipeLeftAction,
    swipeRightAction: swipeRightAction ?? this.swipeRightAction,
    domainHalfLifeOverrides: domainHalfLifeOverrides.present
        ? domainHalfLifeOverrides.value
        : this.domainHalfLifeOverrides,
    tagHalfLifeOverrides: tagHalfLifeOverrides.present
        ? tagHalfLifeOverrides.value
        : this.tagHalfLifeOverrides,
    dailyReadingGoal: dailyReadingGoal ?? this.dailyReadingGoal,
    snoozePresets: snoozePresets ?? this.snoozePresets,
    fontFamily: fontFamily ?? this.fontFamily,
    customAccentColor: customAccentColor.present
        ? customAccentColor.value
        : this.customAccentColor,
    customBgColor: customBgColor.present
        ? customBgColor.value
        : this.customBgColor,
    decayCurveType: decayCurveType ?? this.decayCurveType,
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
      themePalette: data.themePalette.present
          ? data.themePalette.value
          : this.themePalette,
      swipeLeftAction: data.swipeLeftAction.present
          ? data.swipeLeftAction.value
          : this.swipeLeftAction,
      swipeRightAction: data.swipeRightAction.present
          ? data.swipeRightAction.value
          : this.swipeRightAction,
      domainHalfLifeOverrides: data.domainHalfLifeOverrides.present
          ? data.domainHalfLifeOverrides.value
          : this.domainHalfLifeOverrides,
      tagHalfLifeOverrides: data.tagHalfLifeOverrides.present
          ? data.tagHalfLifeOverrides.value
          : this.tagHalfLifeOverrides,
      dailyReadingGoal: data.dailyReadingGoal.present
          ? data.dailyReadingGoal.value
          : this.dailyReadingGoal,
      snoozePresets: data.snoozePresets.present
          ? data.snoozePresets.value
          : this.snoozePresets,
      fontFamily: data.fontFamily.present
          ? data.fontFamily.value
          : this.fontFamily,
      customAccentColor: data.customAccentColor.present
          ? data.customAccentColor.value
          : this.customAccentColor,
      customBgColor: data.customBgColor.present
          ? data.customBgColor.value
          : this.customBgColor,
      decayCurveType: data.decayCurveType.present
          ? data.decayCurveType.value
          : this.decayCurveType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('halfLifeDays: $halfLifeDays, ')
          ..write('notificationThreshold: $notificationThreshold, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('themePalette: $themePalette, ')
          ..write('swipeLeftAction: $swipeLeftAction, ')
          ..write('swipeRightAction: $swipeRightAction, ')
          ..write('domainHalfLifeOverrides: $domainHalfLifeOverrides, ')
          ..write('tagHalfLifeOverrides: $tagHalfLifeOverrides, ')
          ..write('dailyReadingGoal: $dailyReadingGoal, ')
          ..write('snoozePresets: $snoozePresets, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('customAccentColor: $customAccentColor, ')
          ..write('customBgColor: $customBgColor, ')
          ..write('decayCurveType: $decayCurveType')
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
    themePalette,
    swipeLeftAction,
    swipeRightAction,
    domainHalfLifeOverrides,
    tagHalfLifeOverrides,
    dailyReadingGoal,
    snoozePresets,
    fontFamily,
    customAccentColor,
    customBgColor,
    decayCurveType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.halfLifeDays == this.halfLifeDays &&
          other.notificationThreshold == this.notificationThreshold &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.isDarkMode == this.isDarkMode &&
          other.themePalette == this.themePalette &&
          other.swipeLeftAction == this.swipeLeftAction &&
          other.swipeRightAction == this.swipeRightAction &&
          other.domainHalfLifeOverrides == this.domainHalfLifeOverrides &&
          other.tagHalfLifeOverrides == this.tagHalfLifeOverrides &&
          other.dailyReadingGoal == this.dailyReadingGoal &&
          other.snoozePresets == this.snoozePresets &&
          other.fontFamily == this.fontFamily &&
          other.customAccentColor == this.customAccentColor &&
          other.customBgColor == this.customBgColor &&
          other.decayCurveType == this.decayCurveType);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<double> halfLifeDays;
  final Value<double> notificationThreshold;
  final Value<bool> notificationsEnabled;
  final Value<bool> isDarkMode;
  final Value<String> themePalette;
  final Value<String> swipeLeftAction;
  final Value<String> swipeRightAction;
  final Value<String?> domainHalfLifeOverrides;
  final Value<String?> tagHalfLifeOverrides;
  final Value<int> dailyReadingGoal;
  final Value<String> snoozePresets;
  final Value<String> fontFamily;
  final Value<String?> customAccentColor;
  final Value<String?> customBgColor;
  final Value<String> decayCurveType;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.halfLifeDays = const Value.absent(),
    this.notificationThreshold = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.themePalette = const Value.absent(),
    this.swipeLeftAction = const Value.absent(),
    this.swipeRightAction = const Value.absent(),
    this.domainHalfLifeOverrides = const Value.absent(),
    this.tagHalfLifeOverrides = const Value.absent(),
    this.dailyReadingGoal = const Value.absent(),
    this.snoozePresets = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.customAccentColor = const Value.absent(),
    this.customBgColor = const Value.absent(),
    this.decayCurveType = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.halfLifeDays = const Value.absent(),
    this.notificationThreshold = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.themePalette = const Value.absent(),
    this.swipeLeftAction = const Value.absent(),
    this.swipeRightAction = const Value.absent(),
    this.domainHalfLifeOverrides = const Value.absent(),
    this.tagHalfLifeOverrides = const Value.absent(),
    this.dailyReadingGoal = const Value.absent(),
    this.snoozePresets = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.customAccentColor = const Value.absent(),
    this.customBgColor = const Value.absent(),
    this.decayCurveType = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<double>? halfLifeDays,
    Expression<double>? notificationThreshold,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? isDarkMode,
    Expression<String>? themePalette,
    Expression<String>? swipeLeftAction,
    Expression<String>? swipeRightAction,
    Expression<String>? domainHalfLifeOverrides,
    Expression<String>? tagHalfLifeOverrides,
    Expression<int>? dailyReadingGoal,
    Expression<String>? snoozePresets,
    Expression<String>? fontFamily,
    Expression<String>? customAccentColor,
    Expression<String>? customBgColor,
    Expression<String>? decayCurveType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (halfLifeDays != null) 'half_life_days': halfLifeDays,
      if (notificationThreshold != null)
        'notification_threshold': notificationThreshold,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
      if (themePalette != null) 'theme_palette': themePalette,
      if (swipeLeftAction != null) 'swipe_left_action': swipeLeftAction,
      if (swipeRightAction != null) 'swipe_right_action': swipeRightAction,
      if (domainHalfLifeOverrides != null)
        'domain_half_life_overrides': domainHalfLifeOverrides,
      if (tagHalfLifeOverrides != null)
        'tag_half_life_overrides': tagHalfLifeOverrides,
      if (dailyReadingGoal != null) 'daily_reading_goal': dailyReadingGoal,
      if (snoozePresets != null) 'snooze_presets': snoozePresets,
      if (fontFamily != null) 'font_family': fontFamily,
      if (customAccentColor != null) 'custom_accent_color': customAccentColor,
      if (customBgColor != null) 'custom_bg_color': customBgColor,
      if (decayCurveType != null) 'decay_curve_type': decayCurveType,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<double>? halfLifeDays,
    Value<double>? notificationThreshold,
    Value<bool>? notificationsEnabled,
    Value<bool>? isDarkMode,
    Value<String>? themePalette,
    Value<String>? swipeLeftAction,
    Value<String>? swipeRightAction,
    Value<String?>? domainHalfLifeOverrides,
    Value<String?>? tagHalfLifeOverrides,
    Value<int>? dailyReadingGoal,
    Value<String>? snoozePresets,
    Value<String>? fontFamily,
    Value<String?>? customAccentColor,
    Value<String?>? customBgColor,
    Value<String>? decayCurveType,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      halfLifeDays: halfLifeDays ?? this.halfLifeDays,
      notificationThreshold:
          notificationThreshold ?? this.notificationThreshold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themePalette: themePalette ?? this.themePalette,
      swipeLeftAction: swipeLeftAction ?? this.swipeLeftAction,
      swipeRightAction: swipeRightAction ?? this.swipeRightAction,
      domainHalfLifeOverrides:
          domainHalfLifeOverrides ?? this.domainHalfLifeOverrides,
      tagHalfLifeOverrides: tagHalfLifeOverrides ?? this.tagHalfLifeOverrides,
      dailyReadingGoal: dailyReadingGoal ?? this.dailyReadingGoal,
      snoozePresets: snoozePresets ?? this.snoozePresets,
      fontFamily: fontFamily ?? this.fontFamily,
      customAccentColor: customAccentColor ?? this.customAccentColor,
      customBgColor: customBgColor ?? this.customBgColor,
      decayCurveType: decayCurveType ?? this.decayCurveType,
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
    if (themePalette.present) {
      map['theme_palette'] = Variable<String>(themePalette.value);
    }
    if (swipeLeftAction.present) {
      map['swipe_left_action'] = Variable<String>(swipeLeftAction.value);
    }
    if (swipeRightAction.present) {
      map['swipe_right_action'] = Variable<String>(swipeRightAction.value);
    }
    if (domainHalfLifeOverrides.present) {
      map['domain_half_life_overrides'] = Variable<String>(
        domainHalfLifeOverrides.value,
      );
    }
    if (tagHalfLifeOverrides.present) {
      map['tag_half_life_overrides'] = Variable<String>(
        tagHalfLifeOverrides.value,
      );
    }
    if (dailyReadingGoal.present) {
      map['daily_reading_goal'] = Variable<int>(dailyReadingGoal.value);
    }
    if (snoozePresets.present) {
      map['snooze_presets'] = Variable<String>(snoozePresets.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (customAccentColor.present) {
      map['custom_accent_color'] = Variable<String>(customAccentColor.value);
    }
    if (customBgColor.present) {
      map['custom_bg_color'] = Variable<String>(customBgColor.value);
    }
    if (decayCurveType.present) {
      map['decay_curve_type'] = Variable<String>(decayCurveType.value);
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
          ..write('isDarkMode: $isDarkMode, ')
          ..write('themePalette: $themePalette, ')
          ..write('swipeLeftAction: $swipeLeftAction, ')
          ..write('swipeRightAction: $swipeRightAction, ')
          ..write('domainHalfLifeOverrides: $domainHalfLifeOverrides, ')
          ..write('tagHalfLifeOverrides: $tagHalfLifeOverrides, ')
          ..write('dailyReadingGoal: $dailyReadingGoal, ')
          ..write('snoozePresets: $snoozePresets, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('customAccentColor: $customAccentColor, ')
          ..write('customBgColor: $customBgColor, ')
          ..write('decayCurveType: $decayCurveType')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LinksTable links = $LinksTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CustomFiltersTable customFilters = $CustomFiltersTable(this);
  late final $LinkHighlightsTable linkHighlights = $LinkHighlightsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    links,
    collections,
    customFilters,
    linkHighlights,
    appSettings,
  ];
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
      Value<String?> collectionId,
      Value<String?> notes,
      Value<String?> ogImageUrl,
      Value<int?> estimatedReadMinutes,
      Value<DateTime?> readAt,
      Value<DateTime?> archivedAt,
      Value<double?> customHalfLifeDays,
      Value<bool> isDead,
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
      Value<String?> collectionId,
      Value<String?> notes,
      Value<String?> ogImageUrl,
      Value<int?> estimatedReadMinutes,
      Value<DateTime?> readAt,
      Value<DateTime?> archivedAt,
      Value<double?> customHalfLifeDays,
      Value<bool> isDead,
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

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ogImageUrl => $composableBuilder(
    column: $table.ogImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedReadMinutes => $composableBuilder(
    column: $table.estimatedReadMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get customHalfLifeDays => $composableBuilder(
    column: $table.customHalfLifeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDead => $composableBuilder(
    column: $table.isDead,
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

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ogImageUrl => $composableBuilder(
    column: $table.ogImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedReadMinutes => $composableBuilder(
    column: $table.estimatedReadMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get customHalfLifeDays => $composableBuilder(
    column: $table.customHalfLifeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDead => $composableBuilder(
    column: $table.isDead,
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

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get ogImageUrl => $composableBuilder(
    column: $table.ogImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedReadMinutes => $composableBuilder(
    column: $table.estimatedReadMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get customHalfLifeDays => $composableBuilder(
    column: $table.customHalfLifeDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDead =>
      $composableBuilder(column: $table.isDead, builder: (column) => column);
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
                Value<String?> collectionId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> ogImageUrl = const Value.absent(),
                Value<int?> estimatedReadMinutes = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<double?> customHalfLifeDays = const Value.absent(),
                Value<bool> isDead = const Value.absent(),
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
                collectionId: collectionId,
                notes: notes,
                ogImageUrl: ogImageUrl,
                estimatedReadMinutes: estimatedReadMinutes,
                readAt: readAt,
                archivedAt: archivedAt,
                customHalfLifeDays: customHalfLifeDays,
                isDead: isDead,
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
                Value<String?> collectionId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> ogImageUrl = const Value.absent(),
                Value<int?> estimatedReadMinutes = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<double?> customHalfLifeDays = const Value.absent(),
                Value<bool> isDead = const Value.absent(),
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
                collectionId: collectionId,
                notes: notes,
                ogImageUrl: ogImageUrl,
                estimatedReadMinutes: estimatedReadMinutes,
                readAt: readAt,
                archivedAt: archivedAt,
                customHalfLifeDays: customHalfLifeDays,
                isDead: isDead,
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
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String name,
      Value<String?> emoji,
      required DateTime createdAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> emoji,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                emoji: emoji,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> emoji = const Value.absent(),
                required DateTime createdAt,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                createdAt: createdAt,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$AppDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$CustomFiltersTableCreateCompanionBuilder =
    CustomFiltersCompanion Function({
      required String id,
      required String name,
      Value<String> icon,
      Value<double?> minFreshness,
      Value<double?> maxFreshness,
      Value<String?> tags,
      Value<String?> collections,
      Value<String?> domains,
      Value<int?> minReadTime,
      Value<int?> maxReadTime,
      Value<String?> snoozeFilter,
      Value<String> sortField,
      Value<int> rowid,
    });
typedef $$CustomFiltersTableUpdateCompanionBuilder =
    CustomFiltersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<double?> minFreshness,
      Value<double?> maxFreshness,
      Value<String?> tags,
      Value<String?> collections,
      Value<String?> domains,
      Value<int?> minReadTime,
      Value<int?> maxReadTime,
      Value<String?> snoozeFilter,
      Value<String> sortField,
      Value<int> rowid,
    });

class $$CustomFiltersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFiltersTable> {
  $$CustomFiltersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minFreshness => $composableBuilder(
    column: $table.minFreshness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxFreshness => $composableBuilder(
    column: $table.maxFreshness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domains => $composableBuilder(
    column: $table.domains,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minReadTime => $composableBuilder(
    column: $table.minReadTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxReadTime => $composableBuilder(
    column: $table.maxReadTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snoozeFilter => $composableBuilder(
    column: $table.snoozeFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortField => $composableBuilder(
    column: $table.sortField,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFiltersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFiltersTable> {
  $$CustomFiltersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minFreshness => $composableBuilder(
    column: $table.minFreshness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxFreshness => $composableBuilder(
    column: $table.maxFreshness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domains => $composableBuilder(
    column: $table.domains,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minReadTime => $composableBuilder(
    column: $table.minReadTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxReadTime => $composableBuilder(
    column: $table.maxReadTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozeFilter => $composableBuilder(
    column: $table.snoozeFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortField => $composableBuilder(
    column: $table.sortField,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFiltersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFiltersTable> {
  $$CustomFiltersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<double> get minFreshness => $composableBuilder(
    column: $table.minFreshness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxFreshness => $composableBuilder(
    column: $table.maxFreshness,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get collections => $composableBuilder(
    column: $table.collections,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domains =>
      $composableBuilder(column: $table.domains, builder: (column) => column);

  GeneratedColumn<int> get minReadTime => $composableBuilder(
    column: $table.minReadTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxReadTime => $composableBuilder(
    column: $table.maxReadTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snoozeFilter => $composableBuilder(
    column: $table.snoozeFilter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sortField =>
      $composableBuilder(column: $table.sortField, builder: (column) => column);
}

class $$CustomFiltersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFiltersTable,
          CustomFilter,
          $$CustomFiltersTableFilterComposer,
          $$CustomFiltersTableOrderingComposer,
          $$CustomFiltersTableAnnotationComposer,
          $$CustomFiltersTableCreateCompanionBuilder,
          $$CustomFiltersTableUpdateCompanionBuilder,
          (
            CustomFilter,
            BaseReferences<_$AppDatabase, $CustomFiltersTable, CustomFilter>,
          ),
          CustomFilter,
          PrefetchHooks Function()
        > {
  $$CustomFiltersTableTableManager(_$AppDatabase db, $CustomFiltersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFiltersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFiltersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFiltersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<double?> minFreshness = const Value.absent(),
                Value<double?> maxFreshness = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> collections = const Value.absent(),
                Value<String?> domains = const Value.absent(),
                Value<int?> minReadTime = const Value.absent(),
                Value<int?> maxReadTime = const Value.absent(),
                Value<String?> snoozeFilter = const Value.absent(),
                Value<String> sortField = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFiltersCompanion(
                id: id,
                name: name,
                icon: icon,
                minFreshness: minFreshness,
                maxFreshness: maxFreshness,
                tags: tags,
                collections: collections,
                domains: domains,
                minReadTime: minReadTime,
                maxReadTime: maxReadTime,
                snoozeFilter: snoozeFilter,
                sortField: sortField,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> icon = const Value.absent(),
                Value<double?> minFreshness = const Value.absent(),
                Value<double?> maxFreshness = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> collections = const Value.absent(),
                Value<String?> domains = const Value.absent(),
                Value<int?> minReadTime = const Value.absent(),
                Value<int?> maxReadTime = const Value.absent(),
                Value<String?> snoozeFilter = const Value.absent(),
                Value<String> sortField = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFiltersCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                minFreshness: minFreshness,
                maxFreshness: maxFreshness,
                tags: tags,
                collections: collections,
                domains: domains,
                minReadTime: minReadTime,
                maxReadTime: maxReadTime,
                snoozeFilter: snoozeFilter,
                sortField: sortField,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomFiltersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFiltersTable,
      CustomFilter,
      $$CustomFiltersTableFilterComposer,
      $$CustomFiltersTableOrderingComposer,
      $$CustomFiltersTableAnnotationComposer,
      $$CustomFiltersTableCreateCompanionBuilder,
      $$CustomFiltersTableUpdateCompanionBuilder,
      (
        CustomFilter,
        BaseReferences<_$AppDatabase, $CustomFiltersTable, CustomFilter>,
      ),
      CustomFilter,
      PrefetchHooks Function()
    >;
typedef $$LinkHighlightsTableCreateCompanionBuilder =
    LinkHighlightsCompanion Function({
      required String id,
      required String linkId,
      required String content,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LinkHighlightsTableUpdateCompanionBuilder =
    LinkHighlightsCompanion Function({
      Value<String> id,
      Value<String> linkId,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LinkHighlightsTableFilterComposer
    extends Composer<_$AppDatabase, $LinkHighlightsTable> {
  $$LinkHighlightsTableFilterComposer({
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

  ColumnFilters<String> get linkId => $composableBuilder(
    column: $table.linkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LinkHighlightsTableOrderingComposer
    extends Composer<_$AppDatabase, $LinkHighlightsTable> {
  $$LinkHighlightsTableOrderingComposer({
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

  ColumnOrderings<String> get linkId => $composableBuilder(
    column: $table.linkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LinkHighlightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinkHighlightsTable> {
  $$LinkHighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get linkId =>
      $composableBuilder(column: $table.linkId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LinkHighlightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinkHighlightsTable,
          LinkHighlight,
          $$LinkHighlightsTableFilterComposer,
          $$LinkHighlightsTableOrderingComposer,
          $$LinkHighlightsTableAnnotationComposer,
          $$LinkHighlightsTableCreateCompanionBuilder,
          $$LinkHighlightsTableUpdateCompanionBuilder,
          (
            LinkHighlight,
            BaseReferences<_$AppDatabase, $LinkHighlightsTable, LinkHighlight>,
          ),
          LinkHighlight,
          PrefetchHooks Function()
        > {
  $$LinkHighlightsTableTableManager(
    _$AppDatabase db,
    $LinkHighlightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinkHighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinkHighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinkHighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> linkId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinkHighlightsCompanion(
                id: id,
                linkId: linkId,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String linkId,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LinkHighlightsCompanion.insert(
                id: id,
                linkId: linkId,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LinkHighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinkHighlightsTable,
      LinkHighlight,
      $$LinkHighlightsTableFilterComposer,
      $$LinkHighlightsTableOrderingComposer,
      $$LinkHighlightsTableAnnotationComposer,
      $$LinkHighlightsTableCreateCompanionBuilder,
      $$LinkHighlightsTableUpdateCompanionBuilder,
      (
        LinkHighlight,
        BaseReferences<_$AppDatabase, $LinkHighlightsTable, LinkHighlight>,
      ),
      LinkHighlight,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<double> halfLifeDays,
      Value<double> notificationThreshold,
      Value<bool> notificationsEnabled,
      Value<bool> isDarkMode,
      Value<String> themePalette,
      Value<String> swipeLeftAction,
      Value<String> swipeRightAction,
      Value<String?> domainHalfLifeOverrides,
      Value<String?> tagHalfLifeOverrides,
      Value<int> dailyReadingGoal,
      Value<String> snoozePresets,
      Value<String> fontFamily,
      Value<String?> customAccentColor,
      Value<String?> customBgColor,
      Value<String> decayCurveType,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<double> halfLifeDays,
      Value<double> notificationThreshold,
      Value<bool> notificationsEnabled,
      Value<bool> isDarkMode,
      Value<String> themePalette,
      Value<String> swipeLeftAction,
      Value<String> swipeRightAction,
      Value<String?> domainHalfLifeOverrides,
      Value<String?> tagHalfLifeOverrides,
      Value<int> dailyReadingGoal,
      Value<String> snoozePresets,
      Value<String> fontFamily,
      Value<String?> customAccentColor,
      Value<String?> customBgColor,
      Value<String> decayCurveType,
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

  ColumnFilters<String> get themePalette => $composableBuilder(
    column: $table.themePalette,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get swipeLeftAction => $composableBuilder(
    column: $table.swipeLeftAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get swipeRightAction => $composableBuilder(
    column: $table.swipeRightAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domainHalfLifeOverrides => $composableBuilder(
    column: $table.domainHalfLifeOverrides,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagHalfLifeOverrides => $composableBuilder(
    column: $table.tagHalfLifeOverrides,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyReadingGoal => $composableBuilder(
    column: $table.dailyReadingGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snoozePresets => $composableBuilder(
    column: $table.snoozePresets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customAccentColor => $composableBuilder(
    column: $table.customAccentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customBgColor => $composableBuilder(
    column: $table.customBgColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decayCurveType => $composableBuilder(
    column: $table.decayCurveType,
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

  ColumnOrderings<String> get themePalette => $composableBuilder(
    column: $table.themePalette,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get swipeLeftAction => $composableBuilder(
    column: $table.swipeLeftAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get swipeRightAction => $composableBuilder(
    column: $table.swipeRightAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domainHalfLifeOverrides => $composableBuilder(
    column: $table.domainHalfLifeOverrides,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagHalfLifeOverrides => $composableBuilder(
    column: $table.tagHalfLifeOverrides,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyReadingGoal => $composableBuilder(
    column: $table.dailyReadingGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozePresets => $composableBuilder(
    column: $table.snoozePresets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customAccentColor => $composableBuilder(
    column: $table.customAccentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customBgColor => $composableBuilder(
    column: $table.customBgColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decayCurveType => $composableBuilder(
    column: $table.decayCurveType,
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

  GeneratedColumn<String> get themePalette => $composableBuilder(
    column: $table.themePalette,
    builder: (column) => column,
  );

  GeneratedColumn<String> get swipeLeftAction => $composableBuilder(
    column: $table.swipeLeftAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get swipeRightAction => $composableBuilder(
    column: $table.swipeRightAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domainHalfLifeOverrides => $composableBuilder(
    column: $table.domainHalfLifeOverrides,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tagHalfLifeOverrides => $composableBuilder(
    column: $table.tagHalfLifeOverrides,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyReadingGoal => $composableBuilder(
    column: $table.dailyReadingGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snoozePresets => $composableBuilder(
    column: $table.snoozePresets,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customAccentColor => $composableBuilder(
    column: $table.customAccentColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customBgColor => $composableBuilder(
    column: $table.customBgColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decayCurveType => $composableBuilder(
    column: $table.decayCurveType,
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
                Value<String> themePalette = const Value.absent(),
                Value<String> swipeLeftAction = const Value.absent(),
                Value<String> swipeRightAction = const Value.absent(),
                Value<String?> domainHalfLifeOverrides = const Value.absent(),
                Value<String?> tagHalfLifeOverrides = const Value.absent(),
                Value<int> dailyReadingGoal = const Value.absent(),
                Value<String> snoozePresets = const Value.absent(),
                Value<String> fontFamily = const Value.absent(),
                Value<String?> customAccentColor = const Value.absent(),
                Value<String?> customBgColor = const Value.absent(),
                Value<String> decayCurveType = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                halfLifeDays: halfLifeDays,
                notificationThreshold: notificationThreshold,
                notificationsEnabled: notificationsEnabled,
                isDarkMode: isDarkMode,
                themePalette: themePalette,
                swipeLeftAction: swipeLeftAction,
                swipeRightAction: swipeRightAction,
                domainHalfLifeOverrides: domainHalfLifeOverrides,
                tagHalfLifeOverrides: tagHalfLifeOverrides,
                dailyReadingGoal: dailyReadingGoal,
                snoozePresets: snoozePresets,
                fontFamily: fontFamily,
                customAccentColor: customAccentColor,
                customBgColor: customBgColor,
                decayCurveType: decayCurveType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> halfLifeDays = const Value.absent(),
                Value<double> notificationThreshold = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> isDarkMode = const Value.absent(),
                Value<String> themePalette = const Value.absent(),
                Value<String> swipeLeftAction = const Value.absent(),
                Value<String> swipeRightAction = const Value.absent(),
                Value<String?> domainHalfLifeOverrides = const Value.absent(),
                Value<String?> tagHalfLifeOverrides = const Value.absent(),
                Value<int> dailyReadingGoal = const Value.absent(),
                Value<String> snoozePresets = const Value.absent(),
                Value<String> fontFamily = const Value.absent(),
                Value<String?> customAccentColor = const Value.absent(),
                Value<String?> customBgColor = const Value.absent(),
                Value<String> decayCurveType = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                halfLifeDays: halfLifeDays,
                notificationThreshold: notificationThreshold,
                notificationsEnabled: notificationsEnabled,
                isDarkMode: isDarkMode,
                themePalette: themePalette,
                swipeLeftAction: swipeLeftAction,
                swipeRightAction: swipeRightAction,
                domainHalfLifeOverrides: domainHalfLifeOverrides,
                tagHalfLifeOverrides: tagHalfLifeOverrides,
                dailyReadingGoal: dailyReadingGoal,
                snoozePresets: snoozePresets,
                fontFamily: fontFamily,
                customAccentColor: customAccentColor,
                customBgColor: customBgColor,
                decayCurveType: decayCurveType,
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
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CustomFiltersTableTableManager get customFilters =>
      $$CustomFiltersTableTableManager(_db, _db.customFilters);
  $$LinkHighlightsTableTableManager get linkHighlights =>
      $$LinkHighlightsTableTableManager(_db, _db.linkHighlights);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
