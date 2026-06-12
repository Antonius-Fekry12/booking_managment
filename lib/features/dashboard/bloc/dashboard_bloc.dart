import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/formatters.dart';

// --- Events ---
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class UpdateSearchQuery extends DashboardEvent {
  final String query;
  const UpdateSearchQuery(this.query);
  @override
  List<Object> get props => [query];
}

class UpdateSorting extends DashboardEvent {
  final String column;
  const UpdateSorting(this.column);
  @override
  List<Object> get props => [column];
}

class UpdatePendingSort extends DashboardEvent {
  final String criteria;
  const UpdatePendingSort(this.criteria);
  @override
  List<Object> get props => [criteria];
}

// --- State ---
enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final Map<String, dynamic> stats;
  final List<Booking> upcomingBookings;
  final List<Booking> pendingBookings;
  final Map<int, Customer> customers;
  final String searchQuery;
  final String sortColumn;
  final bool sortAscending;
  final String pendingSortCriteria;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats = const {},
    this.upcomingBookings = const [],
    this.pendingBookings = const [],
    this.customers = const {},
    this.searchQuery = '',
    this.sortColumn = 'date',
    this.sortAscending = true,
    this.pendingSortCriteria = 'date',
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    Map<String, dynamic>? stats,
    List<Booking>? upcomingBookings,
    List<Booking>? pendingBookings,
    Map<int, Customer>? customers,
    String? searchQuery,
    String? sortColumn,
    bool? sortAscending,
    String? pendingSortCriteria,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      pendingSortCriteria: pendingSortCriteria ?? this.pendingSortCriteria,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<Booking> get filteredUpcomingBookings {
    final query = searchQuery.toLowerCase();
    
    // 1. Filter
    final filtered = upcomingBookings.where((b) {
      if (query.isEmpty) return true;
      final customer = customers[b.customerId];
      final name = customer?.name.toLowerCase() ?? '';
      final phone = customer?.phone.toLowerCase() ?? '';
      final eventType = b.eventType.toLowerCase();
      final eventLabel = AppConstants.getEventLabel(b.eventType).toLowerCase();
      final venue = b.venue?.toLowerCase() ?? '';

      return name.contains(query) ||
          phone.contains(query) ||
          eventType.contains(query) ||
          eventLabel.contains(query) ||
          venue.contains(query);
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
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
        case 'amount':
          cmp = a.totalAmount.compareTo(b.totalAmount);
          break;
        case 'status':
          cmp = AppConstants.getStatusLabel(a.status)
              .compareTo(AppConstants.getStatusLabel(b.status));
          break;
        default:
          cmp = a.bookingDate.compareTo(b.bookingDate);
      }
      return sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  List<Booking> get sortedPendingBookings {
    final list = pendingBookings.where((b) => b.remainingAmount > 0).toList();
    list.sort((a, b) {
      switch (pendingSortCriteria) {
        case 'amount':
          return b.remainingAmount.compareTo(a.remainingAmount);
        case 'date':
          return a.bookingDate.compareTo(b.bookingDate);
        case 'customerName':
          final nameA = customers[a.customerId]?.name ?? '';
          final nameB = customers[b.customerId]?.name ?? '';
          return nameA.compareTo(nameB);
        default:
          return a.bookingDate.compareTo(b.bookingDate);
      }
    });
    return list;
  }

  @override
  List<Object?> get props => [
        status,
        stats,
        upcomingBookings,
        pendingBookings,
        customers,
        searchQuery,
        sortColumn,
        sortAscending,
        pendingSortCriteria,
        errorMessage,
      ];
}

// --- BLoC ---
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AppDatabase _db = sl<AppDatabase>();

  DashboardBloc() : super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<UpdateSorting>(_onUpdateSorting);
    on<UpdatePendingSort>(_onUpdatePendingSort);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final stats = await _db.getDashboardStats();
      final upcoming = await _db.getUpcomingBookings();
      final allBookings = await _db.getAllBookings();
      final customersList = await _db.getAllCustomers();
      final customersMap = {for (var c in customersList) c.id: c};

      // Exclude cancelled from upcoming + pending lists shown in the dashboard
      final activeUpcoming = upcoming.where((b) => !b.isCancelled).toList();
      final activeAll = allBookings.where((b) => !b.isCancelled).toList();

      emit(state.copyWith(
        status: DashboardStatus.success,
        stats: stats,
        upcomingBookings: activeUpcoming,
        pendingBookings: activeAll,
        customers: customersMap,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onUpdateSorting(
    UpdateSorting event,
    Emitter<DashboardState> emit,
  ) {
    final isSame = state.sortColumn == event.column;
    emit(state.copyWith(
      sortColumn: event.column,
      sortAscending: isSame ? !state.sortAscending : true,
    ));
  }

  void _onUpdatePendingSort(
    UpdatePendingSort event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(pendingSortCriteria: event.criteria));
  }
}
