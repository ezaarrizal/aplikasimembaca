// lib/screens/siswa/badges_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).loadBadges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Badge Saya'),
        backgroundColor: AppColors.siswaColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.badgesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.siswaColor),
              ),
            );
          }

          final badges = gameProvider.badges;

          if (badges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 80,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: AppSizes.paddingLG),
                  Text(
                    'Belum Ada Badge',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text(
                    'Mainkan permainan untuk mendapatkan badge!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: AppSizes.paddingMD,
              crossAxisSpacing: AppSizes.paddingMD,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 50,
                        color: AppColors.warning,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingMD),
                      
                      Text(
                        badge.badgeName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingSM),
                      
                      Text(
                        badge.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingSM),
                      
                      Text(
                        'Diraih: ${_formatDate(badge.earnedDate)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}