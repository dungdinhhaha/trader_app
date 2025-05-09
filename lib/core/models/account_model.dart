import 'package:uuid/uuid.dart';

class Account {
  final String id;
  final String userId;
  final double balance;
  final double profitLoss;
  final double winRate;
  final int totalTrades;
  final int successfulTrades;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    String? id,
    required this.userId,
    this.balance = 0.0,
    this.profitLoss = 0.0,
    this.winRate = 0.0,
    this.totalTrades = 0,
    this.successfulTrades = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Create Account from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      profitLoss: (json['profit_loss'] as num).toDouble(),
      winRate: (json['win_rate'] as num).toDouble(),
      totalTrades: json['total_trades'] as int,
      successfulTrades: json['successful_trades'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert Account to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'profit_loss': profitLoss,
      'win_rate': winRate,
      'total_trades': totalTrades,
      'successful_trades': successfulTrades,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of Account with updated fields
  Account copyWith({
    String? id,
    String? userId,
    double? balance,
    double? profitLoss,
    double? winRate,
    int? totalTrades,
    int? successfulTrades,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      profitLoss: profitLoss ?? this.profitLoss,
      winRate: winRate ?? this.winRate,
      totalTrades: totalTrades ?? this.totalTrades,
      successfulTrades: successfulTrades ?? this.successfulTrades,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
