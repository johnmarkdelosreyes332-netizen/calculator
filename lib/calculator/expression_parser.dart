class ExpressionParser {
  ExpressionParser(this.source);

  final String source;
  int _position = 0;

  double parse() {
    final result = _parseExpression();
    _skipWhitespace();
    if (_position != source.length) {
      throw const FormatException('Unexpected characters in expression');
    }
    if (!result.isFinite) {
      throw const FormatException('Number is too large');
    }
    return result;
  }

  double _parseExpression() {
    var value = _parseTerm();
    while (true) {
      _skipWhitespace();
      if (_take('+')) {
        value += _parseTerm();
      } else if (_take('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    var value = _parseUnary();
    while (true) {
      _skipWhitespace();
      if (_take('*')) {
        value *= _parseUnary();
      } else if (_take('/')) {
        final divisor = _parseUnary();
        if (divisor == 0) {
          throw const CalculatorDivisionByZeroException();
        }
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parseUnary() {
    _skipWhitespace();
    if (_take('+')) return _parseUnary();
    if (_take('-')) return -_parseUnary();
    return _parseNumber();
  }

  double _parseNumber() {
    _skipWhitespace();
    final start = _position;
    var hasDigit = false;
    while (_position < source.length &&
        _isDigit(source.codeUnitAt(_position))) {
      hasDigit = true;
      _position++;
    }
    if (_take('.')) {
      while (_position < source.length &&
          _isDigit(source.codeUnitAt(_position))) {
        hasDigit = true;
        _position++;
      }
    }
    if (!hasDigit) {
      throw const FormatException('Expected a number');
    }
    if (_position < source.length &&
        (source[_position] == 'e' || source[_position] == 'E')) {
      _position++;
      if (_position < source.length &&
          (source[_position] == '+' || source[_position] == '-')) {
        _position++;
      }
      final exponentStart = _position;
      while (_position < source.length &&
          _isDigit(source.codeUnitAt(_position))) {
        _position++;
      }
      if (_position == exponentStart) {
        throw const FormatException('Invalid exponent');
      }
    }

    final value = double.tryParse(source.substring(start, _position));
    if (value == null || !value.isFinite) {
      throw const FormatException('Number is too large');
    }
    return value;
  }

  bool _take(String character) {
    if (_position < source.length && source[_position] == character) {
      _position++;
      return true;
    }
    return false;
  }

  void _skipWhitespace() {
    while (_position < source.length && source.codeUnitAt(_position) <= 0x20) {
      _position++;
    }
  }

  bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
}

class CalculatorDivisionByZeroException implements Exception {
  const CalculatorDivisionByZeroException();
}

String formatCalculatorNumber(double value) {
  if (!value.isFinite) return 'Number too large';
  if (value == 0) return '0';

  final magnitude = value.abs();
  if (magnitude >= 1e12 || magnitude < 1e-8) {
    final parts = value.toStringAsPrecision(10).toLowerCase().split('e');
    final mantissa = _trimDecimalZeros(parts.first);
    final exponent = int.parse(parts.last);
    return '${mantissa}e${exponent >= 0 ? '+' : ''}$exponent';
  }

  return _trimDecimalZeros(value.toStringAsFixed(10));
}

String _trimDecimalZeros(String value) {
  if (!value.contains('.')) return value;
  return value
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
