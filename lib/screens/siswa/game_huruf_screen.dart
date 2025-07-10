// lib/screens/siswa/game_huruf_screen.dart - USING UNIFIED DIALOG

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/game_provider.dart';
import '../../models/game.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/teacher_assistance_dialog.dart'; // ⚡ UPDATED: Using unified dialog
import 'game_completed_screen.dart';

class GameHurufScreen extends StatefulWidget {
  final Game game;

  const GameHurufScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameHurufScreen> createState() => _GameHurufScreenState();
}

class _GameHurufScreenState extends State<GameHurufScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _feedbackController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _feedbackScaleAnimation;
  
  VideoPlayerController? _videoController;
  
  String? _selectedLetter;
  bool _showFeedback = false;
  bool _isCorrectAnswer = false;
  String _feedbackMessage = '';
  bool _showVideo = false;

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
    _videoController?.dispose();
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
    print('🎮 DEBUG: Starting vocal game');
    
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    try {
      final success = await gameProvider.startGame(widget.game.id);
      print('🎮 DEBUG: Game start success: $success');
      
      if (success) {
        if (gameProvider.hasVideo && !gameProvider.videoWatched) {
          setState(() {
            _showVideo = true;
          });
          _initializeAndPlayVideo();
        } else {
          _loadCurrentQuestion();
        }
        _slideController.forward();
      } else {
        print('🎮 DEBUG: Game start failed: ${gameProvider.error}');
        _showErrorAndGoBack('Gagal memulai permainan: ${gameProvider.error}');
      }
    } catch (e) {
      print('🎮 DEBUG: Game start exception: $e');
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
          _showVideo = false;
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
    
    _showTeacherAssistanceDialog();
  }

  void _showTeacherAssistanceDialog() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final question = gameProvider.currentQuestion;
    
    if (question == null || _selectedLetter == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TeacherAssistanceDialog.vocal(
        selectedLetter: _selectedLetter!,
        correctLetter: question.letter,
        onSubmit: (observation) => _submitAnswer(observation),
      ),
    );
  }

  Future<void> _submitAnswer(String? teacherObservation) async {
    if (_selectedLetter == null) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    final result = await gameProvider.submitAnswer(
      _selectedLetter!,
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

  Future<void> _initializeAndPlayVideo() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    try {
      if (gameProvider.videoPath != null && _videoController == null) {
        _videoController = VideoPlayerController.asset(gameProvider.videoPath!);
        await _videoController!.initialize();
        await _videoController!.play();
        _videoController!.addListener(_videoListener);
        setState(() {});
      } else if (_videoController != null && _videoController!.value.isInitialized) {
        setState(() {
          _videoController!.value.isPlaying
              ? _videoController!.pause()
              : _videoController!.play();
        });
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
      _skipToQuestions();
    }
  }

  void _videoListener() {
    if (_videoController != null && 
        _videoController!.value.position >= _videoController!.value.duration) {
      _completeVideoAndContinue();
    }
  }

  Future<void> _completeVideoAndContinue() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    await gameProvider.markVideoWatched();
    _skipToQuestions();
  }

  void _skipToQuestions() {
    setState(() {
      _showVideo = false;
    });
    _loadCurrentQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          if (gameProvider.isLoading && gameProvider.currentSession == null) {
            return const LoadingOverlay(
              message: 'Menyiapkan permainan...',
            );
          }

          if (gameProvider.hasError) {
            return _buildErrorState(gameProvider.error!);
          }

          if (_showVideo && gameProvider.hasVideo && !gameProvider.videoWatched) {
            return _buildVideoState(gameProvider);
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

  Widget _buildVideoState(GameProvider gameProvider) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: _videoController != null && _videoController!.value.isInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          child: VideoPlayer(_videoController!),
                        )
                      : Icon(
                          Icons.play_circle_fill,
                          size: 100,
                          color: AppColors.siswaColor,
                        ),
                ),
                
                const SizedBox(height: AppSizes.paddingLG),
                
                Text(
                  'Video Pembelajaran (Opsional)',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSizes.paddingMD),
                
                Text(
                  'Tonton video pengenalan huruf vokal atau langsung main kuis',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppSizes.paddingXL),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _videoController == null || !_videoController!.value.isInitialized
                            ? _initializeAndPlayVideo
                            : () {
                                setState(() {
                                  _videoController!.value.isPlaying
                                      ? _videoController!.pause()
                                      : _videoController!.play();
                                });
                              },
                        icon: Icon(
                          _videoController != null && _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          _videoController == null || !_videoController!.value.isInitialized
                              ? 'Tonton Video'
                              : (_videoController!.value.isPlaying ? 'Pause' : 'Play'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.siswaColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMD,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppSizes.paddingMD),
                    
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _skipToQuestions,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Langsung Main'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.siswaColor,
                          side: BorderSide(color: AppColors.siswaColor),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMD,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
            'Semua Soal Selesai!',
            style: AppTextStyles.h2.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Text(
            'Kamu sudah menyelesaikan semua soal huruf vokal',
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
              'Lihat Hasil',
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
                child: _buildQuestionContent(gameProvider.currentQuestion!, gameProvider.currentOptions),
              ),
            ),
          ],
        ),
        if (_showFeedback) _buildFeedbackOverlay(),
      ],
    );
  }

  Widget _buildHeader() {
    String title = widget.game.title;
    
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
              child: Text(
                title,
                style: AppTextStyles.h4.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
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

  Widget _buildQuestionContent(GameQuestion question, List<LetterOption> options) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Column(
        children: [
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
          
          // Word display
          _buildWordDisplay(question),
          
          const SizedBox(height: AppSizes.paddingXL),
          
          // Letter options
          _buildLetterOptions(options),
        ],
      ),
    );
  }

  Widget _buildWordDisplay(GameQuestion question) {
    return Container(
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
          // Image display
          if (question.hasImage)
            question.imagePath!.startsWith('http://') || question.imagePath!.startsWith('https://')
                ? Image.network(
                    question.imagePath!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.siswaColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: AppColors.siswaColor,
                        ),
                      );
                    },
                  )
                : Image.asset(
                    question.imagePath!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.siswaColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: AppColors.siswaColor,
                        ),
                      );
                    },
                  )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.siswaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Icon(
                _getImageIcon(question.word),
                size: 60,
                color: AppColors.siswaColor,
              ),
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
                        color: AppColors.warning.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(
                          color: AppColors.warning,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.warning,
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
    );
  }

  Widget _buildLetterOptions(List<LetterOption> options) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
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
              color: isSelected ? AppColors.siswaColor : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: isSelected ? AppColors.siswaColor : Colors.transparent,
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
                option.letter.toLowerCase(),
                style: AppTextStyles.h1.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontFamily:'Aharoni',
                ),
              ),
            ),
          ),
        );
      },
    );
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
                  _isCorrectAnswer ? Icons.check_circle : Icons.refresh,
                  size: 80,
                  color: _isCorrectAnswer ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(height: AppSizes.paddingMD),
                Text(
                  _feedbackMessage,
                  style: AppTextStyles.h3.copyWith(
                    color: _isCorrectAnswer ? AppColors.success : AppColors.warning,
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

  IconData _getImageIcon(String word) {
    switch (word.toLowerCase()) {
      case 'ayam':
        return Icons.egg_alt;
      case 'ikan':
        return Icons.water;
      case 'ular':
        return Icons.waves;
      case 'ember':
        return Icons.palette;
      case 'obat':
        return Icons.medical_services;
      default:
        return Icons.image;
    }
  }
}