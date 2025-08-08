import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class CurrencySelectorEvent extends Equatable {
  const CurrencySelectorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCurrencies extends CurrencySelectorEvent {
  final Map<String, String> currencies;

  const InitializeCurrencies(this.currencies);

  @override
  List<Object?> get props => [currencies];
}

class FromCurrencyChanged extends CurrencySelectorEvent {
  final String currency;

  const FromCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class ToCurrencyChanged extends CurrencySelectorEvent {
  final String currency;

  const ToCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SwapCurrencies extends CurrencySelectorEvent {}

// States
abstract class CurrencySelectorState extends Equatable {
  const CurrencySelectorState();

  @override
  List<Object?> get props => [];
}

class CurrencySelectorInitial extends CurrencySelectorState {}

class CurrencySelectorLoaded extends CurrencySelectorState {
  final Map<String, String> currencies;
  final String fromCurrency;
  final String toCurrency;

  const CurrencySelectorLoaded({
    required this.currencies,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [currencies, fromCurrency, toCurrency];

  CurrencySelectorLoaded copyWith({
    Map<String, String>? currencies,
    String? fromCurrency,
    String? toCurrency,
  }) {
    return CurrencySelectorLoaded(
      currencies: currencies ?? this.currencies,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
    );
  }
}

// BLoC
class CurrencySelectorBloc extends Bloc<CurrencySelectorEvent, CurrencySelectorState> {
  CurrencySelectorBloc() : super(CurrencySelectorInitial()) {
    on<InitializeCurrencies>(_onInitializeCurrencies);
    on<FromCurrencyChanged>(_onFromCurrencyChanged);
    on<ToCurrencyChanged>(_onToCurrencyChanged);
    on<SwapCurrencies>(_onSwapCurrencies);
  }

  void _onInitializeCurrencies(
    InitializeCurrencies event,
    Emitter<CurrencySelectorState> emit,
  ) {
    emit(CurrencySelectorLoaded(
      currencies: event.currencies,
      fromCurrency: 'USD',
      toCurrency: 'INR',
    ));
  }

  void _onFromCurrencyChanged(
    FromCurrencyChanged event,
    Emitter<CurrencySelectorState> emit,
  ) {
    if (state is CurrencySelectorLoaded) {
      final currentState = state as CurrencySelectorLoaded;
      String newToCurrency = currentState.toCurrency;
      
      // If the new from currency is the same as the to currency, find an alternate
      if (event.currency == currentState.toCurrency) {
        newToCurrency = _findAlternateCurrency(event.currency, currentState.currencies);
      }

      emit(currentState.copyWith(
        fromCurrency: event.currency,
        toCurrency: newToCurrency,
      ));
    }
  }

  void _onToCurrencyChanged(
    ToCurrencyChanged event,
    Emitter<CurrencySelectorState> emit,
  ) {
    if (state is CurrencySelectorLoaded) {
      final currentState = state as CurrencySelectorLoaded;
      String newFromCurrency = currentState.fromCurrency;
      
      // If the new to currency is the same as the from currency, find an alternate
      if (event.currency == currentState.fromCurrency) {
        newFromCurrency = _findAlternateCurrency(event.currency, currentState.currencies);
      }

      emit(currentState.copyWith(
        fromCurrency: newFromCurrency,
        toCurrency: event.currency,
      ));
    }
  }

  void _onSwapCurrencies(
    SwapCurrencies event,
    Emitter<CurrencySelectorState> emit,
  ) {
    if (state is CurrencySelectorLoaded) {
      final currentState = state as CurrencySelectorLoaded;
      emit(currentState.copyWith(
        fromCurrency: currentState.toCurrency,
        toCurrency: currentState.fromCurrency,
      ));
    }
  }

  String _findAlternateCurrency(String currentCurrency, Map<String, String> currencies) {
    final currencyList = currencies.keys.toList();
    if (currencyList.length < 2) return currentCurrency;
    
    final currentIndex = currencyList.indexOf(currentCurrency);
    return currencyList[(currentIndex + 1) % currencyList.length];
  }
}
