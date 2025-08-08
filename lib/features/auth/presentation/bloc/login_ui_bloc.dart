import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class LoginUIEvent extends Equatable {
  const LoginUIEvent();

  @override
  List<Object?> get props => [];
}

class TogglePasswordVisibility extends LoginUIEvent {}

// States
abstract class LoginUIState extends Equatable {
  const LoginUIState();

  @override
  List<Object?> get props => [];
}

class LoginUIInitial extends LoginUIState {
  final bool obscurePassword;

  const LoginUIInitial({this.obscurePassword = true});

  @override
  List<Object?> get props => [obscurePassword];

  LoginUIInitial copyWith({bool? obscurePassword}) {
    return LoginUIInitial(
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

// BLoC
class LoginUIBloc extends Bloc<LoginUIEvent, LoginUIState> {
  LoginUIBloc() : super(const LoginUIInitial()) {
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginUIState> emit,
  ) {
    if (state is LoginUIInitial) {
      final currentState = state as LoginUIInitial;
      emit(currentState.copyWith(
        obscurePassword: !currentState.obscurePassword,
      ));
    }
  }
}
