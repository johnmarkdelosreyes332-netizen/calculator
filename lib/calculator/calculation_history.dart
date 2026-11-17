class CalculationHistory {
  const CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  final String expression;
  final String result;
  final DateTime timestamp;

  Map<String, Object> toJson() => {
    'expression': expression,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    final expression = json['expression'];
    final result = json['result'];
    final timestamp = json['timestamp'];
    if (expression is! String || result is! String || timestamp is! String) {
      throw const FormatException('Invalid calculation history entry');
    }
    return CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.parse(timestamp),
    );
  }
}
