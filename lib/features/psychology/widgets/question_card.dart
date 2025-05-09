import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/psychology_models.dart';

class QuestionCard extends StatelessWidget {
  final PsychologyQuestion question;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getCategoryName(question.category),
                    style: TextStyle(
                      color: AppTheme.primaryColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question.answers.length,
              (index) => RadioListTile<int>(
                value: index,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  if (value != null) onAnswerSelected(value);
                },
                title: Text(
                  question.answers[index].text,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'risk_management':
        return 'Quản lý rủi ro';
      case 'emotional_control':
        return 'Kiểm soát cảm xúc';
      case 'discipline':
        return 'Kỷ luật';
      case 'confidence':
        return 'Tự tin';
      case 'adaptability':
        return 'Khả năng thích ứng';
      default:
        return category;
    }
  }
}
