// lib/widgets/detective_feedback_dialog.dart - SIMPLIFIED VERSION (No Notes)

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DetectiveFeedbackDialog extends StatefulWidget {
  final String selectedLetter;
  final String correctLetter;
  final String questionType;
  final int level;
  final Function(bool isCorrect, String? observation) onSubmit;

  const DetectiveFeedbackDialog({
    super.key,
    required this.selectedLetter,
    required this.correctLetter,
    required this.questionType,
    required this.level,
    required this.onSubmit,
  });

  @override
  State<DetectiveFeedbackDialog> createState() => _DetectiveFeedbackDialogState();
}

class _DetectiveFeedbackDialogState extends State<DetectiveFeedbackDialog>
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  bool? _isCorrect;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_isCorrect == null) {
      _showMessage('Silakan pilih apakah jawaban benar atau salah');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // ✅ SIMPLIFIED: Always pass null for observation
    widget.onSubmit(_isCorrect!, null);
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

  String _getLevelTitle() {
    switch (widget.level) {
      case 1: return 'Temukan Perbedaan';
      case 2: return 'Pasangkan Huruf';
      case 3: return 'Lengkapi Kata';
      default: return 'Detektif Huruf';
    }
  }

  Color _getLevelColor() {
    switch (widget.level) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.purple;
      default: return AppColors.siswaColor;
    }
  }

  String _getQuestionTypeInstruction() {
    switch (widget.questionType) {
      case 'find_difference':
        return 'Anak diminta memilih huruf yang berbeda. Jawaban yang benar adalah "${widget.correctLetter}".';
      case 'drag_match':
        return 'Anak diminta mencocokkan huruf "${widget.correctLetter}" dengan pasangannya.';
      case 'fill_blank':
        return 'Anak diminta melengkapi kata dengan huruf "${widget.correctLetter}".';
      default:
        return 'Anak diminta mengenali huruf "${widget.correctLetter}".';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.all(AppSizes.paddingMD),
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: _getLevelColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: _getLevelColor(),
                      size: AppSizes.iconMD,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Penilaian Detektif',
                        style: AppTextStyles.h4.copyWith(
                          color: _getLevelColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingLG),
              
              // Level indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                  vertical: AppSizes.paddingSM,
                ),
                decoration: BoxDecoration(
                  color: _getLevelColor(),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                ),
                child: Text(
                  'Level ${widget.level}: ${_getLevelTitle()}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingMD),
              
              // Question info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instruksi:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getQuestionTypeInstruction(),
                      style: AppTextStyles.bodyMedium,
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMD),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jawaban Anak:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(
                                  widget.selectedLetter,
                                  style: AppTextStyles.h2.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: AppSizes.paddingMD),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jawaban Benar:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  widget.correctLetter,
                                  style: AppTextStyles.h2.copyWith(
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
              
              const SizedBox(height: AppSizes.paddingLG),
              
              // Assessment buttons
              Text(
                'Penilaian Guru/Orangtua:',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingMD),
              
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCorrect = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        decoration: BoxDecoration(
                          color: _isCorrect == true 
                              ? AppColors.success 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(
                            color: AppColors.success,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _isCorrect == true 
                                  ? Colors.white 
                                  : AppColors.success,
                              size: AppSizes.iconLG,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'BENAR',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _isCorrect == true 
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
                  
                  const SizedBox(width: AppSizes.paddingMD),
                  
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCorrect = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        decoration: BoxDecoration(
                          color: _isCorrect == false 
                              ? AppColors.error 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(
                            color: AppColors.error,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel,
                              color: _isCorrect == false 
                                  ? Colors.white 
                                  : AppColors.error,
                              size: AppSizes.iconLG,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SALAH',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _isCorrect == false 
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
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMD,
                        ),
                        side: BorderSide(color: AppColors.textSecondary),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppSizes.paddingMD),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getLevelColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMD,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Simpan Penilaian'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}