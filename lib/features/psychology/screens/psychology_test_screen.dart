import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/themes/app_theme.dart';
import '../providers/psychology_test_provider.dart';
import '../widgets/question_card.dart';
import 'test_result_screen.dart';

class PsychologyTestScreen extends ConsumerStatefulWidget {
  const PsychologyTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PsychologyTestScreen> createState() =>
      _PsychologyTestScreenState();
}

class _PsychologyTestScreenState extends ConsumerState<PsychologyTestScreen> {
  @override
  void initState() {
    super.initState();
    // Load questions when screen initializes
    Future.microtask(
      () => ref.read(psychologyTestProvider.notifier).loadQuestions(),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(psychologyTestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra tâm lý'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: testState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi khi tải câu hỏi:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () =>
                            ref
                                .read(psychologyTestProvider.notifier)
                                .loadQuestions(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
        data: (state) {
          if (state.isSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if exists
          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showError(state.error!);
            });
          }

          if (state.questions.isEmpty) {
            return const Center(
              child: Text(
                'Không có câu hỏi nào.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đánh giá tâm lý giao dịch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hãy trả lời các câu hỏi sau để đánh giá tâm lý giao dịch của bạn. Kết quả sẽ giúp bạn hiểu rõ hơn về điểm mạnh và điểm yếu trong tâm lý giao dịch.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...state.questions.map((question) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: QuestionCard(
                      question: question,
                      selectedAnswer: state.answers[question.id]?.value,
                      onAnswerSelected: (value) {
                        final answer = question.answers.firstWhere(
                          (a) => a.value == value,
                          orElse: () => question.answers.first,
                        );
                        ref
                            .read(psychologyTestProvider.notifier)
                            .selectAnswer(question.id, answer);
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      state.isComplete
                          ? () async {
                            final result =
                                await ref
                                    .read(psychologyTestProvider.notifier)
                                    .submitTest();
                            if (result != null && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          TestResultScreen(result: result),
                                ),
                              );
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Nộp bài ${state.isComplete ? '' : '(${state.answers.length}/${state.questions.length})'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
