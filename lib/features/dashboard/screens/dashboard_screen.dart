import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/api/supabase_api.dart';
import '../../../core/models/trade_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _supabaseApi = SupabaseApi.instance;
  bool _isLoading = true;
  
  // Trading statistics
  double _currentProfit = 0;
  int _totalTrades = 0;
  int _todayTradesCount = 0;
  int _profitableDays = 0;
  double _winRate = 0;
  double _averageWin = 0;
  double _averageLoss = 0;
  
  final _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
    setState(() {
      _isLoading = true;
    });

      final trades = await _supabaseApi.getTrades();
      _calculateStats(trades);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trades: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _calculateStats(List<Trade> trades) {
    if (trades.isEmpty) return;

    // Total trades count
    _totalTrades = trades.length;
    
    // Tính profit hiện tại
    _currentProfit = trades.fold<double>(
      0,
      (sum, trade) => sum + (trade.profit ?? 0),
    );

    // Đếm số lệnh hôm nay
    final now = DateTime.now();
    _todayTradesCount = trades.where((trade) {
      final tradeDate = trade.createdAt;
      return tradeDate.year == now.year &&
          tradeDate.month == now.month &&
          tradeDate.day == now.day;
    }).length;

    // Tính số ngày có lãi
    final tradeDays = trades
      .map((trade) => DateTime(
        trade.createdAt.year,
        trade.createdAt.month,
        trade.createdAt.day,
      ))
      .toSet()
      .toList();

    _profitableDays = tradeDays.where((day) {
      final dayTrades = trades.where((trade) {
        final tradeDate = trade.createdAt;
        return tradeDate.year == day.year &&
            tradeDate.month == day.month &&
            tradeDate.day == day.day;
      }).toList();

      final dayProfit = dayTrades.fold<double>(
        0,
        (sum, trade) => sum + (trade.profit ?? 0),
      );

      return dayProfit > 0;
    }).length;
    
    // Tính Win Rate
    final closedTrades = trades.where((t) => t.status == 'closed').toList();
    final winningTrades = closedTrades.where((t) => (t.profit ?? 0) > 0).toList();
    final losingTrades = closedTrades.where((t) => (t.profit ?? 0) < 0).toList();
    
    _winRate = closedTrades.isEmpty
        ? 0.0
        : (winningTrades.length / closedTrades.length) * 100;
        
    // Tính Average Win/Loss
    _averageWin = winningTrades.isEmpty
        ? 0.0
        : winningTrades.fold<double>(
              0,
              (sum, trade) => sum + (trade.profit ?? 0),
            ) /
            winningTrades.length;

    _averageLoss = losingTrades.isEmpty
        ? 0.0
        : losingTrades.fold<double>(
              0,
              (sum, trade) => sum + (trade.profit ?? 0).abs(),
            ) /
            losingTrades.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tổng quát',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
              : RefreshIndicator(
                onRefresh: _loadData,
              color: AppTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    _buildProfitCard(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                  ],
                          ),
                        ),
                      ),
    );
  }
  
  Widget _buildProfitCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.surfaceColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _currentProfit >= 0 ? AppTheme.successColor.withOpacity(0.5) : AppTheme.errorColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_currentProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _currentProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                color: _currentProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tổng lợi nhuận',
                        style: TextStyle(
                          fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _currencyFormat.format(_currentProfit),
              style: TextStyle(
                fontSize: 36,
                          fontWeight: FontWeight.bold,
                color: _currentProfit >= 0 ? AppTheme.successColor : AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tổng số giao dịch: $_totalTrades',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
  
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      childAspectRatio: 0.85,
      physics: const NeverScrollableScrollPhysics(),
                        children: [
        _buildStatCard(
          title: 'Tỷ lệ thắng',
          value: '${_winRate.toStringAsFixed(1)}%',
          icon: Icons.bar_chart,
          iconColor: AppTheme.primaryColor,
        ),
        _buildStatCard(
          title: 'Giao dịch hôm nay',
          value: _todayTradesCount.toString(),
          icon: Icons.today,
          iconColor: AppTheme.infoColor,
        ),
        _buildStatCard(
          title: 'Ngày có lãi',
          value: _profitableDays.toString(),
          icon: Icons.calendar_today,
          iconColor: AppTheme.secondaryColor,
        ),
        _buildStatCard(
          title: 'Lãi/Lỗ trung bình',
          value: _currencyFormat.format(_averageWin),
          secondValue: _currencyFormat.format(_averageLoss),
          icon: Icons.balance,
          iconColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    String? secondValue,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                          ),
                        ],
                      ),
            const SizedBox(height: 12),
            Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                  textAlign: TextAlign.center,
                ),
                if (secondValue != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    secondValue,
                    style: const TextStyle(
                      fontSize: 14,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ],
                ),
              ),
    );
  }
}
