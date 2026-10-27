import 'package:flutter/material.dart';

/// Tela de opções adicionais, categorias, orçamentos e configurações.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
      ),
      body: const Center(
        child: Text('Menu e configurações'),
      ),
    );
  }
}
