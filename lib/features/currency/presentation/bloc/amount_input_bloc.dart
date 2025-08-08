import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AmountInputEvent extends Equatable {
  const AmountInputEvent();

  @override
  List<Object?> get props => [];
}

class AmountChanged extends AmountInputEvent {
  final String amount;

  const AmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

class QuickAmountSelected extends AmountInputEvent {
  final double amount;

  const QuickAmountSelected(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ValidateAmount extends AmountInputEvent {}

class ClearValidationError extends AmountInputEvent {}

// States
abstract class AmountInputState extends Equatable {
  const AmountInputState();

  @override
  List<Object?> get props => [];
}

class AmountInputInitial extends AmountInputState {}

class AmountInputLoaded extends AmountInputState {
  final String amount;
  final String? validationError;

  const AmountInputLoaded({
    required this.amount,
    this.validationError,
  });

  @override
  List<Object?> get props => [amount, validationError];

  AmountInputLoaded copyWith({
    String? amount,
    String? validationError,
  }) {
    return AmountInputLoaded(
      amount: amount ?? this.amount,
      validationError: validationError ?? this.validationError,
    );
  }
}

// BLoC
class AmountInputBloc extends Bloc<AmountInputEvent, AmountInputState> {
  AmountInputBloc() : super(AmountInputInitial()) {
    on<AmountChanged>(_onAmountChanged);
    on<QuickAmountSelected>(_onQuickAmountSelected);
    on<ValidateAmount>(_onValidateAmount);
    on<ClearValidationError>(_onClearValidationError);
  }

  void _onAmountChanged(
    AmountChanged event,
    Emitter<AmountInputState> emit,
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
    Emitter<AmountInputState> emit,
  ) {
    emit(AmountInputLoaded(
      amount: event.amount.toString(),
      validationError: null,
    ));
  }

  void _onValidateAmount(
    ValidateAmount event,
    Emitter<AmountInputState> emit,
  ) {
    if (state is AmountInputLoaded) {
      final currentState = state as AmountInputLoaded;
      final amount = double.tryParse(currentState.amount);
      
      if (amount == null) {
        emit(currentState.copyWith(
          validationError: 'Please enter a valid amount',
        ));
        return;
      }

      final error = _getAmountValidationError(amount);
      emit(currentState.copyWith(validationError: error));
    }
  }

  void _onClearValidationError(
    ClearValidationError event,
    Emitter<AmountInputState> emit,
  ) {
    if (state is AmountInputLoaded) {
      final currentState = state as AmountInputLoaded;
      emit(currentState.copyWith(validationError: null));
    }
  }

  String? _getAmountValidationError(double amount) {
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 100000) {
      return 'Amount cannot exceed 100,000';
    }
    return null;
  }
}
