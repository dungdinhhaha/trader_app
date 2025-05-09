import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/supabase_api.dart';
import '../../../core/models/psychology_models.dart';
import '../../../core/services/chatgpt_service.dart';
import 'package:uuid/uuid.dart';

final psychologyTestProvider = StateNotifierProvider<
  PsychologyTestNotifier,
  AsyncValue<PsychologyTestState>
>((ref) => PsychologyTestNotifier());

class PsychologyTestState {
  final List<PsychologyQuestion> questions;
  final Map<String, PsychologyAnswer> answers;
  final bool isSubmitting;
  final String? error;
  final List<PsychologyTestResult> testHistory;

  const PsychologyTestState({
    this.questions = const [],
    this.answers = const {},
    this.isSubmitting = false,
    this.error,
    this.testHistory = const [],
  });

  bool get isComplete => answers.length == questions.length;

  PsychologyTestState copyWith({
    List<PsychologyQuestion>? questions,
    Map<String, PsychologyAnswer>? answers,
    bool? isSubmitting,
    String? error,
    List<PsychologyTestResult>? testHistory,
  }) {
    return PsychologyTestState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      testHistory: testHistory ?? this.testHistory,
    );
  }
}

class PsychologyTestNotifier
    extends StateNotifier<AsyncValue<PsychologyTestState>> {
  PsychologyTestNotifier() : super(const AsyncValue.loading()) {
    loadQuestions();
    loadTestHistory();
  }

  final _uuid = const Uuid();

  Future<void> loadQuestions() async {
    try {
      state = const AsyncValue.loading();
      final questions = await SupabaseApi.instance.getPsychologyQuestions();
      state = AsyncValue.data(
        state.value?.copyWith(questions: questions) ??
            PsychologyTestState(questions: questions),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadTestHistory() async {
    try {
      final history = await SupabaseApi.instance.getPsychologyTestResults();
      state = AsyncValue.data(
        state.value?.copyWith(testHistory: history) ??
            PsychologyTestState(testHistory: history),
      );
    } catch (e) {
      print('Error loading test history: $e');
    }
  }

  void selectAnswer(String questionId, PsychologyAnswer answer) {
    state.whenData((state) {
      final newAnswers = Map<String, PsychologyAnswer>.from(state.answers);
      newAnswers[questionId] = answer;
      this.state = AsyncValue.data(state.copyWith(answers: newAnswers));
    });
  }

  Future<PsychologyTestResult?> submitTest() async {
    // Get the current state data directly
    final currentState = state.value;
    if (currentState == null || !currentState.isComplete) {
      this.state = AsyncValue.data(
        (currentState ?? const PsychologyTestState()).copyWith(
          isSubmitting: false,
          error: 'Vui lòng hoàn thành tất cả câu hỏi trước khi nộp.'
        )
      );
      return null;
    }

    // Set submitting state
    this.state = AsyncValue.data(currentState.copyWith(isSubmitting: true, error: null));

    try {
      // Calculate scores by category
      final categoryScoresMap = <String, int>{};
      final categoryMaxScoresMap = <String, int>{}; // Keep this if needed for analysis

      for (final question in currentState.questions) {
        final answer = currentState.answers[question.id];
        if (answer != null) {
          categoryScoresMap[question.category] =
              (categoryScoresMap[question.category] ?? 0) + answer.value;
          // Assuming max score per question is 5, adjust if necessary
          categoryMaxScoresMap[question.category] =
              (categoryMaxScoresMap[question.category] ?? 0) + 5;
        }
      }

      // Create category scores list
      final categoryScoresList = categoryScoresMap.entries.map((entry) {
        return CategoryScore(
          category: entry.key,
          score: entry.value,
          // maxScore is removed from CategoryScore model
        );
      }).toList();

      // Calculate total score
      final totalScore = categoryScoresMap.values.fold<int>(0, (sum, score) => sum + score);
      // totalMaxScore might still be useful for some external analysis logic if kept
      // final totalMaxScore = categoryMaxScoresMap.values.fold<int>(0, (sum, score) => sum + score);

      // Generate analysis and recommendations (ensure services handle potential errors)
      // Note: ChatGPTService calls might need adjustment if they relied on maxScore
      final analysisList = await ChatGPTService.analyzePsychologyTest(
        categoryScoresList,
        totalScore.toDouble(), // Pass total score
      );
      final recommendationsList = await ChatGPTService.analyzePsychologyTest(
        categoryScoresList,
        totalScore.toDouble(), // Pass total score
      );

      // Sanitize analysis and recommendations
      String sanitize(String text) {
        return text
          .replaceAll(RegExp(r'[^\x20-\x7E\s]'), '') // Remove non-printable ASCII chars
          .replaceAll(RegExp(r'â¢'), '') // Remove specific unwanted sequences
          .replaceAll(RegExp(r'[â€¢]'), '') // Remove other common problematic chars
          .trim();
      }

      final sanitizedAnalysis = analysisList
          .map(sanitize)
          .where((s) => s.isNotEmpty)
          .join('\n');
      
      final sanitizedRecommendations = recommendationsList
          .map(sanitize)
          .where((s) => s.isNotEmpty)
          .toList();

      // Create test result
      final result = PsychologyTestResult(
        id: _uuid.v4(),
        // Ensure currentUser is available and not null
        userId: SupabaseApi.instance.currentUser?.id ?? 'unknown_user',
        takenAt: DateTime.now(),
        score: totalScore, // Use the calculated total score
        categoryScores: categoryScoresList,
        analysis: sanitizedAnalysis, // Use sanitized analysis
        recommendations: sanitizedRecommendations, // Use sanitized recommendations
        createdAt: DateTime.now(),
      );

      // Save to database
      await SupabaseApi.instance.createPsychologyTestResult(result.toJson());

      // Update final state (after successful submission)
      this.state = AsyncValue.data(
        currentState.copyWith(
          isSubmitting: false,
          answers: {}, // Reset answers for next test
          // Prepend the new result to the history
          testHistory: [result, ...currentState.testHistory],
          error: null, // Clear any previous error
        ),
      );

      // Return the created result for navigation
      return result;

    } catch (e, stackTrace) {
      print('Error submitting test: $e\n$stackTrace');
      // Update state with error, keep current answers for user to retry if needed
      this.state = AsyncValue.data(
        currentState.copyWith(
          isSubmitting: false,
          error: 'Đã xảy ra lỗi khi nộp bài: ${e.toString()}',
        )
      );
      return null; // Indicate failure
    }
    // Removed the implicit return null at the end
  }
}
