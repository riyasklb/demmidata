import 'package:flutter_bloc/flutter_bloc.dart';
import 'converter_event.dart';
import 'converter_state.dart';
import '../../services/api_service.dart';

class ConverterBloc extends Bloc<ConverterEvent, ConverterState> {
  ConverterBloc() : super(ConverterInitial()) {
    on<ConvertCurrencyRequested>(_onConvertCurrencyRequested);
    on<GetCurrentRateRequested>(_onGetCurrentRateRequested);
    on<InitializeCurrencies>(_onInitializeCurrencies);
    on<FromCurrencyChanged>(_onFromCurrencyChanged);
    on<ToCurrencyChanged>(_onToCurrencyChanged);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<AmountChanged>(_onAmountChanged);
    on<QuickAmountSelected>(_onQuickAmountSelected);
  }

  Future<void> _onConvertCurrencyRequested(
    ConvertCurrencyRequested event,
    Emitter<ConverterState> emit,
  ) async {
    emit(ConverterLoading());
    try {
      final result = await ApiService.convertCurrency(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        amount: event.amount,
      );
      emit(ConverterConversionSuccess(result));
    } catch (e) {
      emit(ConverterError(e.toString()));
    }
  }

  Future<void> _onGetCurrentRateRequested(
    GetCurrentRateRequested event,
    Emitter<ConverterState> emit,
  ) async {
    emit(ConverterLoading());
    try {
      final rate = await ApiService.getCurrentRate(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
      );
      
      emit(ConverterRateSuccess(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        rate: rate,
        isCached: ApiService.isRateCached(event.fromCurrency, event.toCurrency),
        timestamp: ApiService.getCacheTimestamp(event.fromCurrency, event.toCurrency),
      ));
    } catch (e) {
      emit(ConverterError(e.toString()));
    }
  }

  void _onInitializeCurrencies(
    InitializeCurrencies event,
    Emitter<ConverterState> emit,
  ) {
    emit(CurrencySelectorLoaded(
      currencies: event.currencies,
      fromCurrency: 'USD',
      toCurrency: 'INR',
    ));
  }

  void _onFromCurrencyChanged(
    FromCurrencyChanged event,
    Emitter<ConverterState> emit,
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
    Emitter<ConverterState> emit,
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
    Emitter<ConverterState> emit,
  ) {
    if (state is CurrencySelectorLoaded) {
      final currentState = state as CurrencySelectorLoaded;
      emit(currentState.copyWith(
        fromCurrency: currentState.toCurrency,
        toCurrency: currentState.fromCurrency,
      ));
    }
  }

  void _onAmountChanged(
    AmountChanged event,
    Emitter<ConverterState> emit,
  ) {
    if (state is AmountInputLoaded) {
      final currentState = state as AmountInputLoaded;
      emit(currentState.copyWith(
        amount: event.amount,
        validationError: null,
      ));
    } else {
      emit(AmountInputLoaded(amount: event.amount));
    }
  }

  void _onQuickAmountSelected(
    QuickAmountSelected event,
    Emitter<ConverterState> emit,
  ) {
    emit(AmountInputLoaded(
      amount: event.amount.toString(),
      validationError: null,
    ));
  }

  String _findAlternateCurrency(String currentCurrency, Map<String, String> currencies) {
    final currencyList = currencies.keys.toList();
    if (currencyList.length < 2) return currentCurrency;
    
    final currentIndex = currencyList.indexOf(currentCurrency);
    return currencyList[(currentIndex + 1) % currencyList.length];
  }
}
