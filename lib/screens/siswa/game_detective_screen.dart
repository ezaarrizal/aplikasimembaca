// lib/screens/siswa/game_detective_screen.dart - USING UNIFIED DIALOG

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/game.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_overlay.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/teacher_assistance_dialog.dart';
import 'game_completed_screen.dart';

class GameDetectiveScreen extends StatefulWidget {
  final Game game;

  const GameDetectiveScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameDetectiveScreen> createState() => _GameDetectiveScreenState();
}

class _GameDetectiveScreenState extends State<GameDetectiveScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _feedbackController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _feedbackScaleAnimation;

  String? _selectedLetter;
  bool _showFeedback = false;
  bool _isCorrectAnswer = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startGame();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _feedbackScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _startGame() async {
    print('🕵️ DEBUG: Starting detective game');

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    try {
      final success = await gameProvider.startGame(widget.game.id);
      print('🕵️ DEBUG: Game start success: $success');

      if (success) {
        _loadCurrentQuestion();
        _slideController.forward();
      } else {
        print('🕵️ DEBUG: Game start failed: ${gameProvider.error}');
        _showErrorAndGoBack('Gagal memulai permainan: ${gameProvider.error}');
      }
    } catch (e) {
      print('🕵️ DEBUG: Game start exception: $e');
      _showErrorAndGoBack('Terjadi kesalahan: $e');
    }
  }

  void _showErrorAndGoBack(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terjadi Kesalahan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kembali ke Beranda'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCurrentQuestion() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    final success = await gameProvider.loadCurrentQuestion();
    if (success) {
      if (gameProvider.currentQuestion == null) {
        _navigateToGameCompleted();
      } else {
        setState(() {
          _selectedLetter = null;
        });
        _slideController.reset();
        _slideController.forward();
      }
    } else {
      _showErrorAndGoBack('Gagal memuat pertanyaan: ${gameProvider.error}');
    }
  }

  void _selectLetter(String letter) {
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedLetter = letter;
    });

    _showDetectiveFeedbackDialog();
  }

  void _showDetectiveFeedbackDialog() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final question = gameProvider.currentQuestion;

    if (question == null || _selectedLetter == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TeacherAssistanceDialog.detective(
        selectedLetter: _selectedLetter!,
        correctLetter: question.letter,
        gameTitle: widget.game.title,
        level: question.safeLevel,
        questionType: question.safeQuestionType,
        onSubmit: (isCorrect, observation) =>
            _submitAnswer(isCorrect, observation),
      ),
    );
  }

  Future<void> _submitAnswer(bool isCorrect, String? teacherObservation) async {
    if (_selectedLetter == null) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    final result = await gameProvider.submitDetectiveAnswer(
      _selectedLetter!,
      isCorrect: isCorrect,
      teacherObservation: teacherObservation,
    );

    if (result != null) {
      setState(() {
        _isCorrectAnswer = result.isCorrect;
        _feedbackMessage = result.message;
        _showFeedback = true;
      });

      _feedbackController.forward();

      await Future.delayed(const Duration(seconds: 2));
      _feedbackController.reset();

      if (result.sessionCompleted) {
        _navigateToGameCompleted();
      } else {
        await _moveToNextQuestion();
      }
    }
  }

  Future<void> _moveToNextQuestion() async {
    setState(() {
      _selectedLetter = null;
      _showFeedback = false;
    });

    _feedbackController.reset();
    _slideController.reset();

    await _loadCurrentQuestion();
  }

  void _navigateToGameCompleted() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const GameCompletedScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading && gameProvider.currentSession == null) {
            return const LoadingOverlay(
              message: 'Menyiapkan permainan detektif...',
            );
          }

          if (gameProvider.hasError) {
            return _buildErrorState(gameProvider.error!);
          }

          if (gameProvider.currentQuestion == null) {
            return _buildCompletedState();
          }

          return _buildGameState(gameProvider);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXL * 2,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.paddingLG),
            Text(
              'Terjadi Kesalahan',
              style: AppTextStyles.h3.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              error,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXL),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home),
              label: const Text('Kembali ke Beranda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.siswaColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLG,
                  vertical: AppSizes.paddingMD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 120,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSizes.paddingLG),
          Text(
            'Semua Kasus Selesai!',
            style: AppTextStyles.h2.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Text(
            'Kamu sudah menyelesaikan semua kasus detektif huruf',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          ElevatedButton(
            onPressed: _navigateToGameCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL,
                vertical: AppSizes.paddingMD,
              ),
            ),
            child: const Text(
              'Lihat Badge Detektif',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameState(GameProvider gameProvider) {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildQuestionContent(
                    gameProvider.currentQuestion!, gameProvider.currentOptions),
              ),
            ),
          ],
        ),
        if (_showFeedback) _buildFeedbackOverlay(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.siswaColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusLG),
          bottomRight: Radius.circular(AppSizes.radiusLG),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: AppSizes.iconMD,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.game.title,
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                final progress = gameProvider.currentProgress;
                if (progress == null) return const SizedBox(width: 48);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMD,
                    vertical: AppSizes.paddingSM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  ),
                  child: Text(
                    '${progress.current}/${progress.total}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(
      GameQuestion question, List<LetterOption> options) {
    final level = question.safeLevel;
    final questionType = question.safeQuestionType;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Column(
        children: [
          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMD,
              vertical: AppSizes.paddingSM,
            ),
            decoration: BoxDecoration(
              color: _getLevelColor(level),
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            ),
            child: Text(
              'Level $level: ${_getLevelTitle(level, questionType)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AppSizes.paddingLG),

          // Instruction
          Container(
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
            child: Text(
              question.instruction,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSizes.paddingXL),

          // Question content based on level
          if (level == 1)
            _buildLevel1Content(question, options)
          else if (level == 2)
            _buildLevel2Content(question, options)
          else if (level == 3)
            _buildLevel3Content(question, options)
          else
            _buildDefaultContent(question, options),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return AppColors.siswaColor;
    }
  }

  String _getLevelTitle(int level, String questionType) {
    switch (level) {
      case 1:
        return 'Temukan Perbedaan';
      case 2:
        return 'Pasangkan Huruf';
      case 3:
        return 'Lengkapi Kata';
      default:
        return 'Detektif Huruf';
    }
  }

  // Level 1: Find Difference (b-b-d, pilih yang berbeda)
  Widget _buildLevel1Content(
      GameQuestion question, List<LetterOption> options) {
    return Column(
      children: [
        Text(
          'Pilih huruf yang BERBEDA:',
          style: AppTextStyles.h4.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingLG),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((option) {
            final isSelected = _selectedLetter == option.letter;

            return GestureDetector(
              onTap: () => _selectLetter(option.letter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    option.letter,
                    style: AppTextStyles.h1.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSizes.paddingLG),
        Text(
          'Petunjuk: Cari huruf yang tampil hanya sekali!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Level 2: Drag Match
  Widget _buildLevel2Content(
      GameQuestion question, List<LetterOption> options) {
    return Column(
      children: [
        Text(
          'Seret huruf "${question.letter}" ke pasangannya:',
          style: AppTextStyles.h4.copyWith(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSizes.paddingLG),

        // Target frame
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: Colors.orange,
              width: 3,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Text(
              question.letter,
              style: AppTextStyles.h1.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.paddingXL),

        Text(
          'Pilih huruf yang sama:',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSizes.paddingMD),

        // Options
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: AppSizes.paddingMD,
            crossAxisSpacing: AppSizes.paddingMD,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = _selectedLetter == option.letter;

            return GestureDetector(
              onTap: () => _selectLetter(option.letter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey.shade300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    option.letter,
                    style: AppTextStyles.h2.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Level 3: Fill Blank (seperti vocal game tapi dengan huruf detektif)
  Widget _buildLevel3Content(
      GameQuestion question, List<LetterOption> options) {
    return Column(
      children: [
        // Word display with missing letter
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
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
              // ✅ FIXED: Image handling yang benar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _buildQuestionImage(question),
              ),

              const SizedBox(height: AppSizes.paddingLG),

              // Word with missing letter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSM),
                            border: Border.all(
                              color: Colors.purple,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '?',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    question.word.substring(1).toLowerCase(),
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.paddingXL),

        Text(
          'Pilih huruf yang tepat:',
          style: AppTextStyles.h4.copyWith(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSizes.paddingMD),

        // Letter options (unchanged)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: AppSizes.paddingMD,
            crossAxisSpacing: AppSizes.paddingMD,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = _selectedLetter == option.letter;

            return GestureDetector(
              onTap: () => _selectLetter(option.letter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    option.letter,
                    style: AppTextStyles.h1.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

// ✅ NEW: Method untuk menampilkan gambar yang benar
  Widget _buildQuestionImage(GameQuestion question) {
    print('🖼️ DEBUG: Question ID: ${question.id}');
    print('🖼️ DEBUG: Word: ${question.word}');
    print('🖼️ DEBUG: Image path: ${question.imagePath}');
    print('🖼️ DEBUG: Has image: ${question.hasImage}');

    if (question.hasImage &&
        question.imagePath != null &&
        question.imagePath!.isNotEmpty) {
      final imagePath = question.imagePath!.trim();
      print('🖼️ DEBUG: Cleaned image path: $imagePath');

      // ✅ COPY EXACT LOGIC dari Vocal Game yang working
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // Network image dari server
        print('🖼️ DEBUG: Loading as NETWORK image');
        return _buildNetworkImage(imagePath, question.word);
      } else {
        // Local asset (bundled dengan app) - SAMA seperti Vocal Game
        print('🖼️ DEBUG: Loading as LOCAL ASSET');
        return _buildLocalAssetImage(imagePath, question.word);
      }
    } else {
      print(
          '🖼️ DEBUG: No image path, showing fallback for word: ${question.word}');
      return _buildFallbackIcon(question.word);
    }
  }

  Widget _buildLocalAssetImage(String assetPath, String word) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Image.asset(
        assetPath,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('🚨 ERROR: Failed to load asset image: $assetPath');
          print('🚨 ERROR: $error');
          return _buildImageError(word, assetPath, error.toString());
        },
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl, String word) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        headers: {
          'Accept': 'image/*',
          'Cache-Control': 'no-cache',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('✅ DEBUG: Image loaded successfully: $imageUrl');
            return child;
          }

          final progress = loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null;

          print(
              '⏳ DEBUG: Loading image $imageUrl - Progress: ${(progress ?? 0) * 100}%');

          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    value: progress,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading...',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.purple,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('🚨 ERROR: Failed to load network image: $imageUrl');
          print('🚨 ERROR: $error');
          print('🚨 STACK: $stackTrace');

          // Show error info in debug mode
          return _buildImageError(word, imageUrl, error.toString());
        },
      ),
    );
  }

  Widget _buildImageError(String word, String imageUrl, String error) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.red,
          ),
          const SizedBox(height: 4),
          Text(
            word.toLowerCase(),
            style: AppTextStyles.caption.copyWith(
              color: Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'Image Error',
            style: AppTextStyles.caption.copyWith(
              color: Colors.red,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
          // Debug info (remove in production)
          if (kDebugMode) ...[
            const SizedBox(height: 2),
            Text(
              'URL: ${imageUrl.length > 20 ? imageUrl.substring(0, 20) + '...' : imageUrl}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.red,
                fontSize: 6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

// ✅ NEW: Fallback icon jika gambar tidak tersedia
  Widget _buildFallbackIcon(String word) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getWordIcon(word),
            size: 50,
            color: Colors.purple,
          ),
          const SizedBox(height: 4),
          Text(
            word.toLowerCase(),
            style: AppTextStyles.caption.copyWith(
              color: Colors.purple,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Default content (fallback)
  Widget _buildDefaultContent(
      GameQuestion question, List<LetterOption> options) {
    return _buildLevel1Content(question, options);
  }

  Widget _buildFeedbackOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: ScaleTransition(
          scale: _feedbackScaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(AppSizes.paddingXL),
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCorrectAnswer ? Icons.check_circle : Icons.school,
                  size: 80,
                  color: _isCorrectAnswer ? AppColors.success : AppColors.info,
                ),
                const SizedBox(height: AppSizes.paddingMD),
                Text(
                  _feedbackMessage,
                  style: AppTextStyles.h3.copyWith(
                    color:
                        _isCorrectAnswer ? AppColors.success : AppColors.info,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getWordIcon(String word) {
    switch (word.toLowerCase()) {
      case 'bintang':
        return Icons.star;
      case 'pisang':
        return Icons.eco;
      case 'monyet':
        return Icons.pets;
      case 'jeruk':
        return Icons.circle;
      case 'unta':
        return Icons.directions_walk;
      case 'apel':
        return Icons.apple;
      case 'tikus':
        return Icons.mouse;
      default:
        return Icons.help_outline;
    }
  }
}
