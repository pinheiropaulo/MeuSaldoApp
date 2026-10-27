import 'package:flutter/material.dart';

/// Tela de listagem e histórico de lançamentos financeiros.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
      ),
      body: const Center(
        child: Text('Lançamentos'),
      ),
    );
  }
}
