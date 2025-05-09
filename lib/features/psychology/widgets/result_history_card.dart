import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/psychology_models.dart';

class ResultHistoryCard extends StatelessWidget {
  final PsychologyTestResult result;
  final VoidCallback onTap;

  const ResultHistoryCard({Key? key, required this.result, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(result.takenAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.surfaceColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category scores
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    result.categoryScores.map((categoryScore) {
                      return _buildCategoryChip(categoryScore);
                    }).toList(),
              ),
              const SizedBox(height: 16),

              // Brief analysis preview
              Text(
                result.analysis.length > 100
                    ? '${result.analysis.substring(0, 100)}...'
                    : result.analysis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // View details button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Xem chi tiết'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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

  Widget _buildCategoryChip(CategoryScore categoryScore) {
    final categoryName = _getCategoryName(categoryScore.category);

    // Use default styling as percentage is unavailable
    final chipColor = AppTheme.textSecondaryColor.withOpacity(0.5);
    final textColor = AppTheme.textPrimaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        categoryName,
        style: TextStyle(fontSize: 12, color: textColor)
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'risk_management':
        return 'Rủi ro';
      case 'emotional_control':
        return 'Cảm xúc';
      case 'discipline':
        return 'Kỷ luật';
      case 'trading_preparation':
        return 'Chuẩn bị';
      case 'trading_mindset':
        return 'Tư duy';
      case 'self_improvement':
        return 'Phát triển';
      default:
        return category;
    }
  }
}
