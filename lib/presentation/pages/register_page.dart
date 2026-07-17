import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nisnController = TextEditingController();
  final _nipController = TextEditingController();
  final _mapelController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _kelasController = TextEditingController();

  String _selectedRole = 'siswa';
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _nisnController.dispose();
    _nipController.dispose();
    _mapelController.dispose();
    _jurusanController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authNotifierProvider.notifier).register(
          nama: _namaController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmationController.text,
          noTelp: _noTelpController.text.trim(),
          alamat: _alamatController.text.trim(),
          role: _selectedRole,
          nisn: _selectedRole == 'siswa' ? _nisnController.text.trim() : null,
          jurusanId: _selectedRole == 'siswa' ? _jurusanController.text.trim() : null,
          kelas: _selectedRole == 'siswa' ? _kelasController.text.trim() : null,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi data diri untuk mendaftar',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Saya adalah',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Siswa'),
                        selected: _selectedRole == 'siswa',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = 'siswa');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Guru'),
                        selected: _selectedRole == 'guru',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = 'guru');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) => Validators.required(value, fieldName: 'Nama'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _isPasswordHidden = !_isPasswordHidden);
                      },
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmationController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      Validators.confirmPassword(value, _passwordController.text),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noTelpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) => Validators.required(value, fieldName: 'Alamat'),
                ),
                if (_selectedRole == 'siswa') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nisnController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NISN',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) =>
                        Validators.numeric(value, fieldName: 'NISN'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jurusanController,
                    decoration: const InputDecoration(
                      labelText: 'Jurusan ID',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (value) =>
                        Validators.required(value, fieldName: 'Jurusan'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kelasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kelas (10, 11, atau 12)',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                    validator: (value) =>
                        Validators.numeric(value, fieldName: 'Kelas'),
                  ),
                ],
                if (_selectedRole == 'guru') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nipController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NIP',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) =>
                        Validators.numeric(value, fieldName: 'NIP'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mapelController,
                    decoration: const InputDecoration(
                      labelText: 'Mata Pelajaran (opsional)',
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                  ),
                ],
                if (authState.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
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
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _register,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Daftar'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}