import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_motion.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary
                : AppColors.surfaceContainer,
            borderRadius: AppRadius.badge,
            border: widget.isSelected
                ? null
                : Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Text(
            widget.label,
            style: AppTypography.labelMd.copyWith(
              color: widget.isSelected
                  ? AppColors.onPrimary
                  : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryChipsScroll extends StatelessWidget {
  final List<CategoryItem> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const CategoryChipsScroll({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            label: category.label,
            isSelected: index == selectedIndex,
            onTap: () => onCategorySelected(index),
          );
        },
      ),
    );
  }
}

class CategoryItem {
  final String label;
  final int? id;

  const CategoryItem({required this.label, this.id});

  static List<CategoryItem> staticCategories() {
    return const [
      CategoryItem(label: 'Semua'),
      CategoryItem(label: 'Sains'),
      CategoryItem(label: 'Fiksi'),
      CategoryItem(label: 'Sejarah'),
    ];
  }

  static List<CategoryItem> fromApiData(List<dynamic> apiList) {
    return apiList.map((item) {
      final nama =
          item['nama_kategori'] as String? ??
          item['nama_subjek'] as String? ??
          'Lainnya';
      return CategoryItem(id: item['id'] as int?, label: nama);
    }).toList();
  }
}