import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _controller = TextEditingController();
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  String _sourceCurrency = 'USD'; // Default source currency
  String _targetCurrency = 'EUR'; // Default target currency
  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'CAD',
    'NPR'
  ]; // List of currencies

  Future<void> _convertCurrency() async {
    const apiKey = "e6b5b276ed-3827e4842c-sf0khn";
    final amount = double.tryParse(_controller.text);
    if (amount == null) {
      _showSnackBar('Please enter a valid amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.exchangerate-api.com/v4/latest/$_sourceCurrency?apikey=$apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_targetCurrency];
        setState(() {
          _convertedAmount = amount * rate;
        });
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } on SocketException {
      _showSnackBar('No internet connection');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Currency Converter'),
        centerTitle: true,
      
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _convertedAmount.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 252, 250, 250),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                  color: Color.fromARGB(255, 9, 8, 8),
                ),
                decoration: InputDecoration(
                  hintText: 'Please enter amount',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 2.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sourceCurrency,
                    items: _currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _sourceCurrency = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _targetCurrency,
                    items: _currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _targetCurrency = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _convertCurrency,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.black),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Convert'),
            ),
          ],
        ),
      ),
    );
  }
}