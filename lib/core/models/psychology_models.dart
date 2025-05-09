import 'dart:convert';

// Model for a single answer in the psychology question
class PsychologyAnswer {
  final String text;
  final int value;

  PsychologyAnswer({required this.text, required this.value});

  factory PsychologyAnswer.fromJson(Map<String, dynamic> json) {
    final dynamic rawValue = json['value'];
    int value;

    if (rawValue == null) {
      value = 0; // Default value if null
    } else if (rawValue is String) {
      value = int.tryParse(rawValue) ?? 0;
    } else if (rawValue is num) {
      value = rawValue.toInt();
    } else {
      value = 0;
    }

    return PsychologyAnswer(text: json['text'] as String? ?? '', value: value);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'value': value};
  }
}

// Model for a psychology question
class PsychologyQuestion {
  final String id;
  final String question;
  final String category;
  final List<PsychologyAnswer> answers;
  final DateTime createdAt;

  PsychologyQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.answers,
    required this.createdAt,
  });

  factory PsychologyQuestion.fromJson(Map<String, dynamic> json) {
    // Handle JSONB answers field
    List<dynamic> answersJson;
    if (json['answers'] is String) {
      answersJson = jsonDecode(json['answers'] as String) as List<dynamic>;
    } else {
      answersJson = json['answers'] as List<dynamic>;
    }

    final answers =
        answersJson.map((answer) {
          if (answer is String) {
            return PsychologyAnswer.fromJson(jsonDecode(answer));
          }
          return PsychologyAnswer.fromJson(answer as Map<String, dynamic>);
        }).toList();

    return PsychologyQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      category: json['category'] as String? ?? '',
      answers: answers,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Model for category scores in test results
class CategoryScore {
  final String category;
  final int? score;

  CategoryScore({
    required this.category,
    this.score,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'score': score,
  };

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    int? scoreValue;
    final rawScore = json['score'];
    if (rawScore is String) {
      scoreValue = int.tryParse(rawScore);
    } else if (rawScore is int) {
      scoreValue = rawScore;
    }

    return CategoryScore(
      category: json['category'] as String? ?? 'Unknown Category',
      score: scoreValue,
    );
  }
}

// Model for psychology test results
class PsychologyTestResult {
  final String id;
  final String userId;
  final DateTime takenAt;
  final List<CategoryScore> categoryScores;
  final int score;
  final String analysis;
  final List<String> recommendations;
  final DateTime createdAt;

  PsychologyTestResult({
    required this.id,
    required this.userId,
    required this.takenAt,
    required this.categoryScores,
    required this.score,
    required this.analysis,
    required this.recommendations,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'taken_at': takenAt.toIso8601String(),
    'category_scores': categoryScores.map((cs) => cs.toJson()).toList(),
    'score': score,
    'analysis': analysis,
    'recommendations': recommendations,
    'created_at': createdAt.toIso8601String(),
  };

  factory PsychologyTestResult.fromJson(Map<String, dynamic> json) {
    List<CategoryScore> scores = [];
    if (json['category_scores'] != null && json['category_scores'] is List) {
      final categoryScoresData = json['category_scores'] as List;
      scores = categoryScoresData
          .map((item) {
            if (item is Map<String, dynamic>) {
              return CategoryScore.fromJson(item);
            }
            return CategoryScore(category: 'Invalid Data', score: null);
          })
          .toList();
    } else if (json['category_scores'] != null) {
       print("Warning: Unexpected format for category_scores: ${json['category_scores'].runtimeType}");
    }

    List<String> recs = [];
    if (json['recommendations'] != null) {
      if (json['recommendations'] is String) {
        try {
           final decoded = jsonDecode(json['recommendations'] as String);
           if (decoded is List) {
             recs = decoded.map((r) => r.toString()).toList();
           }
        } catch (e) {
           print("Error decoding recommendations string: $e");
        }
      } else if (json['recommendations'] is List) {
        recs = (json['recommendations'] as List).map((r) => r.toString()).toList();
      }
    }

    DateTime parseDateTimeSafe(String? dateString) {
       if (dateString == null) return DateTime.now();
       return DateTime.tryParse(dateString) ?? DateTime.now();
    }

    return PsychologyTestResult(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      takenAt: parseDateTimeSafe(json['taken_at'] as String?),
      categoryScores: scores,
      score: json['score'] as int? ?? 0,
      analysis: json['analysis'] as String? ?? '',
      recommendations: recs,
      createdAt: parseDateTimeSafe(json['created_at'] as String?),
    );
  }
}
