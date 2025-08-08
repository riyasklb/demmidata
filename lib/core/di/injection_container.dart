import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/currency/data/repositories/currency_repository_impl.dart';
import '../../features/currency/domain/repositories/currency_repository.dart';
import '../../features/currency/domain/usecases/convert_currency_usecase.dart';
import '../../features/currency/domain/usecases/get_current_rate_usecase.dart';
import '../../features/currency/presentation/bloc/currency_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Repositories
  late final AuthRepository authRepository = AuthRepositoryImpl();
  late final CurrencyRepository currencyRepository = CurrencyRepositoryImpl();

  // Use Cases
  late final SignInUseCase signInUseCase = SignInUseCase(authRepository);
  late final SignOutUseCase signOutUseCase = SignOutUseCase(authRepository);
  late final ResetPasswordUseCase resetPasswordUseCase = ResetPasswordUseCase(authRepository);
  
  late final ConvertCurrencyUseCase convertCurrencyUseCase = ConvertCurrencyUseCase(currencyRepository);
  late final GetCurrentRateUseCase getCurrentRateUseCase = GetCurrentRateUseCase(currencyRepository);

  // BLoCs
  late final AuthBloc authBloc = AuthBloc(
    signInUseCase: signInUseCase,
    signOutUseCase: signOutUseCase,
    resetPasswordUseCase: resetPasswordUseCase,
  );

  late final CurrencyBloc currencyBloc = CurrencyBloc(
    convertCurrencyUseCase: convertCurrencyUseCase,
    getCurrentRateUseCase: getCurrentRateUseCase,
  );

  // Getter for available currencies
  Map<String, String> get availableCurrencies => currencyRepository.availableCurrencies;

  // Getter for auth state changes stream
  Stream get authStateChanges => authRepository.authStateChanges;

  // Getter for current user
  get currentUser => authRepository.currentUser;

  void dispose() {
    authBloc.close();
    currencyBloc.close();
  }
}

// Global instance
final sl = InjectionContainer();
