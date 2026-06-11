// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTableTable extends CustomersTable
    with TableInfo<$CustomersTableTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _socialMeta = const VerificationMeta('social');
  @override
  late final GeneratedColumn<String> social = GeneratedColumn<String>(
      'social', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, social, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('social')) {
      context.handle(_socialMeta,
          social.isAcceptableOrUnknown(data['social']!, _socialMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      social: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}social']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomersTableTable createAlias(String alias) {
    return $CustomersTableTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;
  final String phone;
  final String? social;
  final DateTime createdAt;
  const Customer(
      {required this.id,
      required this.name,
      required this.phone,
      this.social,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || social != null) {
      map['social'] = Variable<String>(social);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersTableCompanion toCompanion(bool nullToAbsent) {
    return CustomersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      social:
          social == null && nullToAbsent ? const Value.absent() : Value(social),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      social: serializer.fromJson<String?>(json['social']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'social': serializer.toJson<String?>(social),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith(
          {int? id,
          String? name,
          String? phone,
          Value<String?> social = const Value.absent(),
          DateTime? createdAt}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        social: social.present ? social.value : this.social,
        createdAt: createdAt ?? this.createdAt,
      );
  Customer copyWithCompanion(CustomersTableCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      social: data.social.present ? data.social.value : this.social,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('social: $social, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, social, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.social == this.social &&
          other.createdAt == this.createdAt);
}

class CustomersTableCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> social;
  final Value<DateTime> createdAt;
  const CustomersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.social = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.social = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        phone = Value(phone);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? social,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (social != null) 'social': social,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<String?>? social,
      Value<DateTime>? createdAt}) {
    return CustomersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      social: social ?? this.social,
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (social.present) {
      map['social'] = Variable<String>(social.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('social: $social, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BookingsTableTable extends BookingsTable
    with TableInfo<$BookingsTableTable, Booking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookingNumberMeta =
      const VerificationMeta('bookingNumber');
  @override
  late final GeneratedColumn<String> bookingNumber = GeneratedColumn<String>(
      'booking_number', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookingDateMeta =
      const VerificationMeta('bookingDate');
  @override
  late final GeneratedColumn<DateTime> bookingDate = GeneratedColumn<DateTime>(
      'booking_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeStartMeta =
      const VerificationMeta('timeStart');
  @override
  late final GeneratedColumn<String> timeStart = GeneratedColumn<String>(
      'time_start', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeEndMeta =
      const VerificationMeta('timeEnd');
  @override
  late final GeneratedColumn<String> timeEnd = GeneratedColumn<String>(
      'time_end', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _staffMeta = const VerificationMeta('staff');
  @override
  late final GeneratedColumn<String> staff = GeneratedColumn<String>(
      'staff', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _remainingAmountMeta =
      const VerificationMeta('remainingAmount');
  @override
  late final GeneratedColumn<double> remainingAmount = GeneratedColumn<double>(
      'remaining_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookingNumber,
        customerId,
        eventType,
        bookingDate,
        venue,
        timeStart,
        timeEnd,
        staff,
        totalAmount,
        paidAmount,
        remainingAmount,
        status,
        isDeleted,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings';
  @override
  VerificationContext validateIntegrity(Insertable<Booking> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('booking_number')) {
      context.handle(
          _bookingNumberMeta,
          bookingNumber.isAcceptableOrUnknown(
              data['booking_number']!, _bookingNumberMeta));
    } else if (isInserting) {
      context.missing(_bookingNumberMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('booking_date')) {
      context.handle(
          _bookingDateMeta,
          bookingDate.isAcceptableOrUnknown(
              data['booking_date']!, _bookingDateMeta));
    } else if (isInserting) {
      context.missing(_bookingDateMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
          _venueMeta, venue.isAcceptableOrUnknown(data['venue']!, _venueMeta));
    }
    if (data.containsKey('time_start')) {
      context.handle(_timeStartMeta,
          timeStart.isAcceptableOrUnknown(data['time_start']!, _timeStartMeta));
    }
    if (data.containsKey('time_end')) {
      context.handle(_timeEndMeta,
          timeEnd.isAcceptableOrUnknown(data['time_end']!, _timeEndMeta));
    }
    if (data.containsKey('staff')) {
      context.handle(
          _staffMeta, staff.isAcceptableOrUnknown(data['staff']!, _staffMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('remaining_amount')) {
      context.handle(
          _remainingAmountMeta,
          remainingAmount.isAcceptableOrUnknown(
              data['remaining_amount']!, _remainingAmountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Booking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Booking(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookingNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}booking_number'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      bookingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}booking_date'])!,
      venue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue']),
      timeStart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_start']),
      timeEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_end']),
      staff: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff']),
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      remainingAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}remaining_amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BookingsTableTable createAlias(String alias) {
    return $BookingsTableTable(attachedDatabase, alias);
  }
}

class Booking extends DataClass implements Insertable<Booking> {
  final int id;
  final String bookingNumber;
  final int customerId;
  final String eventType;
  final DateTime bookingDate;
  final String? venue;
  final String? timeStart;
  final String? timeEnd;
  final String? staff;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final bool isDeleted;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Booking(
      {required this.id,
      required this.bookingNumber,
      required this.customerId,
      required this.eventType,
      required this.bookingDate,
      this.venue,
      this.timeStart,
      this.timeEnd,
      this.staff,
      required this.totalAmount,
      required this.paidAmount,
      required this.remainingAmount,
      required this.status,
      required this.isDeleted,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['booking_number'] = Variable<String>(bookingNumber);
    map['customer_id'] = Variable<int>(customerId);
    map['event_type'] = Variable<String>(eventType);
    map['booking_date'] = Variable<DateTime>(bookingDate);
    if (!nullToAbsent || venue != null) {
      map['venue'] = Variable<String>(venue);
    }
    if (!nullToAbsent || timeStart != null) {
      map['time_start'] = Variable<String>(timeStart);
    }
    if (!nullToAbsent || timeEnd != null) {
      map['time_end'] = Variable<String>(timeEnd);
    }
    if (!nullToAbsent || staff != null) {
      map['staff'] = Variable<String>(staff);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['remaining_amount'] = Variable<double>(remainingAmount);
    map['status'] = Variable<String>(status);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookingsTableCompanion toCompanion(bool nullToAbsent) {
    return BookingsTableCompanion(
      id: Value(id),
      bookingNumber: Value(bookingNumber),
      customerId: Value(customerId),
      eventType: Value(eventType),
      bookingDate: Value(bookingDate),
      venue:
          venue == null && nullToAbsent ? const Value.absent() : Value(venue),
      timeStart: timeStart == null && nullToAbsent
          ? const Value.absent()
          : Value(timeStart),
      timeEnd: timeEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(timeEnd),
      staff:
          staff == null && nullToAbsent ? const Value.absent() : Value(staff),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      remainingAmount: Value(remainingAmount),
      status: Value(status),
      isDeleted: Value(isDeleted),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Booking(
      id: serializer.fromJson<int>(json['id']),
      bookingNumber: serializer.fromJson<String>(json['bookingNumber']),
      customerId: serializer.fromJson<int>(json['customerId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      bookingDate: serializer.fromJson<DateTime>(json['bookingDate']),
      venue: serializer.fromJson<String?>(json['venue']),
      timeStart: serializer.fromJson<String?>(json['timeStart']),
      timeEnd: serializer.fromJson<String?>(json['timeEnd']),
      staff: serializer.fromJson<String?>(json['staff']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      remainingAmount: serializer.fromJson<double>(json['remainingAmount']),
      status: serializer.fromJson<String>(json['status']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookingNumber': serializer.toJson<String>(bookingNumber),
      'customerId': serializer.toJson<int>(customerId),
      'eventType': serializer.toJson<String>(eventType),
      'bookingDate': serializer.toJson<DateTime>(bookingDate),
      'venue': serializer.toJson<String?>(venue),
      'timeStart': serializer.toJson<String?>(timeStart),
      'timeEnd': serializer.toJson<String?>(timeEnd),
      'staff': serializer.toJson<String?>(staff),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'remainingAmount': serializer.toJson<double>(remainingAmount),
      'status': serializer.toJson<String>(status),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Booking copyWith(
          {int? id,
          String? bookingNumber,
          int? customerId,
          String? eventType,
          DateTime? bookingDate,
          Value<String?> venue = const Value.absent(),
          Value<String?> timeStart = const Value.absent(),
          Value<String?> timeEnd = const Value.absent(),
          Value<String?> staff = const Value.absent(),
          double? totalAmount,
          double? paidAmount,
          double? remainingAmount,
          String? status,
          bool? isDeleted,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Booking(
        id: id ?? this.id,
        bookingNumber: bookingNumber ?? this.bookingNumber,
        customerId: customerId ?? this.customerId,
        eventType: eventType ?? this.eventType,
        bookingDate: bookingDate ?? this.bookingDate,
        venue: venue.present ? venue.value : this.venue,
        timeStart: timeStart.present ? timeStart.value : this.timeStart,
        timeEnd: timeEnd.present ? timeEnd.value : this.timeEnd,
        staff: staff.present ? staff.value : this.staff,
        totalAmount: totalAmount ?? this.totalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        status: status ?? this.status,
        isDeleted: isDeleted ?? this.isDeleted,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Booking copyWithCompanion(BookingsTableCompanion data) {
    return Booking(
      id: data.id.present ? data.id.value : this.id,
      bookingNumber: data.bookingNumber.present
          ? data.bookingNumber.value
          : this.bookingNumber,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      bookingDate:
          data.bookingDate.present ? data.bookingDate.value : this.bookingDate,
      venue: data.venue.present ? data.venue.value : this.venue,
      timeStart: data.timeStart.present ? data.timeStart.value : this.timeStart,
      timeEnd: data.timeEnd.present ? data.timeEnd.value : this.timeEnd,
      staff: data.staff.present ? data.staff.value : this.staff,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      remainingAmount: data.remainingAmount.present
          ? data.remainingAmount.value
          : this.remainingAmount,
      status: data.status.present ? data.status.value : this.status,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Booking(')
          ..write('id: $id, ')
          ..write('bookingNumber: $bookingNumber, ')
          ..write('customerId: $customerId, ')
          ..write('eventType: $eventType, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('venue: $venue, ')
          ..write('timeStart: $timeStart, ')
          ..write('timeEnd: $timeEnd, ')
          ..write('staff: $staff, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('status: $status, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookingNumber,
      customerId,
      eventType,
      bookingDate,
      venue,
      timeStart,
      timeEnd,
      staff,
      totalAmount,
      paidAmount,
      remainingAmount,
      status,
      isDeleted,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Booking &&
          other.id == this.id &&
          other.bookingNumber == this.bookingNumber &&
          other.customerId == this.customerId &&
          other.eventType == this.eventType &&
          other.bookingDate == this.bookingDate &&
          other.venue == this.venue &&
          other.timeStart == this.timeStart &&
          other.timeEnd == this.timeEnd &&
          other.staff == this.staff &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.remainingAmount == this.remainingAmount &&
          other.status == this.status &&
          other.isDeleted == this.isDeleted &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BookingsTableCompanion extends UpdateCompanion<Booking> {
  final Value<int> id;
  final Value<String> bookingNumber;
  final Value<int> customerId;
  final Value<String> eventType;
  final Value<DateTime> bookingDate;
  final Value<String?> venue;
  final Value<String?> timeStart;
  final Value<String?> timeEnd;
  final Value<String?> staff;
  final Value<double> totalAmount;
  final Value<double> paidAmount;
  final Value<double> remainingAmount;
  final Value<String> status;
  final Value<bool> isDeleted;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BookingsTableCompanion({
    this.id = const Value.absent(),
    this.bookingNumber = const Value.absent(),
    this.customerId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.bookingDate = const Value.absent(),
    this.venue = const Value.absent(),
    this.timeStart = const Value.absent(),
    this.timeEnd = const Value.absent(),
    this.staff = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BookingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String bookingNumber,
    required int customerId,
    required String eventType,
    required DateTime bookingDate,
    this.venue = const Value.absent(),
    this.timeStart = const Value.absent(),
    this.timeEnd = const Value.absent(),
    this.staff = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : bookingNumber = Value(bookingNumber),
        customerId = Value(customerId),
        eventType = Value(eventType),
        bookingDate = Value(bookingDate);
  static Insertable<Booking> custom({
    Expression<int>? id,
    Expression<String>? bookingNumber,
    Expression<int>? customerId,
    Expression<String>? eventType,
    Expression<DateTime>? bookingDate,
    Expression<String>? venue,
    Expression<String>? timeStart,
    Expression<String>? timeEnd,
    Expression<String>? staff,
    Expression<double>? totalAmount,
    Expression<double>? paidAmount,
    Expression<double>? remainingAmount,
    Expression<String>? status,
    Expression<bool>? isDeleted,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingNumber != null) 'booking_number': bookingNumber,
      if (customerId != null) 'customer_id': customerId,
      if (eventType != null) 'event_type': eventType,
      if (bookingDate != null) 'booking_date': bookingDate,
      if (venue != null) 'venue': venue,
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      if (staff != null) 'staff': staff,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (remainingAmount != null) 'remaining_amount': remainingAmount,
      if (status != null) 'status': status,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BookingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? bookingNumber,
      Value<int>? customerId,
      Value<String>? eventType,
      Value<DateTime>? bookingDate,
      Value<String?>? venue,
      Value<String?>? timeStart,
      Value<String?>? timeEnd,
      Value<String?>? staff,
      Value<double>? totalAmount,
      Value<double>? paidAmount,
      Value<double>? remainingAmount,
      Value<String>? status,
      Value<bool>? isDeleted,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BookingsTableCompanion(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      customerId: customerId ?? this.customerId,
      eventType: eventType ?? this.eventType,
      bookingDate: bookingDate ?? this.bookingDate,
      venue: venue ?? this.venue,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      staff: staff ?? this.staff,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookingNumber.present) {
      map['booking_number'] = Variable<String>(bookingNumber.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (bookingDate.present) {
      map['booking_date'] = Variable<DateTime>(bookingDate.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (timeStart.present) {
      map['time_start'] = Variable<String>(timeStart.value);
    }
    if (timeEnd.present) {
      map['time_end'] = Variable<String>(timeEnd.value);
    }
    if (staff.present) {
      map['staff'] = Variable<String>(staff.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (remainingAmount.present) {
      map['remaining_amount'] = Variable<double>(remainingAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsTableCompanion(')
          ..write('id: $id, ')
          ..write('bookingNumber: $bookingNumber, ')
          ..write('customerId: $customerId, ')
          ..write('eventType: $eventType, ')
          ..write('bookingDate: $bookingDate, ')
          ..write('venue: $venue, ')
          ..write('timeStart: $timeStart, ')
          ..write('timeEnd: $timeEnd, ')
          ..write('staff: $staff, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('status: $status, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BookingServicesTableTable extends BookingServicesTable
    with TableInfo<$BookingServicesTableTable, BookingService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingServicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookingIdMeta =
      const VerificationMeta('bookingId');
  @override
  late final GeneratedColumn<int> bookingId = GeneratedColumn<int>(
      'booking_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES bookings (id)'));
  static const VerificationMeta _serviceNameMeta =
      const VerificationMeta('serviceName');
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
      'service_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, bookingId, serviceName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'booking_services';
  @override
  VerificationContext validateIntegrity(Insertable<BookingService> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('booking_id')) {
      context.handle(_bookingIdMeta,
          bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta));
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
          _serviceNameMeta,
          serviceName.isAcceptableOrUnknown(
              data['service_name']!, _serviceNameMeta));
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookingService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingService(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}booking_id'])!,
      serviceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_name'])!,
    );
  }

  @override
  $BookingServicesTableTable createAlias(String alias) {
    return $BookingServicesTableTable(attachedDatabase, alias);
  }
}

class BookingService extends DataClass implements Insertable<BookingService> {
  final int id;
  final int bookingId;
  final String serviceName;
  const BookingService(
      {required this.id, required this.bookingId, required this.serviceName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['booking_id'] = Variable<int>(bookingId);
    map['service_name'] = Variable<String>(serviceName);
    return map;
  }

  BookingServicesTableCompanion toCompanion(bool nullToAbsent) {
    return BookingServicesTableCompanion(
      id: Value(id),
      bookingId: Value(bookingId),
      serviceName: Value(serviceName),
    );
  }

  factory BookingService.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingService(
      id: serializer.fromJson<int>(json['id']),
      bookingId: serializer.fromJson<int>(json['bookingId']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookingId': serializer.toJson<int>(bookingId),
      'serviceName': serializer.toJson<String>(serviceName),
    };
  }

  BookingService copyWith({int? id, int? bookingId, String? serviceName}) =>
      BookingService(
        id: id ?? this.id,
        bookingId: bookingId ?? this.bookingId,
        serviceName: serviceName ?? this.serviceName,
      );
  BookingService copyWithCompanion(BookingServicesTableCompanion data) {
    return BookingService(
      id: data.id.present ? data.id.value : this.id,
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      serviceName:
          data.serviceName.present ? data.serviceName.value : this.serviceName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingService(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('serviceName: $serviceName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookingId, serviceName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingService &&
          other.id == this.id &&
          other.bookingId == this.bookingId &&
          other.serviceName == this.serviceName);
}

class BookingServicesTableCompanion extends UpdateCompanion<BookingService> {
  final Value<int> id;
  final Value<int> bookingId;
  final Value<String> serviceName;
  const BookingServicesTableCompanion({
    this.id = const Value.absent(),
    this.bookingId = const Value.absent(),
    this.serviceName = const Value.absent(),
  });
  BookingServicesTableCompanion.insert({
    this.id = const Value.absent(),
    required int bookingId,
    required String serviceName,
  })  : bookingId = Value(bookingId),
        serviceName = Value(serviceName);
  static Insertable<BookingService> custom({
    Expression<int>? id,
    Expression<int>? bookingId,
    Expression<String>? serviceName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingId != null) 'booking_id': bookingId,
      if (serviceName != null) 'service_name': serviceName,
    });
  }

  BookingServicesTableCompanion copyWith(
      {Value<int>? id, Value<int>? bookingId, Value<String>? serviceName}) {
    return BookingServicesTableCompanion(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serviceName: serviceName ?? this.serviceName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookingId.present) {
      map['booking_id'] = Variable<int>(bookingId.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingServicesTableCompanion(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('serviceName: $serviceName')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookingIdMeta =
      const VerificationMeta('bookingId');
  @override
  late final GeneratedColumn<int> bookingId = GeneratedColumn<int>(
      'booking_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES bookings (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookingId, amount, paymentMethod, paymentDate, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('booking_id')) {
      context.handle(_bookingIdMeta,
          bookingId.isAcceptableOrUnknown(data['booking_id']!, _bookingIdMeta));
    } else if (isInserting) {
      context.missing(_bookingIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookingId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}booking_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int bookingId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? notes;
  const Payment(
      {required this.id,
      required this.bookingId,
      required this.amount,
      required this.paymentMethod,
      required this.paymentDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['booking_id'] = Variable<int>(bookingId);
    map['amount'] = Variable<double>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      bookingId: Value(bookingId),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      paymentDate: Value(paymentDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      bookingId: serializer.fromJson<int>(json['bookingId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookingId': serializer.toJson<int>(bookingId),
      'amount': serializer.toJson<double>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Payment copyWith(
          {int? id,
          int? bookingId,
          double? amount,
          String? paymentMethod,
          DateTime? paymentDate,
          Value<String?> notes = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        bookingId: bookingId ?? this.bookingId,
        amount: amount ?? this.amount,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentDate: paymentDate ?? this.paymentDate,
        notes: notes.present ? notes.value : this.notes,
      );
  Payment copyWithCompanion(PaymentsTableCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      bookingId: data.bookingId.present ? data.bookingId.value : this.bookingId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookingId, amount, paymentMethod, paymentDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.bookingId == this.bookingId &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentDate == this.paymentDate &&
          other.notes == this.notes);
}

class PaymentsTableCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> bookingId;
  final Value<double> amount;
  final Value<String> paymentMethod;
  final Value<DateTime> paymentDate;
  final Value<String?> notes;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.bookingId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    this.id = const Value.absent(),
    required int bookingId,
    required double amount,
    this.paymentMethod = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
  })  : bookingId = Value(bookingId),
        amount = Value(amount);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? bookingId,
    Expression<double>? amount,
    Expression<String>? paymentMethod,
    Expression<DateTime>? paymentDate,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingId != null) 'booking_id': bookingId,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
    });
  }

  PaymentsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? bookingId,
      Value<double>? amount,
      Value<String>? paymentMethod,
      Value<DateTime>? paymentDate,
      Value<String?>? notes}) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookingId.present) {
      map['booking_id'] = Variable<int>(bookingId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('bookingId: $bookingId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
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
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
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

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsTableCompanion data) {
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

class SettingsTableCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
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

  SettingsTableCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsTableCompanion(
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
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTableTable customersTable = $CustomersTableTable(this);
  late final $BookingsTableTable bookingsTable = $BookingsTableTable(this);
  late final $BookingServicesTableTable bookingServicesTable =
      $BookingServicesTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        customersTable,
        bookingsTable,
        bookingServicesTable,
        paymentsTable,
        settingsTable
      ];
}

typedef $$CustomersTableTableCreateCompanionBuilder = CustomersTableCompanion
    Function({
  Value<int> id,
  required String name,
  required String phone,
  Value<String?> social,
  Value<DateTime> createdAt,
});
typedef $$CustomersTableTableUpdateCompanionBuilder = CustomersTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> phone,
  Value<String?> social,
  Value<DateTime> createdAt,
});

final class $$CustomersTableTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTableTable, Customer> {
  $$CustomersTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookingsTableTable, List<Booking>>
      _bookingsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookingsTable,
              aliasName: $_aliasNameGenerator(
                  db.customersTable.id, db.bookingsTable.customerId));

  $$BookingsTableTableProcessedTableManager get bookingsTableRefs {
    final manager = $$BookingsTableTableTableManager($_db, $_db.bookingsTable)
        .filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookingsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomersTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get social => $composableBuilder(
      column: $table.social, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> bookingsTableRefs(
      Expression<bool> Function($$BookingsTableTableFilterComposer f) f) {
    final $$BookingsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableFilterComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get social => $composableBuilder(
      column: $table.social, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get social =>
      $composableBuilder(column: $table.social, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> bookingsTableRefs<T extends Object>(
      Expression<T> Function($$BookingsTableTableAnnotationComposer a) f) {
    final $$BookingsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTableTable,
    Customer,
    $$CustomersTableTableFilterComposer,
    $$CustomersTableTableOrderingComposer,
    $$CustomersTableTableAnnotationComposer,
    $$CustomersTableTableCreateCompanionBuilder,
    $$CustomersTableTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableTableReferences),
    Customer,
    PrefetchHooks Function({bool bookingsTableRefs})> {
  $$CustomersTableTableTableManager(
      _$AppDatabase db, $CustomersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> social = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CustomersTableCompanion(
            id: id,
            name: name,
            phone: phone,
            social: social,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String phone,
            Value<String?> social = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CustomersTableCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            social: social,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomersTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookingsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookingsTableRefs) db.bookingsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookingsTableRefs)
                    await $_getPrefetchedData<Customer, $CustomersTableTable,
                            Booking>(
                        currentTable: table,
                        referencedTable: $$CustomersTableTableReferences
                            ._bookingsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableTableReferences(db, table, p0)
                                .bookingsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.customerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTableTable,
    Customer,
    $$CustomersTableTableFilterComposer,
    $$CustomersTableTableOrderingComposer,
    $$CustomersTableTableAnnotationComposer,
    $$CustomersTableTableCreateCompanionBuilder,
    $$CustomersTableTableUpdateCompanionBuilder,
    (Customer, $$CustomersTableTableReferences),
    Customer,
    PrefetchHooks Function({bool bookingsTableRefs})>;
typedef $$BookingsTableTableCreateCompanionBuilder = BookingsTableCompanion
    Function({
  Value<int> id,
  required String bookingNumber,
  required int customerId,
  required String eventType,
  required DateTime bookingDate,
  Value<String?> venue,
  Value<String?> timeStart,
  Value<String?> timeEnd,
  Value<String?> staff,
  Value<double> totalAmount,
  Value<double> paidAmount,
  Value<double> remainingAmount,
  Value<String> status,
  Value<bool> isDeleted,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BookingsTableTableUpdateCompanionBuilder = BookingsTableCompanion
    Function({
  Value<int> id,
  Value<String> bookingNumber,
  Value<int> customerId,
  Value<String> eventType,
  Value<DateTime> bookingDate,
  Value<String?> venue,
  Value<String?> timeStart,
  Value<String?> timeEnd,
  Value<String?> staff,
  Value<double> totalAmount,
  Value<double> paidAmount,
  Value<double> remainingAmount,
  Value<String> status,
  Value<bool> isDeleted,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BookingsTableTableReferences
    extends BaseReferences<_$AppDatabase, $BookingsTableTable, Booking> {
  $$BookingsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTableTable _customerIdTable(_$AppDatabase db) =>
      db.customersTable.createAlias($_aliasNameGenerator(
          db.bookingsTable.customerId, db.customersTable.id));

  $$CustomersTableTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableTableManager($_db, $_db.customersTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BookingServicesTableTable, List<BookingService>>
      _bookingServicesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookingServicesTable,
              aliasName: $_aliasNameGenerator(
                  db.bookingsTable.id, db.bookingServicesTable.bookingId));

  $$BookingServicesTableTableProcessedTableManager
      get bookingServicesTableRefs {
    final manager =
        $$BookingServicesTableTableTableManager($_db, $_db.bookingServicesTable)
            .filter((f) => f.bookingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_bookingServicesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTableTable, List<Payment>>
      _paymentsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.paymentsTable,
              aliasName: $_aliasNameGenerator(
                  db.bookingsTable.id, db.paymentsTable.bookingId));

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager($_db, $_db.paymentsTable)
        .filter((f) => f.bookingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BookingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsTableTable> {
  $$BookingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookingNumber => $composableBuilder(
      column: $table.bookingNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get bookingDate => $composableBuilder(
      column: $table.bookingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeStart => $composableBuilder(
      column: $table.timeStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeEnd => $composableBuilder(
      column: $table.timeEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get staff => $composableBuilder(
      column: $table.staff, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableTableFilterComposer(
              $db: $db,
              $table: $db.customersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> bookingServicesTableRefs(
      Expression<bool> Function($$BookingServicesTableTableFilterComposer f)
          f) {
    final $$BookingServicesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookingServicesTable,
        getReferencedColumn: (t) => t.bookingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingServicesTableTableFilterComposer(
              $db: $db,
              $table: $db.bookingServicesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsTableRefs(
      Expression<bool> Function($$PaymentsTableTableFilterComposer f) f) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentsTable,
        getReferencedColumn: (t) => t.bookingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableTableFilterComposer(
              $db: $db,
              $table: $db.paymentsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BookingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsTableTable> {
  $$BookingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookingNumber => $composableBuilder(
      column: $table.bookingNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get bookingDate => $composableBuilder(
      column: $table.bookingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeStart => $composableBuilder(
      column: $table.timeStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeEnd => $composableBuilder(
      column: $table.timeEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get staff => $composableBuilder(
      column: $table.staff, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableTableOrderingComposer(
              $db: $db,
              $table: $db.customersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsTableTable> {
  $$BookingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookingNumber => $composableBuilder(
      column: $table.bookingNumber, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get bookingDate => $composableBuilder(
      column: $table.bookingDate, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<String> get timeStart =>
      $composableBuilder(column: $table.timeStart, builder: (column) => column);

  GeneratedColumn<String> get timeEnd =>
      $composableBuilder(column: $table.timeEnd, builder: (column) => column);

  GeneratedColumn<String> get staff =>
      $composableBuilder(column: $table.staff, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<double> get remainingAmount => $composableBuilder(
      column: $table.remainingAmount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableTableAnnotationComposer(
              $db: $db,
              $table: $db.customersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> bookingServicesTableRefs<T extends Object>(
      Expression<T> Function($$BookingServicesTableTableAnnotationComposer a)
          f) {
    final $$BookingServicesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.bookingServicesTable,
            getReferencedColumn: (t) => t.bookingId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$BookingServicesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.bookingServicesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> paymentsTableRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentsTable,
        getReferencedColumn: (t) => t.bookingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.paymentsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BookingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookingsTableTable,
    Booking,
    $$BookingsTableTableFilterComposer,
    $$BookingsTableTableOrderingComposer,
    $$BookingsTableTableAnnotationComposer,
    $$BookingsTableTableCreateCompanionBuilder,
    $$BookingsTableTableUpdateCompanionBuilder,
    (Booking, $$BookingsTableTableReferences),
    Booking,
    PrefetchHooks Function(
        {bool customerId,
        bool bookingServicesTableRefs,
        bool paymentsTableRefs})> {
  $$BookingsTableTableTableManager(_$AppDatabase db, $BookingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> bookingNumber = const Value.absent(),
            Value<int> customerId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<DateTime> bookingDate = const Value.absent(),
            Value<String?> venue = const Value.absent(),
            Value<String?> timeStart = const Value.absent(),
            Value<String?> timeEnd = const Value.absent(),
            Value<String?> staff = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<double> remainingAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BookingsTableCompanion(
            id: id,
            bookingNumber: bookingNumber,
            customerId: customerId,
            eventType: eventType,
            bookingDate: bookingDate,
            venue: venue,
            timeStart: timeStart,
            timeEnd: timeEnd,
            staff: staff,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            remainingAmount: remainingAmount,
            status: status,
            isDeleted: isDeleted,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String bookingNumber,
            required int customerId,
            required String eventType,
            required DateTime bookingDate,
            Value<String?> venue = const Value.absent(),
            Value<String?> timeStart = const Value.absent(),
            Value<String?> timeEnd = const Value.absent(),
            Value<String?> staff = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<double> remainingAmount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BookingsTableCompanion.insert(
            id: id,
            bookingNumber: bookingNumber,
            customerId: customerId,
            eventType: eventType,
            bookingDate: bookingDate,
            venue: venue,
            timeStart: timeStart,
            timeEnd: timeEnd,
            staff: staff,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            remainingAmount: remainingAmount,
            status: status,
            isDeleted: isDeleted,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookingsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {customerId = false,
              bookingServicesTableRefs = false,
              paymentsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookingServicesTableRefs) db.bookingServicesTable,
                if (paymentsTableRefs) db.paymentsTable
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
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$BookingsTableTableReferences._customerIdTable(db),
                    referencedColumn:
                        $$BookingsTableTableReferences._customerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookingServicesTableRefs)
                    await $_getPrefetchedData<Booking, $BookingsTableTable,
                            BookingService>(
                        currentTable: table,
                        referencedTable: $$BookingsTableTableReferences
                            ._bookingServicesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BookingsTableTableReferences(db, table, p0)
                                .bookingServicesTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.bookingId == item.id),
                        typedResults: items),
                  if (paymentsTableRefs)
                    await $_getPrefetchedData<Booking, $BookingsTableTable,
                            Payment>(
                        currentTable: table,
                        referencedTable: $$BookingsTableTableReferences
                            ._paymentsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BookingsTableTableReferences(db, table, p0)
                                .paymentsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.bookingId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BookingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookingsTableTable,
    Booking,
    $$BookingsTableTableFilterComposer,
    $$BookingsTableTableOrderingComposer,
    $$BookingsTableTableAnnotationComposer,
    $$BookingsTableTableCreateCompanionBuilder,
    $$BookingsTableTableUpdateCompanionBuilder,
    (Booking, $$BookingsTableTableReferences),
    Booking,
    PrefetchHooks Function(
        {bool customerId,
        bool bookingServicesTableRefs,
        bool paymentsTableRefs})>;
typedef $$BookingServicesTableTableCreateCompanionBuilder
    = BookingServicesTableCompanion Function({
  Value<int> id,
  required int bookingId,
  required String serviceName,
});
typedef $$BookingServicesTableTableUpdateCompanionBuilder
    = BookingServicesTableCompanion Function({
  Value<int> id,
  Value<int> bookingId,
  Value<String> serviceName,
});

final class $$BookingServicesTableTableReferences extends BaseReferences<
    _$AppDatabase, $BookingServicesTableTable, BookingService> {
  $$BookingServicesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BookingsTableTable _bookingIdTable(_$AppDatabase db) =>
      db.bookingsTable.createAlias($_aliasNameGenerator(
          db.bookingServicesTable.bookingId, db.bookingsTable.id));

  $$BookingsTableTableProcessedTableManager get bookingId {
    final $_column = $_itemColumn<int>('booking_id')!;

    final manager = $$BookingsTableTableTableManager($_db, $_db.bookingsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookingServicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookingServicesTableTable> {
  $$BookingServicesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnFilters(column));

  $$BookingsTableTableFilterComposer get bookingId {
    final $$BookingsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookingId,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableFilterComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookingServicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingServicesTableTable> {
  $$BookingServicesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => ColumnOrderings(column));

  $$BookingsTableTableOrderingComposer get bookingId {
    final $$BookingsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookingId,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableOrderingComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookingServicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingServicesTableTable> {
  $$BookingServicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
      column: $table.serviceName, builder: (column) => column);

  $$BookingsTableTableAnnotationComposer get bookingId {
    final $$BookingsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookingId,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookingServicesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookingServicesTableTable,
    BookingService,
    $$BookingServicesTableTableFilterComposer,
    $$BookingServicesTableTableOrderingComposer,
    $$BookingServicesTableTableAnnotationComposer,
    $$BookingServicesTableTableCreateCompanionBuilder,
    $$BookingServicesTableTableUpdateCompanionBuilder,
    (BookingService, $$BookingServicesTableTableReferences),
    BookingService,
    PrefetchHooks Function({bool bookingId})> {
  $$BookingServicesTableTableTableManager(
      _$AppDatabase db, $BookingServicesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingServicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingServicesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingServicesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookingId = const Value.absent(),
            Value<String> serviceName = const Value.absent(),
          }) =>
              BookingServicesTableCompanion(
            id: id,
            bookingId: bookingId,
            serviceName: serviceName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookingId,
            required String serviceName,
          }) =>
              BookingServicesTableCompanion.insert(
            id: id,
            bookingId: bookingId,
            serviceName: serviceName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookingServicesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookingId = false}) {
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
                if (bookingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookingId,
                    referencedTable: $$BookingServicesTableTableReferences
                        ._bookingIdTable(db),
                    referencedColumn: $$BookingServicesTableTableReferences
                        ._bookingIdTable(db)
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
        ));
}

typedef $$BookingServicesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $BookingServicesTableTable,
        BookingService,
        $$BookingServicesTableTableFilterComposer,
        $$BookingServicesTableTableOrderingComposer,
        $$BookingServicesTableTableAnnotationComposer,
        $$BookingServicesTableTableCreateCompanionBuilder,
        $$BookingServicesTableTableUpdateCompanionBuilder,
        (BookingService, $$BookingServicesTableTableReferences),
        BookingService,
        PrefetchHooks Function({bool bookingId})>;
typedef $$PaymentsTableTableCreateCompanionBuilder = PaymentsTableCompanion
    Function({
  Value<int> id,
  required int bookingId,
  required double amount,
  Value<String> paymentMethod,
  Value<DateTime> paymentDate,
  Value<String?> notes,
});
typedef $$PaymentsTableTableUpdateCompanionBuilder = PaymentsTableCompanion
    Function({
  Value<int> id,
  Value<int> bookingId,
  Value<double> amount,
  Value<String> paymentMethod,
  Value<DateTime> paymentDate,
  Value<String?> notes,
});

final class $$PaymentsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTableTable, Payment> {
  $$PaymentsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BookingsTableTable _bookingIdTable(_$AppDatabase db) =>
      db.bookingsTable.createAlias($_aliasNameGenerator(
          db.paymentsTable.bookingId, db.bookingsTable.id));

  $$BookingsTableTableProcessedTableManager get bookingId {
    final $_column = $_itemColumn<int>('booking_id')!;

    final manager = $$BookingsTableTableTableManager($_db, $_db.bookingsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$BookingsTableTableFilterComposer get bookingId {
    final $$BookingsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookingId,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableFilterComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$BookingsTableTableOrderingComposer get bookingId {
    final $$BookingsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookingId,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableOrderingComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$BookingsTableTableAnnotationComposer get bookingId {
    final $$BookingsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookingId,
        referencedTable: $db.bookingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookingsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.bookingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTableTable,
    Payment,
    $$PaymentsTableTableFilterComposer,
    $$PaymentsTableTableOrderingComposer,
    $$PaymentsTableTableAnnotationComposer,
    $$PaymentsTableTableCreateCompanionBuilder,
    $$PaymentsTableTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableTableReferences),
    Payment,
    PrefetchHooks Function({bool bookingId})> {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> bookingId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              PaymentsTableCompanion(
            id: id,
            bookingId: bookingId,
            amount: amount,
            paymentMethod: paymentMethod,
            paymentDate: paymentDate,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int bookingId,
            required double amount,
            Value<String> paymentMethod = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              PaymentsTableCompanion.insert(
            id: id,
            bookingId: bookingId,
            amount: amount,
            paymentMethod: paymentMethod,
            paymentDate: paymentDate,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaymentsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookingId = false}) {
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
                if (bookingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookingId,
                    referencedTable:
                        $$PaymentsTableTableReferences._bookingIdTable(db),
                    referencedColumn:
                        $$PaymentsTableTableReferences._bookingIdTable(db).id,
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

typedef $$PaymentsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTableTable,
    Payment,
    $$PaymentsTableTableFilterComposer,
    $$PaymentsTableTableOrderingComposer,
    $$PaymentsTableTableAnnotationComposer,
    $$PaymentsTableTableCreateCompanionBuilder,
    $$PaymentsTableTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableTableReferences),
    Payment,
    PrefetchHooks Function({bool bookingId})>;
typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
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

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    Setting,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTableTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    Setting,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTableTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(_db, _db.customersTable);
  $$BookingsTableTableTableManager get bookingsTable =>
      $$BookingsTableTableTableManager(_db, _db.bookingsTable);
  $$BookingServicesTableTableTableManager get bookingServicesTable =>
      $$BookingServicesTableTableTableManager(_db, _db.bookingServicesTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
