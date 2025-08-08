# Currency Converter App

A modern, animated currency converter mobile app built with Flutter using BLoC architecture and Firebase authentication.

## Features

### 🔐 Authentication
- Firebase-based email/password authentication
- Secure login with validation
- Password reset functionality
- Automatic session management

### 💱 Currency Conversion
- Real-time currency conversion using CurrencyLayer API
- Support for 12 major currencies (USD, INR, EUR, AED, GBP, JPY, CAD, AUD, CHF, CNY, NZD, SGD)
- Interactive currency selection with animated dropdowns
- Quick amount selection buttons
- Amount validation (positive values, max $100,000)

### 🚀 Smart Caching System
- **Fresh Cache**: Rates cached for 5 minutes (green indicator)
- **Stale Cache**: Rates usable for up to 30 minutes (orange/red indicator)
- **Offline Support**: App works with cached data when offline
- **API Fallback**: Graceful degradation when API is unavailable

### 🎨 Smooth Animations & UI/UX
- Fluid screen transitions with slide animations
- Fade-in animations for content
- Interactive button animations
- Modern Material Design 3 UI
- Responsive layout for all screen sizes

### 📊 Real-time Information
- Live exchange rates with timestamps
- Cache status indicators
- Error handling with user-friendly messages
- Loading states with progress indicators

## Architecture

The app follows Clean Architecture principles with BLoC pattern:

```
lib/
├── main.dart
├── core/
│   └── di/
│       └── injection_container.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_usecase.dart
│   │   │       ├── sign_out_usecase.dart
│   │   │       └── reset_password_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           └── login_page.dart
│   └── currency/
│       ├── data/
│       │   ├── models/
│       │   │   └── conversion_result_model.dart
│       │   └── repositories/
│       │       └── currency_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── conversion_result_entity.dart
│       │   │   └── currency_entity.dart
│       │   ├── repositories/
│       │   │   └── currency_repository.dart
│       │   └── usecases/
│       │       ├── convert_currency_usecase.dart
│       │       └── get_current_rate_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── currency_bloc.dart
│           │   ├── currency_event.dart
│           │   ├── currency_state.dart
│           │   ├── currency_selector_bloc.dart
│           │   └── amount_input_bloc.dart
│           └── pages/
│               └── currency_selector_page.dart
└── screens/
    └── converter/
        ├── amount_input_screen.dart
        └── result_screen.dart
```

## Caching Strategy

### Cache Duration
- **Fresh Cache**: 5 minutes (optimal user experience)
- **Stale Cache**: 30 minutes (fallback for offline/API issues)

### Cache Behavior
1. **API Available**: Fetch fresh rates and cache them
2. **API Unavailable + Fresh Cache**: Use cached data (green indicator)
3. **API Unavailable + Stale Cache**: Use cached data with warning (orange/red indicator)
4. **No Cache Available**: Show error message

### Cache Indicators
- 🟢 **Fresh**: Rate is less than 5 minutes old
- 🟠 **Cached**: Rate is between 5-30 minutes old
- 🔴 **Stale Cache**: Rate is older than 5 minutes (shown when API fails)

## API Integration

### CurrencyLayer API
- **Endpoint**: `http://api.currencylayer.com/convert`
- **Access Key**: Included in the app
- **Rate Limits**: Free tier with reasonable limits
- **Response Format**: JSON with success/error handling

### Example API Call
```bash
curl --location --request GET 'http://api.currencylayer.com/convert?access_key=YOUR_KEY&from=USD&to=EUR&amount=25&format=1'
```

### API Response
```json
{
    "success": true,
    "query": {
        "from": "USD",
        "to": "EUR",
        "amount": 25
    },
    "info": {
        "timestamp": 1754673966,
        "quote": 0.85746
    },
    "result": 21.4365
}
```

## Business Logic Functions

### getBestRate(from, to)
This function implements the bonus business logic requirement:

```dart
Future<Map<String, dynamic>?> getBestRate({
  required String fromCurrency,
  required String toCurrency,
}) async
```

**Behavior:**
1. **Tries API first**: Attempts to fetch fresh rate
2. **Falls back to cache**: Uses cached data if under 30 minutes old
3. **Returns null**: If no rate is available
4. **Works offline**: Uses cached data when network is unavailable

**Return Format:**
```dart
{
  'rate': 1.2345,
  'timestamp': DateTime.now(),
  'isCached': true,
  'isStale': false,
}
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
4. Run the app:
   ```bash
   flutter run
   ```

### Dependencies
```yaml
dependencies:
  flutter_bloc: ^9.1.1
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.0
  http: ^1.1.0
  equatable: ^2.0.5
  shared_preferences: ^2.2.2
  lottie: ^3.0.0
  cached_network_image: ^3.3.0
  connectivity_plus: ^5.0.2
```

## Usage Flow

1. **Login**: Enter email and password to authenticate
2. **Select Currencies**: Choose source and target currencies with animated dropdowns
3. **Enter Amount**: Input amount with validation and quick selection buttons
4. **View Results**: See conversion with rate information and cache status
5. **Continue**: Convert another amount or start new conversion

## Error Handling

### Network Errors
- Graceful fallback to cached data
- User-friendly error messages
- Retry mechanisms

### API Errors
- Proper error parsing and display
- Fallback to cached rates when possible
- Clear error state management

### Validation Errors
- Real-time input validation
- Clear error messages
- Prevent invalid conversions

## Performance Features

- **Efficient Caching**: In-memory cache with timestamps
- **Optimized API Calls**: Avoid duplicate requests within cache window
- **Smooth Animations**: Hardware-accelerated animations
- **Responsive UI**: Adapts to different screen sizes

## Testing

The app includes comprehensive testing:
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Demo

The app includes smooth animations and transitions inspired by modern mobile apps:
- Slide transitions between screens
- Fade-in animations for content
- Interactive button animations
- Fluid currency selection experience

## Support

For support or questions, please open an issue in the repository.
