import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

class TestIntroCard extends StatelessWidget {
  final VoidCallback onStartTest;

  const TestIntroCard({Key? key, required this.onStartTest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kiểm Tra Tâm Lý Giao Dịch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đánh giá điểm mạnh và điểm yếu trong tâm lý của bạn',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Bài kiểm tra này sẽ giúp bạn xác định các khía cạnh tâm lý giao dịch cần cải thiện. Nội dung bao gồm:',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.shield_outlined,
              color: Colors.orange,
              text: 'Quản lý rủi ro',
            ),
            _buildFeatureItem(
              icon: Icons.sentiment_satisfied_alt,
              color: Colors.green,
              text: 'Kiểm soát cảm xúc',
            ),
            _buildFeatureItem(
              icon: Icons.rule,
              color: Colors.red,
              text: 'Kỷ luật giao dịch',
            ),
            _buildFeatureItem(
              icon: Icons.checklist,
              color: Colors.blue,
              text: 'Chuẩn bị giao dịch',
            ),
            const SizedBox(height: 24),
            Text(
              'Bài kiểm tra mất khoảng 5 phút để hoàn thành. Kết quả của bạn sẽ được AI phân tích để đưa ra các khuyến nghị cá nhân hóa.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'BẮT ĐẦU KIỂM TRA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
