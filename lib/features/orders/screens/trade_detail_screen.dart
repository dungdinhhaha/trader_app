import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/trade_model.dart';
import '../../../core/api/supabase_api.dart';

class TradeDetailScreen extends StatefulWidget {
  final Trade? trade;
  final String? tradeId;

  const TradeDetailScreen({Key? key, this.trade, this.tradeId})
    : super(key: key);

  @override
  State<TradeDetailScreen> createState() => _TradeDetailScreenState();
}

class _TradeDetailScreenState extends State<TradeDetailScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  Trade? trade;
  bool _isLoading = false;
  bool _deletingTrade = false;
  bool _loadingTrade = false;
  String? _tradeMethodName;
  final _supabaseApi = SupabaseApi.instance;

  @override
  void initState() {
    super.initState();
    trade = widget.trade;
    if (trade == null && widget.tradeId != null) {
      _loadTradeById();
    } else if (trade != null && trade!.tradeMethodId != null) {
      _loadTradeMethodName();
    }
  }

  Future<void> _loadTradeById() async {
    setState(() {
      _loadingTrade = true;
    });

    try {
      final loadedTrade = await _supabaseApi.getTrade(widget.tradeId!);
      setState(() {
        trade = loadedTrade;
        _loadingTrade = false;
      });
    } catch (e) {
      setState(() {
        _loadingTrade = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trade: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _loadTradeMethodName() async {
    try {
      final method = await _supabaseApi.getTradeMethod(trade!.tradeMethodId!);
      if (mounted) {
        setState(() {
          _tradeMethodName = method.name;
        });
      }
    } catch (e) {
      print('Error loading trade method: $e');
    }
  }

  Future<void> _closeTrade() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Close Trade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: trade?.entryPrice.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Exit Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Handle exit price change
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Calculate profit based on trade type and exit price
                            final exitPrice = double.parse(
                              (trade!.entryPrice * 1.05).toStringAsFixed(2),
                            );
                            final profit =
                                trade!.type == 'long'
                                    ? (exitPrice - trade!.entryPrice) *
                                        trade!.quantity
                                    : (trade!.entryPrice - exitPrice) *
                                        trade!.quantity;

                            Navigator.of(
                              context,
                            ).pop({'exitPrice': exitPrice, 'profit': profit});
                          },
                          child: const Text('CLOSE TRADE'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final closedTrade = trade!.closeTrade(
          exitPrice: result['exitPrice'],
          profit: result['profit'],
        );

        await _supabaseApi.updateTrade(closedTrade);

        setState(() {
          trade = closedTrade;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trade closed successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error closing trade: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTrade() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa giao dịch'),
            content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('HỦY'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'XÓA',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _deletingTrade = true;
      });

      try {
        await _supabaseApi.deleteTrade(trade!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trade deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate deletion
        }
      } catch (e) {
        setState(() {
          _deletingTrade = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting trade: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (trade?.status == 'open')
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Đóng giao dịch',
              onPressed: _isLoading ? null : _closeTrade,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa giao dịch',
            onPressed: _isLoading || _deletingTrade ? null : _deleteTrade,
          ),
        ],
      ),
      body: _isLoading || _deletingTrade || _loadingTrade
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trade Header with Status Banner
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Status Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: trade?.status == 'open' 
                              ? AppTheme.infoColor 
                              : AppTheme.textSecondaryColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${trade?.status?.toUpperCase() ?? ''} ${trade?.realBacktest?.toUpperCase() ?? ''} TRADE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        // Trade Basic Info
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    trade?.symbol ?? '',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: trade?.type == 'long'
                                          ? AppTheme.successColor.withOpacity(0.2)
                                          : AppTheme.errorColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      trade?.type?.toUpperCase() ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: trade?.type == 'long'
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (trade?.profit != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'P/L: ${currencyFormat.format(trade!.profit!)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: trade!.profit! >= 0
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      trade!.profit! >= 0
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      color: trade!.profit! >= 0
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trade Details Card
                  _buildInfoCard(
                    title: 'Thông tin giao dịch',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          label: 'Số lượng',
                          value: trade?.quantity.toString() ?? '',
                        ),
                        _buildInfoRow(
                          label: 'Giá vào lệnh',
                          value: currencyFormat.format(trade?.entryPrice ?? 0),
                        ),
                        if (trade?.exitPrice != null)
                          _buildInfoRow(
                            label: 'Giá thoát lệnh',
                            value: currencyFormat.format(trade!.exitPrice!),
                          ),
                        if (trade?.tradeMethodId != null)
                          _buildInfoRow(
                            label: 'Phương pháp',
                            value: _tradeMethodName ?? 'Đang tải...',
                            valueColor: AppTheme.infoColor,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dates Card
                  _buildInfoCard(
                    title: 'Thời gian',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          label: 'Ngày vào lệnh',
                          value: DateFormat('MMM dd, yyyy HH:mm')
                              .format(trade?.entryDate ?? DateTime.now()),
                        ),
                        if (trade?.exitDate != null)
                          _buildInfoRow(
                            label: 'Ngày thoát lệnh',
                            value: DateFormat('MMM dd, yyyy HH:mm')
                                .format(trade!.exitDate!),
                          ),
                        _buildInfoRow(
                          label: 'Ngày tạo',
                          value: DateFormat('MMM dd, yyyy HH:mm')
                              .format(trade?.createdAt ?? DateTime.now()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes Card
                  if (trade?.note != null && trade!.note!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Ghi chú',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          trade!.note!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Images Card
                  if (trade?.images != null && trade!.images!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Hình ảnh',
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(16),
                          itemCount: trade!.images!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  trade!.images![index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
