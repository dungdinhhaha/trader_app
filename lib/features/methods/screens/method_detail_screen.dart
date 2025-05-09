import 'package:flutter/material.dart';
import 'package:trader_app/core/api/supabase_api.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/trade_method_model.dart';
import '../../../core/services/chatgpt_service.dart';


class MethodDetailScreen extends StatefulWidget {
  final TradeMethod method;

  const MethodDetailScreen({Key? key, required this.method}) : super(key: key);

  @override
  State<MethodDetailScreen> createState() => _MethodDetailScreenState();
}

class _MethodDetailScreenState extends State<MethodDetailScreen> {
  bool _isAnalyzing = false;
  List<String>? _analysis;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.method.recommendations != null &&
        widget.method.recommendations!.isNotEmpty) {
      _analysis = ChatGPTService.cleanDatabaseContent(
        widget.method.recommendations!,
      );
    }
  }

  Future<void> _analyzeWithChatGPT() async {
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final analysis = await ChatGPTService.analyzeTradeMethod(widget.method);

      // Update the method with new recommendations
      final updatedMethod = widget.method.copyWith(
        recommendations: analysis,
        updatedAt: DateTime.now(),
      );

      // Save to database
      await SupabaseApi.instance.updateTradeMethod(updatedMethod);

      if (mounted) {
        setState(() {
          _analysis = analysis;
          _isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật phân tích phương pháp thành công'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isAnalyzing = false;
        });
      }
    }
  }

  Widget _buildStatCard(String title, String value, {IconData? icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(String title, List<String> tags, {IconData? icon}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  tags.map((tag) {
                    return Container(
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
                        tag,
                        style: TextStyle(
                          color: AppTheme.primaryColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    if (_isAnalyzing) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Đang phân tích phương pháp...',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi khi phân tích:\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _analyzeWithChatGPT,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_analysis != null && _analysis!.isNotEmpty) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Phân tích từ ChatGPT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._analysis!.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.startsWith('•')
                              ? item.substring(1).trim()
                              : item,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _analyzeWithChatGPT,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Phân tích lại',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final method = widget.method;
    final age = DateTime.now().difference(method.createdAt).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phương pháp'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section with stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Tỷ lệ thắng',
                          '${method.winRate}%',
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Tuổi',
                          '$age ngày',
                          icon: Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Số giao dịch',
                          method.totalTrades.toString(),
                          icon: Icons.bar_chart,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description section
            Card(
              elevation: 2,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Mô tả',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      method.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tags sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTagsSection(
                    'Chỉ báo',
                    method.indicators,
                    icon: Icons.show_chart,
                  ),
                  const SizedBox(height: 16),
                  _buildTagsSection(
                    'Khung thời gian',
                    method.timeframes,
                    icon: Icons.access_time,
                  ),
                ],
              ),
            ),

            // Analysis button
            if (_analysis == null && !_isAnalyzing && _error == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _analyzeWithChatGPT,
                  icon: const Icon(Icons.analytics),
                  label: const Text(
                    'Phân tích với ChatGPT',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Analysis section
            _buildAnalysisSection(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
