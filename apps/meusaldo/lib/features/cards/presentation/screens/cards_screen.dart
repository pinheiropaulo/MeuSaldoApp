import 'package:flutter/material.dart';

/// Tela de cartões de crédito e gestão de faturas.
class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões & Faturas'),
      ),
      body: const Center(
        child: Text('Cartões de crédito'),
      ),
    );
  }
}
