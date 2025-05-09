class Trade {
  final String id;
  final String userId;
  final String symbol;
  final String type; // 'long' or 'short'
  final double entryPrice;
  final double? exitPrice;
  final double quantity;
  final DateTime entryDate;
  final DateTime? exitDate;
  final String status; // 'open' or 'closed'
  final double? profit;
  final String? note;
  final String? tradeMethodId;
  final List<String>? images;
  final DateTime createdAt;
  final String realBacktest; // 'real' or 'backtest'

  Trade({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.entryPrice,
    this.exitPrice,
    required this.quantity,
    required this.entryDate,
    this.exitDate,
    required this.status,
    this.profit,
    this.note,
    this.tradeMethodId,
    this.images,
    required this.createdAt,
    required this.realBacktest,
  });

  // Create Trade from JSON
  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      symbol: json['symbol'] as String,
      type: json['type'] as String,
      entryPrice: (json['entry_price'] as num).toDouble(),
      exitPrice:
          json['exit_price'] != null
              ? (json['exit_price'] as num).toDouble()
              : null,
      quantity: (json['quantity'] as num).toDouble(),
      entryDate: DateTime.parse(json['entry_date'] as String),
      exitDate:
          json['exit_date'] != null
              ? DateTime.parse(json['exit_date'] as String)
              : null,
      status: json['status'] as String,
      profit:
          json['profit'] != null ? (json['profit'] as num).toDouble() : null,
      note: json['note'] as String?,
      tradeMethodId: json['trade_method_id'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      realBacktest: json['real_backtest'] as String,
    );
  }

  // Convert Trade to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'symbol': symbol,
      'type': type,
      'entry_price': entryPrice,
      'exit_price': exitPrice,
      'quantity': quantity,
      'entry_date': entryDate.toIso8601String(),
      'exit_date': exitDate?.toIso8601String(),
      'status': status,
      'profit': profit,
      'note': note,
      'trade_method_id': tradeMethodId,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'real_backtest': realBacktest,
    };
  }

  // Create a copy of Trade with updated fields
  Trade copyWith({
    String? id,
    String? userId,
    String? symbol,
    String? type,
    double? entryPrice,
    double? exitPrice,
    double? quantity,
    DateTime? entryDate,
    DateTime? exitDate,
    String? status,
    double? profit,
    String? note,
    String? tradeMethodId,
    List<String>? images,
    DateTime? createdAt,
    String? realBacktest,
  }) {
    return Trade(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      quantity: quantity ?? this.quantity,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      status: status ?? this.status,
      profit: profit ?? this.profit,
      note: note ?? this.note,
      tradeMethodId: tradeMethodId ?? this.tradeMethodId,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      realBacktest: realBacktest ?? this.realBacktest,
    );
  }

  // Close a trade
  Trade closeTrade({
    required double exitPrice,
    required double profit,
    DateTime? exitDate,
  }) {
    return copyWith(
      exitPrice: exitPrice,
      profit: profit,
      exitDate: exitDate ?? DateTime.now(),
      status: 'closed',
    );
  }
}
