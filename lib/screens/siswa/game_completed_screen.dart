// lib/screens/siswa/game_completed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants.dart';
import 'siswa_dashboard.dart';

class GameCompletedScreen extends StatefulWidget {
  const GameCompletedScreen({super.key});

  @override
  State<GameCompletedScreen> createState() => _GameCompletedScreenState();
}

class _GameCompletedScreenState extends State<GameCompletedScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadResults();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _scaleController.forward();
    _confettiController.repeat(reverse: true);
  }

  Future<void> _loadResults() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    await gameProvider.getSessionResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.siswaColor,
              Color(0xFF00CEC9),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Celebration icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.warning.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.emoji_events,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingXL),
                      
                      // Success message
                      Text(
                        'Selamat! 🎉',
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingMD),
                      
                      Text(
                        'Kamu sudah menyelesaikan\npermainan huruf vokal!',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingXL),
                      
                      // Results card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Hasil Belajar',
                              style: AppTextStyles.h4,
                            ),
                            
                            const SizedBox(height: AppSizes.paddingMD),
                            
                            if (gameProvider.currentSession != null) ...[
                              _buildResultItem(
                                'Soal Dikerjakan',
                                '${gameProvider.currentSession!.questionsCompleted.length}/${gameProvider.currentSession!.game?.totalQuestions ?? 0}',
                                Icons.quiz,
                                AppColors.info,
                              ),
                              
                              _buildResultItem(
                                'Progress',
                                '${gameProvider.currentSession!.progressPercentage.toInt()}%',
                                Icons.trending_up,
                                AppColors.success,
                              ),
                              
                              if (gameProvider.badges.isNotEmpty)
                                _buildResultItem(
                                  'Badge Baru',
                                  'Ahli Huruf Vokal',
                                  Icons.emoji_events,
                                  AppColors.warning,
                                ),
                            ] else ...[
                              _buildResultItem(
                                'Status',
                                'Selesai',
                                Icons.check_circle,
                                AppColors.success,
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingXL),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SiswaDashboard(),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.home),
                              label: const Text('Beranda'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.siswaColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingMD,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: AppSizes.paddingMD),
                          
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Reset game state and go back to game
                                gameProvider.resetCurrentGame();
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/siswa/game/huruf',
                                  arguments: {'game': gameProvider.currentSession?.game},
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Main Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingMD,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizes.iconMD,
            ),
          ),
          
          const SizedBox(width: AppSizes.paddingMD),
          
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}