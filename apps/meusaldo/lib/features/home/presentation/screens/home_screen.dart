import 'package:flutter/material.dart';

/// Tela inicial (Dashboard / Resumo do mês).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MeuSaldo'),
      ),
      body: const Center(
        child: Text('Início'),
      ),
    );
  }
}
