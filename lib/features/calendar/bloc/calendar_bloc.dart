import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';

// --- Events ---
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object> get props => [];
}

class LoadMonthBookings extends CalendarEvent {
  final DateTime month;
  const LoadMonthBookings(this.month);
  @override
  List<Object> get props => [month];
}

class ChangeMonthEvent extends CalendarEvent {
  final DateTime month;
  const ChangeMonthEvent(this.month);
  @override
  List<Object> get props => [month];
}

class DeleteCalendarBookingEvent extends CalendarEvent {
  final int id;
  const DeleteCalendarBookingEvent(this.id);
  @override
  List<Object> get props => [id];
}

// --- State ---
enum CalendarStatus { initial, loading, success, failure }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final DateTime currentMonth;
  final List<Booking> bookings;
  final String? errorMessage;

  const CalendarState({
    this.status = CalendarStatus.initial,
    required this.currentMonth,
    this.bookings = const [],
    this.errorMessage,
  });

  CalendarState copyWith({
    CalendarStatus? status,
    DateTime? currentMonth,
    List<Booking>? bookings,
    String? errorMessage,
  }) {
    return CalendarState(
      status: status ?? this.status,
      currentMonth: currentMonth ?? this.currentMonth,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentMonth, bookings, errorMessage];
}

// --- BLoC ---
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final AppDatabase _db = sl<AppDatabase>();

  CalendarBloc() : super(CalendarState(currentMonth: DateTime.now())) {
    on<LoadMonthBookings>(_onLoadMonthBookings);
    on<ChangeMonthEvent>(_onChangeMonth);
    on<DeleteCalendarBookingEvent>(_onDeleteBooking);
  }

  Future<void> _onLoadMonthBookings(
    LoadMonthBookings event,
    Emitter<CalendarState> emit,
  ) async {
    emit(state.copyWith(status: CalendarStatus.loading));
    try {
      final all = await _db.getAllBookings();
      final monthBookings = all
          .where((b) =>
              b.bookingDate.year == event.month.year &&
              b.bookingDate.month == event.month.month)
          .toList();
      emit(state.copyWith(
        status: CalendarStatus.success,
        bookings: monthBookings,
        currentMonth: event.month,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonthEvent event,
    Emitter<CalendarState> emit,
  ) async {
    add(LoadMonthBookings(event.month));
  }

  Future<void> _onDeleteBooking(
    DeleteCalendarBookingEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      await _db.softDeleteBooking(event.id);
      add(LoadMonthBookings(state.currentMonth));
    } catch (e) {
      emit(state.copyWith(
        status: CalendarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
