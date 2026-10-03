// Basic smoke test for Ustad Ji app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ustad_ji_app/main.dart';

void main() {
  testWidgets('App renders customer screen with title', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const UstadJiApp());

    // Verify the app title appears.
    expect(find.text('Ustad Ji'), findsWidgets);

    // Verify the main CTA button exists.
    expect(find.text('Find Ustad'), findsOneWidget);
  });
}