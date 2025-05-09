import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/trade_model.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;
  final NumberFormat currencyFormat;
  final Function(Trade) onViewDetails;
  final Function(Trade) onCloseTrade;
  final Function(String) onDeleteTrade;

  const TradeCard({
    Key? key,
    required this.trade,
    required this.currencyFormat,
    required this.onViewDetails,
    required this.onCloseTrade,
    required this.onDeleteTrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Slidable(
        key: ValueKey(trade.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            // View Details Action
            SlidableAction(
              onPressed: (_) => onViewDetails(trade),
              backgroundColor: AppTheme.infoColor,
              foregroundColor: Colors.white,
              icon: Icons.visibility,
              label: 'Details',
            ),

            // Close Trade or Delete Action
            if (trade.status == 'open')
              SlidableAction(
                onPressed: (_) => onCloseTrade(trade),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                icon: Icons.check_circle,
                label: 'Close',
              )
            else
              SlidableAction(
                onPressed: (_) => onDeleteTrade(trade.id),
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppTheme.surfaceColor,
          child: InkWell(
            onTap: () => onViewDetails(trade),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symbol and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: trade.type == 'long'
                                  ? AppTheme.successColor.withOpacity(0.2)
                                  : AppTheme.errorColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              trade.type == 'long' ? 'Mua' : 'Bán',
                              style: TextStyle(
                                fontSize: 12,
                                color: trade.type == 'long'
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trade.symbol,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: trade.status == 'open'
                              ? AppTheme.infoColor.withOpacity(0.2)
                              : AppTheme.textSecondaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trade.status == 'open' ? 'Đang mở' : 'Đã đóng',
                          style: TextStyle(
                            fontSize: 12,
                            color: trade.status == 'open'
                                ? AppTheme.infoColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Entry Price and Exit Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giá vào',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Giá vào: ${currencyFormat.format(trade.entryPrice)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            trade.status == 'open' ? 'Current' : 'Exit Price',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (trade.exitPrice != null)
                            Text(
                              'Giá ra: ${currencyFormat.format(trade.exitPrice!)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quantity and Profit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bar_chart,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Số lượng: ${trade.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (trade.profit != null)
                        Text(
                          'Lợi nhuận: ${currencyFormat.format(trade.profit!)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: trade.profit! >= 0
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(trade.entryDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      if (trade.exitDate != null)
                        Text(
                          '➜ ${DateFormat('MMM dd, yyyy').format(trade.exitDate!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
