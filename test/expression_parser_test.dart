import 'package:flutter_test/flutter_test.dart';
import 'package:gold_calculator/calculator/expression_parser.dart';

void main() {
  group('ExpressionParser', () {
    test('respects multiplication and division precedence', () {
      expect(ExpressionParser('2+3*4').parse(), 14);
      expect(ExpressionParser('12/3-2').parse(), 2);
    });

    test('supports decimal numbers and unary signs', () {
      expect(ExpressionParser('-2.5*2').parse(), -5);
      expect(ExpressionParser('5+-3').parse(), 2);
    });

    test('formats floating-point results without representation noise', () {
      expect(
        formatCalculatorNumber(ExpressionParser('0.1+0.2').parse()),
        '0.3',
      );
    });

    test('uses scientific notation for extreme magnitudes', () {
      expect(formatCalculatorNumber(1e15), '1e+15');
      expect(formatCalculatorNumber(1e-10), '1e-10');
    });

    test('reports division by zero', () {
      expect(
        () => ExpressionParser('5/0').parse(),
        throwsA(isA<CalculatorDivisionByZeroException>()),
      );
    });

    test('rejects malformed or non-finite expressions', () {
      expect(() => ExpressionParser('2..3').parse(), throwsFormatException);
      expect(() => ExpressionParser('1e999').parse(), throwsFormatException);
    });
  });
}
