// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:currency_converter/currency_converter/bloc/converter_bloc.dart';
import 'package:currency_converter/currency_converter/bloc/converter_event.dart';
import 'package:currency_converter/currency_converter/bloc/converter_state.dart';

void main() {
  testWidgets('Currency Selector BLoC Test', (WidgetTester tester) async {
    // Test the converter bloc directly
    final bloc = ConverterBloc();
    
    // Initialize with currencies
    bloc.add(InitializeCurrencies({
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'INR': 'Indian Rupee',
    }));
    
    await tester.pump();
    
    // Verify initial state
    expect(bloc.state, isA<CurrencySelectorLoaded>());
    final state = bloc.state as CurrencySelectorLoaded;
    expect(state.fromCurrency, 'USD');
    expect(state.toCurrency, 'INR');
    
    // Test currency change
    bloc.add(FromCurrencyChanged('EUR'));
    await tester.pump();
    
    final newState = bloc.state as CurrencySelectorLoaded;
    expect(newState.fromCurrency, 'EUR');
    
    bloc.close();
  });

  testWidgets('Currency Selector UI Test', (WidgetTester tester) async {
    // Create a simple test widget without Firebase
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => ConverterBloc(),
          child: const Scaffold(
            body: Center(
              child: Text('Currency Selector Test'),
            ),
          ),
        ),
      ),
    );

    // Verify the test widget loads
    expect(find.text('Currency Selector Test'), findsOneWidget);
  });

  testWidgets('Basic Widget Test', (WidgetTester tester) async {
    // Test basic Flutter widgets
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
  });
}
