import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCurrentPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Change password logic would go here
      // For now, just show success and go back
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password berhasil diubah'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah password: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.accentContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: AppColors.accent,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Text(
                        'Ubah Password Anda',
                        style: AppTypography.headlineMd,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        'Pastikan password baru Anda kuat dan mudah diingat',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Form fields
                    AppTextField(
                      labelText: 'Password Saat Ini',
                      hintText: 'Masukkan password saat ini',
                      controller: _currentPasswordController,
                      obscureText: _isCurrentPasswordHidden,
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isCurrentPasswordHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.outline,
                        ),
                        onPressed: () {
                          setState(() => _isCurrentPasswordHidden = !_isCurrentPasswordHidden);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password saat ini tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      labelText: 'Password Baru',
                      hintText: 'Masukkan password baru',
                      controller: _newPasswordController,
                      obscureText: _isNewPasswordHidden,
                      prefixIcon: const Icon(Icons.lock_reset, color: AppColors.outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.outline,
                        ),
                        onPressed: () {
                          setState(() => _isNewPasswordHidden = !_isNewPasswordHidden);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password baru tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      labelText: 'Konfirmasi Password Baru',
                      hintText: 'Ulangi password baru',
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmPasswordHidden,
                      prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.outline,
                        ),
                        onPressed: () {
                          setState(() => _isConfirmPasswordHidden = !_isConfirmPasswordHidden);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Tips section
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accentContainer,
                        borderRadius: AppRadius.rMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Password Kuat:',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onAccentContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '• Minimal 8 karakter\n• Kombinasi huruf besar dan kecil\n• Mengandung angka dan simbol\n• Jangan gunakan informasi pribadi',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
          // Sticky save bar
          _buildStickyBar(),
        ],
      ),
    );
  }

  Widget _buildStickyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: _isLoading ? 'Mengubah...' : 'Ubah Password',
          onPressed: _changePassword,
          isLoading: _isLoading,
          isExpanded: true,
        ),
      ),
    );
  }
}