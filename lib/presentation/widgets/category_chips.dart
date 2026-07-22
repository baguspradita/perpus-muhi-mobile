import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
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
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.categoryBg,
          borderRadius: AppRadius.rXl,
          border: isSelected
              ? null
              : Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadowPrimary,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            label: category.label,
            icon: category.icon,
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
  final IconData icon;
  final int? id;

  const CategoryItem({required this.label, required this.icon, this.id});

  static List<CategoryItem> fromApiData(List<dynamic> apiList) {
    return apiList.map((item) {
      final nama = item['nama_kategori'] as String? ?? item['nama_subjek'] as String? ?? 'Lainnya';
      return CategoryItem(
        id: item['id'] as int?,
        label: nama,
        icon: _iconForLabel(nama),
      );
    }).toList();
  }

  static IconData _iconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'semua':
        return Icons.apps;
      case 'fiksi':
        return Icons.menu_book;
      case 'biography':
      case 'biografi':
        return Icons.person;
      case 'picture':
        return Icons.image;
      case 'novel':
        return Icons.book;
      case 'sains':
        return Icons.science;
      case 'sejarah':
        return Icons.history_edu;
      case 'teknologi':
        return Icons.computer;
      case 'agama':
        return Icons.book_online;
      case 'komputer':
        return Icons.laptop;
      case 'pendidikan':
        return Icons.school;
      case 'olahraga':
        return Icons.fitness_center;
      case 'seni':
        return Icons.palette;
      case 'sosial':
        return Icons.people;
      default:
        return Icons.category;
    }
  }
}