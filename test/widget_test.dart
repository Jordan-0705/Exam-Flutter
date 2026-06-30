// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam_flutter/main.dart';

void main() {
  testWidgets('BadWallet app test', (WidgetTester tester) async {
    await tester.pumpWidget(const BadWalletApp());

    expect(find.text('BadWallet'), findsOneWidget);
    expect(find.text('Votre portefeuille numérique'), findsOneWidget);
  });
}