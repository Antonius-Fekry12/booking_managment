import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';

// --- Events ---
abstract class CustomersEvent extends Equatable {
  const CustomersEvent();
  @override
  List<Object> get props => [];
}

class LoadCustomers extends CustomersEvent {}

class AddCustomerEvent extends CustomersEvent {
  final CustomersTableCompanion customer;
  const AddCustomerEvent(this.customer);
  @override
  List<Object> get props => [customer];
}

class SearchCustomersEvent extends CustomersEvent {
  final String query;
  const SearchCustomersEvent(this.query);
  @override
  List<Object> get props => [query];
}

// --- State ---
enum CustomersStatus { initial, loading, success, failure }

class CustomersState extends Equatable {
  final CustomersStatus status;
  final List<Customer> customers;
  final String searchQuery;
  final String? errorMessage;

  const CustomersState({
    this.status = CustomersStatus.initial,
    this.customers = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  CustomersState copyWith({
    CustomersStatus? status,
    List<Customer>? customers,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CustomersState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, customers, searchQuery, errorMessage];
}

// --- BLoC ---
class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final AppDatabase _db = sl<AppDatabase>();

  CustomersBloc() : super(const CustomersState()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<SearchCustomersEvent>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    emit(state.copyWith(status: CustomersStatus.loading));
    try {
      final customers = await _db.getAllCustomers();
      emit(state.copyWith(
        status: CustomersStatus.success,
        customers: customers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CustomersStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await _db.insertCustomer(event.customer);
      add(LoadCustomers());
    } catch (e) {
      emit(state.copyWith(
        status: CustomersStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchCustomers(
    SearchCustomersEvent event,
    Emitter<CustomersState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
