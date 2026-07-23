import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _noTelpController;
  late final TextEditingController _alamatController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _namaController = TextEditingController(text: user?.nama ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _noTelpController = TextEditingController(text: user?.noTelp ?? '');
    _alamatController = TextEditingController(text: user?.alamat ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update profile logic would go here
      // For now, just show success and go back
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: $e'),
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
        title: const Text('Edit Profil'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto profil section
              Center(
                child: Stack(
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final user = ref.watch(authNotifierProvider).user;
                        return CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            user?.nama?.isNotEmpty == true 
                                ? user!.nama[0].toUpperCase() 
                                : 'U',
                            style: AppTypography.headlineLgMobile.copyWith(
                              color: AppColors.primary,
                              fontSize: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surfaceContainerLowest,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Form fields
              Text(
                'Informasi Pribadi',
                style: AppTypography.headlineMd,
              ),
              const SizedBox(height: AppSpacing.lg),

              AppTextField(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                controller: _namaController,
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.outline),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                labelText: 'Email',
                hintText: 'Masukkan email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.outline),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                labelText: 'Nomor Telepon',
                hintText: 'Masukkan nomor telepon',
                controller: _noTelpController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.outline),
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                labelText: 'Alamat',
                hintText: 'Masukkan alamat lengkap',
                controller: _alamatController,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.outline),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                  isExpanded: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}