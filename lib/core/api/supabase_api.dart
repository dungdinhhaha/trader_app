import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../models/account_model.dart';
import '../models/psychology_models.dart';
import '../models/trade_method_model.dart';
import '../models/trade_model.dart';
import '../models/user_model.dart' as app_user;

class SupabaseApi {
  static SupabaseApi? _instance;
  late final SupabaseClient _client;

  // Private constructor
  SupabaseApi._() {
    _client = Supabase.instance.client;
  }

  // Singleton pattern
  static SupabaseApi get instance {
    _instance ??= SupabaseApi._();
    return _instance!;
  }

  // Initialize Supabase
  static Future<void> initialize() async {
    // Kiểm tra xem Supabase đã được khởi tạo chưa
    if (Supabase.instance.client != null) {
      // Đã được khởi tạo rồi, không cần khởi tạo lại
      return;
    }

    // Chưa được khởi tạo, tiến hành khởi tạo
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  // Get the current user
  User? get currentUser => _client.auth.currentUser;

  // Get the user session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current user as app user model
  Future<app_user.User?> getCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    final userData =
        await _client.from('profiles').select().eq('id', user.id).single();

    return app_user.User.fromJson({...user.toJson(), ...userData});
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // CRUD operations for Account
  Future<Account> getOrCreateAccount() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final data =
          await _client
              .from('accounts')
              .select()
              .eq('user_id', currentUser!.id)
              .maybeSingle();

      if (data != null) {
        return Account.fromJson(data);
      } else {
        // Create a new account
        final newAccount = Account(userId: currentUser!.id);
        final insertedData =
            await _client
                .from('accounts')
                .insert(newAccount.toJson())
                .select()
                .single();

        return Account.fromJson(insertedData);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Account> updateAccount(Account account) async {
    final data =
        await _client
            .from('accounts')
            .update(account.toJson())
            .eq('id', account.id)
            .select()
            .single();

    return Account.fromJson(data);
  }

  // CRUD operations for Trades
  Future<List<Trade>> getTrades({
    String? status,
    String? methodId,
    String? realBacktest,
  }) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    var query = _client
        .from('trades')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    // Execute the query first to get data
    final data = await query;

    // Filter the results in memory
    var result = data.map((json) => Trade.fromJson(json)).toList();

    if (status != null) {
      result = result.where((trade) => trade.status == status).toList();
    }

    if (methodId != null) {
      result =
          result.where((trade) => trade.tradeMethodId == methodId).toList();
    }

    if (realBacktest != null) {
      result =
          result.where((trade) => trade.realBacktest == realBacktest).toList();
    }

    return result;
  }

  Future<Trade> getTrade(String id) async {
    final data = await _client.from('trades').select().eq('id', id).single();

    return Trade.fromJson(data);
  }

  Future<Trade> createTrade(Trade trade) async {
    final data =
        await _client.from('trades').insert(trade.toJson()).select().single();

    return Trade.fromJson(data);
  }

  Future<Trade> updateTrade(Trade trade) async {
    final data =
        await _client
            .from('trades')
            .update(trade.toJson())
            .eq('id', trade.id)
            .select()
            .single();

    return Trade.fromJson(data);
  }

  Future<void> deleteTrade(String id) async {
    await _client.from('trades').delete().eq('id', id);
  }

  // CRUD operations for Trade Methods
  Future<List<TradeMethod>> getTradeMethods() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final data = await _client
        .from('trade_methods')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);

    return data.map((json) => TradeMethod.fromJson(json)).toList();
  }

  Future<TradeMethod> getTradeMethod(String id) async {
    final data =
        await _client.from('trade_methods').select().eq('id', id).single();

    return TradeMethod.fromJson(data);
  }

  Future<TradeMethod> createTradeMethod(TradeMethod method) async {
    final data = await _client
        .from('trade_methods')
        .insert({
          ...method.toJson(),
          'total_trades': 0,
          'win_trades': 0,
          'lose_trades': 0,
          'draw_trades': 0,
          'recommendations': [],
        })
        .select()
        .single();

    return TradeMethod.fromJson(data);
  }

  Future<TradeMethod> updateTradeMethod(TradeMethod method) async {
    final data =
        await _client
            .from('trade_methods')
            .update(method.toJson())
            .eq('id', method.id)
            .select()
            .single();

    return TradeMethod.fromJson(data);
  }

  Future<void> deleteTradeMethod(String id) async {
    await _client.from('trade_methods').delete().eq('id', id);
  }

  // CRUD operations for Psychology
  Future<List<PsychologyQuestion>> getPsychologyQuestions() async {
    try {
      print('Fetching psychology questions...');

      final response = await _client
          .from('psychology_questions')
          .select()
          .order('created_at');

      print('Raw response from database:');
      print(response);

      if (response == null || !(response is List)) {
        throw Exception('Invalid response format from database');
      }

      final List<PsychologyQuestion> questions = [];

      for (var data in response) {
        try {
          // Ensure required fields exist
          if (data['id'] == null ||
              data['question'] == null ||
              data['category'] == null ||
              data['answers'] == null) {
            print('Warning: Missing required fields for question: $data');
            continue;
          }

          // Handle answers field - it should be a List<Map> from JSONB
          var answersData = data['answers'];
          List<Map<String, dynamic>> answersList = [];

          if (answersData is List) {
            answersList =
                answersData.map((item) {
                  if (item is Map) {
                    return Map<String, dynamic>.from(item);
                  }
                  throw Exception(
                    'Invalid answer format: answer item is not a Map',
                  );
                }).toList();
          } else {
            print('Warning: answers is not a List for question ${data['id']}');
            continue;
          }

          // Validate answers format
          bool isValidAnswers = answersList.every((answer) {
            return answer.containsKey('text') && answer.containsKey('score');
          });

          if (!isValidAnswers) {
            print('Warning: Invalid answer format for question ${data['id']}');
            continue;
          }

          // Create PsychologyQuestion object
          final question = PsychologyQuestion(
            id: data['id'] as String,
            question: data['question'] as String,
            category: data['category'] as String,
            answers:
                answersList.map((answer) {
                  // Handle score conversion
                  var score = answer['score'];
                  if (score is String) {
                    score = int.tryParse(score) ?? 0;
                  } else if (score is num) {
                    score = score.toInt();
                  } else {
                    score = 0;
                  }

                  return PsychologyAnswer(
                    text: answer['text'] as String? ?? '',
                    value: score, // Map score to value
                  );
                }).toList(),
            createdAt: DateTime.parse(data['created_at'] as String),
          );

          questions.add(question);
          print('Successfully processed question ${data['id']}');
        } catch (e, stackTrace) {
          print('Error processing question: $e');
          print('Stack trace: $stackTrace');
          print('Raw data: $data');
          continue;
        }
      }

      print('Successfully loaded ${questions.length} questions');
      return questions;
    } catch (e, stackTrace) {
      print('Error fetching psychology questions: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch psychology questions: $e');
    }
  }

  Future<List<PsychologyTestResult>> getPsychologyTestResults() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final data = await _client
        .from('psychology_test_results')
        .select()
        .eq('user_id', currentUser!.id)
        .order('taken_at', ascending: false);

    return data.map((json) => PsychologyTestResult.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> createPsychologyTestResult(
    Map<String, dynamic> result,
  ) async {
    try {
      final response =
          await _client
              .from('psychology_test_results')
              .insert(result)
              .select()
              .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create psychology test result: $e');
    }
  }
}
