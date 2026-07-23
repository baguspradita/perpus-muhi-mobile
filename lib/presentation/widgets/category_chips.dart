import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class CategoryChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.rPill,
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariant, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadowPrimary,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.primary,
            fontWeight: FontWeight.w600,
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
      height: 40,
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
      final nama = item['nama_kategori'] as String? ?? item['nama_subjek'] as String? ?? 'Lainnya';
      return CategoryItem(
        id: item['id'] as int?,
        label: nama,
      );
    }).toList();
  }
}