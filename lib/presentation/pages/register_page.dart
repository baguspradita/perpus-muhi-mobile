import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
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

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
    _loadJurusan();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(authNotifierProvider.notifier).register(
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
      if (next.isAuthenticated) {
        context.go(RouteNames.home);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: AppSpacing.xxl),
                                _buildRoleSelector(),
                                const SizedBox(height: AppSpacing.xl),
                                _buildFormFields(),
                                if (authState.errorMessage.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  _buildErrorMessage(authState.errorMessage),
                                ],
                                const SizedBox(height: AppSpacing.xxl),
                                AppButton(
                                  label: 'Buat Akun',
                                  isExpanded: true,
                                  isLoading: authState.isLoading,
                                  icon: Icons.person_add_alt_1_rounded,
                                  onPressed: _register,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _buildFooter(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.rXl,
            child: Image.asset(
              'assets/images/logo-muhi.png',
              fit: BoxFit.cover,
              width: 80,
              height: 80,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Selamat Datang',
          style: AppTypography.heading1.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Bergabunglah dengan Perpustakaan Muhi untuk mengakses koleksi buku yang kaya',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saya adalah',
          style: AppTypography.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.rLg,
          ),
          child: Row(
            children: [
              Expanded(
                child: _RoleChip(
                  label: 'Siswa',
                  icon: Icons.school_rounded,
                  isSelected: _selectedRole == 'siswa',
                  onTap: () => setState(() => _selectedRole = 'siswa'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RoleChip(
                  label: 'Guru',
                  icon: Icons.person_rounded,
                  isSelected: _selectedRole == 'guru',
                  onTap: () => setState(() => _selectedRole = 'guru'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          labelText: 'Nama Lengkap',
          hintText: 'Masukkan nama lengkap',
          controller: _namaController,
          prefixIcon: const Icon(Icons.person_rounded, size: 20),
          validator: (v) => Validators.required(v, fieldName: 'Nama'),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          labelText: 'Email',
          hintText: 'contoh@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_rounded, size: 20),
          validator: Validators.email,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          labelText: 'Kata Sandi',
          hintText: 'Minimal 8 karakter',
          controller: _passwordController,
          obscureText: _isPasswordHidden,
          prefixIcon: const Icon(Icons.lock_rounded, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordHidden
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 20,
            ),
            onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
          ),
          validator: Validators.password,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          labelText: 'Konfirmasi Kata Sandi',
          hintText: 'Ulangi kata sandi',
          controller: _passwordConfirmController,
          obscureText: _isPasswordConfirmHidden,
          prefixIcon: const Icon(Icons.lock_rounded, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordConfirmHidden
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 20,
            ),
            onPressed: () => setState(() => _isPasswordConfirmHidden = !_isPasswordConfirmHidden),
          ),
          validator: (v) => Validators.confirmPassword(v, _passwordController.text),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          labelText: 'No. Telepon',
          hintText: '0812xxxxxxx',
          controller: _noTelpController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_rounded, size: 20),
          validator: Validators.phone,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          labelText: 'Alamat',
          hintText: 'Masukkan alamat lengkap',
          controller: _alamatController,
          maxLines: 2,
          prefixIcon: const Icon(Icons.location_on_rounded, size: 20),
          validator: (v) => Validators.required(v, fieldName: 'Alamat'),
        ),
        if (_selectedRole == 'siswa') ...[
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            labelText: 'NISN',
            hintText: 'Masukkan NISN',
            controller: _nisnController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.badge_rounded, size: 20),
            validator: (v) => Validators.numeric(v, fieldName: 'NISN'),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_isLoadingJurusan)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_jurusanList.isEmpty)
            AppTextField(
              labelText: 'Jurusan',
              hintText: 'Tidak ada data jurusan',
              prefixIcon: const Icon(Icons.school_rounded, size: 20),
              enabled: false,
            )
          else
            DropdownButtonFormField<int>(
              value: _selectedJurusanId,
              decoration: InputDecoration(
                labelText: 'Jurusan',
                prefixIcon: const Icon(Icons.school_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: AppRadius.rLg),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.rLg,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.rLg,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.rLg,
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
              items: _jurusanList.map((j) => DropdownMenuItem<int>(
                value: j['id'] as int?,
                child: Text(j['nama_jurusan'] as String? ?? ''),
              )).toList(),
              onChanged: (v) => setState(() => _selectedJurusanId = v),
              validator: (v) => v == null ? 'Silakan pilih jurusan' : null,
            ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _selectedKelas,
            decoration: InputDecoration(
              labelText: 'Kelas',
              prefixIcon: const Icon(Icons.class_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: AppRadius.rLg),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.rLg,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.rLg,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.rLg,
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            items: const [
              DropdownMenuItem(value: '10', child: Text('Kelas 10')),
              DropdownMenuItem(value: '11', child: Text('Kelas 11')),
              DropdownMenuItem(value: '12', child: Text('Kelas 12')),
            ],
            onChanged: (v) => setState(() => _selectedKelas = v),
            validator: (v) => v == null ? 'Silakan pilih kelas' : null,
          ),
        ],
        if (_selectedRole == 'guru') ...[
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            labelText: 'NIP',
            hintText: 'Masukkan NIP',
            controller: _nipController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.badge_rounded, size: 20),
            validator: (v) => Validators.numeric(v, fieldName: 'NIP'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            labelText: 'Mata Pelajaran',
            hintText: 'Masukkan mata pelajaran (opsional)',
            controller: _mapelController,
            prefixIcon: const Icon(Icons.book_rounded, size: 20),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => context.go(RouteNames.login),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Masuk',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.rMd,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
