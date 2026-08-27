import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_effects.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/buku_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_buku_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_avatar.dart';
import '../widgets/book_card.dart';
import '../widgets/section_header.dart';
import '../widgets/procedural_book_cover.dart';
import '../widgets/app_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/staggered_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static bool _notifCountInitialized = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardBukuState = ref.watch(dashboardBukuProvider);

    if (!_notifCountInitialized) {
      _notifCountInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationProvider.notifier).loadUnreadCount();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Beranda'),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(notificationProvider).unreadBadge;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifikasi',
                    onPressed: () => context.push(RouteNames.notifications),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context, user, dashboardBukuState),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStatsSection(context, ref, dashboardState),
                ],
              ),
            ),
          ),
          _buildBookSections(context, ref, dashboardBukuState),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    UserEntity? user,
    DashboardBukuState bukuState,
  ) {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      < 11 => 'Selamat pagi',
      < 15 => 'Selamat siang',
      < 18 => 'Selamat sore',
      _ => 'Selamat malam',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppGradients.buttonPrimary,
        borderRadius: AppRadius.hero,
        boxShadow: AppGradients.elevation4,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.heroCenterRadial(
                    primaryColor: AppColors.accent.withValues(alpha: 0.08),
                    accentColor: AppColors.accent.withValues(alpha: 0.04),
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    name: user?.nama ?? 'U',
                    size: 48,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    textColor: Colors.white,
                    showBorder: false,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: AppTypography.labelMd.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.nama ?? 'Pengguna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    WidgetRef ref,
    dynamic dashboardState,
  ) {
    final d = dashboardState.dashboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan', style: AppTypography.headlineMd),
        const SizedBox(height: AppSpacing.md),
        // Wide card
        StatCard(
          title: 'Buku Tersedia',
          value: d?.totalBuku.toString() ?? '1,240',
          icon: Icons.menu_book,
          iconColor: AppColors.primary,
          bgColor: AppColors.surfaceContainerLowest,
          isExpanded: true,
        ),
        const SizedBox(height: AppSpacing.md),
        // Two compact cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Dipinjam',
                value: d?.peminjamanAktif.toString() ?? '2',
                icon: Icons.menu_book,
                iconColor: AppColors.primary,
                bgColor: AppColors.surfaceContainerLowest,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'Terlambat',
                value: d?.peminjamanTerlambat.toString() ?? '0',
                icon: Icons.warning_amber,
                iconColor: AppColors.danger,
                bgColor: AppColors.surfaceContainerLowest,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookSections(
    BuildContext context,
    WidgetRef ref,
    DashboardBukuState state,
  ) {
    final sections = [
      _BookSectionData(
        title: 'Rekomendasi',
        books: state.rekomendasiBuku,
        emptyIcon: Icons.recommend_outlined,
        emptyTitle: 'Belum Ada Rekomendasi',
        emptySubtitle: 'Rekomendasi akan muncul berdasarkan minat baca Anda.',
      ),
      _BookSectionData(
        title: 'Buku Baru',
        books: state.bukuBaru,
        emptyIcon: Icons.new_releases_outlined,
        emptyTitle: 'Belum Ada Buku Baru',
        emptySubtitle: 'Buku terbaru akan muncul di sini.',
      ),
      _BookSectionData(
        title: 'Populer Bulan Ini',
        books: state.bukuPopuler,
        emptyIcon: Icons.trending_up_outlined,
        emptyTitle: 'Belum Ada Data Populer',
        emptySubtitle: 'Buku paling banyak dibaca akan muncul di sini.',
      ),
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final section = sections[index];
          return _buildHorizontalBookSection(context, section, index);
        },
        childCount: sections.length,
      ),
    );
  }

Widget _buildHorizontalBookSection(
    BuildContext context,
    _BookSectionData section,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: section.title,
          actionLabel: 'Lihat Semua',
          onAction: () => context.push(RouteNames.katalog),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (section.books.isEmpty)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SizedBox(
              height: 200,
              child: Center(
                child: EmptyState(
                  icon: section.emptyIcon,
                  title: section.emptyTitle,
                  subtitle: section.emptySubtitle,
                  useIllustration: false,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: section.books.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final book = section.books[index];
                final isAvailable = (book.stokTersedia ?? 0) > 0;
                return StaggerCell(
                  index: index,
                  child: SizedBox(
                    width: 150,
                    child: BookCard(
                      title: book.judul,
                      author: book.penulis,
                      coverUrl: book.coverUrl,
                      coverColor: _getCoverColor(book.id),
                      isAvailable: isAvailable,
                      loanStatus: isAvailable ? 'Tersedia' : 'Habis',
                      bookId: book.id,
                      isGridMode: true,
                      heroTag: book.id,
                      onTap: () => context.push(
                        RouteNames.bookDetail,
                        extra: book,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (index != 2) const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Color _getCoverColor(int id) {
    final colors = [
      AppColors.primary,
      const Color(0xFF2D3F5F),
      const Color(0xFF3E4F6B),
      const Color(0xFF0F1A2E),
      const Color(0xFF21344F),
    ];
    return colors[id % colors.length];
  }
}

class _BookSectionData {
  final String title;
  final List<BukuEntity> books;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  _BookSectionData({
    required this.title,
    required this.books,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });
}