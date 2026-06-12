// lib/features/bookings/presentation/create_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';
import '../../../core/di/service_locator.dart';
import '../bloc/bookings_bloc.dart';

class CreateBookingScreen extends StatefulWidget {
  final int? editBookingId;
  const CreateBookingScreen({super.key, this.editBookingId});

  @override
  State<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _socialCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _staffCtrl = TextEditingController();
  final _totalCtrl = TextEditingController(text: '0');
  final _paidCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  // State
  DateTime _selectedDate = DateTime.now();
  String? _eventType;
  // ignore: prefer_final_fields
  Set<String> _selectedServices = {};
  String _status = 'confirmed';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isEditMode = false;
  Booking? _existingBooking;
  Customer? _existingCustomer;
  bool _prefilled = false; // guard against double-init

  double get _remaining {
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;
    return total - paid;
  }

  @override
  void initState() {
    super.initState();
    if (widget.editBookingId != null) {
      _isEditMode = true;
      _loadExistingBooking();
    }
  }

  /// Load the existing booking from DB and prefill all controllers.
  Future<void> _loadExistingBooking() async {
    if (_prefilled) return;
    _prefilled = true;
    try {
      final db = sl<AppDatabase>();
      final booking = await db.getBookingById(widget.editBookingId!);
      if (booking == null) return;
      final customer = await db.getCustomerById(booking.customerId);
      final services = await db.getServicesForBooking(widget.editBookingId!);

      if (!mounted) return;
      setState(() {
        _existingBooking = booking;
        _existingCustomer = customer;

        // Prefill controllers
        _nameCtrl.text = customer?.name ?? '';
        _phoneCtrl.text = customer?.phone ?? '';
        _socialCtrl.text = customer?.social ?? '';
        _venueCtrl.text = booking.venue ?? '';
        _staffCtrl.text = booking.staff ?? '';
        _totalCtrl.text = booking.totalAmount.toStringAsFixed(0);
        _paidCtrl.text = booking.paidAmount.toStringAsFixed(0);
        _notesCtrl.text = booking.notes ?? '';
        _timeCtrl.text = booking.timeStart ?? '';
        _selectedDate = booking.bookingDate;
        _eventType = booking.eventType;
        _selectedServices = services.map((s) => s.serviceName).toSet();
        _status = booking.status;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _socialCtrl.dispose();
    _venueCtrl.dispose();
    _staffCtrl.dispose();
    _totalCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'ص' : 'م';
      setState(() {
        _timeCtrl.text = '$hour:$minute $period';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventType == null) {
      setState(() => _errorMessage = 'الرجاء اختيار نوع المناسبة');
      return;
    }
    if (_timeCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'الرجاء اختيار وقت الحجز');
      return;
    }

    if (!_isEditMode) {
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      if (selectedDateOnly.isBefore(today)) {
        setState(() {
          _errorMessage = 'تاريخ الحجز لا يمكن أن يكون في الماضي';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final db = sl<AppDatabase>();
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;

    try {
      // ─── EDIT MODE ────────────────────────────────────────────
      if (_isEditMode && _existingBooking != null) {
        // Update customer info
        if (_existingCustomer != null) {
          await db.updateCustomer(
            CustomersTableCompanion(
              id: Value(_existingCustomer!.id),
              name: Value(_nameCtrl.text.trim()),
              phone: Value(_phoneCtrl.text.trim()),
              social: Value(_socialCtrl.text.trim().isEmpty
                  ? null
                  : _socialCtrl.text.trim()),
            ),
          );
        }

        final updatedBooking = BookingsTableCompanion(
          id: Value(_existingBooking!.id),
          bookingNumber: Value(_existingBooking!.bookingNumber),
          customerId: Value(_existingBooking!.customerId),
          eventType: Value(_eventType!),
          bookingDate: Value(_selectedDate),
          venue: Value(_venueCtrl.text.trim().isEmpty
              ? null
              : _venueCtrl.text.trim()),
          staff: Value(_staffCtrl.text.trim().isEmpty
              ? null
              : _staffCtrl.text.trim()),
          timeStart: Value(_timeCtrl.text.trim().isEmpty
              ? null
              : _timeCtrl.text.trim()),
          totalAmount: Value(total),
          paidAmount: Value(paid),
          remainingAmount: Value(total - paid),
          status: Value(_status),
          notes: Value(_notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim()),
          updatedAt: Value(DateTime.now()),
        );

        if (mounted) {
          context.read<BookingsBloc>().add(
                UpdateBookingEvent(updatedBooking, _selectedServices.toList()),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الحجز بنجاح',
                  style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/bookings/${_existingBooking!.id}');
        }
        return;
      }

      // ─── CREATE MODE ──────────────────────────────────────────
      // Check for duplicate booking
      final isDuplicate = await db.isDateBooked(_selectedDate);
      final allowDuplicates =
          await db.getSetting('allow_duplicate_bookings') == 'true';

      if (isDuplicate && !allowDuplicates) {
        setState(() {
          _errorMessage = 'هذا اليوم محجوز مسبقاً. يمكنك تغيير الإعداد للسماح بحجوزات متعددة.';
          _isLoading = false;
        });
        return;
      }

      // Create/find customer
      final customers = await db.getAllCustomers();
      int customerId;
      final existingCustomer = customers.firstWhere(
        (c) => c.phone == _phoneCtrl.text.trim(),
        orElse: () => Customer(
          id: -1,
          name: '',
          phone: '',
          social: null,
          createdAt: DateTime.now(),
        ),
      );

      if (existingCustomer.id == -1) {
        customerId = await db.insertCustomer(
          CustomersTableCompanion.insert(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            social: Value(_socialCtrl.text.trim().isEmpty
                ? null
                : _socialCtrl.text.trim()),
          ),
        );
      } else {
        customerId = existingCustomer.id;
      }

      // Generate booking number
      const uuid = Uuid();
      final bookingNumber =
          'BK-${uuid.v4().substring(0, 4).toUpperCase()}';

      // Insert booking
      final bookingId = await db.insertBooking(
        BookingsTableCompanion.insert(
          bookingNumber: bookingNumber,
          customerId: customerId,
          eventType: _eventType!,
          bookingDate: _selectedDate,
          venue: Value(_venueCtrl.text.trim().isEmpty
              ? null
              : _venueCtrl.text.trim()),
          staff: Value(_staffCtrl.text.trim().isEmpty
              ? null
              : _staffCtrl.text.trim()),
          timeStart: Value(_timeCtrl.text.trim().isEmpty
              ? null
              : _timeCtrl.text.trim()),
          totalAmount: Value(total),
          paidAmount: Value(paid),
          remainingAmount: Value(total - paid),
          status: Value(_status),
          notes: Value(_notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim()),
        ),
      );

      // Insert services
      await db.replaceServicesForBooking(
          bookingId, _selectedServices.toList());

      // Insert initial payment if paid > 0
      if (paid > 0) {
        await db.addPayment(
          PaymentsTableCompanion.insert(
            bookingId: bookingId,
            amount: paid,
            paymentMethod: const Value('cash'),
          ),
        );
      }

      if (mounted) {
        context.read<BookingsBloc>().add(LoadAllBookings());
        context.go('/bookings/$bookingId');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Calendar + actions
                _buildLeftPanel(),
                // Right: Form
                Expanded(
                  child: _buildForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            _isEditMode ? 'تعديل الحجز' : 'إنشاء حجز جديد',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textSecondary),
          const Spacer(),
          // Search
          Container(
            width: 220,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search_rounded,
                      size: 18, color: AppColors.textTertiary),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث...',
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
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_rounded,
                color: AppColors.textSecondary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 260,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'تاريخ الحجز',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInlineCalendar(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('تأكيد الحجز'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Cancel
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'إلغاء العملية',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم إرسال رسالة نصية للعميل لتأكيد الحجز فور الضغط على زر "تأكيد الحجز". تأكد من صحة البيانات المالية.',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.danger, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineCalendar() {
    final now = DateTime.now();
    final daysInMonth =
        DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final firstWeekday =
        DateTime(_selectedDate.year, _selectedDate.month, 1).weekday % 7;

    return Column(
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              onPressed: () => setState(() {
                _selectedDate = DateTime(
                    _selectedDate.year, _selectedDate.month - 1, 1);
              }),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text(
              _arabicMonthYear(_selectedDate),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              onPressed: () => setState(() {
                _selectedDate = DateTime(
                    _selectedDate.year, _selectedDate.month + 1, 1);
              }),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Weekday headers
        Row(
          children: ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox.shrink();
            final day = index - firstWeekday + 1;
            final date = DateTime(_selectedDate.year, _selectedDate.month, day);
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;
            final isToday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

            return GestureDetector(
              onTap: isPast ? null : () => setState(() {
                    _selectedDate = date;
                  }),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primaryLighter
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : isPast
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                      fontWeight:
                          isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info
            _SectionCard(
              icon: Icons.person_outline_rounded,
              title: 'بيانات العميل',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'الاسم الكامل',
                          hint: 'مثلاً: محمد عبدالله',
                          controller: _nameCtrl,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'اسم العميل مطلوب';
                            if (v.trim().length < 3) return 'الاسم لا يقل عن 3 أحرف';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FormField(
                          label: 'رقم الهاتف',
                          hint: 'مثلاً: 01xxxxxxxxx',
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'رقم الهاتف مطلوب';
                            final trimmed = v.trim();
                            if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) return 'يجب إدخال أرقام فقط';
                            if (trimmed.length < 10 || trimmed.length > 15) {
                              return 'رقم الهاتف يجب أن يكون بين 10 و 15 رقماً';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'التواصل الاجتماعي (اختياري)',
                    hint: '@username',
                    controller: _socialCtrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Event details
            _SectionCard(
              icon: Icons.celebration_rounded,
              title: 'تفاصيل المناسبة',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'نوع المناسبة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _eventType,
                              hint: const Text(
                                'اختر نوع المناسبة...',
                                style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: AppColors.border)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: AppColors.border)),
                              ),
                              items: AppConstants.eventTypes
                                  .map((e) => DropdownMenuItem(
                                        value: e['key'],
                                        child: Text(e['label']!,
                                            style: const TextStyle(fontFamily: 'Cairo')),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _eventType = v),
                              validator: (v) => v == null ? 'نوع المناسبة مطلوب' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectTime(context),
                          child: AbsorbPointer(
                            child: _FormField(
                              label: 'وقت الحجز',
                              hint: 'اختر الوقت...',
                              controller: _timeCtrl,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'وقت الحجز مطلوب' : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'الخدمات المطلوبة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.serviceTypes.map((s) {
                      final key = s['key']!;
                      final isSelected = _selectedServices.contains(key);
                      return FilterChip(
                        label: Text(s['label']!),
                        selected: isSelected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _selectedServices.add(key);
                          } else {
                            _selectedServices.remove(key);
                          }
                        }),
                        selectedColor: AppColors.primaryLighter,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                        ),
                        backgroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'موقع التصوير (اختياري)',
                          hint: 'مثلاً: قاعة الأوركيد',
                          controller: _venueCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FormField(
                          label: 'فريق العمل (اختياري)',
                          hint: 'أحمد، ليلى + مساعدين',
                          controller: _staffCtrl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Financial
            _SectionCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'البيانات المالية',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FinancialField(
                          label: 'السعر الإجمالي',
                          controller: _totalCtrl,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'السعر الإجمالي مطلوب';
                            final val = double.tryParse(v.trim());
                            if (val == null) return 'يجب إدخال أرقام فقط';
                            if (val < 0) return 'يجب أن يكون السعر أكبر من أو يساوي صفر';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _FinancialField(
                          label: 'المبلغ المدفوع',
                          controller: _paidCtrl,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final val = double.tryParse(v.trim());
                            if (val == null) return 'يجب إدخال أرقام فقط';
                            if (val < 0) return 'يجب أن يكون المبلغ أكبر من أو يساوي صفر';
                            final total = double.tryParse(_totalCtrl.text.trim()) ?? 0;
                            if (val > total) {
                              return 'المبلغ المدفوع لا يمكن أن يكون أكبر من السعر الإجمالي';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _remaining > 0
                                ? AppColors.dangerLight
                                : AppColors.successLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _remaining > 0
                                  ? AppColors.danger.withOpacity(0.3)
                                  : AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'المبلغ المتبقي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_remaining.toStringAsFixed(2)} ج.م',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _remaining > 0
                                      ? AppColors.danger
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status
                  Row(
                    children: [
                      const Text(
                        'حالة الحجز:',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ...AppConstants.statusTypes.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(s['label']!),
                            selected: _status == s['key'],
                            onSelected: (v) {
                              if (v) setState(() => _status = s['key']!);
                            },
                            selectedColor: AppColors.primaryLighter,
                            labelStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: _status == s['key']
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'ملاحظات (اختياري)',
                    hint: 'أي ملاحظات إضافية...',
                    controller: _notesCtrl,
                    maxLines: 3,
                    validator: (v) {
                      if (v != null && v.length > 500) {
                        return 'الملاحظات لا يمكن أن تزيد عن 500 حرف';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _arabicMonthYear(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const _FinancialField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            prefixText: 'ج.م  ',
            prefixStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
