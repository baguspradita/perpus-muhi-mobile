import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  int _currentStep = 1;

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nisnController = TextEditingController();
  final _nipController = TextEditingController();
  final _mapelController = TextEditingController();

  String _selectedRole = 'siswa';
  bool _isPasswordHidden = true;
  bool _isPasswordConfirmHidden = true;

  int? _selectedJurusanId;
  String? _selectedKelas;

  List<Map<String, dynamic>> _jurusanList = [];
  bool _isLoadingJurusan = false;

  @override
  void initState() {
    super.initState();
    _loadJurusan();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _nisnController.dispose();
    _nipController.dispose();
    _mapelController.dispose();
    super.dispose();
  }

  Future<void> _loadJurusan() async {
    setState(() => _isLoadingJurusan = true);
    try {
      final dio = sl<Dio>();
      final response = await dio.get('/jurusan/aktif');
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] != null) {
        final list = data['data'] as List;
        setState(() {
          _jurusanList = list.map((e) => e as Map<String, dynamic>).toList();
          _isLoadingJurusan = false;
        });
      } else {
        setState(() => _isLoadingJurusan = false);
      }
    } catch (_) {
      setState(() => _isLoadingJurusan = false);
    }
  }

  void _goToStep2() {
    if (_step1Key.currentState?.validate() != true) return;
    setState(() => _currentStep = 2);
  }

  void _goToStep1() {
    setState(() => _currentStep = 1);
  }

  void _register() {
    if (_step2Key.currentState?.validate() != true) return;

    ref.read(authNotifierProvider.notifier).register(
          nama: _namaController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmController.text,
          noTelp: _noTelpController.text.trim(),
          alamat: _alamatController.text.trim(),
          role: _selectedRole,
          nisn: _selectedRole == 'siswa' ? _nisnController.text.trim() : null,
          jurusanId: _selectedRole == 'siswa' ? _selectedJurusanId?.toString() : null,
          kelas: _selectedRole == 'siswa' ? _selectedKelas : null,
          nip: _selectedRole == 'guru' ? _nipController.text.trim() : null,
          mapel: _selectedRole == 'guru' ? _mapelController.text.trim() : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        context.go(RouteNames.home);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: _currentStep == 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToStep1,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 24),
              _currentStep == 1 ? _buildStep1() : _buildStep2(authState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepDot(
          step: 1,
          isActive: _currentStep == 1,
          isCompleted: _currentStep > 1,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: _currentStep > 1 ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _StepDot(
          step: 2,
          isActive: _currentStep == 2,
          isCompleted: false,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Step $_currentStep dari 2',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Diri Anda',
            style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Saya adalah',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Siswa'),
                  selected: _selectedRole == 'siswa',
                  selectedColor: AppColors.primaryContainer,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedRole = 'siswa');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Guru'),
                  selected: _selectedRole == 'guru',
                  selectedColor: AppColors.primaryContainer,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedRole = 'guru');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _namaController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (v) => Validators.required(v, fieldName: 'Nama'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordHidden,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
              ),
            ),
            validator: Validators.password,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _passwordConfirmController,
            obscureText: _isPasswordConfirmHidden,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordConfirmHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _isPasswordConfirmHidden = !_isPasswordConfirmHidden),
              ),
            ),
            validator: (v) => Validators.confirmPassword(v, _passwordController.text),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _noTelpController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'No. Telepon',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: Validators.phone,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _alamatController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Alamat',
              prefixIcon: Icon(Icons.location_on_outlined),
              alignLabelWithHint: true,
            ),
            validator: (v) => Validators.required(v, fieldName: 'Alamat'),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Lanjut',
            icon: Icons.arrow_forward,
            isExpanded: true,
            onPressed: _goToStep2,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textSecondary)),
                TextButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(AuthState authState) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedRole == 'siswa' ? 'Data Siswa' : 'Data Guru',
            style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_selectedRole == 'siswa') ...[
            TextFormField(
              controller: _nisnController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NISN',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => Validators.numeric(v, fieldName: 'NISN'),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isLoadingJurusan)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              DropdownButtonFormField<int>(
                value: _selectedJurusanId,
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: _jurusanList.map((j) => DropdownMenuItem<int>(
                  value: j['id'],
                  child: Text(j['nama_jurusan'] ?? ''),
                )).toList(),
                onChanged: (v) => setState(() => _selectedJurusanId = v),
                validator: (v) => v == null ? 'Pilih jurusan' : null,
              ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _selectedKelas,
              decoration: const InputDecoration(
                labelText: 'Kelas',
                prefixIcon: Icon(Icons.class_outlined),
              ),
              items: ['10', '11', '12'].map((k) => DropdownMenuItem<String>(
                value: k,
                child: Text('Kelas $k'),
              )).toList(),
              onChanged: (v) => setState(() => _selectedKelas = v),
              validator: (v) => v == null ? 'Pilih kelas' : null,
            ),
          ],
          if (_selectedRole == 'guru') ...[
            TextFormField(
              controller: _nipController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NIP',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => Validators.numeric(v, fieldName: 'NIP'),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _mapelController,
              decoration: const InputDecoration(
                labelText: 'Mata Pelajaran (opsional)',
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
          ],
          if (authState.errorMessage.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      authState.errorMessage,
                      style: const TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Kembali',
                  type: AppButtonType.outline,
                  icon: Icons.arrow_back,
                  isExpanded: true,
                  onPressed: _goToStep1,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Daftar',
                  icon: Icons.check,
                  isExpanded: true,
                  isLoading: authState.isLoading,
                  onPressed: _register,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.step,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.success
            : isActive
                ? AppColors.primary
                : AppColors.surfaceVariant,
        border: Border.all(
          color: isCompleted
              ? AppColors.success
              : isActive
                  ? AppColors.primary
                  : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                '$step',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive || isCompleted ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
