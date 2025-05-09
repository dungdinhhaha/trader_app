import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/trade_model.dart';

class CloseTradeDialog extends StatefulWidget {
  final Trade trade;
  final NumberFormat currencyFormat;

  const CloseTradeDialog({
    Key? key,
    required this.trade,
    required this.currencyFormat,
  }) : super(key: key);

  @override
  State<CloseTradeDialog> createState() => _CloseTradeDialogState();
}

class _CloseTradeDialogState extends State<CloseTradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _exitPriceController = TextEditingController();
  final _profitController = TextEditingController();
  bool _calculatingProfit = false;

  @override
  void initState() {
    super.initState();
    // Set initial exit price to current market price (would be fetched from API)
    _exitPriceController.text = widget.trade.entryPrice.toString();
    _calculateProfit();
  }

  @override
  void dispose() {
    _exitPriceController.dispose();
    _profitController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    try {
      final exitPrice = double.parse(_exitPriceController.text);
      double profit;

      // Calculate profit based on trade type
      if (widget.trade.type == 'long') {
        profit = (exitPrice - widget.trade.entryPrice) * widget.trade.quantity;
      } else {
        // short
        profit = (widget.trade.entryPrice - exitPrice) * widget.trade.quantity;
      }

      setState(() {
        _profitController.text = profit.toStringAsFixed(2);
        _calculatingProfit = false;
      });
    } catch (e) {
      setState(() {
        _profitController.text = '0.00';
        _calculatingProfit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Close Trade',
        style: TextStyle(color: AppTheme.textPrimaryColor),
      ),
      backgroundColor: AppTheme.surfaceColor,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trade Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.trade.type == 'long'
                            ? AppTheme.successColor.withOpacity(0.2)
                            : AppTheme.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.trade.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.trade.type == 'long'
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.trade.symbol,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Entry Price
            Row(
              children: [
                const Text(
                  'Entry Price: ',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                Text(
                  widget.currencyFormat.format(widget.trade.entryPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exit Price Field
            TextFormField(
              controller: _exitPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppTheme.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Exit Price',
                hintText: 'Enter exit price',
                suffixIcon: Icon(Icons.price_change_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter exit price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (_) {
                setState(() {
                  _calculatingProfit = true;
                });
                _calculateProfit();
              },
            ),
            const SizedBox(height: 16),

            // Profit/Loss Field
            TextFormField(
              controller: _profitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              style: TextStyle(
                color:
                    _calculatingProfit
                        ? AppTheme.textSecondaryColor
                        : double.parse(_profitController.text) >= 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Profit/Loss',
                hintText: 'Calculated profit/loss',
                suffixIcon:
                    _calculatingProfit
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        )
                        : Icon(
                          double.parse(_profitController.text) >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color:
                              double.parse(_profitController.text) >= 0
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                        ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter profit/loss';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'exitPrice': double.parse(_exitPriceController.text),
                'profit': double.parse(_profitController.text),
              });
            }
          },
          child: const Text('CLOSE TRADE'),
        ),
      ],
    );
  }
}
