import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/psychology_models.dart';
import '../models/trade_method_model.dart';

class ChatGPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o';
  // TODO: Replace with environment variable
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  // Prompts
  static String _getMethodAnalysisPrompt(TradeMethod method) {
    return '''
Phân tích phương pháp giao dịch sau:
Tên: ${method.name}
Tỷ lệ thắng: ${method.winRate}%
Mô tả: ${method.description}
Chỉ báo: ${method.indicators.join(', ')}
Khung thời gian: ${method.timeframes.join(', ')}

Vui lòng cung cấp phân tích và khuyến nghị theo các điểm sau (bằng tiếng Việt):
1. Điểm mạnh và điểm yếu
2. Điều kiện thị trường phù hợp nhất
3. Rủi ro tiềm ẩn và chiến lược giảm thiểu
4. Đề xuất cải thiện
5. Khuyến nghị về quản lý vị thế và rủi ro

Mỗi điểm bắt đầu bằng dấu chấm (•).
''';
  }

  static String _getInvestmentSuggestionsPrompt(double capital) {
    return '''
Với vốn giao dịch là \$${capital.toStringAsFixed(2)}, vui lòng cung cấp các khuyến nghị theo các điểm sau (bằng tiếng Việt):
1. Chiến lược quản lý vị thế và rủi ro
2. Thị trường và công cụ giao dịch phù hợp
3. Phân bổ danh mục đầu tư
4. Các yếu tố rủi ro cần cân nhắc
5. Phương pháp giao dịch cụ thể

Mỗi điểm bắt đầu bằng dấu chấm (•).
''';
  }

  // Helper methods
  static String _cleanContent(String content) {
    return content
      .replaceAll(RegExp(r'[^\p{L}\p{N}\p{P}\p{Z}\p{S}\p{M}]', unicode: true), '') // Giữ lại các ký tự Unicode hợp lệ
      .replaceAll('â¢', '•') // Sửa bullet points
      .replaceAll('â€¢', '•')
      .replaceAll('â€"', '-')
      .replaceAll('â€˜', ''')
      .replaceAll('â€™', ''')
      .replaceAll('â€œ', '"')
      .replaceAll('â€', '"')
      .replaceAll('â€¦', '...')
      .replaceAll('###', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  }

  static List<String> cleanDatabaseContent(List<String> content) {
    return content.map((item) {
      return item
          .replaceAll('Ã¡', 'á')
          .replaceAll('Ã ', 'à')
          .replaceAll('\u1ea1', 'ạ')
          .replaceAll('\u1ea3', 'ả')
          .replaceAll('Ã£', 'ã')
          .replaceAll('Äƒ', 'ă')
          .replaceAll('\u1eb1', 'ằ')
          .replaceAll('\u1eaf', 'ắ')
          .replaceAll('\u1eb7', 'ặ')
          .replaceAll('\u1eb3', 'ẳ')
          .replaceAll('\u1eb5', 'ẵ')
          .replaceAll('Ã¢', 'â')
          .replaceAll('\u1ea7', 'ầ')
          .replaceAll('\u1ea5', 'ấ')
          .replaceAll('\u1ead', 'ậ')
          .replaceAll('\u1ea9', 'ẩ')
          .replaceAll('\u1eab', 'ẫ')
          .replaceAll('Ã©', 'é')
          .replaceAll('Ã¨', 'è')
          .replaceAll('\u1eb9', 'ẹ')
          .replaceAll('\u1ebb', 'ẻ')
          .replaceAll('\u1ebd', 'ẽ')
          .replaceAll('Ãª', 'ê')
          .replaceAll('\u1ec1', 'ề')
          .replaceAll('\u1ebf', 'ế')
          .replaceAll('\u1ec7', 'ệ')
          .replaceAll('\u1ec3', 'ể')
          .replaceAll('\u1ec5', 'ễ')
          .replaceAll('Ã­', 'í')
          .replaceAll('Ã¬', 'ì')
          .replaceAll('\u1ecb', 'ị')
          .replaceAll('\u1ec9', 'ỉ')
          .replaceAll('Ä©', 'ĩ')
          .replaceAll('Ã³', 'ó')
          .replaceAll('Ã²', 'ò')
          .replaceAll('\u1ecd', 'ọ')
          .replaceAll('\u1ecf', 'ỏ')
          .replaceAll('Ãµ', 'õ')
          .replaceAll('Ã´', 'ô')
          .replaceAll('\u1ed3', 'ồ')
          .replaceAll('\u1ed1', 'ố')
          .replaceAll('\u1ed9', 'ộ')
          .replaceAll('\u1ed5', 'ổ')
          .replaceAll('\u1ed7', 'ỗ')
          .replaceAll('Æ¡', 'ơ')
          .replaceAll('\u1edd', 'ờ')
          .replaceAll('\u1edb', 'ớ')
          .replaceAll('\u1ee3', 'ợ')
          .replaceAll('\u1edf', 'ở')
          .replaceAll('\u1ee1', 'ỡ')
          .replaceAll('Ãº', 'ú')
          .replaceAll('Ã¹', 'ù')
          .replaceAll('\u1ee5', 'ụ')
          .replaceAll('\u1ee7', 'ủ')
          .replaceAll('Å©', 'ũ')
          .replaceAll('Æ°', 'ư')
          .replaceAll('\u1eeb', 'ừ')
          .replaceAll('\u1ee9', 'ứ')
          .replaceAll('\u1ef1', 'ự')
          .replaceAll('\u1eed', 'ử')
          .replaceAll('\u1eef', 'ữ')
          .replaceAll('Ã½', 'ý')
          .replaceAll('\u1ef3', 'ỳ')
          .replaceAll('\u1ef5', 'ỵ')
          .replaceAll('\u1ef7', 'ỷ')
          .replaceAll('\u1ef9', 'ỹ')
          .replaceAll('\u0111', 'đ')
          // Xử lý các ký tự đặc biệt khác
          .replaceAll('â¢', '•')
          .replaceAll('â€¢', '•')
          .replaceAll('â€"', '-')
          .replaceAll('â€˜', ''')
          .replaceAll('â€™', ''')
          .replaceAll('â€œ', '"')
          .replaceAll('â€', '"')
          .replaceAll('â€¦', '...')
          .replaceAll('\\n', '\n')
          .replaceAll('\\"', '"')
          .replaceAll('\\\'', '\'')
          .replaceAll('\\\\', '\\')
          .trim();
    }).toList();
  }

  static List<String> _processResponse(String content) {
    return content
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .map((line) {
        var cleanLine = _cleanContent(line);
        
        // Handle section headers (ending with ':')
        if (cleanLine.endsWith(':')) {
          return '\n${cleanLine.toUpperCase()}';
        }
        
        // Convert text between ** to uppercase and remove **
        cleanLine = cleanLine.replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'),
          (match) => '${match.group(1)?.toUpperCase() ?? ''}'
        );
        
        // Remove leading - character
        if (cleanLine.startsWith('-')) {
          cleanLine = cleanLine.substring(1).trim();
        }
        
        // Add bullet points for non-header lines
        if (!cleanLine.startsWith('•')) {
          cleanLine = '• $cleanLine';
        }
        return cleanLine;
      })
      .where((line) => line.length > 2)
      .toList();
  }

  // Core API request
  static Future<String> _makeRequest(String prompt, String role) async {
    try {
      print('\n=== Making ChatGPT Request ===');
      print('Role: $role');
      print('Prompt: $prompt');

      final messages = [
        {'role': 'system', 'content': role},
        {'role': 'user', 'content': prompt},
      ];

      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
        'top_p': 1,
        'frequency_penalty': 0,
        'presence_penalty': 0,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      print('\n=== Response Details ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedResponse['choices'] != null &&
            decodedResponse['choices'].isNotEmpty) {
          final content = decodedResponse['choices'][0]['message']['content'] as String;
          return utf8.decode(utf8.encode(content)); // Đảm bảo encode/decode UTF-8 đúng cách
        }
      }

      throw Exception(
        'Failed to get response: ${response.statusCode}\n${response.body}',
      );
    } catch (e, stackTrace) {
      print('\n=== Error Details ===');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  // Public methods
  static Future<List<String>> analyzeTradeMethod(TradeMethod method) async {
    try {
      print('\n=== Analyzing Trade Method ===');
      print('Method: ${method.name}');

      final content = await _makeRequest(
        _getMethodAnalysisPrompt(method),
        'Bạn là một chuyên gia phân tích chiến lược giao dịch. Hãy cung cấp phân tích bằng tiếng Việt theo format gạch đầu dòng.',
      );

      final recommendations = _processResponse(content);
      print('\n=== Analysis Results ===');
      print('Number of recommendations: ${recommendations.length}');
      print('Recommendations: $recommendations');

      return recommendations;
    } catch (e) {
      print('\n=== Analysis Error ===');
      print('Error: $e');
      rethrow;
    }
  }

  static Future<List<String>> getInvestmentSuggestions(double capital) async {
    try {
      print('\n=== Getting Investment Suggestions ===');
      print('Capital: \$${capital.toStringAsFixed(2)}');

      final content = await _makeRequest(
        _getInvestmentSuggestionsPrompt(capital),
        'Bạn là một chuyên gia tư vấn đầu tư. Hãy cung cấp các khuyến nghị bằng tiếng Việt theo format gạch đầu dòng.',
      );

      final recommendations = _processResponse(content);
      print('\n=== Suggestions Results ===');
      print('Number of recommendations: ${recommendations.length}');
      print('Recommendations: $recommendations');

      return recommendations;
    } catch (e) {
      print('\n=== Suggestions Error ===');
      print('Error: $e');
      rethrow;
    }
  }

  static Future<List<String>> analyzePsychologyTest(
    List<CategoryScore> scores,
    double totalScore,
  ) async {
    try {
      print('\n=== Analyzing Psychology Test ===');
      print('Total Score: $totalScore');

      final prompt = '''
Phân tích kết quả kiểm tra tâm lý giao dịch sau:
${scores.map((s) => "${s.category}: ${s.score}").join("\n")}
Tổng điểm: $totalScore

Vui lòng cung cấp phân tích chi tiết và khuyến nghị theo các điểm sau (bằng tiếng Việt):
1. Tình trạng tâm lý tổng quan
2. Điểm mạnh cần duy trì
3. Các lĩnh vực cần cải thiện
4. Các bước cụ thể để cải thiện

Mỗi điểm bắt đầu bằng dấu chấm (•).
''';

      final content = await _makeRequest(
        prompt,
        'Bạn là một chuyên gia phân tích tâm lý giao dịch. Hãy cung cấp phân tích bằng tiếng Việt theo format gạch đầu dòng.',
      );

      final recommendations = _processResponse(content);
      print('\n=== Analysis Results ===');
      print('Number of recommendations: ${recommendations.length}');
      print('Recommendations: $recommendations');

      return recommendations;
    } catch (e) {
      print('\n=== Analysis Error ===');
      print('Error: $e');
      rethrow;
    }
  }
}
