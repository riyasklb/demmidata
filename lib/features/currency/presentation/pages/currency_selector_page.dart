import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/currency_selector_bloc.dart';
import '../../../../screens/converter/amount_input_screen.dart';

class CurrencySelectorPage extends StatefulWidget {
  const CurrencySelectorPage({super.key});

  @override
  State<CurrencySelectorPage> createState() => _CurrencySelectorPageState();
}

class _CurrencySelectorPageState extends State<CurrencySelectorPage> {
  @override
  void initState() {
    super.initState();
    context.read<CurrencySelectorBloc>().add(InitializeCurrencies(sl.availableCurrencies));
  }

  void _swapCurrencies() {
    context.read<CurrencySelectorBloc>().add(SwapCurrencies());
  }

  void _proceedToAmount() {
    final state = context.read<CurrencySelectorBloc>().state;
    if (state is CurrencySelectorLoaded) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AmountInputScreen(
            fromCurrency: state.fromCurrency,
            toCurrency: state.toCurrency,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencySelectorBloc, CurrencySelectorState>(
      builder: (context, state) {
        if (state is! CurrencySelectorLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Currencies'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Header
                const Text(
                  'Currency Converter',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select currencies to convert',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Currency Selection Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // From Currency
                        _buildCurrencyDropdown(
                          label: 'From Currency',
                          value: state.fromCurrency,
                          currencies: state.currencies,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<CurrencySelectorBloc>().add(FromCurrencyChanged(value));
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        // Swap Button
                        _buildSwapButton(),
                        const SizedBox(height: 24),

                        // To Currency
                        _buildCurrencyDropdown(
                          label: 'To Currency',
                          value: state.toCurrency,
                          currencies: state.currencies,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<CurrencySelectorBloc>().add(ToCurrencyChanged(value));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0, top: 24),
                  child: ElevatedButton(
                    onPressed: _proceedToAmount,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: GestureDetector(
        onTap: _swapCurrencies,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.swap_vert,
            color: Colors.blue,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required String? value,
    required Map<String, String> currencies,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, size: 28),
            items: currencies.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Currency Code Badge
                      Container(
                        width: 48,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Currency Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
