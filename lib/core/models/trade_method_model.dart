class TradeMethod {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> rules;
  final List<String> indicators;
  final List<String> timeframes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int totalTrades;
  final int winTrades;
  final int loseTrades;
  final int drawTrades;
  final List<String>? recommendations;

  TradeMethod({
     required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.rules,
    required this.indicators,
    required this.timeframes,
    required this.createdAt,
    this.updatedAt,
    this.totalTrades = 0,
    this.winTrades = 0,
    this.loseTrades = 0,
    this.drawTrades = 0,
    this.recommendations,
  });

  // Calculate win rate
  double get winRate {
    if (totalTrades == 0) return 0;
    return (winTrades / totalTrades) * 100;
  }

  // Create TradeMethod from JSON
  factory TradeMethod.fromJson(Map<String, dynamic> json) {
    return TradeMethod(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rules: List<String>.from(json['rules'] as List),
      indicators: List<String>.from(json['indicators'] as List),
      timeframes: List<String>.from(json['timeframes'] as List),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      totalTrades: json['total_trades'] as int? ?? 0,
      winTrades: json['win_trades'] as int? ?? 0,
      loseTrades: json['lose_trades'] as int? ?? 0,
      drawTrades: json['draw_trades'] as int? ?? 0,
      recommendations:
          json['recommendations'] != null
              ? List<String>.from(json['recommendations'] as List)
              : null,
    );
  }

  // Convert TradeMethod to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'rules': rules,
      'indicators': indicators,
      'timeframes': timeframes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'total_trades': totalTrades,
      'win_trades': winTrades,
      'lose_trades': loseTrades,
      'draw_trades': drawTrades,
      'recommendations': recommendations,
    };
  }

  // Create a copy of TradeMethod with updated fields
  TradeMethod copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? rules,
    List<String>? indicators,
    List<String>? timeframes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalTrades,
    int? winTrades,
    int? loseTrades,
    int? drawTrades,
    List<String>? recommendations,
  }) {
    return TradeMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      indicators: indicators ?? this.indicators,
      timeframes: timeframes ?? this.timeframes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalTrades: totalTrades ?? this.totalTrades,
      winTrades: winTrades ?? this.winTrades,
      loseTrades: loseTrades ?? this.loseTrades,
      drawTrades: drawTrades ?? this.drawTrades,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  // Update statistics after a trade
  TradeMethod updateStatistics({
    required String result, // 'win', 'lose', or 'draw'
  }) {
    final newTotalTrades = totalTrades + 1;
    final newWinTrades = result == 'win' ? winTrades + 1 : winTrades;
    final newLoseTrades = result == 'lose' ? loseTrades + 1 : loseTrades;
    final newDrawTrades = result == 'draw' ? drawTrades + 1 : drawTrades;

    return copyWith(
      totalTrades: newTotalTrades,
      winTrades: newWinTrades,
      loseTrades: newLoseTrades,
      drawTrades: newDrawTrades,
      updatedAt: DateTime.now(),
    );
  }
}
