// lib/features/settings/presentation/settings_screen.dart
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _studioNameCtrl = TextEditingController();
  bool _allowDuplicateBookings = false;
  String _currency = 'ج.م';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // BLoC triggers LoadSettings on create; no manual _loadSettings call needed.
  }

  // Settings are loaded via BLoC – no manual load needed.
  void _syncFromState(SettingsState state) {
    if (_isLoading) {
      _studioNameCtrl.text = state.studioName;
      _allowDuplicateBookings = state.allowDuplicateBookings;
      _currency = state.currency;
      _isLoading = false;
    }
  }

  Future<void> _saveSettings(BuildContext context) async {
    context.read<SettingsBloc>().add(SaveSettings(
      studioName: _studioNameCtrl.text,
      allowDuplicateBookings: _allowDuplicateBookings,
      currency: _currency,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _studioNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc()..add(LoadSettings()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state.status == SettingsStatus.initial ||
                state.status == SettingsStatus.loading) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                      child: Center(child: CircularProgressIndicator())),
                ],
              );
            }
            if (_isLoading) _syncFromState(state);
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: 'إعدادات الستوديو',
                          icon: Icons.business_rounded,
                          children: [
                            _SettingRow(
                              label: 'اسم الستوديو',
                              description: 'الاسم الذي سيظهر في الفواتير والتقارير',
                              child: SizedBox(
                                width: 280,
                                child: TextFormField(
                                  controller: _studioNameCtrl,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            _SettingRow(
                              label: 'رمز العملة',
                              description: 'رمز العملة المستخدم في الفواتير',
                              child: DropdownButton<String>(
                                value: _currency,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'ج.م',
                                      child: Text('جنيه مصري (ج.م)')),
                                  DropdownMenuItem(
                                      value: 'USD',
                                      child: Text('دولار أمريكي (\$)')),
                                  DropdownMenuItem(
                                      value: 'AED',
                                      child: Text('درهم إماراتي (د.إ)')),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _currency = v);
                                },
                                style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'إعدادات الحجوزات',
                          icon: Icons.event_note_rounded,
                          children: [
                            _SettingRow(
                              label: 'السماح بحجوزات متعددة في نفس اليوم',
                              description:
                                  'عند التفعيل، يمكن إنشاء أكثر من حجز في نفس اليوم',
                              child: Switch(
                                value: _allowDuplicateBookings,
                                onChanged: (v) =>
                                    setState(() => _allowDuplicateBookings = v),
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'إعدادات الإشعارات',
                          icon: Icons.notifications_rounded,
                          children: [
                            _SettingRow(
                              label: 'تذكير قبل الحجز بيومين',
                              description:
                                  'إرسال إشعار للعميل قبل يومين من موعده',
                              child: Switch(
                                value: true,
                                onChanged: (v) {},
                                activeColor: AppColors.primary,
                              ),
                            ),
                            const Divider(height: 24),
                            _SettingRow(
                              label: 'تذكير قبل الحجز بيوم',
                              description:
                                  'إرسال إشعار للعميل قبل يوم من موعده',
                              child: Switch(
                                value: true,
                                onChanged: (v) {},
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Builder(
                          builder: (ctx) => ElevatedButton.icon(
                            onPressed: () => _saveSettings(ctx),
                            icon: const Icon(Icons.save_rounded, size: 18),
                            label: const Text('حفظ الإعدادات'),
                          ),
                        ),
                      ],
                    ),
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
          Text('الإعدادات',
              style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;

  const _SettingRow({
    required this.label,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
