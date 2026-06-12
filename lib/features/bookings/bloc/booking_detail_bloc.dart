import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';

// --- Events ---
abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookingDetail extends BookingDetailEvent {
  final int bookingId;
  const LoadBookingDetail(this.bookingId);
  @override
  List<Object> get props => [bookingId];
}

class AddPaymentEvent extends BookingDetailEvent {
  final PaymentsTableCompanion payment;
  const AddPaymentEvent(this.payment);
  @override
  List<Object> get props => [payment];
}

class CancelBookingDetailEvent extends BookingDetailEvent {
  final String reason;
  const CancelBookingDetailEvent(this.reason);
  @override
  List<Object> get props => [reason];
}

class RefreshBookingDetailEvent extends BookingDetailEvent {}

// --- State ---
enum BookingDetailStatus { initial, loading, success, failure }

class BookingDetailState extends Equatable {
  final BookingDetailStatus status;
  final Booking? booking;
  final Customer? customer;
  final List<BookingService> services;
  final List<Payment> payments;
  final String? errorMessage;
  final bool paymentAdded; // transient flag for snackbar

  const BookingDetailState({
    this.status = BookingDetailStatus.initial,
    this.booking,
    this.customer,
    this.services = const [],
    this.payments = const [],
    this.errorMessage,
    this.paymentAdded = false,
  });

  BookingDetailState copyWith({
    BookingDetailStatus? status,
    Booking? booking,
    Customer? customer,
    List<BookingService>? services,
    List<Payment>? payments,
    String? errorMessage,
    bool? paymentAdded,
  }) {
    return BookingDetailState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      customer: customer ?? this.customer,
      services: services ?? this.services,
      payments: payments ?? this.payments,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentAdded: paymentAdded ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [status, booking, customer, services, payments, errorMessage, paymentAdded];
}

// --- BLoC ---
class BookingDetailBloc
    extends Bloc<BookingDetailEvent, BookingDetailState> {
  final AppDatabase _db = sl<AppDatabase>();

  BookingDetailBloc() : super(const BookingDetailState()) {
    on<LoadBookingDetail>(_onLoadBookingDetail);
    on<RefreshBookingDetailEvent>(_onRefresh);
    on<AddPaymentEvent>(_onAddPayment);
    on<CancelBookingDetailEvent>(_onCancelBooking);
  }

  Future<void> _onLoadBookingDetail(
    LoadBookingDetail event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(state.copyWith(status: BookingDetailStatus.loading));
    await _loadData(event.bookingId, emit);
  }

  Future<void> _onRefresh(
    RefreshBookingDetailEvent event,
    Emitter<BookingDetailState> emit,
  ) async {
    if (state.booking == null) return;
    await _loadData(state.booking!.id, emit);
  }

  Future<void> _loadData(int bookingId, Emitter<BookingDetailState> emit) async {
    try {
      final booking = await _db.getBookingById(bookingId);
      if (booking == null) throw Exception('Booking not found');

      final customer = await _db.getCustomerById(booking.customerId);
      final services = await _db.getServicesForBooking(bookingId);
      final payments = await _db.getPaymentsForBooking(bookingId);

      emit(state.copyWith(
        status: BookingDetailStatus.success,
        booking: booking,
        customer: customer,
        services: services,
        payments: payments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddPayment(
    AddPaymentEvent event,
    Emitter<BookingDetailState> emit,
  ) async {
    try {
      final booking = state.booking;
      if (booking == null) return;

      // Insert payment
      await _db.addPayment(event.payment);

      // Recalculate booking amounts
      final allPayments = await _db.getPaymentsForBooking(booking.id);
      final totalPaid = allPayments.fold<double>(0, (sum, p) => sum + p.amount);
      final newRemaining = (booking.totalAmount - totalPaid).clamp(0.0, double.infinity);

      await _db.updateBookingAmounts(booking.id, totalPaid, newRemaining);

      // Reload full detail
      await _loadData(booking.id, emit);

      // Signal payment was added (for snackbar)
      emit(state.copyWith(paymentAdded: true));
    } catch (e) {
      emit(state.copyWith(
        status: BookingDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingDetailEvent event,
    Emitter<BookingDetailState> emit,
  ) async {
    try {
      final booking = state.booking;
      if (booking == null) return;

      await _db.cancelBooking(booking.id, event.reason);

      // Reload to reflect cancellation
      await _loadData(booking.id, emit);
    } catch (e) {
      emit(state.copyWith(
        status: BookingDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
