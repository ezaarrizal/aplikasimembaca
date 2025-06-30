// lib/widgets/teacher_assistance_dialog.dart - UNIFIED VERSION

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TeacherAssistanceDialog extends StatefulWidget {
  final String selectedLetter;
  final String correctLetter;
  final Function(String?) onSubmit; // For vocal game
  final Function(bool isCorrect, String? observation)? onSubmitDetective; // For detective game
  final bool isDetectiveMode;
  final String? gameTitle;
  final int? level;
  final String? questionType;

  const TeacherAssistanceDialog({
    super.key,
    required this.selectedLetter,
    required this.correctLetter,
    required this.onSubmit,
    this.onSubmitDetective,
    this.isDetectiveMode = false,
    this.gameTitle,
    this.level,
    this.questionType,
  });

  // Factory constructor for vocal game (existing usage)
  factory TeacherAssistanceDialog.vocal({
    required String selectedLetter,
    required String correctLetter,
    required Function(String?) onSubmit,
  }) {
    return TeacherAssistanceDialog(
      selectedLetter: selectedLetter,
      correctLetter: correctLetter,
      onSubmit: onSubmit,
      isDetectiveMode: false,
    );
  }

  // Factory constructor for detective game
  factory TeacherAssistanceDialog.detective({
    required String selectedLetter,
    required String correctLetter,
    required Function(bool isCorrect, String? observation) onSubmit,
    String? gameTitle,
    int? level,
    String? questionType,
  }) {
    return TeacherAssistanceDialog(
      selectedLetter: selectedLetter,
      correctLetter: correctLetter,
      onSubmit: (_) {}, // Dummy function for vocal mode
      onSubmitDetective: onSubmit,
      isDetectiveMode: true,
      gameTitle: gameTitle,
      level: level,
      questionType: questionType,
    );
  }

  @override
  State<TeacherAssistanceDialog> createState() => _TeacherAssistanceDialogState();
}

class _TeacherAssistanceDialogState extends State<TeacherAssistanceDialog> {
  bool _isAutoCorrect = false;
  bool? _manualCorrectness; // For detective mode manual evaluation

  @override
  void initState() {
    super.initState();
    _isAutoCorrect = widget.selectedLetter.toLowerCase() == widget.correctLetter.toLowerCase();
  }

  String _getGameModeTitle() {
    if (widget.isDetectiveMode) {
      return 'Penilaian Detektif${widget.level != null ? " - Level ${widget.level}" : ""}';
    } else {
      return 'Bantuan Guru/Orangtua';
    }
  }

  IconData _getGameModeIcon() {
    return widget.isDetectiveMode ? Icons.search : Icons.school;
  }

  Color _getGameModeColor() {
    if (widget.isDetectiveMode) {
      switch (widget.level ?? 1) {
        case 1: return Colors.green;
        case 2: return Colors.orange;
        case 3: return Colors.purple;
        default: return AppColors.siswaColor;
      }
    } else {
      return AppColors.siswaColor;
    }
  }

  String _getInstructionText() {
    if (widget.isDetectiveMode) {
      return 'Pilih apakah jawaban siswa benar atau salah berdasarkan pengamatan Anda.';
    } else {
      return _isAutoCorrect 
          ? 'Selamat! Jawaban sudah benar. Berikan pujian dan lanjut ke soal berikutnya.'
          : 'Jawaban belum tepat. Bantu siswa mengucapkan huruf yang benar dan coba lagi.';
    }
  }

  void _submitAnswer() {
    if (widget.isDetectiveMode) {
      if (_manualCorrectness == null) {
        _showMessage('Silakan pilih apakah jawaban benar atau salah');
        return;
      }
      Navigator.pop(context);
      widget.onSubmitDetective!(_manualCorrectness!, null);
    } else {
      Navigator.pop(context);
      widget.onSubmit(null);
    }
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
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getGameModeIcon(),
            color: _getGameModeColor(),
            size: AppSizes.iconMD,
          ),
          const SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: Text(
              _getGameModeTitle(),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Answer comparison
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Jawaban Siswa',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Text(
                              widget.selectedLetter,
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Jawaban Benar',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              widget.correctLetter,
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingMD),
          
          // Auto-detection status (for vocal game)
          if (!widget.isDetectiveMode)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                color: _isAutoCorrect 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAutoCorrect ? Icons.check_circle : Icons.info,
                    color: _isAutoCorrect ? AppColors.success : AppColors.warning,
                    size: AppSizes.iconMD,
                  ),
                  const SizedBox(width: AppSizes.paddingSM),
                  Expanded(
                    child: Text(
                      _isAutoCorrect ? 'Jawaban Benar!' : 'Jawaban Belum Tepat',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isAutoCorrect ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Manual evaluation (for detective game)
          if (widget.isDetectiveMode) ...[
            Text(
              'Penilaian Manual:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSM),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _manualCorrectness = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSizes.paddingMD),
                      decoration: BoxDecoration(
                        color: _manualCorrectness == true 
                            ? AppColors.success 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(
                          color: AppColors.success,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _manualCorrectness == true 
                                ? Colors.white 
                                : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'BENAR',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _manualCorrectness == true 
                                  ? Colors.white 
                                  : AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppSizes.paddingSM),
                
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _manualCorrectness = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSizes.paddingMD),
                      decoration: BoxDecoration(
                        color: _manualCorrectness == false 
                            ? AppColors.error 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel,
                            color: _manualCorrectness == false 
                                ? Colors.white 
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SALAH',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _manualCorrectness == false 
                                  ? Colors.white 
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppSizes.paddingMD),
          
          // Instruction
          Text(
            _getInstructionText(),
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submitAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isDetectiveMode 
                ? _getGameModeColor()
                : (_isAutoCorrect ? AppColors.success : AppColors.warning),
            foregroundColor: Colors.white,
          ),
          child: Text(
            widget.isDetectiveMode 
                ? 'Simpan Penilaian'
                : (_isAutoCorrect ? 'Lanjut' : 'Coba Lagi')
          ),
        ),
      ],
    );
  }
}