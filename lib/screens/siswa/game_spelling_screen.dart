// lib/screens/siswa/game_spelling_screen.dart - COMPLETE AUDIO IMPLEMENTATION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../providers/game_provider.dart';
import '../../models/game.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_overlay.dart';
import 'game_completed_screen.dart';

class GameSpellingScreen extends StatefulWidget {
  final Game game;

  const GameSpellingScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameSpellingScreen> createState() => _GameSpellingScreenState();
}

class _GameSpellingScreenState extends State<GameSpellingScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _feedbackController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _feedbackScaleAnimation;

  VideoPlayerController? _videoController;

  // ⚡ NEW: Audio Player
  AudioPlayer? _audioPlayer;
  bool _isPlayingAudio = false;

  String? _selectedLetter;
  List<String> _selectedSequence = []; // For Level 2 arrange syllables
  bool _showFeedback = false;
  bool _isCorrectAnswer = false;
  String _feedbackMessage = '';
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAudioPlayer(); // ⚡ NEW: Initialize audio
    _startGame();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _feedbackController.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose(); // ⚡ NEW: Dispose audio
    super.dispose();
  }

  // ⚡ NEW: Initialize audio player
  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
  }

  // ⚡ NEW: Play audio method with web compatibility
  Future<void> _playAudio(String audioPath) async {
    try {
      print('🔊 Attempting to play: $audioPath');

      // ⚡ IMPORTANT: Clean path (remove duplicate assets/)
      String cleanPath = audioPath;
      if (cleanPath.startsWith('assets/')) {
        cleanPath = cleanPath.substring(7); // Remove 'assets/' prefix
      }

      print('🔍 Clean path: $cleanPath');

      await _audioPlayer?.stop();

      setState(() {
        _isPlayingAudio = true;
      });

      // ⚡ FIXED: Use clean path
      await _audioPlayer?.play(AssetSource(cleanPath));

      print('✅ Audio command sent');

      // Auto-stop after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
      });
    } catch (e) {
      print('❌ Audio error: $e');
      setState(() {
        _isPlayingAudio = false;
      });
      _showAudioFallback(audioPath);
    }
  }

  // ⚡ NEW: Stop audio method
  Future<void> _stopAudio() async {
    await _audioPlayer?.stop();
    setState(() {
      _isPlayingAudio = false;
    });
  }

  // ⚡ NEW: Audio error handler
  void _showAudioError(String audioPath) {
    final audioText = _getAudioText(audioPath);
    _showMessage('Audio tidak dapat diputar. Silakan baca: $audioText');
  }

  // ⚡ NEW: Audio fallback - show text instead
  void _showAudioFallback(String audioPath) {
    final text = _getAudioText(audioPath);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.volume_off, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Bacaan Audio'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ⚡ NEW: Get audio text based on file path
  String _getAudioText(String audioPath) {
    if (audioPath.contains('soal1')) return 'ibu beli sapu biru';
    if (audioPath.contains('soal2')) return 'aku suka baca buku';
    if (audioPath.contains('soal3')) return 'papa beli baju baru';
    if (audioPath.contains('soal4')) return 'risa suka lagu baru';
    if (audioPath.contains('soal5')) return 'mama minum susu sapi';
    if (audioPath.contains('soal6')) return 'rusa lari di hutan';
    if (audioPath.contains('soal7')) return 'makan telur mata sapi';
    return 'Audio tidak tersedia';
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
    print('📚 DEBUG: Starting spelling game');

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    try {
      final success = await gameProvider.startGame(widget.game.id);
      print('📚 DEBUG: Game start success: $success');

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
        print('📚 DEBUG: Game start failed: ${gameProvider.error}');
        _showErrorAndGoBack('Gagal memulai permainan: ${gameProvider.error}');
      }
    } catch (e) {
      print('📚 DEBUG: Game start exception: $e');
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
          _selectedSequence = [];
        });
        _slideController.reset();
        _slideController.forward();
      }
    } else {
      _showErrorAndGoBack('Gagal memuat pertanyaan: ${gameProvider.error}');
    }
  }

  // Level 1: Complete Word - Select syllable
  void _selectSyllable(String syllable) {
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedLetter = syllable;
    });

    _submitLevel1Answer();
  }

  // Level 2: Arrange Syllables - Add syllable to sequence
  void _addToSequence(String syllable) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_selectedSequence.length < 4) {
        // Max 4 syllables
        _selectedSequence.add(syllable);
      }
    });
  }

  // Level 2: Remove syllable from sequence
  void _removeFromSequence(int index) {
    HapticFeedback.lightImpact();

    setState(() {
      if (index >= 0 && index < _selectedSequence.length) {
        _selectedSequence.removeAt(index);
      }
    });
  }

  // Level 2: Clear sequence
  void _clearSequence() {
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedSequence.clear();
    });
  }

  // Level 2: Submit sequence
  void _submitLevel2Answer() {
    if (_selectedSequence.isEmpty) {
      _showMessage('Silakan susun suku kata terlebih dahulu');
      return;
    }

    _submitSpellingAnswer();
  }

  // Level 3: Next sentence
  void _nextSentence() {
    _submitSpellingAnswer(actionType: 'next');
  }

  Future<void> _submitLevel1Answer() async {
    if (_selectedLetter == null) return;
    _submitSpellingAnswer();
  }

  Future<void> _submitSpellingAnswer({String actionType = 'answer'}) async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    final result = await gameProvider.submitSpellingAnswer(
      selectedLetter: _selectedLetter,
      selectedSequence: _selectedSequence.isNotEmpty ? _selectedSequence : null,
      actionType: actionType,
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
      _selectedSequence = [];
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
      } else if (_videoController != null &&
          _videoController!.value.isInitialized) {
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
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
              message: 'Menyiapkan belajar mengeja...',
            );
          }

          if (gameProvider.hasError) {
            return _buildErrorState(gameProvider.error!);
          }

          if (_showVideo &&
              gameProvider.hasVideo &&
              !gameProvider.videoWatched) {
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
                  child: _videoController != null &&
                          _videoController!.value.isInitialized
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMD),
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
                  'Tonton video pengenalan mengeja atau langsung main',
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
                        onPressed: _videoController == null ||
                                !_videoController!.value.isInitialized
                            ? _initializeAndPlayVideo
                            : () {
                                setState(() {
                                  _videoController!.value.isPlaying
                                      ? _videoController!.pause()
                                      : _videoController!.play();
                                });
                              },
                        icon: Icon(
                          _videoController != null &&
                                  _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          _videoController == null ||
                                  !_videoController!.value.isInitialized
                              ? 'Tonton Video'
                              : (_videoController!.value.isPlaying
                                  ? 'Pause'
                                  : 'Play'),
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
            'Semua Level Selesai!',
            style: AppTextStyles.h2.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Text(
            'Kamu sudah menyelesaikan belajar mengeja',
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
              'Lihat Badge Mengeja',
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
                    Icons.spellcheck,
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
            _buildLevel3Content(question)
          else
            _buildLevel1Content(question, options),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return AppColors.siswaColor;
    }
  }

  String _getLevelTitle(int level, String questionType) {
    switch (level) {
      case 1:
        return 'Melengkapi Kata';
      case 2:
        return 'Menyusun Suku Kata';
      case 3:
        return 'Membaca Kalimat';
      default:
        return 'Belajar Mengeja';
    }
  }

  // Level 1: Complete Word
  Widget _buildLevel1Content(
      GameQuestion question, List<LetterOption> options) {
    return Column(
      children: [
        // Image display
        if (question.hasImage)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildQuestionImage(question),
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(
              _getWordIcon(question.word),
              size: 60,
              color: Colors.blue,
            ),
          ),

        const SizedBox(height: AppSizes.paddingLG),

        // Word pattern (e.g., "... + pu" or "bi + ...")
        Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            // Get word pattern from additional data
            final additionalData =
                gameProvider.currentSession?.game?.toString() ?? '';

            return Container(
              padding: const EdgeInsets.all(AppSizes.paddingLG),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border:
                    Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
              ),
              child: Text(
                question.wordPattern ??
                    '... + ${question.word.substring(question.word.length - 2)}',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),

        const SizedBox(height: AppSizes.paddingLG),

        Text(
          'Pilih suku kata yang tepat:',
          style: AppTextStyles.h4.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSizes.paddingMD),

        // Syllable options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((option) {
            final isSelected = _selectedLetter == option.letter;

            return GestureDetector(
              onTap: () => _selectSyllable(option.letter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
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
          }).toList(),
        ),
      ],
    );
  }

  // Level 2: Arrange Syllables
  Widget _buildLevel2Content(
      GameQuestion question, List<LetterOption> options) {
    return Column(
      children: [
        // Image display
        if (question.hasImage)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildQuestionImage(question),
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: Icon(
              _getWordIcon(question.word),
              size: 60,
              color: Colors.orange,
            ),
          ),

        const SizedBox(height: AppSizes.paddingLG),

        Text(
          'Susun suku kata menjadi: "${question.word}"',
          style: AppTextStyles.h4.copyWith(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSizes.paddingMD),

        // Sequence boxes
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final hasItem = index < _selectedSequence.length;

              return GestureDetector(
                onTap: hasItem ? () => _removeFromSequence(index) : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: hasItem ? Colors.orange : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(
                      color: hasItem ? Colors.orange : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      hasItem ? _selectedSequence[index] : '?',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: hasItem ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: AppSizes.paddingMD),

        // Action buttons for sequence
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: _selectedSequence.isNotEmpty ? _clearSequence : null,
              icon: const Icon(Icons.clear),
              label: const Text('Hapus'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  _selectedSequence.length >= 2 ? _submitLevel2Answer : null,
              icon: const Icon(Icons.send),
              label: const Text('Kirim'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.paddingLG),

        Text(
          'Pilih suku kata untuk disusun:',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSizes.paddingMD),

        // Available syllables
        Wrap(
          spacing: AppSizes.paddingMD,
          runSpacing: AppSizes.paddingMD,
          children: options.map((option) {
            return GestureDetector(
              onTap: () => _addToSequence(option.letter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                  vertical: AppSizes.paddingSM,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  option.letter,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ⚡ UPDATED: Level 3 with complete audio implementation
  Widget _buildLevel3Content(GameQuestion question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sentence display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(color: Colors.green.withOpacity(0.3), width: 3),
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
              Icon(
                Icons.auto_stories,
                size: 60,
                color: Colors.green,
              ),
              const SizedBox(height: AppSizes.paddingLG),
              Text(
                question.wordPattern ?? question.word,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.paddingXL),

        // Audio buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Audio button
            ElevatedButton.icon(
              onPressed: () {
                if (_isPlayingAudio) {
                  _stopAudio();
                } else {
                  // ⚡ FIXED: Always try to play, with fallback
                  final audioPath = question.audioWordPath ??
                      'games/spelling/audio/sentences/soal1.mp3';
                  _playAudio(audioPath);
                }
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isPlayingAudio ? Icons.stop : Icons.volume_up,
                  key: ValueKey(_isPlayingAudio),
                ),
              ),
              label: Text(_isPlayingAudio ? 'Stop' : 'Dengarkan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlayingAudio ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLG,
                  vertical: AppSizes.paddingMD,
                ),
              ),
            ),

            const SizedBox(width: AppSizes.paddingMD),

            // Fallback text button
            OutlinedButton.icon(
              onPressed: () {
                final audioPath = question.audioWordPath ??
                    'games/spelling/audio/sentences/soal1.mp3';
                _showAudioFallback(audioPath);
              },
              icon: const Icon(Icons.text_fields),
              label: const Text('Lihat Teks'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.paddingXL),

        // Next button
        ElevatedButton.icon(
          onPressed: _nextSentence,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Selanjutnya'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingXL,
              vertical: AppSizes.paddingMD,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionImage(GameQuestion question) {
    if (question.hasImage &&
        question.imagePath != null &&
        question.imagePath!.isNotEmpty) {
      final imagePath = question.imagePath!.trim();

      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return _buildNetworkImage(imagePath, question.word);
      } else {
        return _buildLocalAssetImage(imagePath, question.word);
      }
    } else {
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
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
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
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(String word) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.siswaColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getWordIcon(word),
            size: 50,
            color: AppColors.siswaColor,
          ),
          const SizedBox(height: 4),
          Text(
            word.toLowerCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.siswaColor,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                  color:
                      _isCorrectAnswer ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(height: AppSizes.paddingMD),
                Text(
                  _feedbackMessage,
                  style: AppTextStyles.h3.copyWith(
                    color: _isCorrectAnswer
                        ? AppColors.success
                        : AppColors.warning,
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
      case 'sapu':
      case 'sapu biru':
        return Icons.cleaning_services;
      case 'biru':
        return Icons.palette;
      case 'roti':
        return Icons.bakery_dining;
      case 'pita':
        return Icons.cake;
      case 'buku':
      case 'baca buku':
        return Icons.book;
      case 'baju':
      case 'baju baru':
        return Icons.checkroom;
      case 'lari':
      case 'lari pagi':
        return Icons.directions_run;
      case 'guru':
      case 'ibu guru':
        return Icons.school;
      default:
        return Icons.help_outline;
    }
  }
}
