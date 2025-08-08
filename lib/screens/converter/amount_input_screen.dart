import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/currency/presentation/bloc/currency_bloc.dart';
import '../../features/currency/presentation/bloc/amount_input_bloc.dart';
import 'result_screen.dart';

class AmountInputScreen extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;

  const AmountInputScreen({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  State<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends State<AmountInputScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }



  void _convertCurrency() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    // Trigger button animation
    await _buttonAnimationController.forward();
    await _buttonAnimationController.reverse();

    context.read<CurrencyBloc>().add(ConvertCurrencyRequested(
      fromCurrency: widget.fromCurrency,
      toCurrency: widget.toCurrency,
      amount: amount,
    ));
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    return _getAmountValidationError(amount);
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CurrencyConversionSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                fromCurrency: state.result.fromCurrency,
                toCurrency: state.result.toCurrency,
                originalAmount: state.result.originalAmount,
                convertedAmount: state.result.convertedAmount,
              ),
            ),
          );
        }
      },
      child: BlocBuilder<AmountInputBloc, AmountInputState>(
        builder: (context, amountState) {
          return BlocBuilder<CurrencyBloc, CurrencyState>(
            builder: (context, currencyState) {
              final isLoading = currencyState is CurrencyLoading;
              final validationError = amountState is AmountInputLoaded ? amountState.validationError : null;
              
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Enter Amount'),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                    
                        // Currency Display
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCurrencyChip(widget.fromCurrency, 'From'),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.blue,
                                size: 24,
                              ),
                              _buildCurrencyChip(widget.toCurrency, 'To'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                    
                        // Amount Input
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          onChanged: (value) {
                            context.read<AmountInputBloc>().add(AmountChanged(value));
                          },
                          validator: _validateInput,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter amount to convert',
                            prefixIcon: const Icon(Icons.attach_money),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                    
                        // Validation Error
                        if (validationError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              validationError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                    
                        const SizedBox(height: 24),
                    
                        // Quick Amount Buttons
                        const Text(
                          'Quick Amounts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 10, 50, 100, 500, 1000].map((amount) {
                            return ElevatedButton(
                              onPressed: () {
                                _amountController.text = amount.toString();
                                context.read<AmountInputBloc>().add(QuickAmountSelected(amount.toDouble()));
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text('\$$amount'),
                            );
                          }).toList(),
                        ),
                    
                        const Spacer(),
                    
                        // Convert Button
                        AnimatedBuilder(
                          animation: _buttonScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScaleAnimation.value,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _convertCurrency,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Convert',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrencyChip(String currencyCode, String label) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue),
          ),
          child: Text(
            currencyCode,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
