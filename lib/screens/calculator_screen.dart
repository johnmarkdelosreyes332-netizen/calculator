import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../calculator/calculation_history.dart';
import '../calculator/calculator_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import 'galaxy_background.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GalaxyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) =>
                  PopupMenuButton<AppAccent>(
                    tooltip: 'Choose accent color',
                    icon: const Icon(Icons.palette_outlined),
                    initialValue: themeProvider.accent,
                    onSelected: (accent) async {
                      final saved = await context
                          .read<ThemeProvider>()
                          .setAccent(accent);
                      if (!saved && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Color changed, but could not be saved.',
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => AppAccent.values
                        .map(
                          (accent) => PopupMenuItem<AppAccent>(
                            value: accent,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: accent.light,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(accent.label)),
                                if (accent == themeProvider.accent)
                                  const Icon(Icons.check_rounded, size: 18),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => IconButton(
                tooltip: themeProvider.isDarkMode
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                onPressed: () async {
                  final saved = await context
                      .read<ThemeProvider>()
                      .toggleTheme();
                  if (!saved && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme changed, but could not be saved.'),
                      ),
                    );
                  }
                },
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Calculation history',
              onPressed: () => _showHistory(context),
              icon: const Icon(Icons.history_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  orientation == Orientation.portrait ? 18 : 28,
                  0,
                  orientation == Orientation.portrait ? 18 : 28,
                  12,
                ),
                child: const Column(
                  children: [
                    Expanded(flex: 4, child: _CalculatorDisplay()),
                    Expanded(flex: 6, child: _Keypad()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _HistorySheet(),
    );
  }
}

class _CalculatorDisplay extends StatelessWidget {
  const _CalculatorDisplay();

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        final palette = AppTheme.paletteOf(context);
        final value = calculator.displayValue;
        final isError =
            value == 'Cannot divide by zero' ||
            value == 'Number is too large' ||
            value == 'Invalid expression';
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 150;
            return SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      calculator.formattedExpression,
                      maxLines: 1,
                      style: TextStyle(
                        color: calculator.formattedExpression.isEmpty
                            ? palette.muted
                            : palette.mutedGold,
                        fontSize: compact ? 14 : 20,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 0 : 8),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: TextStyle(
                          color: isError ? palette.error : palette.display,
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 0 : 28),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad();

  static const _rows = [
    [
      _CalculatorKey.ac,
      _CalculatorKey.backspace,
      _CalculatorKey.percent,
      _CalculatorKey.divide,
    ],
    [
      _CalculatorKey.seven,
      _CalculatorKey.eight,
      _CalculatorKey.nine,
      _CalculatorKey.multiply,
    ],
    [
      _CalculatorKey.four,
      _CalculatorKey.five,
      _CalculatorKey.six,
      _CalculatorKey.subtract,
    ],
    [
      _CalculatorKey.one,
      _CalculatorKey.two,
      _CalculatorKey.three,
      _CalculatorKey.add,
    ],
    [
      _CalculatorKey.sign,
      _CalculatorKey.zero,
      _CalculatorKey.decimal,
      _CalculatorKey.equals,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxHeight < 300 ? 6.0 : 10.0;
        return Column(
          children: [
            for (var rowIndex = 0; rowIndex < _rows.length; rowIndex++) ...[
              if (rowIndex > 0) SizedBox(height: spacing),
              Expanded(
                child: Row(
                  children: [
                    for (var column = 0; column < 4; column++) ...[
                      if (column > 0) SizedBox(width: spacing),
                      Expanded(
                        child: _KeyButton(
                          keyType: _rows[rowIndex][column],
                          onPressed: () =>
                              _handleKey(context, _rows[rowIndex][column]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _handleKey(BuildContext context, _CalculatorKey key) {
    final calculator = context.read<CalculatorProvider>();
    switch (key) {
      case _CalculatorKey.ac:
        calculator.clear();
        break;
      case _CalculatorKey.backspace:
        calculator.backspace();
        break;
      case _CalculatorKey.percent:
        calculator.applyPercent();
        break;
      case _CalculatorKey.sign:
        calculator.toggleSign();
        break;
      case _CalculatorKey.decimal:
        calculator.inputDecimal();
        break;
      case _CalculatorKey.add:
        calculator.inputOperator('+');
        break;
      case _CalculatorKey.subtract:
        calculator.inputOperator('-');
        break;
      case _CalculatorKey.multiply:
        calculator.inputOperator('*');
        break;
      case _CalculatorKey.divide:
        calculator.inputOperator('/');
        break;
      case _CalculatorKey.equals:
        calculator.evaluate();
        break;
      case _CalculatorKey.zero:
        calculator.inputDigit('0');
        break;
      case _CalculatorKey.one:
        calculator.inputDigit('1');
        break;
      case _CalculatorKey.two:
        calculator.inputDigit('2');
        break;
      case _CalculatorKey.three:
        calculator.inputDigit('3');
        break;
      case _CalculatorKey.four:
        calculator.inputDigit('4');
        break;
      case _CalculatorKey.five:
        calculator.inputDigit('5');
        break;
      case _CalculatorKey.six:
        calculator.inputDigit('6');
        break;
      case _CalculatorKey.seven:
        calculator.inputDigit('7');
        break;
      case _CalculatorKey.eight:
        calculator.inputDigit('8');
        break;
      case _CalculatorKey.nine:
        calculator.inputDigit('9');
        break;
    }
  }
}

enum _CalculatorKey {
  ac,
  backspace,
  percent,
  divide,
  seven,
  eight,
  nine,
  multiply,
  four,
  five,
  six,
  subtract,
  one,
  two,
  three,
  add,
  sign,
  zero,
  decimal,
  equals,
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({required this.keyType, required this.onPressed});

  final _CalculatorKey keyType;
  final VoidCallback onPressed;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final keyType = widget.keyType;
    final palette = AppTheme.paletteOf(context);
    final isOperator = const {
      _CalculatorKey.add,
      _CalculatorKey.subtract,
      _CalculatorKey.multiply,
      _CalculatorKey.divide,
    }.contains(keyType);
    final isEquals = keyType == _CalculatorKey.equals;
    final isUtility = const {
      _CalculatorKey.ac,
      _CalculatorKey.backspace,
      _CalculatorKey.percent,
      _CalculatorKey.sign,
    }.contains(keyType);

    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: isEquals || isOperator
            ? Colors.transparent
            : isUtility
            ? palette.utilityKey
            : palette.numberKey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: isUtility
              ? BorderSide(color: palette.outline, width: 0.8)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: isEquals
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.accentHighlight, palette.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : isOperator
              ? BoxDecoration(color: palette.operatorKey)
              : null,
          child: Semantics(
            button: true,
            label: _keyDescription(keyType),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onPressed();
              },
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              splashFactory: InkRipple.splashFactory,
              borderRadius: BorderRadius.circular(22),
              splashColor:
                  (isOperator || isEquals
                          ? palette.operatorText
                          : palette.accent)
                      .withValues(alpha: 0.32),
              highlightColor: palette.accent.withValues(alpha: 0.12),
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return palette.accent.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)) {
                  return palette.accent.withValues(alpha: 0.08);
                }
                return null;
              }),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _KeyLabel(
                    keyType: keyType,
                    color: isEquals || isOperator
                        ? palette.operatorText
                        : isUtility
                        ? palette.utilityText
                        : palette.numberText,
                    isEquals: isEquals,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _keyDescription(_CalculatorKey key) => switch (key) {
    _CalculatorKey.ac => 'Clear all',
    _CalculatorKey.backspace => 'Delete',
    _CalculatorKey.percent => 'Percent',
    _CalculatorKey.divide => 'Divide',
    _CalculatorKey.multiply => 'Multiply',
    _CalculatorKey.subtract => 'Subtract',
    _CalculatorKey.add => 'Add',
    _CalculatorKey.sign => 'Toggle sign',
    _CalculatorKey.decimal => 'Decimal point',
    _CalculatorKey.equals => 'Equals',
    _ => switch (key) {
      _CalculatorKey.zero => '0',
      _CalculatorKey.one => '1',
      _CalculatorKey.two => '2',
      _CalculatorKey.three => '3',
      _CalculatorKey.four => '4',
      _CalculatorKey.five => '5',
      _CalculatorKey.six => '6',
      _CalculatorKey.seven => '7',
      _CalculatorKey.eight => '8',
      _CalculatorKey.nine => '9',
      _ => '',
    },
  };
}

class _KeyLabel extends StatelessWidget {
  const _KeyLabel({
    required this.keyType,
    required this.color,
    required this.isEquals,
  });

  final _CalculatorKey keyType;
  final Color color;
  final bool isEquals;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (keyType) {
      _CalculatorKey.ac => ('AC', null),
      _CalculatorKey.backspace => (null, Icons.backspace_outlined),
      _CalculatorKey.percent => ('%', null),
      _CalculatorKey.divide => ('÷', null),
      _CalculatorKey.seven => ('7', null),
      _CalculatorKey.eight => ('8', null),
      _CalculatorKey.nine => ('9', null),
      _CalculatorKey.multiply => ('×', null),
      _CalculatorKey.four => ('4', null),
      _CalculatorKey.five => ('5', null),
      _CalculatorKey.six => ('6', null),
      _CalculatorKey.subtract => ('−', null),
      _CalculatorKey.one => ('1', null),
      _CalculatorKey.two => ('2', null),
      _CalculatorKey.three => ('3', null),
      _CalculatorKey.add => ('+', null),
      _CalculatorKey.sign => ('±', null),
      _CalculatorKey.zero => ('0', null),
      _CalculatorKey.decimal => ('.', null),
      _CalculatorKey.equals => ('=', null),
    };

    if (icon != null) {
      return Icon(icon, size: 23, color: color);
    }
    return Text(
      label!,
      style: TextStyle(
        color: color,
        fontSize: isEquals
            ? 34
            : keyType == _CalculatorKey.ac
            ? 17
            : 25,
        fontWeight: isEquals ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, _) {
        final palette = AppTheme.paletteOf(context);
        final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 16),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.68,
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.mutedGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'History',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (calculator.history.isNotEmpty)
                        TextButton(
                          onPressed: () => _confirmClear(context),
                          child: const Text('Clear history'),
                        ),
                    ],
                  ),
                  if (calculator.historyError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        calculator.historyError!,
                        style: TextStyle(color: palette.error, fontSize: 13),
                      ),
                    ),
                  Expanded(
                    child: calculator.history.isEmpty
                        ? Center(
                            child: Text(
                              'Your calculations will appear here',
                              style: TextStyle(color: palette.muted),
                            ),
                          )
                        : ListView.separated(
                            itemCount: calculator.history.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: palette.divider, height: 1),
                            itemBuilder: (context, index) {
                              final entry = calculator.history[index];
                              return _HistoryTile(
                                entry: entry,
                                onTap: () {
                                  calculator.useHistoryResult(entry);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear calculation history?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (shouldClear == true && context.mounted) {
      await context.read<CalculatorProvider>().clearHistory();
    }
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.onTap});

  final CalculationHistory entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.paletteOf(context);
    final date = entry.timestamp.toLocal();
    final timeLabel =
        '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}'
        '  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      onTap: onTap,
      title: Text(
        entry.expression,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(color: palette.muted, fontSize: 15),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          timeLabel,
          textAlign: TextAlign.right,
          style: TextStyle(color: palette.mutedGold, fontSize: 11),
        ),
      ),
      trailing: Text(
        '= ${entry.result}',
        style: TextStyle(
          color: palette.display,
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
