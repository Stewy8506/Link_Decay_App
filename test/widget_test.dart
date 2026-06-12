import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:link_decay_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LinkShelfApp()));
    await tester.pump(Duration.zero);
    // Just ensure it builds without errors.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
