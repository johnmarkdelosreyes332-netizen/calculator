import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculation_history.dart';
import 'expression_parser.dart';

class CalculatorProvider extends ChangeNotifier {
  static const _historyKey = 'calculation_history';
  static final _numberAtEnd = RegExp(r'(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?$');

  late final Future<void> _historyReady;
  String _expression = '';
  String _completedExpression = '';
  String? _message;
  bool _hasJustEvaluated = false;
  bool _isDisposed = false;
  List<CalculationHistory> _history = const [];
  String? _historyError;

  String get expression => _expression;
  String get displayExpression =>
      _completedExpression.isNotEmpty ? _completedExpression : _expression;
  List<CalculationHistory> get history => List.unmodifiable(_history);
  String? get historyError => _historyError;

  String get displayValue {
    if (_message != null) return _message!;
    if (_expression.isEmpty) return '0';
    try {
      return formatCalculatorNumber(ExpressionParser(_expression).parse());
    } on CalculatorDivisionByZeroException {
      return 'Cannot divide by zero';
    } on FormatException {
      final match = _numberAtEnd.firstMatch(_expression);
      if (match == null) return _previewWithoutTrailingOperators();
      final start = _includeUnarySign(_expression, match.start);
      return _expression.substring(start);
    }
  }

  String get formattedExpression => _formatExpression(displayExpression);

  CalculatorProvider() {
    _historyReady = _loadHistory();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void inputDigit(String digit) {
    if (digit.length != 1 ||
        digit.codeUnitAt(0) < 0x30 ||
        digit.codeUnitAt(0) > 0x39) {
      return;
    }
    _prepareForEntry();
    final match = _numberAtEnd.firstMatch(_expression);
    if (match != null) {
      final start = _includeUnarySign(_expression, match.start);
      final current = _expression.substring(start);
      if (current == '0' || current == '-0') {
        final sign = current.startsWith('-') ? '-' : '';
        _expression = '${_expression.substring(0, start)}$sign$digit';
      } else {
        _expression += digit;
      }
    } else {
      _expression += digit;
    }
    _message = null;
    notifyListeners();
  }

  void inputDecimal() {
    _prepareForEntry();
    final match = _numberAtEnd.firstMatch(_expression);
    if (match != null) {
      final number = match.group(0)!;
      if (number.contains('.') ||
          number.contains('e') ||
          number.contains('E')) {
        return;
      }
      _expression += '.';
    } else {
      _expression += '0.';
    }
    _message = null;
    notifyListeners();
  }

  void inputOperator(String operator) {
    if (!const {'+', '-', '*', '/'}.contains(operator)) return;
    if (_hasJustEvaluated) {
      _hasJustEvaluated = false;
      _completedExpression = '';
    }
    if (_expression.isEmpty) {
      if (operator == '-') _expression = '-';
    } else if (_endsWithOperator(_expression)) {
      if (_expression.endsWith('-') &&
          (_expression.length == 1 ||
              _isOperator(_expression[_expression.length - 2]))) {
        if (operator == '-') {
          _expression = _expression.substring(0, _expression.length - 1);
        } else {
          _expression =
              '${_expression.substring(0, _expression.length - 2)}$operator';
        }
      } else if (operator == '-' &&
          !_expression.endsWith('+') &&
          !_expression.endsWith('*') &&
          !_expression.endsWith('/')) {
        _expression += '-';
      } else {
        _expression =
            '${_expression.substring(0, _expression.length - 1)}$operator';
      }
    } else {
      _expression += operator;
    }
    _message = null;
    notifyListeners();
  }

  void toggleSign() {
    if (_hasJustEvaluated) {
      _expression = _expression.isEmpty ? '0' : _expression;
      _completedExpression = '';
      _hasJustEvaluated = false;
    }
    final match = _numberAtEnd.firstMatch(_expression);
    if (match == null) {
      if (_expression.isEmpty) {
        _expression = '-';
      } else if (_endsWithOperator(_expression)) {
        if (_expression.endsWith('-') &&
            (_expression.length == 1 ||
                _isOperator(_expression[_expression.length - 2]))) {
          _expression = _expression.substring(0, _expression.length - 1);
        } else {
          _expression += '-';
        }
      }
    } else {
      final start = _includeUnarySign(_expression, match.start);
      final number = _expression.substring(start);
      _expression =
          _expression.substring(0, start) +
          (number.startsWith('-') ? number.substring(1) : '-$number');
    }
    _message = null;
    notifyListeners();
  }

  void applyPercent() {
    final match = _numberAtEnd.firstMatch(_expression);
    if (match == null) return;
    final start = _includeUnarySign(_expression, match.start);
    final number = double.tryParse(_expression.substring(start));
    if (number == null) return;
    if (_hasJustEvaluated) {
      _completedExpression = '';
    }
    _expression =
        '${_expression.substring(0, start)}'
        '${formatCalculatorNumber(number / 100)}';
    _hasJustEvaluated = false;
    _message = null;
    notifyListeners();
  }

  void backspace() {
    if (_message != null) {
      _message = null;
    } else if (_hasJustEvaluated) {
      _expression = '';
      _completedExpression = '';
      _hasJustEvaluated = false;
    } else if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
    }
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _completedExpression = '';
    _message = null;
    _hasJustEvaluated = false;
    notifyListeners();
  }

  Future<void> evaluate() async {
    if (_expression.isEmpty || _endsWithOperator(_expression)) return;
    try {
      final result = formatCalculatorNumber(
        ExpressionParser(_expression).parse(),
      );
      final completed = _expression;
      _completedExpression = completed;
      _expression = result;
      _hasJustEvaluated = true;
      _message = null;
      notifyListeners();

      await _historyReady;
      _history = [
        CalculationHistory(
          expression: _formatExpression(completed),
          result: result,
          timestamp: DateTime.now(),
        ),
        ..._history,
      ];
      _notifyListenersIfAlive();
      await _saveHistory();
    } on CalculatorDivisionByZeroException {
      _message = 'Cannot divide by zero';
      notifyListeners();
    } on FormatException catch (error) {
      _message = error.message == 'Number is too large'
          ? 'Number is too large'
          : 'Invalid expression';
      notifyListeners();
    }
  }

  void useHistoryResult(CalculationHistory entry) {
    _expression = entry.result;
    _completedExpression = '';
    _message = null;
    _hasJustEvaluated = true;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _historyReady;
    _history = const [];
    _historyError = null;
    _notifyListenersIfAlive();
    await _saveHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final entries = preferences.getStringList(_historyKey) ?? const [];
      final loaded = <CalculationHistory>[];
      for (final entry in entries) {
        final decoded = jsonDecode(entry);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid calculation history data');
        }
        loaded.add(CalculationHistory.fromJson(decoded));
      }
      _history = loaded;
      _notifyListenersIfAlive();
    } on FormatException catch (error, stackTrace) {
      _reportHistoryError(
        'Could not read saved calculation history',
        error,
        stackTrace,
      );
    } on PlatformException catch (error, stackTrace) {
      _reportHistoryError(
        'Could not read saved calculation history',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _saveHistory() async {
    try {
      await _historyReady;
      final preferences = await SharedPreferences.getInstance();
      final entries = _history
          .map((entry) => jsonEncode(entry.toJson()))
          .toList(growable: false);
      final saved = await preferences.setStringList(_historyKey, entries);
      if (!saved) {
        throw const FormatException('The device declined the history update');
      }
      _historyError = null;
      _notifyListenersIfAlive();
    } on FormatException catch (error, stackTrace) {
      _reportHistoryError(
        'Could not save calculation history',
        error,
        stackTrace,
      );
    } on PlatformException catch (error, stackTrace) {
      _reportHistoryError(
        'Could not save calculation history',
        error,
        stackTrace,
      );
    }
  }

  void _reportHistoryError(
    String message,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('$message: $error\n$stackTrace');
    _historyError = message;
    _notifyListenersIfAlive();
  }

  void _notifyListenersIfAlive() {
    if (!_isDisposed) notifyListeners();
  }

  void _prepareForEntry() {
    if (_hasJustEvaluated) {
      _expression = '';
      _completedExpression = '';
      _hasJustEvaluated = false;
    }
  }

  String _previewWithoutTrailingOperators() {
    var candidate = _expression;
    while (candidate.isNotEmpty && _endsWithOperator(candidate)) {
      candidate = candidate.substring(0, candidate.length - 1);
      if (candidate.isEmpty) continue;
      try {
        return formatCalculatorNumber(ExpressionParser(candidate).parse());
      } on CalculatorDivisionByZeroException {
        return 'Cannot divide by zero';
      } on FormatException {
        continue;
      }
    }
    return '0';
  }

  static bool _isOperator(String character) =>
      character == '+' ||
      character == '-' ||
      character == '*' ||
      character == '/';

  static bool _endsWithOperator(String expression) =>
      expression.isNotEmpty && _isOperator(expression[expression.length - 1]);

  static int _includeUnarySign(String expression, int numberStart) {
    if (numberStart == 0 || expression[numberStart - 1] != '-') {
      return numberStart;
    }
    final beforeSign = numberStart - 1;
    if (beforeSign == 0 || _isOperator(expression[beforeSign - 1])) {
      return beforeSign;
    }
    return numberStart;
  }

  static String _formatExpression(String expression) =>
      expression.replaceAll('*', '×').replaceAll('/', '÷').replaceAll('-', '−');
}
