import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/presentation/widgets/keyword_highlight_text.dart';

void main() {
  testWidgets('renders multiple TextSpans when there are hits', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: KeywordHighlightText(
          text: '南京到上海',
          hits: [KeywordHit(ruleId:'k', keyword:'到', type: MatchType.contains, priority:50, highlightPositions:[2])],
        ),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText));
    // The TextSpan children must contain more than one piece (plain + highlighted + plain).
    final children = (rich.text as TextSpan).children ?? const <InlineSpan>[];
    expect(children.length, greaterThan(1));
  });

  testWidgets('renders single span with no hits', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: KeywordHighlightText(text: 'hello', hits: [])),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText));
    expect(((rich.text as TextSpan).children ?? const <InlineSpan>[]).length, 1);
    expect(((rich.text as TextSpan).children!.first as TextSpan).text, 'hello');
  });

  testWidgets('applies background color to highlighted characters only', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: KeywordHighlightText(
          text: 'ab',
          hits: [KeywordHit(ruleId:'k', keyword:'a', type: MatchType.contains, priority:1, highlightPositions:[0])],
        ),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText));
    // Find the span whose text is 'a' — it should have a non-null backgroundColor.
    final spans = ((rich.text as TextSpan).children ?? const <InlineSpan>[]) as List<TextSpan>;
    final aSpan = spans.firstWhere((s) => s.text == 'a');
    expect(aSpan.style?.backgroundColor, isNotNull);
    final bSpan = spans.firstWhere((s) => s.text == 'b');
    expect(bSpan.style?.backgroundColor, isNull);
  });

  testWidgets('handles repeated keyword (multiple positions)', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: KeywordHighlightText(
          text: '到这到那',
          hits: [KeywordHit(ruleId:'k', keyword:'到', type: MatchType.contains, priority:1, highlightPositions:[0,2])],
        ),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText));
    final spans = ((rich.text as TextSpan).children ?? const <InlineSpan>[]) as List<TextSpan>;
    // Both '到' chars should be highlighted. Collect all single-char spans that are '到'.
    final daoSpans = spans.where((s) => s.text == '到').toList();
    expect(daoSpans.length, 2);
    expect(daoSpans.every((s) => s.style?.backgroundColor != null), isTrue);
  });

  testWidgets('handles multi-char keyword highlight range', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: KeywordHighlightText(
          text: 'x南京y',
          hits: [KeywordHit(ruleId:'k', keyword:'南京', type: MatchType.contains, priority:1, highlightPositions:[1])],
        ),
      ),
    ));
    final rich = tester.widget<RichText>(find.byType(RichText));
    final spans = ((rich.text as TextSpan).children ?? const <InlineSpan>[]) as List<TextSpan>;
    // The keyword '南京' occupies indices 1 and 2 — both should be highlighted.
    final nj = spans.firstWhere((s) => s.text == '南京' || s.text!.contains('南京'));
    expect(nj.style?.backgroundColor, isNotNull);
  });
}
