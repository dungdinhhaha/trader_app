import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/api/supabase_api.dart';
import '../../../core/models/trade_method_model.dart';
import '../widgets/method_card.dart';
import 'method_detail_screen.dart';
import 'method_form_screen.dart';

class MethodsScreen extends StatefulWidget {
  const MethodsScreen({Key? key}) : super(key: key);

  @override
  State<MethodsScreen> createState() => _MethodsScreenState();
}

class _MethodsScreenState extends State<MethodsScreen> {
  final SupabaseApi _api = SupabaseApi.instance;
  List<TradeMethod> _methods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy dữ liệu từ Supabase
      final api = SupabaseApi.instance;
      final fetchedMethods = await api.getTradeMethods();

      if (mounted) {
        setState(() {
          _methods = fetchedMethods;
          _isLoading = false;
        });
      }
    } catch (error) {
      // Nếu có lỗi, sử dụng dữ liệu mẫu
      final mockMethods = _getMockMethods();

      if (mounted) {
        setState(() {
          _methods = mockMethods;
          _isLoading = false;
        });

        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi khi tải dữ liệu: ${error.toString()}. Đang sử dụng dữ liệu mẫu.',
            ),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }

  List<TradeMethod> _getMockMethods() {
    return [
      TradeMethod(
        id: 'method-1',
        userId: 'user123',
        name: 'Double Bottom Reversal',
        description:
            'Price pattern that signals a potential reversal from a downtrend to an uptrend.',
        rules: [
          'Wait for a double bottom pattern on the chart',
          'Confirm with RSI divergence',
          'Enter when price breaks above neckline',
        ],
        indicators: ['RSI', 'MACD', 'Volume'],
        timeframes: ['1h', '4h', 'Daily'],
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        totalTrades: 28,
        winTrades: 18,
        loseTrades: 10,
      ),
      TradeMethod(
        id: 'method-2',
        userId: 'user123',
        name: 'Golden Cross Strategy',
        description:
            'Using moving average crosses to identify potential long-term trend changes.',
        rules: [
          'Enter when 50 EMA crosses above 200 EMA',
          'Place stop loss below recent swing low',
          'Take profit at major resistance levels',
        ],
        indicators: ['EMA 50', 'EMA 200', 'Stochastic'],
        timeframes: ['4h', 'Daily', 'Weekly'],
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        totalTrades: 15,
        winTrades: 11,
        loseTrades: 4,
      ),
      TradeMethod(
        id: 'method-3',
        userId: 'user123',
        name: 'Supply Demand Zones',
        description:
            'Trading based on institutional supply and demand imbalances in the market.',
        rules: [
          'Identify clean supply/demand zones',
          'Wait for price to retest the zone',
          'Enter after confirmation candle',
        ],
        indicators: ['Price Action', 'Volume', 'Order Blocks'],
        timeframes: ['15m', '1h', '4h'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        totalTrades: 32,
        winTrades: 21,
        loseTrades: 11,
      ),
    ];
  }

  void _navigateToMethodDetail(TradeMethod method) async {
    // Sử dụng GoRouter thay vì Navigator
    final result = await context.push<TradeMethod>(
      '/methods/${method.id}',
      extra: method,
    );

    if (result != null) {
      // Method was updated or deleted
      setState(() {
        final index = _methods.indexWhere((m) => m.id == method.id);
        if (index != -1) {
          _methods[index] = result;
        }
      });
    }
  }

  void _navigateToMethodForm({TradeMethod? method}) async {
    if (method != null) {
      // Edit existing method
      final result = await context.pushNamed<TradeMethod>(
        'methodEdit',
        pathParameters: {'id': method.id ?? ''},
        extra: method,
      );
      if (result != null) {
        setState(() {
          final index = _methods.indexWhere((m) => m.id == method.id);
          if (index != -1) {
            _methods[index] = result;
          }
        });
      }
    } else {
      // Create new method
      final result = await context.pushNamed<TradeMethod>('methodCreate');
      if (result != null) {
        setState(() {
          _methods.insert(0, result);
        });
      }
    }
  }

  void _onMethodTap(TradeMethod method) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Xem chi tiết'),
                  onTap: () => Navigator.pop(context, 'view'),
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Chỉnh sửa'),
                  onTap: () => Navigator.pop(context, 'edit'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Xóa'),
                  onTap: () => Navigator.pop(context, 'delete'),
                ),
              ],
            ),
          ),
    );

    if (!mounted) return;

    switch (result) {
      case 'view':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MethodDetailScreen(method: method),
          ),
        );
        break;
      case 'edit':
        final updatedMethod = await Navigator.push<TradeMethod>(
          context,
          MaterialPageRoute(
            builder: (context) => MethodFormScreen(method: method),
          ),
        );
        if (updatedMethod != null) {
          _loadMethods();
        }
        break;
      case 'delete':
        _deleteMethod(method);
        break;
    }
  }

  Future<void> _deleteMethod(TradeMethod method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa phương pháp "${method.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Xóa',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await SupabaseApi.instance.deleteTradeMethod(method.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa phương pháp thành công')),
          );
          _loadMethods();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa phương pháp: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Methods'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMethods,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _methods.isEmpty
              ? _buildEmptyState()
              : _buildMethodsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToMethodForm();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: AppTheme.secondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No trading methods yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to create your first method',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodsList() {
    return RefreshIndicator(
      onRefresh: _loadMethods,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        itemBuilder: (context, index) {
          final method = _methods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: MethodCard(
              method: method,
              onTap: () => _onMethodTap(method),
            ),
          );
        },
      ),
    );
  }
}
