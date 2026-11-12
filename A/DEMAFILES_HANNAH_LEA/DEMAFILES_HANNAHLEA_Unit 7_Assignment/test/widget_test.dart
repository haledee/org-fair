import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:org_fair/main.dart';
import 'package:org_fair/config.dart';
import 'package:org_fair/data/event_repository.dart';
import 'package:org_fair/data/orgs.dart';

void main() {
  testWidgets('OrgFairApp loads successfully smoke test', (WidgetTester tester) async {
    // Build our app with the required repository and events parameters.
    await tester.pumpWidget(
      OrgFairApp(
        repository: OrgRepository(),
        events: EventRepository(createEventSource(http.Client())),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}