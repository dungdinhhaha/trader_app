import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/trade_model.dart';
import '../../core/api/supabase_api.dart';
import 'widgets/close_trade_dialog.dart';
import 'widgets/trade_card.dart';
import 'screens/trade_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  bool _isLoading = true;
  String _activeFilter = 'all'; // 'all', 'open', 'closed'

  // Sample data - will be replaced with actual data
  List<Trade> _trades = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrades();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrades() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy dữ liệu thực từ Supabase
      final api = SupabaseApi.instance;
      final fetchedTrades = await api.getTrades();

      if (mounted) {
        setState(() {
          _trades = fetchedTrades;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  List<Trade> get _filteredTrades {
    if (_activeFilter == 'all') return _trades;
    return _trades.where((trade) => trade.status == _activeFilter).toList();
  }

  List<Trade> get _realTrades =>
      _filteredTrades.where((trade) => trade.realBacktest == 'real').toList();
  List<Trade> get _backtestTrades =>
      _filteredTrades
          .where((trade) => trade.realBacktest == 'backtest')
          .toList();

  Future<void> _closeTrade(Trade trade) async {
    // Show dialog to enter exit price and profit
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) =>
              CloseTradeDialog(trade: trade, currencyFormat: currencyFormat),
    );

    if (result != null) {
      try {
        // Cập nhật trade vào Supabase và trong state
        final api = SupabaseApi.instance;
        final updatedTrade = trade.copyWith(
          exitPrice: result['exitPrice'],
          profit: result['profit'],
          exitDate: DateTime.now(),
          status: 'closed',
        );

        // Gửi cập nhật đến Supabase
        final savedTrade = await api.updateTrade(updatedTrade);

        // Cập nhật state
        setState(() {
          _trades =
              _trades
                  .map((t) => t.id == savedTrade.id ? savedTrade : t)
                  .toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đóng giao dịch thành công'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đóng giao dịch: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTrade(String id) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa giao dịch'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa giao dịch này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('HỦY'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('XÓA'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        // Xóa giao dịch từ Supabase
        final api = SupabaseApi.instance;
        await api.deleteTrade(id);

        // Cập nhật state
        setState(() {
          _trades = _trades.where((t) => t.id != id).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa giao dịch thành công'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa giao dịch: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _viewTradeDetails(Trade trade) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TradeDetailScreen(trade: trade)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrades,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'Tổng cộng',
                        _trades.length.toString(),
                        Icons.analytics,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _buildStatCard(
                        'Đang mở',
                        _trades.where((t) => t.status == 'open').length.toString(),
                        Icons.pending_actions,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _buildStatCard(
                        'Đã đóng',
                        _trades.where((t) => t.status == 'closed').length.toString(),
                        Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),

                // Filter and Tabs Container
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Filter bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _activeFilter = 'all'),
                            child: Text(
                              'Tất cả',
                              style: TextStyle(
                                color: _activeFilter == 'all'
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _activeFilter = 'open'),
                            child: Text(
                              'Đang mở',
                              style: TextStyle(
                                color: _activeFilter == 'open'
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _activeFilter = 'closed'),
                            child: Text(
                              'Đã đóng',
                              style: TextStyle(
                                color: _activeFilter == 'closed'
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 1),

                      // Tabs
                      TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: AppTheme.textSecondaryColor,
                        padding: const EdgeInsets.all(4),
                        tabs: const [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet, size: 16),
                                SizedBox(width: 8),
                                Text('Thực tế'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.science, size: 16),
                                SizedBox(width: 8),
                                Text('Thử nghiệm'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTradesList(_realTrades),
                      _buildTradesList(_backtestTrades),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTradesList(List<Trade> trades) {
    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_list_bulleted,
              size: 48,
              color: AppTheme.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy giao dịch nào',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm giao dịch mới để bắt đầu',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrades,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: trades.length,
        itemBuilder: (context, index) {
          final trade = trades[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TradeCard(
              trade: trade,
              currencyFormat: currencyFormat,
              onViewDetails: _viewTradeDetails,
              onCloseTrade: _closeTrade,
              onDeleteTrade: _deleteTrade,
            ),
          );
        },
      ),
    );
  }
}
