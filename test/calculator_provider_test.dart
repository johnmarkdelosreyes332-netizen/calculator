import 'package:flutter_test/flutter_test.dart';
import 'package:gold_calculator/calculator/calculator_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('replaces consecutive operators and continues from a result', () async {
    final calculator = CalculatorProvider();
    calculator.inputDigit('2');
    calculator.inputOperator('+');
    calculator.inputOperator('*');
    expect(calculator.displayValue, '2');
    calculator.inputDigit('3');

    expect(calculator.expression, '2*3');
    await calculator.evaluate();
    expect(calculator.displayValue, '6');

    calculator.inputOperator('+');
    calculator.inputDigit('1');
    await calculator.evaluate();
    expect(calculator.displayValue, '7');
    expect(calculator.history, hasLength(2));
    expect(calculator.history.first.expression, '6+1');
    calculator.dispose();
  });

  test('normalizes leading zeros and prevents duplicate decimal points', () {
    final calculator = CalculatorProvider();
    calculator.inputDigit('0');
    calculator.inputDigit('0');
    calculator.inputDigit('7');
    calculator.inputDecimal();
    calculator.inputDecimal();
    calculator.inputDigit('5');

    expect(calculator.expression, '7.5');
  });

  test('shows a clear division-by-zero message', () async {
    final calculator = CalculatorProvider();
    calculator.inputDigit('8');
    calculator.inputOperator('/');
    calculator.inputDigit('0');

    await calculator.evaluate();
    expect(calculator.displayValue, 'Cannot divide by zero');
    expect(calculator.history, isEmpty);
    calculator.dispose();
  });

  test(
    'applies percent to a completed result without stale expression text',
    () async {
      final calculator = CalculatorProvider();
      calculator.inputDigit('5');
      await calculator.evaluate();
      calculator.applyPercent();

      expect(calculator.displayValue, '0.05');
      expect(calculator.formattedExpression, '0.05');
      calculator.dispose();
    },
  );
}
