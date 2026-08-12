// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes
    with TableInfo<$ClientesTable, ClienteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombre,
        telefono,
        email,
        direccion,
        observaciones,
        fechaRegistro,
        activo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(Insertable<ClienteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    } else if (isInserting) {
      context.missing(_fechaRegistroMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClienteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClienteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class ClienteRow extends DataClass implements Insertable<ClienteRow> {
  final int id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? observaciones;
  final DateTime fechaRegistro;
  final bool activo;
  const ClienteRow(
      {required this.id,
      required this.nombre,
      this.telefono,
      this.email,
      this.direccion,
      this.observaciones,
      required this.fechaRegistro,
      required this.activo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      fechaRegistro: Value(fechaRegistro),
      activo: Value(activo),
    );
  }

  factory ClienteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClienteRow(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'direccion': serializer.toJson<String?>(direccion),
      'observaciones': serializer.toJson<String?>(observaciones),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  ClienteRow copyWith(
          {int? id,
          String? nombre,
          Value<String?> telefono = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> direccion = const Value.absent(),
          Value<String?> observaciones = const Value.absent(),
          DateTime? fechaRegistro,
          bool? activo}) =>
      ClienteRow(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        telefono: telefono.present ? telefono.value : this.telefono,
        email: email.present ? email.value : this.email,
        direccion: direccion.present ? direccion.value : this.direccion,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
        activo: activo ?? this.activo,
      );
  ClienteRow copyWithCompanion(ClientesCompanion data) {
    return ClienteRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClienteRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, telefono, email, direccion,
      observaciones, fechaRegistro, activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClienteRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.direccion == this.direccion &&
          other.observaciones == this.observaciones &&
          other.fechaRegistro == this.fechaRegistro &&
          other.activo == this.activo);
}

class ClientesCompanion extends UpdateCompanion<ClienteRow> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<String?> direccion;
  final Value<String?> observaciones;
  final Value<DateTime> fechaRegistro;
  final Value<bool> activo;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.activo = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.observaciones = const Value.absent(),
    required DateTime fechaRegistro,
    this.activo = const Value.absent(),
  })  : nombre = Value(nombre),
        fechaRegistro = Value(fechaRegistro);
  static Insertable<ClienteRow> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? direccion,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaRegistro,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (direccion != null) 'direccion': direccion,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
      if (activo != null) 'activo': activo,
    });
  }

  ClientesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<String?>? telefono,
      Value<String?>? email,
      Value<String?>? direccion,
      Value<String?>? observaciones,
      Value<DateTime>? fechaRegistro,
      Value<bool>? activo}) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, nombre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(Insertable<Categoria> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nombre;
  const Categoria({required this.id, required this.nombre});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
    );
  }

  factory Categoria.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
    };
  }

  Categoria copyWith({int? id, String? nombre}) => Categoria(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
      );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nombre: $nombre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nombre == this.nombre);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nombre;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
  }) : nombre = Value(nombre);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nombre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
    });
  }

  CategoriasCompanion copyWith({Value<int>? id, Value<String>? nombre}) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre')
          ..write(')'))
        .toString();
  }
}

class $ViajesTable extends Viajes with TableInfo<$ViajesTable, Viaje> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ViajesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _destinoMeta =
      const VerificationMeta('destino');
  @override
  late final GeneratedColumn<String> destino = GeneratedColumn<String>(
      'destino', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _distribuidoMeta =
      const VerificationMeta('distribuido');
  @override
  late final GeneratedColumn<bool> distribuido = GeneratedColumn<bool>(
      'distribuido', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("distribuido" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fecha, destino, observaciones, distribuido];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'viajes';
  @override
  VerificationContext validateIntegrity(Insertable<Viaje> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('destino')) {
      context.handle(_destinoMeta,
          destino.isAcceptableOrUnknown(data['destino']!, _destinoMeta));
    } else if (isInserting) {
      context.missing(_destinoMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('distribuido')) {
      context.handle(
          _distribuidoMeta,
          distribuido.isAcceptableOrUnknown(
              data['distribuido']!, _distribuidoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Viaje map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Viaje(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      destino: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}destino'])!,
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      distribuido: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}distribuido'])!,
    );
  }

  @override
  $ViajesTable createAlias(String alias) {
    return $ViajesTable(attachedDatabase, alias);
  }
}

class Viaje extends DataClass implements Insertable<Viaje> {
  final int id;
  final DateTime fecha;
  final String destino;
  final String? observaciones;
  final bool distribuido;
  const Viaje(
      {required this.id,
      required this.fecha,
      required this.destino,
      this.observaciones,
      required this.distribuido});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['destino'] = Variable<String>(destino);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['distribuido'] = Variable<bool>(distribuido);
    return map;
  }

  ViajesCompanion toCompanion(bool nullToAbsent) {
    return ViajesCompanion(
      id: Value(id),
      fecha: Value(fecha),
      destino: Value(destino),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      distribuido: Value(distribuido),
    );
  }

  factory Viaje.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Viaje(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      destino: serializer.fromJson<String>(json['destino']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      distribuido: serializer.fromJson<bool>(json['distribuido']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'destino': serializer.toJson<String>(destino),
      'observaciones': serializer.toJson<String?>(observaciones),
      'distribuido': serializer.toJson<bool>(distribuido),
    };
  }

  Viaje copyWith(
          {int? id,
          DateTime? fecha,
          String? destino,
          Value<String?> observaciones = const Value.absent(),
          bool? distribuido}) =>
      Viaje(
        id: id ?? this.id,
        fecha: fecha ?? this.fecha,
        destino: destino ?? this.destino,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        distribuido: distribuido ?? this.distribuido,
      );
  Viaje copyWithCompanion(ViajesCompanion data) {
    return Viaje(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      destino: data.destino.present ? data.destino.value : this.destino,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      distribuido:
          data.distribuido.present ? data.distribuido.value : this.distribuido,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Viaje(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('destino: $destino, ')
          ..write('observaciones: $observaciones, ')
          ..write('distribuido: $distribuido')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fecha, destino, observaciones, distribuido);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Viaje &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.destino == this.destino &&
          other.observaciones == this.observaciones &&
          other.distribuido == this.distribuido);
}

class ViajesCompanion extends UpdateCompanion<Viaje> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<String> destino;
  final Value<String?> observaciones;
  final Value<bool> distribuido;
  const ViajesCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.destino = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.distribuido = const Value.absent(),
  });
  ViajesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime fecha,
    required String destino,
    this.observaciones = const Value.absent(),
    this.distribuido = const Value.absent(),
  })  : fecha = Value(fecha),
        destino = Value(destino);
  static Insertable<Viaje> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<String>? destino,
    Expression<String>? observaciones,
    Expression<bool>? distribuido,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (destino != null) 'destino': destino,
      if (observaciones != null) 'observaciones': observaciones,
      if (distribuido != null) 'distribuido': distribuido,
    });
  }

  ViajesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? fecha,
      Value<String>? destino,
      Value<String?>? observaciones,
      Value<bool>? distribuido}) {
    return ViajesCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      destino: destino ?? this.destino,
      observaciones: observaciones ?? this.observaciones,
      distribuido: distribuido ?? this.distribuido,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (destino.present) {
      map['destino'] = Variable<String>(destino.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (distribuido.present) {
      map['distribuido'] = Variable<bool>(distribuido.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ViajesCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('destino: $destino, ')
          ..write('observaciones: $observaciones, ')
          ..write('distribuido: $distribuido')
          ..write(')'))
        .toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, Gasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _viajeIdMeta =
      const VerificationMeta('viajeId');
  @override
  late final GeneratedColumn<int> viajeId = GeneratedColumn<int>(
      'viaje_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES viajes (id)'));
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
      'monto', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, viajeId, tipo, monto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(Insertable<Gasto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('viaje_id')) {
      context.handle(_viajeIdMeta,
          viajeId.isAcceptableOrUnknown(data['viaje_id']!, _viajeIdMeta));
    } else if (isInserting) {
      context.missing(_viajeIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
          _montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gasto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      viajeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viaje_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      monto: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monto'])!,
    );
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }
}

class Gasto extends DataClass implements Insertable<Gasto> {
  final int id;
  final int viajeId;
  final String tipo;
  final int monto;
  const Gasto(
      {required this.id,
      required this.viajeId,
      required this.tipo,
      required this.monto});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['viaje_id'] = Variable<int>(viajeId);
    map['tipo'] = Variable<String>(tipo);
    map['monto'] = Variable<int>(monto);
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(
      id: Value(id),
      viajeId: Value(viajeId),
      tipo: Value(tipo),
      monto: Value(monto),
    );
  }

  factory Gasto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gasto(
      id: serializer.fromJson<int>(json['id']),
      viajeId: serializer.fromJson<int>(json['viajeId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      monto: serializer.fromJson<int>(json['monto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'viajeId': serializer.toJson<int>(viajeId),
      'tipo': serializer.toJson<String>(tipo),
      'monto': serializer.toJson<int>(monto),
    };
  }

  Gasto copyWith({int? id, int? viajeId, String? tipo, int? monto}) => Gasto(
        id: id ?? this.id,
        viajeId: viajeId ?? this.viajeId,
        tipo: tipo ?? this.tipo,
        monto: monto ?? this.monto,
      );
  Gasto copyWithCompanion(GastosCompanion data) {
    return Gasto(
      id: data.id.present ? data.id.value : this.id,
      viajeId: data.viajeId.present ? data.viajeId.value : this.viajeId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      monto: data.monto.present ? data.monto.value : this.monto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gasto(')
          ..write('id: $id, ')
          ..write('viajeId: $viajeId, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, viajeId, tipo, monto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gasto &&
          other.id == this.id &&
          other.viajeId == this.viajeId &&
          other.tipo == this.tipo &&
          other.monto == this.monto);
}

class GastosCompanion extends UpdateCompanion<Gasto> {
  final Value<int> id;
  final Value<int> viajeId;
  final Value<String> tipo;
  final Value<int> monto;
  const GastosCompanion({
    this.id = const Value.absent(),
    this.viajeId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.monto = const Value.absent(),
  });
  GastosCompanion.insert({
    this.id = const Value.absent(),
    required int viajeId,
    required String tipo,
    required int monto,
  })  : viajeId = Value(viajeId),
        tipo = Value(tipo),
        monto = Value(monto);
  static Insertable<Gasto> custom({
    Expression<int>? id,
    Expression<int>? viajeId,
    Expression<String>? tipo,
    Expression<int>? monto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (viajeId != null) 'viaje_id': viajeId,
      if (tipo != null) 'tipo': tipo,
      if (monto != null) 'monto': monto,
    });
  }

  GastosCompanion copyWith(
      {Value<int>? id,
      Value<int>? viajeId,
      Value<String>? tipo,
      Value<int>? monto}) {
    return GastosCompanion(
      id: id ?? this.id,
      viajeId: viajeId ?? this.viajeId,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (viajeId.present) {
      map['viaje_id'] = Variable<int>(viajeId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')
          ..write('id: $id, ')
          ..write('viajeId: $viajeId, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto')
          ..write(')'))
        .toString();
  }
}

class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoriaIdMeta =
      const VerificationMeta('categoriaId');
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
      'categoria_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categorias (id)'));
  static const VerificationMeta _viajeIdMeta =
      const VerificationMeta('viajeId');
  @override
  late final GeneratedColumn<int> viajeId = GeneratedColumn<int>(
      'viaje_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES viajes (id)'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _precioCompraMeta =
      const VerificationMeta('precioCompra');
  @override
  late final GeneratedColumn<int> precioCompra = GeneratedColumn<int>(
      'precio_compra', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _comisionViajeMeta =
      const VerificationMeta('comisionViaje');
  @override
  late final GeneratedColumn<int> comisionViaje = GeneratedColumn<int>(
      'comision_viaje', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _precioVentaMeta =
      const VerificationMeta('precioVenta');
  @override
  late final GeneratedColumn<int> precioVenta = GeneratedColumn<int>(
      'precio_venta', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cantidadDisponibleMeta =
      const VerificationMeta('cantidadDisponible');
  @override
  late final GeneratedColumn<int> cantidadDisponible = GeneratedColumn<int>(
      'cantidad_disponible', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fotoPathMeta =
      const VerificationMeta('fotoPath');
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
      'foto_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoriaId,
        viajeId,
        nombre,
        descripcion,
        precioCompra,
        comisionViaje,
        precioVenta,
        cantidadDisponible,
        fotoPath,
        activo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(Insertable<Producto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
          _categoriaIdMeta,
          categoriaId.isAcceptableOrUnknown(
              data['categoria_id']!, _categoriaIdMeta));
    }
    if (data.containsKey('viaje_id')) {
      context.handle(_viajeIdMeta,
          viajeId.isAcceptableOrUnknown(data['viaje_id']!, _viajeIdMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
          _precioCompraMeta,
          precioCompra.isAcceptableOrUnknown(
              data['precio_compra']!, _precioCompraMeta));
    }
    if (data.containsKey('comision_viaje')) {
      context.handle(
          _comisionViajeMeta,
          comisionViaje.isAcceptableOrUnknown(
              data['comision_viaje']!, _comisionViajeMeta));
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
          _precioVentaMeta,
          precioVenta.isAcceptableOrUnknown(
              data['precio_venta']!, _precioVentaMeta));
    }
    if (data.containsKey('cantidad_disponible')) {
      context.handle(
          _cantidadDisponibleMeta,
          cantidadDisponible.isAcceptableOrUnknown(
              data['cantidad_disponible']!, _cantidadDisponibleMeta));
    }
    if (data.containsKey('foto_path')) {
      context.handle(_fotoPathMeta,
          fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta));
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoriaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}categoria_id']),
      viajeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}viaje_id']),
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      precioCompra: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}precio_compra']),
      comisionViaje: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}comision_viaje'])!,
      precioVenta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}precio_venta']),
      cantidadDisponible: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}cantidad_disponible'])!,
      fotoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_path']),
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final int id;
  final int? categoriaId;
  final int? viajeId;
  final String nombre;
  final String? descripcion;
  final int? precioCompra;
  final int comisionViaje;
  final int? precioVenta;
  final int cantidadDisponible;
  final String? fotoPath;
  final bool activo;
  const Producto(
      {required this.id,
      this.categoriaId,
      this.viajeId,
      required this.nombre,
      this.descripcion,
      this.precioCompra,
      required this.comisionViaje,
      this.precioVenta,
      required this.cantidadDisponible,
      this.fotoPath,
      required this.activo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    if (!nullToAbsent || viajeId != null) {
      map['viaje_id'] = Variable<int>(viajeId);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || precioCompra != null) {
      map['precio_compra'] = Variable<int>(precioCompra);
    }
    map['comision_viaje'] = Variable<int>(comisionViaje);
    if (!nullToAbsent || precioVenta != null) {
      map['precio_venta'] = Variable<int>(precioVenta);
    }
    map['cantidad_disponible'] = Variable<int>(cantidadDisponible);
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      viajeId: viajeId == null && nullToAbsent
          ? const Value.absent()
          : Value(viajeId),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      precioCompra: precioCompra == null && nullToAbsent
          ? const Value.absent()
          : Value(precioCompra),
      comisionViaje: Value(comisionViaje),
      precioVenta: precioVenta == null && nullToAbsent
          ? const Value.absent()
          : Value(precioVenta),
      cantidadDisponible: Value(cantidadDisponible),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      activo: Value(activo),
    );
  }

  factory Producto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<int>(json['id']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      viajeId: serializer.fromJson<int?>(json['viajeId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      precioCompra: serializer.fromJson<int?>(json['precioCompra']),
      comisionViaje: serializer.fromJson<int>(json['comisionViaje']),
      precioVenta: serializer.fromJson<int?>(json['precioVenta']),
      cantidadDisponible: serializer.fromJson<int>(json['cantidadDisponible']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'viajeId': serializer.toJson<int?>(viajeId),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'precioCompra': serializer.toJson<int?>(precioCompra),
      'comisionViaje': serializer.toJson<int>(comisionViaje),
      'precioVenta': serializer.toJson<int?>(precioVenta),
      'cantidadDisponible': serializer.toJson<int>(cantidadDisponible),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Producto copyWith(
          {int? id,
          Value<int?> categoriaId = const Value.absent(),
          Value<int?> viajeId = const Value.absent(),
          String? nombre,
          Value<String?> descripcion = const Value.absent(),
          Value<int?> precioCompra = const Value.absent(),
          int? comisionViaje,
          Value<int?> precioVenta = const Value.absent(),
          int? cantidadDisponible,
          Value<String?> fotoPath = const Value.absent(),
          bool? activo}) =>
      Producto(
        id: id ?? this.id,
        categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
        viajeId: viajeId.present ? viajeId.value : this.viajeId,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        precioCompra:
            precioCompra.present ? precioCompra.value : this.precioCompra,
        comisionViaje: comisionViaje ?? this.comisionViaje,
        precioVenta: precioVenta.present ? precioVenta.value : this.precioVenta,
        cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
        fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
        activo: activo ?? this.activo,
      );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      categoriaId:
          data.categoriaId.present ? data.categoriaId.value : this.categoriaId,
      viajeId: data.viajeId.present ? data.viajeId.value : this.viajeId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      comisionViaje: data.comisionViaje.present
          ? data.comisionViaje.value
          : this.comisionViaje,
      precioVenta:
          data.precioVenta.present ? data.precioVenta.value : this.precioVenta,
      cantidadDisponible: data.cantidadDisponible.present
          ? data.cantidadDisponible.value
          : this.cantidadDisponible,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('viajeId: $viajeId, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('comisionViaje: $comisionViaje, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('cantidadDisponible: $cantidadDisponible, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      categoriaId,
      viajeId,
      nombre,
      descripcion,
      precioCompra,
      comisionViaje,
      precioVenta,
      cantidadDisponible,
      fotoPath,
      activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.categoriaId == this.categoriaId &&
          other.viajeId == this.viajeId &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.precioCompra == this.precioCompra &&
          other.comisionViaje == this.comisionViaje &&
          other.precioVenta == this.precioVenta &&
          other.cantidadDisponible == this.cantidadDisponible &&
          other.fotoPath == this.fotoPath &&
          other.activo == this.activo);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<int?> categoriaId;
  final Value<int?> viajeId;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<int?> precioCompra;
  final Value<int> comisionViaje;
  final Value<int?> precioVenta;
  final Value<int> cantidadDisponible;
  final Value<String?> fotoPath;
  final Value<bool> activo;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.viajeId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.comisionViaje = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.cantidadDisponible = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.activo = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.viajeId = const Value.absent(),
    required String nombre,
    this.descripcion = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.comisionViaje = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.cantidadDisponible = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.activo = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Producto> custom({
    Expression<int>? id,
    Expression<int>? categoriaId,
    Expression<int>? viajeId,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<int>? precioCompra,
    Expression<int>? comisionViaje,
    Expression<int>? precioVenta,
    Expression<int>? cantidadDisponible,
    Expression<String>? fotoPath,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (viajeId != null) 'viaje_id': viajeId,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (comisionViaje != null) 'comision_viaje': comisionViaje,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (cantidadDisponible != null) 'cantidad_disponible': cantidadDisponible,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (activo != null) 'activo': activo,
    });
  }

  ProductosCompanion copyWith(
      {Value<int>? id,
      Value<int?>? categoriaId,
      Value<int?>? viajeId,
      Value<String>? nombre,
      Value<String?>? descripcion,
      Value<int?>? precioCompra,
      Value<int>? comisionViaje,
      Value<int?>? precioVenta,
      Value<int>? cantidadDisponible,
      Value<String?>? fotoPath,
      Value<bool>? activo}) {
    return ProductosCompanion(
      id: id ?? this.id,
      categoriaId: categoriaId ?? this.categoriaId,
      viajeId: viajeId ?? this.viajeId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioCompra: precioCompra ?? this.precioCompra,
      comisionViaje: comisionViaje ?? this.comisionViaje,
      precioVenta: precioVenta ?? this.precioVenta,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      fotoPath: fotoPath ?? this.fotoPath,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (viajeId.present) {
      map['viaje_id'] = Variable<int>(viajeId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<int>(precioCompra.value);
    }
    if (comisionViaje.present) {
      map['comision_viaje'] = Variable<int>(comisionViaje.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<int>(precioVenta.value);
    }
    if (cantidadDisponible.present) {
      map['cantidad_disponible'] = Variable<int>(cantidadDisponible.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('viajeId: $viajeId, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('comisionViaje: $comisionViaje, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('cantidadDisponible: $cantidadDisponible, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $EncargosTable extends Encargos with TableInfo<$EncargosTable, Encargo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncargosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
      'cliente_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clientes (id)'));
  static const VerificationMeta _correlativoClienteMeta =
      const VerificationMeta('correlativoCliente');
  @override
  late final GeneratedColumn<int> correlativoCliente = GeneratedColumn<int>(
      'correlativo_cliente', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaEntregaEstimadaMeta =
      const VerificationMeta('fechaEntregaEstimada');
  @override
  late final GeneratedColumn<DateTime> fechaEntregaEstimada =
      GeneratedColumn<DateTime>('fecha_entrega_estimada', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tipoVentaMeta =
      const VerificationMeta('tipoVenta');
  @override
  late final GeneratedColumn<String> tipoVenta = GeneratedColumn<String>(
      'tipo_venta', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Por encargo'));
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clienteId,
        correlativoCliente,
        fecha,
        fechaEntregaEstimada,
        estado,
        observaciones,
        tipoVenta,
        activo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encargos';
  @override
  VerificationContext validateIntegrity(Insertable<Encargo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    }
    if (data.containsKey('correlativo_cliente')) {
      context.handle(
          _correlativoClienteMeta,
          correlativoCliente.isAcceptableOrUnknown(
              data['correlativo_cliente']!, _correlativoClienteMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('fecha_entrega_estimada')) {
      context.handle(
          _fechaEntregaEstimadaMeta,
          fechaEntregaEstimada.isAcceptableOrUnknown(
              data['fecha_entrega_estimada']!, _fechaEntregaEstimadaMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('tipo_venta')) {
      context.handle(_tipoVentaMeta,
          tipoVenta.isAcceptableOrUnknown(data['tipo_venta']!, _tipoVentaMeta));
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encargo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encargo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cliente_id']),
      correlativoCliente: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}correlativo_cliente'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      fechaEntregaEstimada: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}fecha_entrega_estimada']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      tipoVenta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_venta'])!,
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
    );
  }

  @override
  $EncargosTable createAlias(String alias) {
    return $EncargosTable(attachedDatabase, alias);
  }
}

class Encargo extends DataClass implements Insertable<Encargo> {
  final int id;
  final int? clienteId;

  /// Regla 8.6: Numeración local al cliente (ENC-1, ENC-2...)
  final int correlativoCliente;
  final DateTime fecha;
  final DateTime? fechaEntregaEstimada;
  final String estado;
  final String? observaciones;
  final String tipoVenta;
  final bool activo;
  const Encargo(
      {required this.id,
      this.clienteId,
      required this.correlativoCliente,
      required this.fecha,
      this.fechaEntregaEstimada,
      required this.estado,
      this.observaciones,
      required this.tipoVenta,
      required this.activo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<int>(clienteId);
    }
    map['correlativo_cliente'] = Variable<int>(correlativoCliente);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || fechaEntregaEstimada != null) {
      map['fecha_entrega_estimada'] = Variable<DateTime>(fechaEntregaEstimada);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['tipo_venta'] = Variable<String>(tipoVenta);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  EncargosCompanion toCompanion(bool nullToAbsent) {
    return EncargosCompanion(
      id: Value(id),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      correlativoCliente: Value(correlativoCliente),
      fecha: Value(fecha),
      fechaEntregaEstimada: fechaEntregaEstimada == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaEntregaEstimada),
      estado: Value(estado),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      tipoVenta: Value(tipoVenta),
      activo: Value(activo),
    );
  }

  factory Encargo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encargo(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int?>(json['clienteId']),
      correlativoCliente: serializer.fromJson<int>(json['correlativoCliente']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      fechaEntregaEstimada:
          serializer.fromJson<DateTime?>(json['fechaEntregaEstimada']),
      estado: serializer.fromJson<String>(json['estado']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      tipoVenta: serializer.fromJson<String>(json['tipoVenta']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int?>(clienteId),
      'correlativoCliente': serializer.toJson<int>(correlativoCliente),
      'fecha': serializer.toJson<DateTime>(fecha),
      'fechaEntregaEstimada':
          serializer.toJson<DateTime?>(fechaEntregaEstimada),
      'estado': serializer.toJson<String>(estado),
      'observaciones': serializer.toJson<String?>(observaciones),
      'tipoVenta': serializer.toJson<String>(tipoVenta),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Encargo copyWith(
          {int? id,
          Value<int?> clienteId = const Value.absent(),
          int? correlativoCliente,
          DateTime? fecha,
          Value<DateTime?> fechaEntregaEstimada = const Value.absent(),
          String? estado,
          Value<String?> observaciones = const Value.absent(),
          String? tipoVenta,
          bool? activo}) =>
      Encargo(
        id: id ?? this.id,
        clienteId: clienteId.present ? clienteId.value : this.clienteId,
        correlativoCliente: correlativoCliente ?? this.correlativoCliente,
        fecha: fecha ?? this.fecha,
        fechaEntregaEstimada: fechaEntregaEstimada.present
            ? fechaEntregaEstimada.value
            : this.fechaEntregaEstimada,
        estado: estado ?? this.estado,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        tipoVenta: tipoVenta ?? this.tipoVenta,
        activo: activo ?? this.activo,
      );
  Encargo copyWithCompanion(EncargosCompanion data) {
    return Encargo(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      correlativoCliente: data.correlativoCliente.present
          ? data.correlativoCliente.value
          : this.correlativoCliente,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      fechaEntregaEstimada: data.fechaEntregaEstimada.present
          ? data.fechaEntregaEstimada.value
          : this.fechaEntregaEstimada,
      estado: data.estado.present ? data.estado.value : this.estado,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      tipoVenta: data.tipoVenta.present ? data.tipoVenta.value : this.tipoVenta,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encargo(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('correlativoCliente: $correlativoCliente, ')
          ..write('fecha: $fecha, ')
          ..write('fechaEntregaEstimada: $fechaEntregaEstimada, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones, ')
          ..write('tipoVenta: $tipoVenta, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clienteId, correlativoCliente, fecha,
      fechaEntregaEstimada, estado, observaciones, tipoVenta, activo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encargo &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.correlativoCliente == this.correlativoCliente &&
          other.fecha == this.fecha &&
          other.fechaEntregaEstimada == this.fechaEntregaEstimada &&
          other.estado == this.estado &&
          other.observaciones == this.observaciones &&
          other.tipoVenta == this.tipoVenta &&
          other.activo == this.activo);
}

class EncargosCompanion extends UpdateCompanion<Encargo> {
  final Value<int> id;
  final Value<int?> clienteId;
  final Value<int> correlativoCliente;
  final Value<DateTime> fecha;
  final Value<DateTime?> fechaEntregaEstimada;
  final Value<String> estado;
  final Value<String?> observaciones;
  final Value<String> tipoVenta;
  final Value<bool> activo;
  const EncargosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.correlativoCliente = const Value.absent(),
    this.fecha = const Value.absent(),
    this.fechaEntregaEstimada = const Value.absent(),
    this.estado = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.tipoVenta = const Value.absent(),
    this.activo = const Value.absent(),
  });
  EncargosCompanion.insert({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.correlativoCliente = const Value.absent(),
    required DateTime fecha,
    this.fechaEntregaEstimada = const Value.absent(),
    required String estado,
    this.observaciones = const Value.absent(),
    this.tipoVenta = const Value.absent(),
    this.activo = const Value.absent(),
  })  : fecha = Value(fecha),
        estado = Value(estado);
  static Insertable<Encargo> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<int>? correlativoCliente,
    Expression<DateTime>? fecha,
    Expression<DateTime>? fechaEntregaEstimada,
    Expression<String>? estado,
    Expression<String>? observaciones,
    Expression<String>? tipoVenta,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (correlativoCliente != null) 'correlativo_cliente': correlativoCliente,
      if (fecha != null) 'fecha': fecha,
      if (fechaEntregaEstimada != null)
        'fecha_entrega_estimada': fechaEntregaEstimada,
      if (estado != null) 'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
      if (tipoVenta != null) 'tipo_venta': tipoVenta,
      if (activo != null) 'activo': activo,
    });
  }

  EncargosCompanion copyWith(
      {Value<int>? id,
      Value<int?>? clienteId,
      Value<int>? correlativoCliente,
      Value<DateTime>? fecha,
      Value<DateTime?>? fechaEntregaEstimada,
      Value<String>? estado,
      Value<String?>? observaciones,
      Value<String>? tipoVenta,
      Value<bool>? activo}) {
    return EncargosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      correlativoCliente: correlativoCliente ?? this.correlativoCliente,
      fecha: fecha ?? this.fecha,
      fechaEntregaEstimada: fechaEntregaEstimada ?? this.fechaEntregaEstimada,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (correlativoCliente.present) {
      map['correlativo_cliente'] = Variable<int>(correlativoCliente.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (fechaEntregaEstimada.present) {
      map['fecha_entrega_estimada'] =
          Variable<DateTime>(fechaEntregaEstimada.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (tipoVenta.present) {
      map['tipo_venta'] = Variable<String>(tipoVenta.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncargosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('correlativoCliente: $correlativoCliente, ')
          ..write('fecha: $fecha, ')
          ..write('fechaEntregaEstimada: $fechaEntregaEstimada, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones, ')
          ..write('tipoVenta: $tipoVenta, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $EncargoDetalleTable extends EncargoDetalle
    with TableInfo<$EncargoDetalleTable, EncargoDetalleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncargoDetalleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _encargoIdMeta =
      const VerificationMeta('encargoId');
  @override
  late final GeneratedColumn<int> encargoId = GeneratedColumn<int>(
      'encargo_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES encargos (id)'));
  static const VerificationMeta _productoIdMeta =
      const VerificationMeta('productoId');
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
      'producto_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES productos (id)'));
  static const VerificationMeta _nombreTemporalMeta =
      const VerificationMeta('nombreTemporal');
  @override
  late final GeneratedColumn<String> nombreTemporal = GeneratedColumn<String>(
      'nombre_temporal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _precioUnitarioMeta =
      const VerificationMeta('precioUnitario');
  @override
  late final GeneratedColumn<int> precioUnitario = GeneratedColumn<int>(
      'precio_unitario', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _costoUnitarioMeta =
      const VerificationMeta('costoUnitario');
  @override
  late final GeneratedColumn<int> costoUnitario = GeneratedColumn<int>(
      'costo_unitario', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        encargoId,
        productoId,
        nombreTemporal,
        cantidad,
        precioUnitario,
        costoUnitario
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encargo_detalle';
  @override
  VerificationContext validateIntegrity(Insertable<EncargoDetalleData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('encargo_id')) {
      context.handle(_encargoIdMeta,
          encargoId.isAcceptableOrUnknown(data['encargo_id']!, _encargoIdMeta));
    } else if (isInserting) {
      context.missing(_encargoIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
          _productoIdMeta,
          productoId.isAcceptableOrUnknown(
              data['producto_id']!, _productoIdMeta));
    }
    if (data.containsKey('nombre_temporal')) {
      context.handle(
          _nombreTemporalMeta,
          nombreTemporal.isAcceptableOrUnknown(
              data['nombre_temporal']!, _nombreTemporalMeta));
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
          _precioUnitarioMeta,
          precioUnitario.isAcceptableOrUnknown(
              data['precio_unitario']!, _precioUnitarioMeta));
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
          _costoUnitarioMeta,
          costoUnitario.isAcceptableOrUnknown(
              data['costo_unitario']!, _costoUnitarioMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EncargoDetalleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncargoDetalleData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      encargoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}encargo_id'])!,
      productoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}producto_id']),
      nombreTemporal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre_temporal']),
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cantidad'])!,
      precioUnitario: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}precio_unitario']),
      costoUnitario: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}costo_unitario']),
    );
  }

  @override
  $EncargoDetalleTable createAlias(String alias) {
    return $EncargoDetalleTable(attachedDatabase, alias);
  }
}

class EncargoDetalleData extends DataClass
    implements Insertable<EncargoDetalleData> {
  final int id;
  final int encargoId;
  final int? productoId;
  final String? nombreTemporal;
  final int cantidad;
  final int? precioUnitario;
  final int? costoUnitario;
  const EncargoDetalleData(
      {required this.id,
      required this.encargoId,
      this.productoId,
      this.nombreTemporal,
      required this.cantidad,
      this.precioUnitario,
      this.costoUnitario});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['encargo_id'] = Variable<int>(encargoId);
    if (!nullToAbsent || productoId != null) {
      map['producto_id'] = Variable<int>(productoId);
    }
    if (!nullToAbsent || nombreTemporal != null) {
      map['nombre_temporal'] = Variable<String>(nombreTemporal);
    }
    map['cantidad'] = Variable<int>(cantidad);
    if (!nullToAbsent || precioUnitario != null) {
      map['precio_unitario'] = Variable<int>(precioUnitario);
    }
    if (!nullToAbsent || costoUnitario != null) {
      map['costo_unitario'] = Variable<int>(costoUnitario);
    }
    return map;
  }

  EncargoDetalleCompanion toCompanion(bool nullToAbsent) {
    return EncargoDetalleCompanion(
      id: Value(id),
      encargoId: Value(encargoId),
      productoId: productoId == null && nullToAbsent
          ? const Value.absent()
          : Value(productoId),
      nombreTemporal: nombreTemporal == null && nullToAbsent
          ? const Value.absent()
          : Value(nombreTemporal),
      cantidad: Value(cantidad),
      precioUnitario: precioUnitario == null && nullToAbsent
          ? const Value.absent()
          : Value(precioUnitario),
      costoUnitario: costoUnitario == null && nullToAbsent
          ? const Value.absent()
          : Value(costoUnitario),
    );
  }

  factory EncargoDetalleData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncargoDetalleData(
      id: serializer.fromJson<int>(json['id']),
      encargoId: serializer.fromJson<int>(json['encargoId']),
      productoId: serializer.fromJson<int?>(json['productoId']),
      nombreTemporal: serializer.fromJson<String?>(json['nombreTemporal']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<int?>(json['precioUnitario']),
      costoUnitario: serializer.fromJson<int?>(json['costoUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'encargoId': serializer.toJson<int>(encargoId),
      'productoId': serializer.toJson<int?>(productoId),
      'nombreTemporal': serializer.toJson<String?>(nombreTemporal),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<int?>(precioUnitario),
      'costoUnitario': serializer.toJson<int?>(costoUnitario),
    };
  }

  EncargoDetalleData copyWith(
          {int? id,
          int? encargoId,
          Value<int?> productoId = const Value.absent(),
          Value<String?> nombreTemporal = const Value.absent(),
          int? cantidad,
          Value<int?> precioUnitario = const Value.absent(),
          Value<int?> costoUnitario = const Value.absent()}) =>
      EncargoDetalleData(
        id: id ?? this.id,
        encargoId: encargoId ?? this.encargoId,
        productoId: productoId.present ? productoId.value : this.productoId,
        nombreTemporal:
            nombreTemporal.present ? nombreTemporal.value : this.nombreTemporal,
        cantidad: cantidad ?? this.cantidad,
        precioUnitario:
            precioUnitario.present ? precioUnitario.value : this.precioUnitario,
        costoUnitario:
            costoUnitario.present ? costoUnitario.value : this.costoUnitario,
      );
  EncargoDetalleData copyWithCompanion(EncargoDetalleCompanion data) {
    return EncargoDetalleData(
      id: data.id.present ? data.id.value : this.id,
      encargoId: data.encargoId.present ? data.encargoId.value : this.encargoId,
      productoId:
          data.productoId.present ? data.productoId.value : this.productoId,
      nombreTemporal: data.nombreTemporal.present
          ? data.nombreTemporal.value
          : this.nombreTemporal,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncargoDetalleData(')
          ..write('id: $id, ')
          ..write('encargoId: $encargoId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreTemporal: $nombreTemporal, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('costoUnitario: $costoUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, encargoId, productoId, nombreTemporal,
      cantidad, precioUnitario, costoUnitario);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncargoDetalleData &&
          other.id == this.id &&
          other.encargoId == this.encargoId &&
          other.productoId == this.productoId &&
          other.nombreTemporal == this.nombreTemporal &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.costoUnitario == this.costoUnitario);
}

class EncargoDetalleCompanion extends UpdateCompanion<EncargoDetalleData> {
  final Value<int> id;
  final Value<int> encargoId;
  final Value<int?> productoId;
  final Value<String?> nombreTemporal;
  final Value<int> cantidad;
  final Value<int?> precioUnitario;
  final Value<int?> costoUnitario;
  const EncargoDetalleCompanion({
    this.id = const Value.absent(),
    this.encargoId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreTemporal = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.costoUnitario = const Value.absent(),
  });
  EncargoDetalleCompanion.insert({
    this.id = const Value.absent(),
    required int encargoId,
    this.productoId = const Value.absent(),
    this.nombreTemporal = const Value.absent(),
    required int cantidad,
    this.precioUnitario = const Value.absent(),
    this.costoUnitario = const Value.absent(),
  })  : encargoId = Value(encargoId),
        cantidad = Value(cantidad);
  static Insertable<EncargoDetalleData> custom({
    Expression<int>? id,
    Expression<int>? encargoId,
    Expression<int>? productoId,
    Expression<String>? nombreTemporal,
    Expression<int>? cantidad,
    Expression<int>? precioUnitario,
    Expression<int>? costoUnitario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encargoId != null) 'encargo_id': encargoId,
      if (productoId != null) 'producto_id': productoId,
      if (nombreTemporal != null) 'nombre_temporal': nombreTemporal,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
    });
  }

  EncargoDetalleCompanion copyWith(
      {Value<int>? id,
      Value<int>? encargoId,
      Value<int?>? productoId,
      Value<String?>? nombreTemporal,
      Value<int>? cantidad,
      Value<int?>? precioUnitario,
      Value<int?>? costoUnitario}) {
    return EncargoDetalleCompanion(
      id: id ?? this.id,
      encargoId: encargoId ?? this.encargoId,
      productoId: productoId ?? this.productoId,
      nombreTemporal: nombreTemporal ?? this.nombreTemporal,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      costoUnitario: costoUnitario ?? this.costoUnitario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (encargoId.present) {
      map['encargo_id'] = Variable<int>(encargoId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombreTemporal.present) {
      map['nombre_temporal'] = Variable<String>(nombreTemporal.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<int>(precioUnitario.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<int>(costoUnitario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncargoDetalleCompanion(')
          ..write('id: $id, ')
          ..write('encargoId: $encargoId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreTemporal: $nombreTemporal, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('costoUnitario: $costoUnitario')
          ..write(')'))
        .toString();
  }
}

class $PagosTable extends Pagos with TableInfo<$PagosTable, Pago> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
      'cliente_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clientes (id)'));
  static const VerificationMeta _encargoIdMeta =
      const VerificationMeta('encargoId');
  @override
  late final GeneratedColumn<int> encargoId = GeneratedColumn<int>(
      'encargo_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES encargos (id)'));
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
      'monto', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _metodoMeta = const VerificationMeta('metodo');
  @override
  late final GeneratedColumn<String> metodo = GeneratedColumn<String>(
      'metodo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conceptoMeta =
      const VerificationMeta('concepto');
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
      'concepto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, clienteId, encargoId, monto, fecha, metodo, tipo, concepto];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos';
  @override
  VerificationContext validateIntegrity(Insertable<Pago> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('encargo_id')) {
      context.handle(_encargoIdMeta,
          encargoId.isAcceptableOrUnknown(data['encargo_id']!, _encargoIdMeta));
    }
    if (data.containsKey('monto')) {
      context.handle(
          _montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('metodo')) {
      context.handle(_metodoMeta,
          metodo.isAcceptableOrUnknown(data['metodo']!, _metodoMeta));
    } else if (isInserting) {
      context.missing(_metodoMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(_conceptoMeta,
          concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pago map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pago(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cliente_id'])!,
      encargoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}encargo_id']),
      monto: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monto'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      metodo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      concepto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concepto']),
    );
  }

  @override
  $PagosTable createAlias(String alias) {
    return $PagosTable(attachedDatabase, alias);
  }
}

class Pago extends DataClass implements Insertable<Pago> {
  final int id;
  final int clienteId;
  final int? encargoId;
  final int monto;
  final DateTime fecha;
  final String metodo;
  final String tipo;
  final String? concepto;
  const Pago(
      {required this.id,
      required this.clienteId,
      this.encargoId,
      required this.monto,
      required this.fecha,
      required this.metodo,
      required this.tipo,
      this.concepto});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    if (!nullToAbsent || encargoId != null) {
      map['encargo_id'] = Variable<int>(encargoId);
    }
    map['monto'] = Variable<int>(monto);
    map['fecha'] = Variable<DateTime>(fecha);
    map['metodo'] = Variable<String>(metodo);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || concepto != null) {
      map['concepto'] = Variable<String>(concepto);
    }
    return map;
  }

  PagosCompanion toCompanion(bool nullToAbsent) {
    return PagosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      encargoId: encargoId == null && nullToAbsent
          ? const Value.absent()
          : Value(encargoId),
      monto: Value(monto),
      fecha: Value(fecha),
      metodo: Value(metodo),
      tipo: Value(tipo),
      concepto: concepto == null && nullToAbsent
          ? const Value.absent()
          : Value(concepto),
    );
  }

  factory Pago.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pago(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      encargoId: serializer.fromJson<int?>(json['encargoId']),
      monto: serializer.fromJson<int>(json['monto']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      metodo: serializer.fromJson<String>(json['metodo']),
      tipo: serializer.fromJson<String>(json['tipo']),
      concepto: serializer.fromJson<String?>(json['concepto']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'encargoId': serializer.toJson<int?>(encargoId),
      'monto': serializer.toJson<int>(monto),
      'fecha': serializer.toJson<DateTime>(fecha),
      'metodo': serializer.toJson<String>(metodo),
      'tipo': serializer.toJson<String>(tipo),
      'concepto': serializer.toJson<String?>(concepto),
    };
  }

  Pago copyWith(
          {int? id,
          int? clienteId,
          Value<int?> encargoId = const Value.absent(),
          int? monto,
          DateTime? fecha,
          String? metodo,
          String? tipo,
          Value<String?> concepto = const Value.absent()}) =>
      Pago(
        id: id ?? this.id,
        clienteId: clienteId ?? this.clienteId,
        encargoId: encargoId.present ? encargoId.value : this.encargoId,
        monto: monto ?? this.monto,
        fecha: fecha ?? this.fecha,
        metodo: metodo ?? this.metodo,
        tipo: tipo ?? this.tipo,
        concepto: concepto.present ? concepto.value : this.concepto,
      );
  Pago copyWithCompanion(PagosCompanion data) {
    return Pago(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      encargoId: data.encargoId.present ? data.encargoId.value : this.encargoId,
      monto: data.monto.present ? data.monto.value : this.monto,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      metodo: data.metodo.present ? data.metodo.value : this.metodo,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pago(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('encargoId: $encargoId, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('metodo: $metodo, ')
          ..write('tipo: $tipo, ')
          ..write('concepto: $concepto')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, clienteId, encargoId, monto, fecha, metodo, tipo, concepto);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pago &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.encargoId == this.encargoId &&
          other.monto == this.monto &&
          other.fecha == this.fecha &&
          other.metodo == this.metodo &&
          other.tipo == this.tipo &&
          other.concepto == this.concepto);
}

class PagosCompanion extends UpdateCompanion<Pago> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<int?> encargoId;
  final Value<int> monto;
  final Value<DateTime> fecha;
  final Value<String> metodo;
  final Value<String> tipo;
  final Value<String?> concepto;
  const PagosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.encargoId = const Value.absent(),
    this.monto = const Value.absent(),
    this.fecha = const Value.absent(),
    this.metodo = const Value.absent(),
    this.tipo = const Value.absent(),
    this.concepto = const Value.absent(),
  });
  PagosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    this.encargoId = const Value.absent(),
    required int monto,
    required DateTime fecha,
    required String metodo,
    required String tipo,
    this.concepto = const Value.absent(),
  })  : clienteId = Value(clienteId),
        monto = Value(monto),
        fecha = Value(fecha),
        metodo = Value(metodo),
        tipo = Value(tipo);
  static Insertable<Pago> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<int>? encargoId,
    Expression<int>? monto,
    Expression<DateTime>? fecha,
    Expression<String>? metodo,
    Expression<String>? tipo,
    Expression<String>? concepto,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (encargoId != null) 'encargo_id': encargoId,
      if (monto != null) 'monto': monto,
      if (fecha != null) 'fecha': fecha,
      if (metodo != null) 'metodo': metodo,
      if (tipo != null) 'tipo': tipo,
      if (concepto != null) 'concepto': concepto,
    });
  }

  PagosCompanion copyWith(
      {Value<int>? id,
      Value<int>? clienteId,
      Value<int?>? encargoId,
      Value<int>? monto,
      Value<DateTime>? fecha,
      Value<String>? metodo,
      Value<String>? tipo,
      Value<String?>? concepto}) {
    return PagosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      encargoId: encargoId ?? this.encargoId,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      metodo: metodo ?? this.metodo,
      tipo: tipo ?? this.tipo,
      concepto: concepto ?? this.concepto,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (encargoId.present) {
      map['encargo_id'] = Variable<int>(encargoId.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (metodo.present) {
      map['metodo'] = Variable<String>(metodo.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('encargoId: $encargoId, ')
          ..write('monto: $monto, ')
          ..write('fecha: $fecha, ')
          ..write('metodo: $metodo, ')
          ..write('tipo: $tipo, ')
          ..write('concepto: $concepto')
          ..write(')'))
        .toString();
  }
}

class $PerfilUsuarioTable extends PerfilUsuario
    with TableInfo<$PerfilUsuarioTable, PerfilUsuarioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PerfilUsuarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaNacimientoMeta =
      const VerificationMeta('fechaNacimiento');
  @override
  late final GeneratedColumn<DateTime> fechaNacimiento =
      GeneratedColumn<DateTime>('fecha_nacimiento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, nombre, fechaNacimiento];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'perfil_usuario';
  @override
  VerificationContext validateIntegrity(Insertable<PerfilUsuarioData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('fecha_nacimiento')) {
      context.handle(
          _fechaNacimientoMeta,
          fechaNacimiento.isAcceptableOrUnknown(
              data['fecha_nacimiento']!, _fechaNacimientoMeta));
    } else if (isInserting) {
      context.missing(_fechaNacimientoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PerfilUsuarioData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PerfilUsuarioData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      fechaNacimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_nacimiento'])!,
    );
  }

  @override
  $PerfilUsuarioTable createAlias(String alias) {
    return $PerfilUsuarioTable(attachedDatabase, alias);
  }
}

class PerfilUsuarioData extends DataClass
    implements Insertable<PerfilUsuarioData> {
  final int id;
  final String nombre;
  final DateTime fechaNacimiento;
  const PerfilUsuarioData(
      {required this.id, required this.nombre, required this.fechaNacimiento});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['fecha_nacimiento'] = Variable<DateTime>(fechaNacimiento);
    return map;
  }

  PerfilUsuarioCompanion toCompanion(bool nullToAbsent) {
    return PerfilUsuarioCompanion(
      id: Value(id),
      nombre: Value(nombre),
      fechaNacimiento: Value(fechaNacimiento),
    );
  }

  factory PerfilUsuarioData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PerfilUsuarioData(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      fechaNacimiento: serializer.fromJson<DateTime>(json['fechaNacimiento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'fechaNacimiento': serializer.toJson<DateTime>(fechaNacimiento),
    };
  }

  PerfilUsuarioData copyWith(
          {int? id, String? nombre, DateTime? fechaNacimiento}) =>
      PerfilUsuarioData(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      );
  PerfilUsuarioData copyWithCompanion(PerfilUsuarioCompanion data) {
    return PerfilUsuarioData(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      fechaNacimiento: data.fechaNacimiento.present
          ? data.fechaNacimiento.value
          : this.fechaNacimiento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PerfilUsuarioData(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fechaNacimiento: $fechaNacimiento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, fechaNacimiento);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PerfilUsuarioData &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.fechaNacimiento == this.fechaNacimiento);
}

class PerfilUsuarioCompanion extends UpdateCompanion<PerfilUsuarioData> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<DateTime> fechaNacimiento;
  const PerfilUsuarioCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.fechaNacimiento = const Value.absent(),
  });
  PerfilUsuarioCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required DateTime fechaNacimiento,
  })  : nombre = Value(nombre),
        fechaNacimiento = Value(fechaNacimiento);
  static Insertable<PerfilUsuarioData> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<DateTime>? fechaNacimiento,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (fechaNacimiento != null) 'fecha_nacimiento': fechaNacimiento,
    });
  }

  PerfilUsuarioCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<DateTime>? fechaNacimiento}) {
    return PerfilUsuarioCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (fechaNacimiento.present) {
      map['fecha_nacimiento'] = Variable<DateTime>(fechaNacimiento.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PerfilUsuarioCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('fechaNacimiento: $fechaNacimiento')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $ViajesTable viajes = $ViajesTable(this);
  late final $GastosTable gastos = $GastosTable(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $EncargosTable encargos = $EncargosTable(this);
  late final $EncargoDetalleTable encargoDetalle = $EncargoDetalleTable(this);
  late final $PagosTable pagos = $PagosTable(this);
  late final $PerfilUsuarioTable perfilUsuario = $PerfilUsuarioTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        clientes,
        categorias,
        viajes,
        gastos,
        productos,
        encargos,
        encargoDetalle,
        pagos,
        perfilUsuario
      ];
}

typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  required String nombre,
  Value<String?> telefono,
  Value<String?> email,
  Value<String?> direccion,
  Value<String?> observaciones,
  required DateTime fechaRegistro,
  Value<bool> activo,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String?> telefono,
  Value<String?> email,
  Value<String?> direccion,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
  Value<bool> activo,
});

final class $$ClientesTableReferences
    extends BaseReferences<_$AppDatabase, $ClientesTable, ClienteRow> {
  $$ClientesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EncargosTable, List<Encargo>> _encargosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.encargos,
          aliasName: 'clientes__id__encargos__cliente_id');

  $$EncargosTableProcessedTableManager get encargosRefs {
    final manager = $$EncargosTableTableManager($_db, $_db.encargos)
        .filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_encargosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pagos,
          aliasName: 'clientes__id__pagos__cliente_id');

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  Expression<bool> encargosRefs(
      Expression<bool> Function($$EncargosTableFilterComposer f) f) {
    final $$EncargosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableFilterComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pagosRefs(
      Expression<bool> Function($$PagosTableFilterComposer f) f) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  Expression<T> encargosRefs<T extends Object>(
      Expression<T> Function($$EncargosTableAnnotationComposer a) f) {
    final $$EncargosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableAnnotationComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
      Expression<T> Function($$PagosTableAnnotationComposer a) f) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientesTable,
    ClienteRow,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (ClienteRow, $$ClientesTableReferences),
    ClienteRow,
    PrefetchHooks Function({bool encargosRefs, bool pagosRefs})> {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
            Value<bool> activo = const Value.absent(),
          }) =>
              ClientesCompanion(
            id: id,
            nombre: nombre,
            telefono: telefono,
            email: email,
            direccion: direccion,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
            activo: activo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            Value<String?> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            required DateTime fechaRegistro,
            Value<bool> activo = const Value.absent(),
          }) =>
              ClientesCompanion.insert(
            id: id,
            nombre: nombre,
            telefono: telefono,
            email: email,
            direccion: direccion,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
            activo: activo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClientesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({encargosRefs = false, pagosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (encargosRefs) db.encargos,
                if (pagosRefs) db.pagos
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (encargosRefs)
                    await $_getPrefetchedData<ClienteRow, $ClientesTable,
                            Encargo>(
                        currentTable: table,
                        referencedTable:
                            $$ClientesTableReferences._encargosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientesTableReferences(db, table, p0)
                                .encargosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.clienteId == item.id),
                        typedResults: items),
                  if (pagosRefs)
                    await $_getPrefetchedData<ClienteRow, $ClientesTable, Pago>(
                        currentTable: table,
                        referencedTable:
                            $$ClientesTableReferences._pagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientesTableReferences(db, table, p0).pagosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.clienteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClientesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientesTable,
    ClienteRow,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (ClienteRow, $$ClientesTableReferences),
    ClienteRow,
    PrefetchHooks Function({bool encargosRefs, bool pagosRefs})>;
typedef $$CategoriasTableCreateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  required String nombre,
});
typedef $$CategoriasTableUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  Value<String> nombre,
});

final class $$CategoriasTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriasTable, Categoria> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductosTable, List<Producto>>
      _productosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.productos,
              aliasName: 'categorias__id__productos__categoria_id');

  $$ProductosTableProcessedTableManager get productosRefs {
    final manager = $$ProductosTableTableManager($_db, $_db.productos)
        .filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  Expression<bool> productosRefs(
      Expression<bool> Function($$ProductosTableFilterComposer f) f) {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableFilterComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  Expression<T> productosRefs<T extends Object>(
      Expression<T> Function($$ProductosTableAnnotationComposer a) f) {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.categoriaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableAnnotationComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriasTable,
    Categoria,
    $$CategoriasTableFilterComposer,
    $$CategoriasTableOrderingComposer,
    $$CategoriasTableAnnotationComposer,
    $$CategoriasTableCreateCompanionBuilder,
    $$CategoriasTableUpdateCompanionBuilder,
    (Categoria, $$CategoriasTableReferences),
    Categoria,
    PrefetchHooks Function({bool productosRefs})> {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
          }) =>
              CategoriasCompanion(
            id: id,
            nombre: nombre,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
          }) =>
              CategoriasCompanion.insert(
            id: id,
            nombre: nombre,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriasTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productosRefs) db.productos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productosRefs)
                    await $_getPrefetchedData<Categoria, $CategoriasTable,
                            Producto>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriasTableReferences._productosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriasTableReferences(db, table, p0)
                                .productosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoriaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriasTable,
    Categoria,
    $$CategoriasTableFilterComposer,
    $$CategoriasTableOrderingComposer,
    $$CategoriasTableAnnotationComposer,
    $$CategoriasTableCreateCompanionBuilder,
    $$CategoriasTableUpdateCompanionBuilder,
    (Categoria, $$CategoriasTableReferences),
    Categoria,
    PrefetchHooks Function({bool productosRefs})>;
typedef $$ViajesTableCreateCompanionBuilder = ViajesCompanion Function({
  Value<int> id,
  required DateTime fecha,
  required String destino,
  Value<String?> observaciones,
  Value<bool> distribuido,
});
typedef $$ViajesTableUpdateCompanionBuilder = ViajesCompanion Function({
  Value<int> id,
  Value<DateTime> fecha,
  Value<String> destino,
  Value<String?> observaciones,
  Value<bool> distribuido,
});

final class $$ViajesTableReferences
    extends BaseReferences<_$AppDatabase, $ViajesTable, Viaje> {
  $$ViajesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GastosTable, List<Gasto>> _gastosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.gastos,
          aliasName: 'viajes__id__gastos__viaje_id');

  $$GastosTableProcessedTableManager get gastosRefs {
    final manager = $$GastosTableTableManager($_db, $_db.gastos)
        .filter((f) => f.viajeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gastosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProductosTable, List<Producto>>
      _productosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.productos,
              aliasName: 'viajes__id__productos__viaje_id');

  $$ProductosTableProcessedTableManager get productosRefs {
    final manager = $$ProductosTableTableManager($_db, $_db.productos)
        .filter((f) => f.viajeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ViajesTableFilterComposer
    extends Composer<_$AppDatabase, $ViajesTable> {
  $$ViajesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destino => $composableBuilder(
      column: $table.destino, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get distribuido => $composableBuilder(
      column: $table.distribuido, builder: (column) => ColumnFilters(column));

  Expression<bool> gastosRefs(
      Expression<bool> Function($$GastosTableFilterComposer f) f) {
    final $$GastosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gastos,
        getReferencedColumn: (t) => t.viajeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GastosTableFilterComposer(
              $db: $db,
              $table: $db.gastos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> productosRefs(
      Expression<bool> Function($$ProductosTableFilterComposer f) f) {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.viajeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableFilterComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ViajesTableOrderingComposer
    extends Composer<_$AppDatabase, $ViajesTable> {
  $$ViajesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destino => $composableBuilder(
      column: $table.destino, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get distribuido => $composableBuilder(
      column: $table.distribuido, builder: (column) => ColumnOrderings(column));
}

class $$ViajesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ViajesTable> {
  $$ViajesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get destino =>
      $composableBuilder(column: $table.destino, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<bool> get distribuido => $composableBuilder(
      column: $table.distribuido, builder: (column) => column);

  Expression<T> gastosRefs<T extends Object>(
      Expression<T> Function($$GastosTableAnnotationComposer a) f) {
    final $$GastosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gastos,
        getReferencedColumn: (t) => t.viajeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GastosTableAnnotationComposer(
              $db: $db,
              $table: $db.gastos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> productosRefs<T extends Object>(
      Expression<T> Function($$ProductosTableAnnotationComposer a) f) {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.viajeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableAnnotationComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ViajesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ViajesTable,
    Viaje,
    $$ViajesTableFilterComposer,
    $$ViajesTableOrderingComposer,
    $$ViajesTableAnnotationComposer,
    $$ViajesTableCreateCompanionBuilder,
    $$ViajesTableUpdateCompanionBuilder,
    (Viaje, $$ViajesTableReferences),
    Viaje,
    PrefetchHooks Function({bool gastosRefs, bool productosRefs})> {
  $$ViajesTableTableManager(_$AppDatabase db, $ViajesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ViajesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ViajesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ViajesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<String> destino = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<bool> distribuido = const Value.absent(),
          }) =>
              ViajesCompanion(
            id: id,
            fecha: fecha,
            destino: destino,
            observaciones: observaciones,
            distribuido: distribuido,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime fecha,
            required String destino,
            Value<String?> observaciones = const Value.absent(),
            Value<bool> distribuido = const Value.absent(),
          }) =>
              ViajesCompanion.insert(
            id: id,
            fecha: fecha,
            destino: destino,
            observaciones: observaciones,
            distribuido: distribuido,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ViajesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({gastosRefs = false, productosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gastosRefs) db.gastos,
                if (productosRefs) db.productos
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gastosRefs)
                    await $_getPrefetchedData<Viaje, $ViajesTable, Gasto>(
                        currentTable: table,
                        referencedTable:
                            $$ViajesTableReferences._gastosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ViajesTableReferences(db, table, p0).gastosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.viajeId == item.id),
                        typedResults: items),
                  if (productosRefs)
                    await $_getPrefetchedData<Viaje, $ViajesTable, Producto>(
                        currentTable: table,
                        referencedTable:
                            $$ViajesTableReferences._productosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ViajesTableReferences(db, table, p0)
                                .productosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.viajeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ViajesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ViajesTable,
    Viaje,
    $$ViajesTableFilterComposer,
    $$ViajesTableOrderingComposer,
    $$ViajesTableAnnotationComposer,
    $$ViajesTableCreateCompanionBuilder,
    $$ViajesTableUpdateCompanionBuilder,
    (Viaje, $$ViajesTableReferences),
    Viaje,
    PrefetchHooks Function({bool gastosRefs, bool productosRefs})>;
typedef $$GastosTableCreateCompanionBuilder = GastosCompanion Function({
  Value<int> id,
  required int viajeId,
  required String tipo,
  required int monto,
});
typedef $$GastosTableUpdateCompanionBuilder = GastosCompanion Function({
  Value<int> id,
  Value<int> viajeId,
  Value<String> tipo,
  Value<int> monto,
});

final class $$GastosTableReferences
    extends BaseReferences<_$AppDatabase, $GastosTable, Gasto> {
  $$GastosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ViajesTable _viajeIdTable(_$AppDatabase db) =>
      db.viajes.createAlias('gastos__viaje_id__viajes__id');

  $$ViajesTableProcessedTableManager get viajeId {
    final $_column = $_itemColumn<int>('viaje_id')!;

    final manager = $$ViajesTableTableManager($_db, $_db.viajes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_viajeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GastosTableFilterComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnFilters(column));

  $$ViajesTableFilterComposer get viajeId {
    final $$ViajesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.viajeId,
        referencedTable: $db.viajes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ViajesTableFilterComposer(
              $db: $db,
              $table: $db.viajes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GastosTableOrderingComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnOrderings(column));

  $$ViajesTableOrderingComposer get viajeId {
    final $$ViajesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.viajeId,
        referencedTable: $db.viajes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ViajesTableOrderingComposer(
              $db: $db,
              $table: $db.viajes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GastosTableAnnotationComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  $$ViajesTableAnnotationComposer get viajeId {
    final $$ViajesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.viajeId,
        referencedTable: $db.viajes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ViajesTableAnnotationComposer(
              $db: $db,
              $table: $db.viajes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GastosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GastosTable,
    Gasto,
    $$GastosTableFilterComposer,
    $$GastosTableOrderingComposer,
    $$GastosTableAnnotationComposer,
    $$GastosTableCreateCompanionBuilder,
    $$GastosTableUpdateCompanionBuilder,
    (Gasto, $$GastosTableReferences),
    Gasto,
    PrefetchHooks Function({bool viajeId})> {
  $$GastosTableTableManager(_$AppDatabase db, $GastosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> viajeId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<int> monto = const Value.absent(),
          }) =>
              GastosCompanion(
            id: id,
            viajeId: viajeId,
            tipo: tipo,
            monto: monto,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int viajeId,
            required String tipo,
            required int monto,
          }) =>
              GastosCompanion.insert(
            id: id,
            viajeId: viajeId,
            tipo: tipo,
            monto: monto,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GastosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({viajeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (viajeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.viajeId,
                    referencedTable: $$GastosTableReferences._viajeIdTable(db),
                    referencedColumn:
                        $$GastosTableReferences._viajeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GastosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GastosTable,
    Gasto,
    $$GastosTableFilterComposer,
    $$GastosTableOrderingComposer,
    $$GastosTableAnnotationComposer,
    $$GastosTableCreateCompanionBuilder,
    $$GastosTableUpdateCompanionBuilder,
    (Gasto, $$GastosTableReferences),
    Gasto,
    PrefetchHooks Function({bool viajeId})>;
typedef $$ProductosTableCreateCompanionBuilder = ProductosCompanion Function({
  Value<int> id,
  Value<int?> categoriaId,
  Value<int?> viajeId,
  required String nombre,
  Value<String?> descripcion,
  Value<int?> precioCompra,
  Value<int> comisionViaje,
  Value<int?> precioVenta,
  Value<int> cantidadDisponible,
  Value<String?> fotoPath,
  Value<bool> activo,
});
typedef $$ProductosTableUpdateCompanionBuilder = ProductosCompanion Function({
  Value<int> id,
  Value<int?> categoriaId,
  Value<int?> viajeId,
  Value<String> nombre,
  Value<String?> descripcion,
  Value<int?> precioCompra,
  Value<int> comisionViaje,
  Value<int?> precioVenta,
  Value<int> cantidadDisponible,
  Value<String?> fotoPath,
  Value<bool> activo,
});

final class $$ProductosTableReferences
    extends BaseReferences<_$AppDatabase, $ProductosTable, Producto> {
  $$ProductosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('productos__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager($_db, $_db.categorias)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ViajesTable _viajeIdTable(_$AppDatabase db) =>
      db.viajes.createAlias('productos__viaje_id__viajes__id');

  $$ViajesTableProcessedTableManager? get viajeId {
    final $_column = $_itemColumn<int>('viaje_id');
    if ($_column == null) return null;
    final manager = $$ViajesTableTableManager($_db, $_db.viajes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_viajeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EncargoDetalleTable, List<EncargoDetalleData>>
      _encargoDetalleRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.encargoDetalle,
              aliasName: 'productos__id__encargo_detalle__producto_id');

  $$EncargoDetalleTableProcessedTableManager get encargoDetalleRefs {
    final manager = $$EncargoDetalleTableTableManager($_db, $_db.encargoDetalle)
        .filter((f) => f.productoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_encargoDetalleRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get precioCompra => $composableBuilder(
      column: $table.precioCompra, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get comisionViaje => $composableBuilder(
      column: $table.comisionViaje, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get precioVenta => $composableBuilder(
      column: $table.precioVenta, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidadDisponible => $composableBuilder(
      column: $table.cantidadDisponible,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriasTableFilterComposer(
              $db: $db,
              $table: $db.categorias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ViajesTableFilterComposer get viajeId {
    final $$ViajesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.viajeId,
        referencedTable: $db.viajes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ViajesTableFilterComposer(
              $db: $db,
              $table: $db.viajes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> encargoDetalleRefs(
      Expression<bool> Function($$EncargoDetalleTableFilterComposer f) f) {
    final $$EncargoDetalleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.encargoDetalle,
        getReferencedColumn: (t) => t.productoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargoDetalleTableFilterComposer(
              $db: $db,
              $table: $db.encargoDetalle,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get precioCompra => $composableBuilder(
      column: $table.precioCompra,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get comisionViaje => $composableBuilder(
      column: $table.comisionViaje,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get precioVenta => $composableBuilder(
      column: $table.precioVenta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidadDisponible => $composableBuilder(
      column: $table.cantidadDisponible,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriasTableOrderingComposer(
              $db: $db,
              $table: $db.categorias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ViajesTableOrderingComposer get viajeId {
    final $$ViajesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.viajeId,
        referencedTable: $db.viajes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ViajesTableOrderingComposer(
              $db: $db,
              $table: $db.viajes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<int> get precioCompra => $composableBuilder(
      column: $table.precioCompra, builder: (column) => column);

  GeneratedColumn<int> get comisionViaje => $composableBuilder(
      column: $table.comisionViaje, builder: (column) => column);

  GeneratedColumn<int> get precioVenta => $composableBuilder(
      column: $table.precioVenta, builder: (column) => column);

  GeneratedColumn<int> get cantidadDisponible => $composableBuilder(
      column: $table.cantidadDisponible, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoriaId,
        referencedTable: $db.categorias,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriasTableAnnotationComposer(
              $db: $db,
              $table: $db.categorias,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ViajesTableAnnotationComposer get viajeId {
    final $$ViajesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.viajeId,
        referencedTable: $db.viajes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ViajesTableAnnotationComposer(
              $db: $db,
              $table: $db.viajes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> encargoDetalleRefs<T extends Object>(
      Expression<T> Function($$EncargoDetalleTableAnnotationComposer a) f) {
    final $$EncargoDetalleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.encargoDetalle,
        getReferencedColumn: (t) => t.productoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargoDetalleTableAnnotationComposer(
              $db: $db,
              $table: $db.encargoDetalle,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProductosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductosTable,
    Producto,
    $$ProductosTableFilterComposer,
    $$ProductosTableOrderingComposer,
    $$ProductosTableAnnotationComposer,
    $$ProductosTableCreateCompanionBuilder,
    $$ProductosTableUpdateCompanionBuilder,
    (Producto, $$ProductosTableReferences),
    Producto,
    PrefetchHooks Function(
        {bool categoriaId, bool viajeId, bool encargoDetalleRefs})> {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> categoriaId = const Value.absent(),
            Value<int?> viajeId = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<int?> precioCompra = const Value.absent(),
            Value<int> comisionViaje = const Value.absent(),
            Value<int?> precioVenta = const Value.absent(),
            Value<int> cantidadDisponible = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<bool> activo = const Value.absent(),
          }) =>
              ProductosCompanion(
            id: id,
            categoriaId: categoriaId,
            viajeId: viajeId,
            nombre: nombre,
            descripcion: descripcion,
            precioCompra: precioCompra,
            comisionViaje: comisionViaje,
            precioVenta: precioVenta,
            cantidadDisponible: cantidadDisponible,
            fotoPath: fotoPath,
            activo: activo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> categoriaId = const Value.absent(),
            Value<int?> viajeId = const Value.absent(),
            required String nombre,
            Value<String?> descripcion = const Value.absent(),
            Value<int?> precioCompra = const Value.absent(),
            Value<int> comisionViaje = const Value.absent(),
            Value<int?> precioVenta = const Value.absent(),
            Value<int> cantidadDisponible = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<bool> activo = const Value.absent(),
          }) =>
              ProductosCompanion.insert(
            id: id,
            categoriaId: categoriaId,
            viajeId: viajeId,
            nombre: nombre,
            descripcion: descripcion,
            precioCompra: precioCompra,
            comisionViaje: comisionViaje,
            precioVenta: precioVenta,
            cantidadDisponible: cantidadDisponible,
            fotoPath: fotoPath,
            activo: activo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProductosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoriaId = false,
              viajeId = false,
              encargoDetalleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (encargoDetalleRefs) db.encargoDetalle
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoriaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoriaId,
                    referencedTable:
                        $$ProductosTableReferences._categoriaIdTable(db),
                    referencedColumn:
                        $$ProductosTableReferences._categoriaIdTable(db).id,
                  ) as T;
                }
                if (viajeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.viajeId,
                    referencedTable:
                        $$ProductosTableReferences._viajeIdTable(db),
                    referencedColumn:
                        $$ProductosTableReferences._viajeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (encargoDetalleRefs)
                    await $_getPrefetchedData<Producto, $ProductosTable,
                            EncargoDetalleData>(
                        currentTable: table,
                        referencedTable: $$ProductosTableReferences
                            ._encargoDetalleRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProductosTableReferences(db, table, p0)
                                .encargoDetalleRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.productoId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProductosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductosTable,
    Producto,
    $$ProductosTableFilterComposer,
    $$ProductosTableOrderingComposer,
    $$ProductosTableAnnotationComposer,
    $$ProductosTableCreateCompanionBuilder,
    $$ProductosTableUpdateCompanionBuilder,
    (Producto, $$ProductosTableReferences),
    Producto,
    PrefetchHooks Function(
        {bool categoriaId, bool viajeId, bool encargoDetalleRefs})>;
typedef $$EncargosTableCreateCompanionBuilder = EncargosCompanion Function({
  Value<int> id,
  Value<int?> clienteId,
  Value<int> correlativoCliente,
  required DateTime fecha,
  Value<DateTime?> fechaEntregaEstimada,
  required String estado,
  Value<String?> observaciones,
  Value<String> tipoVenta,
  Value<bool> activo,
});
typedef $$EncargosTableUpdateCompanionBuilder = EncargosCompanion Function({
  Value<int> id,
  Value<int?> clienteId,
  Value<int> correlativoCliente,
  Value<DateTime> fecha,
  Value<DateTime?> fechaEntregaEstimada,
  Value<String> estado,
  Value<String?> observaciones,
  Value<String> tipoVenta,
  Value<bool> activo,
});

final class $$EncargosTableReferences
    extends BaseReferences<_$AppDatabase, $EncargosTable, Encargo> {
  $$EncargosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('encargos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager? get clienteId {
    final $_column = $_itemColumn<int>('cliente_id');
    if ($_column == null) return null;
    final manager = $$ClientesTableTableManager($_db, $_db.clientes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EncargoDetalleTable, List<EncargoDetalleData>>
      _encargoDetalleRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.encargoDetalle,
              aliasName: 'encargos__id__encargo_detalle__encargo_id');

  $$EncargoDetalleTableProcessedTableManager get encargoDetalleRefs {
    final manager = $$EncargoDetalleTableTableManager($_db, $_db.encargoDetalle)
        .filter((f) => f.encargoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_encargoDetalleRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pagos,
          aliasName: 'encargos__id__pagos__encargo_id');

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.encargoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EncargosTableFilterComposer
    extends Composer<_$AppDatabase, $EncargosTable> {
  $$EncargosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correlativoCliente => $composableBuilder(
      column: $table.correlativoCliente,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaEntregaEstimada => $composableBuilder(
      column: $table.fechaEntregaEstimada,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoVenta => $composableBuilder(
      column: $table.tipoVenta, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableFilterComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> encargoDetalleRefs(
      Expression<bool> Function($$EncargoDetalleTableFilterComposer f) f) {
    final $$EncargoDetalleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.encargoDetalle,
        getReferencedColumn: (t) => t.encargoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargoDetalleTableFilterComposer(
              $db: $db,
              $table: $db.encargoDetalle,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pagosRefs(
      Expression<bool> Function($$PagosTableFilterComposer f) f) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.encargoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EncargosTableOrderingComposer
    extends Composer<_$AppDatabase, $EncargosTable> {
  $$EncargosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correlativoCliente => $composableBuilder(
      column: $table.correlativoCliente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaEntregaEstimada => $composableBuilder(
      column: $table.fechaEntregaEstimada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoVenta => $composableBuilder(
      column: $table.tipoVenta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableOrderingComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EncargosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncargosTable> {
  $$EncargosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get correlativoCliente => $composableBuilder(
      column: $table.correlativoCliente, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaEntregaEstimada => $composableBuilder(
      column: $table.fechaEntregaEstimada, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<String> get tipoVenta =>
      $composableBuilder(column: $table.tipoVenta, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableAnnotationComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> encargoDetalleRefs<T extends Object>(
      Expression<T> Function($$EncargoDetalleTableAnnotationComposer a) f) {
    final $$EncargoDetalleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.encargoDetalle,
        getReferencedColumn: (t) => t.encargoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargoDetalleTableAnnotationComposer(
              $db: $db,
              $table: $db.encargoDetalle,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
      Expression<T> Function($$PagosTableAnnotationComposer a) f) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.encargoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EncargosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EncargosTable,
    Encargo,
    $$EncargosTableFilterComposer,
    $$EncargosTableOrderingComposer,
    $$EncargosTableAnnotationComposer,
    $$EncargosTableCreateCompanionBuilder,
    $$EncargosTableUpdateCompanionBuilder,
    (Encargo, $$EncargosTableReferences),
    Encargo,
    PrefetchHooks Function(
        {bool clienteId, bool encargoDetalleRefs, bool pagosRefs})> {
  $$EncargosTableTableManager(_$AppDatabase db, $EncargosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncargosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncargosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncargosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> clienteId = const Value.absent(),
            Value<int> correlativoCliente = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<DateTime?> fechaEntregaEstimada = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<String> tipoVenta = const Value.absent(),
            Value<bool> activo = const Value.absent(),
          }) =>
              EncargosCompanion(
            id: id,
            clienteId: clienteId,
            correlativoCliente: correlativoCliente,
            fecha: fecha,
            fechaEntregaEstimada: fechaEntregaEstimada,
            estado: estado,
            observaciones: observaciones,
            tipoVenta: tipoVenta,
            activo: activo,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> clienteId = const Value.absent(),
            Value<int> correlativoCliente = const Value.absent(),
            required DateTime fecha,
            Value<DateTime?> fechaEntregaEstimada = const Value.absent(),
            required String estado,
            Value<String?> observaciones = const Value.absent(),
            Value<String> tipoVenta = const Value.absent(),
            Value<bool> activo = const Value.absent(),
          }) =>
              EncargosCompanion.insert(
            id: id,
            clienteId: clienteId,
            correlativoCliente: correlativoCliente,
            fecha: fecha,
            fechaEntregaEstimada: fechaEntregaEstimada,
            estado: estado,
            observaciones: observaciones,
            tipoVenta: tipoVenta,
            activo: activo,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EncargosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {clienteId = false,
              encargoDetalleRefs = false,
              pagosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (encargoDetalleRefs) db.encargoDetalle,
                if (pagosRefs) db.pagos
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (clienteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clienteId,
                    referencedTable:
                        $$EncargosTableReferences._clienteIdTable(db),
                    referencedColumn:
                        $$EncargosTableReferences._clienteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (encargoDetalleRefs)
                    await $_getPrefetchedData<Encargo, $EncargosTable,
                            EncargoDetalleData>(
                        currentTable: table,
                        referencedTable: $$EncargosTableReferences
                            ._encargoDetalleRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EncargosTableReferences(db, table, p0)
                                .encargoDetalleRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.encargoId == item.id),
                        typedResults: items),
                  if (pagosRefs)
                    await $_getPrefetchedData<Encargo, $EncargosTable, Pago>(
                        currentTable: table,
                        referencedTable:
                            $$EncargosTableReferences._pagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EncargosTableReferences(db, table, p0).pagosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.encargoId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EncargosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EncargosTable,
    Encargo,
    $$EncargosTableFilterComposer,
    $$EncargosTableOrderingComposer,
    $$EncargosTableAnnotationComposer,
    $$EncargosTableCreateCompanionBuilder,
    $$EncargosTableUpdateCompanionBuilder,
    (Encargo, $$EncargosTableReferences),
    Encargo,
    PrefetchHooks Function(
        {bool clienteId, bool encargoDetalleRefs, bool pagosRefs})>;
typedef $$EncargoDetalleTableCreateCompanionBuilder = EncargoDetalleCompanion
    Function({
  Value<int> id,
  required int encargoId,
  Value<int?> productoId,
  Value<String?> nombreTemporal,
  required int cantidad,
  Value<int?> precioUnitario,
  Value<int?> costoUnitario,
});
typedef $$EncargoDetalleTableUpdateCompanionBuilder = EncargoDetalleCompanion
    Function({
  Value<int> id,
  Value<int> encargoId,
  Value<int?> productoId,
  Value<String?> nombreTemporal,
  Value<int> cantidad,
  Value<int?> precioUnitario,
  Value<int?> costoUnitario,
});

final class $$EncargoDetalleTableReferences extends BaseReferences<
    _$AppDatabase, $EncargoDetalleTable, EncargoDetalleData> {
  $$EncargoDetalleTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EncargosTable _encargoIdTable(_$AppDatabase db) =>
      db.encargos.createAlias('encargo_detalle__encargo_id__encargos__id');

  $$EncargosTableProcessedTableManager get encargoId {
    final $_column = $_itemColumn<int>('encargo_id')!;

    final manager = $$EncargosTableTableManager($_db, $_db.encargos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encargoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias('encargo_detalle__producto_id__productos__id');

  $$ProductosTableProcessedTableManager? get productoId {
    final $_column = $_itemColumn<int>('producto_id');
    if ($_column == null) return null;
    final manager = $$ProductosTableTableManager($_db, $_db.productos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EncargoDetalleTableFilterComposer
    extends Composer<_$AppDatabase, $EncargoDetalleTable> {
  $$EncargoDetalleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreTemporal => $composableBuilder(
      column: $table.nombreTemporal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario, builder: (column) => ColumnFilters(column));

  $$EncargosTableFilterComposer get encargoId {
    final $$EncargosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.encargoId,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableFilterComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productoId,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableFilterComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EncargoDetalleTableOrderingComposer
    extends Composer<_$AppDatabase, $EncargoDetalleTable> {
  $$EncargoDetalleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreTemporal => $composableBuilder(
      column: $table.nombreTemporal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario,
      builder: (column) => ColumnOrderings(column));

  $$EncargosTableOrderingComposer get encargoId {
    final $$EncargosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.encargoId,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableOrderingComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productoId,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableOrderingComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EncargoDetalleTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncargoDetalleTable> {
  $$EncargoDetalleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreTemporal => $composableBuilder(
      column: $table.nombreTemporal, builder: (column) => column);

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario, builder: (column) => column);

  GeneratedColumn<int> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario, builder: (column) => column);

  $$EncargosTableAnnotationComposer get encargoId {
    final $$EncargosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.encargoId,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableAnnotationComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.productoId,
        referencedTable: $db.productos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductosTableAnnotationComposer(
              $db: $db,
              $table: $db.productos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EncargoDetalleTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EncargoDetalleTable,
    EncargoDetalleData,
    $$EncargoDetalleTableFilterComposer,
    $$EncargoDetalleTableOrderingComposer,
    $$EncargoDetalleTableAnnotationComposer,
    $$EncargoDetalleTableCreateCompanionBuilder,
    $$EncargoDetalleTableUpdateCompanionBuilder,
    (EncargoDetalleData, $$EncargoDetalleTableReferences),
    EncargoDetalleData,
    PrefetchHooks Function({bool encargoId, bool productoId})> {
  $$EncargoDetalleTableTableManager(
      _$AppDatabase db, $EncargoDetalleTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncargoDetalleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncargoDetalleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncargoDetalleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> encargoId = const Value.absent(),
            Value<int?> productoId = const Value.absent(),
            Value<String?> nombreTemporal = const Value.absent(),
            Value<int> cantidad = const Value.absent(),
            Value<int?> precioUnitario = const Value.absent(),
            Value<int?> costoUnitario = const Value.absent(),
          }) =>
              EncargoDetalleCompanion(
            id: id,
            encargoId: encargoId,
            productoId: productoId,
            nombreTemporal: nombreTemporal,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            costoUnitario: costoUnitario,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int encargoId,
            Value<int?> productoId = const Value.absent(),
            Value<String?> nombreTemporal = const Value.absent(),
            required int cantidad,
            Value<int?> precioUnitario = const Value.absent(),
            Value<int?> costoUnitario = const Value.absent(),
          }) =>
              EncargoDetalleCompanion.insert(
            id: id,
            encargoId: encargoId,
            productoId: productoId,
            nombreTemporal: nombreTemporal,
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            costoUnitario: costoUnitario,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EncargoDetalleTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({encargoId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (encargoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.encargoId,
                    referencedTable:
                        $$EncargoDetalleTableReferences._encargoIdTable(db),
                    referencedColumn:
                        $$EncargoDetalleTableReferences._encargoIdTable(db).id,
                  ) as T;
                }
                if (productoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.productoId,
                    referencedTable:
                        $$EncargoDetalleTableReferences._productoIdTable(db),
                    referencedColumn:
                        $$EncargoDetalleTableReferences._productoIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EncargoDetalleTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EncargoDetalleTable,
    EncargoDetalleData,
    $$EncargoDetalleTableFilterComposer,
    $$EncargoDetalleTableOrderingComposer,
    $$EncargoDetalleTableAnnotationComposer,
    $$EncargoDetalleTableCreateCompanionBuilder,
    $$EncargoDetalleTableUpdateCompanionBuilder,
    (EncargoDetalleData, $$EncargoDetalleTableReferences),
    EncargoDetalleData,
    PrefetchHooks Function({bool encargoId, bool productoId})>;
typedef $$PagosTableCreateCompanionBuilder = PagosCompanion Function({
  Value<int> id,
  required int clienteId,
  Value<int?> encargoId,
  required int monto,
  required DateTime fecha,
  required String metodo,
  required String tipo,
  Value<String?> concepto,
});
typedef $$PagosTableUpdateCompanionBuilder = PagosCompanion Function({
  Value<int> id,
  Value<int> clienteId,
  Value<int?> encargoId,
  Value<int> monto,
  Value<DateTime> fecha,
  Value<String> metodo,
  Value<String> tipo,
  Value<String?> concepto,
});

final class $$PagosTableReferences
    extends BaseReferences<_$AppDatabase, $PagosTable, Pago> {
  $$PagosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('pagos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager($_db, $_db.clientes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $EncargosTable _encargoIdTable(_$AppDatabase db) =>
      db.encargos.createAlias('pagos__encargo_id__encargos__id');

  $$EncargosTableProcessedTableManager? get encargoId {
    final $_column = $_itemColumn<int>('encargo_id');
    if ($_column == null) return null;
    final manager = $$EncargosTableTableManager($_db, $_db.encargos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_encargoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PagosTableFilterComposer extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concepto => $composableBuilder(
      column: $table.concepto, builder: (column) => ColumnFilters(column));

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableFilterComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EncargosTableFilterComposer get encargoId {
    final $$EncargosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.encargoId,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableFilterComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PagosTableOrderingComposer
    extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodo => $composableBuilder(
      column: $table.metodo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concepto => $composableBuilder(
      column: $table.concepto, builder: (column) => ColumnOrderings(column));

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableOrderingComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EncargosTableOrderingComposer get encargoId {
    final $$EncargosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.encargoId,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableOrderingComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PagosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get metodo =>
      $composableBuilder(column: $table.metodo, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableAnnotationComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$EncargosTableAnnotationComposer get encargoId {
    final $$EncargosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.encargoId,
        referencedTable: $db.encargos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EncargosTableAnnotationComposer(
              $db: $db,
              $table: $db.encargos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PagosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PagosTable,
    Pago,
    $$PagosTableFilterComposer,
    $$PagosTableOrderingComposer,
    $$PagosTableAnnotationComposer,
    $$PagosTableCreateCompanionBuilder,
    $$PagosTableUpdateCompanionBuilder,
    (Pago, $$PagosTableReferences),
    Pago,
    PrefetchHooks Function({bool clienteId, bool encargoId})> {
  $$PagosTableTableManager(_$AppDatabase db, $PagosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> clienteId = const Value.absent(),
            Value<int?> encargoId = const Value.absent(),
            Value<int> monto = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<String> metodo = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String?> concepto = const Value.absent(),
          }) =>
              PagosCompanion(
            id: id,
            clienteId: clienteId,
            encargoId: encargoId,
            monto: monto,
            fecha: fecha,
            metodo: metodo,
            tipo: tipo,
            concepto: concepto,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int clienteId,
            Value<int?> encargoId = const Value.absent(),
            required int monto,
            required DateTime fecha,
            required String metodo,
            required String tipo,
            Value<String?> concepto = const Value.absent(),
          }) =>
              PagosCompanion.insert(
            id: id,
            clienteId: clienteId,
            encargoId: encargoId,
            monto: monto,
            fecha: fecha,
            metodo: metodo,
            tipo: tipo,
            concepto: concepto,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PagosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({clienteId = false, encargoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (clienteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clienteId,
                    referencedTable: $$PagosTableReferences._clienteIdTable(db),
                    referencedColumn:
                        $$PagosTableReferences._clienteIdTable(db).id,
                  ) as T;
                }
                if (encargoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.encargoId,
                    referencedTable: $$PagosTableReferences._encargoIdTable(db),
                    referencedColumn:
                        $$PagosTableReferences._encargoIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PagosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PagosTable,
    Pago,
    $$PagosTableFilterComposer,
    $$PagosTableOrderingComposer,
    $$PagosTableAnnotationComposer,
    $$PagosTableCreateCompanionBuilder,
    $$PagosTableUpdateCompanionBuilder,
    (Pago, $$PagosTableReferences),
    Pago,
    PrefetchHooks Function({bool clienteId, bool encargoId})>;
typedef $$PerfilUsuarioTableCreateCompanionBuilder = PerfilUsuarioCompanion
    Function({
  Value<int> id,
  required String nombre,
  required DateTime fechaNacimiento,
});
typedef $$PerfilUsuarioTableUpdateCompanionBuilder = PerfilUsuarioCompanion
    Function({
  Value<int> id,
  Value<String> nombre,
  Value<DateTime> fechaNacimiento,
});

class $$PerfilUsuarioTableFilterComposer
    extends Composer<_$AppDatabase, $PerfilUsuarioTable> {
  $$PerfilUsuarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaNacimiento => $composableBuilder(
      column: $table.fechaNacimiento,
      builder: (column) => ColumnFilters(column));
}

class $$PerfilUsuarioTableOrderingComposer
    extends Composer<_$AppDatabase, $PerfilUsuarioTable> {
  $$PerfilUsuarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaNacimiento => $composableBuilder(
      column: $table.fechaNacimiento,
      builder: (column) => ColumnOrderings(column));
}

class $$PerfilUsuarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $PerfilUsuarioTable> {
  $$PerfilUsuarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaNacimiento => $composableBuilder(
      column: $table.fechaNacimiento, builder: (column) => column);
}

class $$PerfilUsuarioTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PerfilUsuarioTable,
    PerfilUsuarioData,
    $$PerfilUsuarioTableFilterComposer,
    $$PerfilUsuarioTableOrderingComposer,
    $$PerfilUsuarioTableAnnotationComposer,
    $$PerfilUsuarioTableCreateCompanionBuilder,
    $$PerfilUsuarioTableUpdateCompanionBuilder,
    (
      PerfilUsuarioData,
      BaseReferences<_$AppDatabase, $PerfilUsuarioTable, PerfilUsuarioData>
    ),
    PerfilUsuarioData,
    PrefetchHooks Function()> {
  $$PerfilUsuarioTableTableManager(_$AppDatabase db, $PerfilUsuarioTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PerfilUsuarioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PerfilUsuarioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PerfilUsuarioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<DateTime> fechaNacimiento = const Value.absent(),
          }) =>
              PerfilUsuarioCompanion(
            id: id,
            nombre: nombre,
            fechaNacimiento: fechaNacimiento,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            required DateTime fechaNacimiento,
          }) =>
              PerfilUsuarioCompanion.insert(
            id: id,
            nombre: nombre,
            fechaNacimiento: fechaNacimiento,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PerfilUsuarioTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PerfilUsuarioTable,
    PerfilUsuarioData,
    $$PerfilUsuarioTableFilterComposer,
    $$PerfilUsuarioTableOrderingComposer,
    $$PerfilUsuarioTableAnnotationComposer,
    $$PerfilUsuarioTableCreateCompanionBuilder,
    $$PerfilUsuarioTableUpdateCompanionBuilder,
    (
      PerfilUsuarioData,
      BaseReferences<_$AppDatabase, $PerfilUsuarioTable, PerfilUsuarioData>
    ),
    PerfilUsuarioData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$ViajesTableTableManager get viajes =>
      $$ViajesTableTableManager(_db, _db.viajes);
  $$GastosTableTableManager get gastos =>
      $$GastosTableTableManager(_db, _db.gastos);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$EncargosTableTableManager get encargos =>
      $$EncargosTableTableManager(_db, _db.encargos);
  $$EncargoDetalleTableTableManager get encargoDetalle =>
      $$EncargoDetalleTableTableManager(_db, _db.encargoDetalle);
  $$PagosTableTableManager get pagos =>
      $$PagosTableTableManager(_db, _db.pagos);
  $$PerfilUsuarioTableTableManager get perfilUsuario =>
      $$PerfilUsuarioTableTableManager(_db, _db.perfilUsuario);
}
