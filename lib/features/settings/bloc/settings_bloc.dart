import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';

// --- Events ---
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class SaveSettings extends SettingsEvent {
  final String studioName;
  final bool allowDuplicateBookings;
  final String currency;

  const SaveSettings({
    required this.studioName,
    required this.allowDuplicateBookings,
    required this.currency,
  });

  @override
  List<Object> get props => [studioName, allowDuplicateBookings, currency];
}

// --- State ---
enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String studioName;
  final bool allowDuplicateBookings;
  final String currency;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.studioName = 'ستوديو التصوير',
    this.allowDuplicateBookings = false,
    this.currency = 'ج.م',
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    String? studioName,
    bool? allowDuplicateBookings,
    String? currency,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      studioName: studioName ?? this.studioName,
      allowDuplicateBookings: allowDuplicateBookings ?? this.allowDuplicateBookings,
      currency: currency ?? this.currency,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, studioName, allowDuplicateBookings, currency, errorMessage];
}

// --- BLoC ---
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AppDatabase _db = sl<AppDatabase>();

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveSettings>(_onSaveSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final studioName = await _db.getSetting('studio_name');
      final allowDup = await _db.getSetting('allow_duplicate_bookings');
      final currency = await _db.getSetting('currency');

      emit(state.copyWith(
        status: SettingsStatus.success,
        studioName: studioName ?? 'ستوديو التصوير',
        allowDuplicateBookings: allowDup == 'true',
        currency: currency ?? 'ج.م',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSaveSettings(
    SaveSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _db.setSetting('studio_name', event.studioName);
      await _db.setSetting('allow_duplicate_bookings', event.allowDuplicateBookings.toString());
      await _db.setSetting('currency', event.currency);

      emit(state.copyWith(
        status: SettingsStatus.success,
        studioName: event.studioName,
        allowDuplicateBookings: event.allowDuplicateBookings,
        currency: event.currency,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
