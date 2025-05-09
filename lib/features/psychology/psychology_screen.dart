import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/psychology_models.dart';
import '../../core/api/supabase_api.dart';
import 'widgets/test_intro_card.dart';
import 'widgets/result_history_card.dart';
import 'screens/psychology_test_screen.dart';
import 'screens/test_result_screen.dart';

class PsychologyScreen extends StatefulWidget {
  const PsychologyScreen({Key? key}) : super(key: key);

  @override
  State<PsychologyScreen> createState() => _PsychologyScreenState();
}

class _PsychologyScreenState extends State<PsychologyScreen> {
  bool _isLoading = true;
  List<PsychologyTestResult> _testResults = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy dữ liệu từ Supabase
      final api = SupabaseApi.instance;
      final results = await api.getPsychologyTestResults();

      if (mounted) {
        setState(() {
          _testResults = results;
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

  void _startTest() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PsychologyTestScreen()),
    );

    if (result != null) {
      // Cập nhật lại danh sách kết quả
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâm Lý Giao Dịch'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _testResults.isEmpty
              ? _buildEmptyState()
              : _buildTestResultsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 64, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Phân Tích Tâm Lý',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cải thiện tâm lý giao dịch của bạn',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startTest,
            icon: const Icon(Icons.quiz),
            label: const Text('Bắt Đầu Kiểm Tra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultsList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Intro card
          TestIntroCard(onStartTest: _startTest),

          const SizedBox(height: 24),

          const Text(
            'Lịch Sử Kiểm Tra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),

          const SizedBox(height: 16),

          ..._testResults
              .map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ResultHistoryCard(
                    result: result,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestResultScreen(result: result),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
