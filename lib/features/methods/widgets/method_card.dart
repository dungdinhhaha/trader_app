import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/trade_method_model.dart';

class MethodCard extends StatelessWidget {
  final TradeMethod method;
  final VoidCallback onTap;

  const MethodCard({Key? key, required this.method, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate win rate color
    final winRateColor = _getWinRateColor(method.winRate);

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
              // Method header with name and statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Method name and age
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMethodAge(method.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Win rate badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: winRateColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up, size: 16, color: winRateColor),
                        const SizedBox(width: 4),
                        Text(
                          '${method.winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: winRateColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Method description
              Text(
                method.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Horizontal divider
              const Divider(height: 1, color: AppTheme.secondaryColor),

              const SizedBox(height: 12),

              // Method stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Trades',
                    method.totalTrades.toString(),
                    Icons.analytics_outlined,
                  ),
                  _buildStatItem(
                    'Wins',
                    method.winTrades.toString(),
                    Icons.check_circle_outline,
                    color: AppTheme.successColor,
                  ),
                  _buildStatItem(
                    'Losses',
                    method.loseTrades.toString(),
                    Icons.cancel,
                    color: AppTheme.errorColor,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags row with horizontal scroll
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    // Indicators tag
                    const Icon(
                      Icons.bar_chart,
                      size: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              method.indicators.map((indicator) {
                                return _buildTag(
                                  indicator,
                                  AppTheme.primaryColor.withOpacity(0.7),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Timeframes row
              SizedBox(
                height: 30,
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children:
                          method.timeframes.map((timeframe) {
                            return _buildTag(
                              timeframe,
                              AppTheme.infoColor.withOpacity(0.7),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color ?? AppTheme.textSecondaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  String _getMethodAge(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} old';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} old';
    } else {
      return 'Created today';
    }
  }

  Color _getWinRateColor(double winRate) {
    if (winRate >= 70) {
      return AppTheme.successColor;
    } else if (winRate >= 50) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }
}
