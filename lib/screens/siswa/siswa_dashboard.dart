// lib/screens/siswa/siswa_dashboard.dart - FIXED OVERFLOW VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../models/game.dart';
import '../../widgets/role_card.dart';
import '../../utils/constants.dart';

class SiswaDashboard extends StatefulWidget {
  const SiswaDashboard({super.key});

  @override
  State<SiswaDashboard> createState() => _SiswaDashboardState();
}

class _SiswaDashboardState extends State<SiswaDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        backgroundColor: AppColors.siswaColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/siswa/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      // ⚡ FIX 1: Wrap body dengan SafeArea untuk proper spacing
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // ⚡ FIX 2: Add physics untuk better scrolling
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: ConstrainedBox(
                // ⚡ FIX 3: Constrain minimum height
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSizes.paddingMD * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    _buildGreetingSection(),

                    const SizedBox(height: AppSizes.paddingLG),

                    // Games Section
                    _buildGamesSection(),

                    const SizedBox(height: AppSizes.paddingLG),

                    // Progress Section
                    _buildProgressSection(),

                    // ⚡ FIX 4: Quick Stats made optional/collapsible
                    const SizedBox(height: AppSizes.paddingLG),
                    _buildQuickStatsSection(),

                    // ⚡ FIX 5: Add bottom padding for safe scrolling
                    const SizedBox(height: AppSizes.paddingXL),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ⚡ EXTRACTED: Greeting section for better organization
  Widget _buildGreetingSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.siswaColor, Color(0xFF00CEC9)],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.nama ?? 'Siswa',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yuk belajar membaca dengan seru! 🎮',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ⚡ EXTRACTED: Games section with improved grid
  Widget _buildGamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permainan Edukatif',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSizes.paddingMD),
        Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            if (gameProvider.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingXL),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.siswaColor),
                  ),
                ),
              );
            }

            if (gameProvider.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: AppSizes.iconLG,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      Text(
                        'Gagal memuat permainan',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      ElevatedButton(
                        onPressed: () => gameProvider.refresh(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final games = gameProvider.games;
            final badges = gameProvider.badges;
            final allItems = [...games];

            // ⚡ FIX 6: Calculate dynamic height untuk grid
            const double cardAspectRatio = 1.0;
            const int crossAxisCount = 2;
            final double screenWidth = MediaQuery.of(context).size.width;
            final double cardWidth = (screenWidth - (AppSizes.paddingMD * 3)) / crossAxisCount;
            final double cardHeight = cardWidth / cardAspectRatio;
            final int rows = ((allItems.length + 1) / crossAxisCount).ceil(); // +1 for badge card
            final double gridHeight = (rows * cardHeight) + ((rows - 1) * AppSizes.paddingMD);

            return SizedBox(
              height: gridHeight,
              child: GridView.count(
                // ⚡ FIX 7: Remove NeverScrollableScrollPhysics
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSizes.paddingMD,
                mainAxisSpacing: AppSizes.paddingMD,
                childAspectRatio: cardAspectRatio,
                children: [
                  // Game cards
                  ...games.map((game) {
                    return RoleCard(
                      title: game.title,
                      subtitle: game.skillFocus,
                      icon: _getGameIcon(game.title),
                      color: _getGameColor(game.title),
                      badge: game.hasBadge ? '✓' : (game.hasPlayed ? '●' : null),
                      onTap: () => _playGame(game),
                    );
                  }).toList(),

                  // Badge collection card
                  RoleCard(
                    title: 'Badge Saya',
                    subtitle: 'Lihat koleksi badge',
                    icon: Icons.emoji_events,
                    color: AppColors.info,
                    badge: badges.isNotEmpty ? badges.length.toString() : null,
                    onTap: () {
                      Navigator.pushNamed(context, '/siswa/badges');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ⚡ EXTRACTED: Progress section
  Widget _buildProgressSection() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Belajar',
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: AppSizes.paddingMD),
              
              // ⚡ FIX 8: Limit progress items untuk avoid overflow
              if (gameProvider.games.isNotEmpty)
                ...gameProvider.games.take(3).map((game) => _buildProgressItem(
                  game.title,
                  game.studentProgress?.progressPercentage ?? 0.0,
                  _getGameColor(game.title),
                )).toList()
              else ...[
                _buildProgressItem('Huruf Vokal', 0.0, AppColors.siswaColor),
                _buildProgressItem('Detektif Huruf', 0.0, Colors.orange),
                _buildProgressItem('Baca Kata', 0.0, Colors.green),
              ],
              
              const SizedBox(height: AppSizes.paddingMD),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.info,
                      size: AppSizes.iconMD,
                    ),
                    const SizedBox(width: AppSizes.paddingSM),
                    Expanded(
                      child: Text(
                        'Total Badge: ${gameProvider.totalBadges}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                    // Badge type indicators
                    if (gameProvider.badges.isNotEmpty) ...[
                      _buildBadgeTypeIndicator(
                        '🎵',
                        gameProvider.badges.where((b) => b.badgeName.contains('Vokal')).length,
                      ),
                      const SizedBox(width: AppSizes.paddingSM),
                      _buildBadgeTypeIndicator(
                        '🕵️',
                        gameProvider.badges.where((b) => b.badgeName.contains('Detektif')).length,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ⚡ IMPROVED: Compact quick stats section
  Widget _buildQuickStatsSection() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final totalGames = gameProvider.games.length;
        final completedGames = gameProvider.games.where((g) => g.isCompleted).length;
        final totalBadges = gameProvider.totalBadges;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingMD), // ⚡ Reduced padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.info.withOpacity(0.1),
                AppColors.success.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: AppColors.info,
                    size: AppSizes.iconMD,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Statistik Belajar',
                    style: AppTextStyles.bodyLarge.copyWith( // ⚡ Smaller text
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMD),
              
              // ⚡ FIX 9: Horizontal stats row with constrained height
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Game',
                        '$totalGames',
                        Icons.games,
                        AppColors.siswaColor,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Selesai',
                        '$completedGames',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Badge',
                        '$totalBadges',
                        Icons.emoji_events,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(String title, double progress, Color color) {
    double normalizedProgress = progress > 1 ? progress / 100 : progress;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(normalizedProgress * 100).toInt()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSM),
          LinearProgressIndicator(
            value: normalizedProgress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTypeIndicator(String emoji, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  // ⚡ IMPROVED: Compact stat item
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ⚡ Constrain height
      children: [
        Container(
          padding: const EdgeInsets.all(8), // ⚡ Reduced padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8), // ⚡ Smaller radius
          ),
          child: Icon(
            icon,
            color: color,
            size: AppSizes.iconMD - 4, // ⚡ Slightly smaller icon
          ),
        ),
        const SizedBox(height: 4), // ⚡ Reduced spacing
        Text(
          value,
          style: AppTextStyles.h4.copyWith( // ⚡ Smaller text
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith( // ⚡ Smaller label
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _playGame(Game game) {
    String routePath;

    if (game.title == 'Permainan Huruf Vokal') {
      routePath = '/siswa/game/huruf';
    } else if (game.title == 'Detektif Huruf') {
      routePath = '/siswa/game/detektif';
    } else if (game.title == 'Belajar Mengeja') {
      routePath = '/siswa/game/spelling';
    } else {
      routePath = '/siswa/game/auto';
    }

    Navigator.pushNamed(
      context,
      routePath,
      arguments: {'game': game},
    ).then((_) {
      Provider.of<GameProvider>(context, listen: false).refresh();
    });
  }

  Color _getGameColor(String title) {
    if (title.toLowerCase().contains('vokal') ||
        title.toLowerCase().contains('huruf vokal')) {
      return AppColors.siswaColor;
    } else if (title.toLowerCase().contains('detektif')) {
      return Colors.orange;
    } else if (title.toLowerCase().contains('kata') ||
               title.toLowerCase().contains('mengeja')) {
      return Colors.green;
    } else if (title.toLowerCase().contains('cerita')) {
      return Colors.purple;
    }
    return AppColors.siswaColor;
  }

  IconData _getGameIcon(String title) {
    if (title.toLowerCase().contains('vokal') ||
        title.toLowerCase().contains('huruf vokal')) {
      return Icons.abc;
    } else if (title.toLowerCase().contains('detektif')) {
      return Icons.search;
    } else if (title.toLowerCase().contains('kata') ||
               title.toLowerCase().contains('mengeja')) {
      return Icons.spellcheck;
    } else if (title.toLowerCase().contains('cerita')) {
      return Icons.menu_book;
    }
    return Icons.games;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah kamu yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}