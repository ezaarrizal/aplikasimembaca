// lib/models/detective_answer_submission.dart - FIXED VERSION
class DetectiveAnswerSubmission {
  final String selectedLetter;
  final bool isCorrect;
  final String? teacherObservation;

  DetectiveAnswerSubmission({
    required this.selectedLetter,
    required this.isCorrect,
    this.teacherObservation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'selected_letter': selectedLetter,
      'is_correct': isCorrect,
    };
    
    // ✅ FIX: Use direct null check without field promotion
    final observation = teacherObservation;
    if (observation != null && observation.isNotEmpty) {
      json['teacher_observation'] = observation;
    }
    
    return json;
  }
}