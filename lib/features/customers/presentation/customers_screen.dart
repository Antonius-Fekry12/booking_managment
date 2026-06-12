// lib/features/customers/presentation/customers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';
import 'package:drift/drift.dart' hide Column;
import '../bloc/customers_bloc.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _showAddForm = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _socialCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCustomer() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) return;
    final customer = CustomersTableCompanion.insert(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      social: Value(_socialCtrl.text.isEmpty ? null : _socialCtrl.text.trim()),
    );
    context.read<CustomersBloc>().add(AddCustomerEvent(customer));
    setState(() {
      _showAddForm = false;
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _socialCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomersBloc()..add(LoadCustomers()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<CustomersBloc, CustomersState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                if (_showAddForm) _buildAddForm(),
                Expanded(
                  child: state.status == CustomersStatus.loading || state.status == CustomersStatus.initial
                      ? const Center(child: CircularProgressIndicator())
                      : state.status == CustomersStatus.failure
                          ? Center(child: Text('${state.errorMessage}'))
                          : Builder(
                              builder: (context) {
                                final filtered = state.customers
                                    .where((c) =>
                                        state.searchQuery.isEmpty ||
                                        c.name.contains(state.searchQuery) ||
                                        c.phone.contains(state.searchQuery))
                                    .toList();
                                return _buildList(context, filtered);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('العملاء', style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          Container(
            width: 240,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search_rounded,
                      size: 18, color: AppColors.textTertiary),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (v) => context.read<CustomersBloc>().add(SearchCustomersEvent(v)),
                    decoration: const InputDecoration(
                      hintText: 'بحث في العملاء...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () =>
                setState(() => _showAddForm = !_showAddForm),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('إضافة عميل'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إضافة عميل جديد',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameCtrl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    hintText: 'محمد أحمد',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '+966 5x xxx xxxx',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _socialCtrl,
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: const InputDecoration(
                    labelText: 'التواصل الاجتماعي (اختياري)',
                    hintText: '@username',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _addCustomer,
                child: const Text('حفظ'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () =>
                    setState(() => _showAddForm = false),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Customer> customers) {
    if (customers.isEmpty) {
      return const Center(
        child: Text('لا يوجد عملاء',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                color: AppColors.textSecondary)),
      );
    }

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                  bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TH('الاسم')),
                Expanded(flex: 2, child: _TH('رقم الهاتف')),
                Expanded(flex: 2, child: _TH('التواصل الاجتماعي')),
                Expanded(flex: 2, child: _TH('تاريخ التسجيل')),
                SizedBox(width: 60),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = customers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryLighter,
                              child: Text(
                                c.name.isNotEmpty ? c.name[0] : '?',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(c.name,
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(c.phone,
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 13)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          c.social ?? '—',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          AppFormatters.formatDateShort(
                              c.createdAt),
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                              Icons.more_vert_rounded,
                              size: 18,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary));
  }
}
