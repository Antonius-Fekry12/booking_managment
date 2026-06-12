import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/formatters.dart';

// --- Events ---
abstract class BookingsEvent extends Equatable {
  const BookingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllBookings extends BookingsEvent {}

class UpdateSearchQuery extends BookingsEvent {
  final String query;
  const UpdateSearchQuery(this.query);
  @override
  List<Object> get props => [query];
}

class UpdateFilterStatus extends BookingsEvent {
  final String? status;
  const UpdateFilterStatus(this.status);
  @override
  List<Object?> get props => [status];
}

class UpdateSorting extends BookingsEvent {
  final String column;
  const UpdateSorting(this.column);
  @override
  List<Object> get props => [column];
}

class UpdatePage extends BookingsEvent {
  final int page;
  const UpdatePage(this.page);
  @override
  List<Object> get props => [page];
}

class CreateBookingEvent extends BookingsEvent {
  final BookingsTableCompanion booking;
  const CreateBookingEvent(this.booking);
  @override
  List<Object?> get props => [booking];
}

class UpdateBookingEvent extends BookingsEvent {
  final BookingsTableCompanion booking;
  final List<String> services;
  const UpdateBookingEvent(this.booking, this.services);
  @override
  List<Object?> get props => [booking, services];
}

class CancelBookingEvent extends BookingsEvent {
  final int id;
  final String reason;
  const CancelBookingEvent(this.id, this.reason);
  @override
  List<Object?> get props => [id, reason];
}

class DeleteBookingEvent extends BookingsEvent {
  final int id;
  const DeleteBookingEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// --- State ---
enum BookingsStatus { initial, loading, success, failure }

class BookingsState extends Equatable {
  final BookingsStatus status;
  final List<Booking> bookings;
  final Map<int, Customer> customers;
  final String searchQuery;
  final String? filterStatus;
  final String sortColumn;
  final bool sortAscending;
  final int currentPage;
  final int pageSize;
  final String? errorMessage;

  const BookingsState({
    this.status = BookingsStatus.initial,
    this.bookings = const [],
    this.customers = const {},
    this.searchQuery = '',
    this.filterStatus,
    this.sortColumn = 'date',
    this.sortAscending = false,
    this.currentPage = 1,
    this.pageSize = 20,
    this.errorMessage,
  });

  BookingsState copyWith({
    BookingsStatus? status,
    List<Booking>? bookings,
    Map<int, Customer>? customers,
    String? searchQuery,
    Object? filterStatus = _sentinel,
    String? sortColumn,
    bool? sortAscending,
    int? currentPage,
    int? pageSize,
    String? errorMessage,
  }) {
    return BookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus == _sentinel ? this.filterStatus : filterStatus as String?,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static const _sentinel = Object();

  // Reactive getters
  List<Booking> get filteredBookings {
    final query = searchQuery.toLowerCase();
    return bookings.where((b) {
      // 1. Status / cancellation filter
      if (filterStatus != null) {
        if (filterStatus == 'cancelled') {
          // show only cancelled (either status column OR isCancelled flag)
          if (b.status != 'cancelled' && !b.isCancelled) return false;
        } else {
          // for other statuses, exclude cancelled bookings
          if (b.status != filterStatus || b.isCancelled) return false;
        }
      }

      // 2. Search Query Filter
      if (query.isEmpty) return true;
      final customer = customers[b.customerId];
      final name = customer?.name.toLowerCase() ?? '';
      final phone = customer?.phone.toLowerCase() ?? '';
      final eventType = b.eventType.toLowerCase();
      final eventLabel = AppConstants.getEventLabel(b.eventType).toLowerCase();
      final venue = b.venue?.toLowerCase() ?? '';
      final number = b.bookingNumber.toLowerCase();

      return name.contains(query) ||
          phone.contains(query) ||
          eventType.contains(query) ||
          eventLabel.contains(query) ||
          venue.contains(query) ||
          number.contains(query);
    }).toList();
  }

  List<Booking> get sortedBookings {
    final list = List<Booking>.from(filteredBookings);
    list.sort((a, b) {
      int cmp;
      switch (sortColumn) {
        case 'customerName':
          final nameA = customers[a.customerId]?.name ?? '';
          final nameB = customers[b.customerId]?.name ?? '';
          cmp = nameA.compareTo(nameB);
          break;
        case 'date':
        case 'time':
          cmp = a.bookingDate.compareTo(b.bookingDate);
          break;
        case 'eventType':
          cmp = AppConstants.getEventLabel(a.eventType)
              .compareTo(AppConstants.getEventLabel(b.eventType));
          break;
        case 'status':
          cmp = AppConstants.getStatusLabel(a.status)
              .compareTo(AppConstants.getStatusLabel(b.status));
          break;
        case 'price':
          cmp = a.totalAmount.compareTo(b.totalAmount);
          break;
        default:
          cmp = a.bookingDate.compareTo(b.bookingDate);
      }
      return sortAscending ? cmp : -cmp;
    });
    return list;
  }

  List<Booking> get paginatedBookings {
    final list = sortedBookings;
    final start = (currentPage - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  int get totalPages {
    final count = filteredBookings.length;
    if (count == 0) return 1;
    return (count / pageSize).ceil();
  }

  @override
  List<Object?> get props => [
        status,
        bookings,
        customers,
        searchQuery,
        filterStatus,
        sortColumn,
        sortAscending,
        currentPage,
        pageSize,
        errorMessage,
      ];
}

// --- BLoC ---
class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final AppDatabase _db = sl<AppDatabase>();

  BookingsBloc() : super(const BookingsState()) {
    on<LoadAllBookings>(_onLoadAllBookings);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<UpdateFilterStatus>(_onUpdateFilterStatus);
    on<UpdateSorting>(_onUpdateSorting);
    on<UpdatePage>(_onUpdatePage);
    on<CreateBookingEvent>(_onCreateBooking);
    on<UpdateBookingEvent>(_onUpdateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<DeleteBookingEvent>(_onDeleteBooking);
  }

  Future<void> _onLoadAllBookings(
    LoadAllBookings event,
    Emitter<BookingsState> emit,
  ) async {
    emit(state.copyWith(status: BookingsStatus.loading));
    try {
      final bookings = await _db.getAllBookings();
      final customersList = await _db.getAllCustomers();
      final customersMap = {for (var c in customersList) c.id: c};
      
      emit(state.copyWith(
        status: BookingsStatus.success,
        bookings: bookings,
        customers: customersMap,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<BookingsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query, currentPage: 1));
  }

  void _onUpdateFilterStatus(
    UpdateFilterStatus event,
    Emitter<BookingsState> emit,
  ) {
    // If null, we pass 'null' explicitly to avoid being ignored by copyWith default check
    emit(BookingsState(
      status: state.status,
      bookings: state.bookings,
      customers: state.customers,
      searchQuery: state.searchQuery,
      filterStatus: event.status,
      sortColumn: state.sortColumn,
      sortAscending: state.sortAscending,
      currentPage: 1,
      pageSize: state.pageSize,
      errorMessage: state.errorMessage,
    ));
  }

  void _onUpdateSorting(
    UpdateSorting event,
    Emitter<BookingsState> emit,
  ) {
    final isSame = state.sortColumn == event.column;
    emit(state.copyWith(
      sortColumn: event.column,
      sortAscending: isSame ? !state.sortAscending : true,
      currentPage: 1,
    ));
  }

  void _onUpdatePage(
    UpdatePage event,
    Emitter<BookingsState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    try {
      await _db.insertBooking(event.booking);
      add(LoadAllBookings()); // reload after create
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateBooking(
    UpdateBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    try {
      await _db.updateBooking(event.booking);
      // Replace services
      final bookingId = event.booking.id.value;
      await _db.replaceServicesForBooking(bookingId, event.services);
      add(LoadAllBookings());
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    try {
      await _db.cancelBooking(event.id, event.reason);
      add(LoadAllBookings());
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteBooking(
    DeleteBookingEvent event,
    Emitter<BookingsState> emit,
  ) async {
    try {
      await _db.softDeleteBooking(event.id);
      add(LoadAllBookings()); // reload after delete
    } catch (e) {
      emit(state.copyWith(
        status: BookingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
