import 'package:flutter/material.dart';

/// Tela de listagem e gestão de contas financeiras.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
      ),
      body: const Center(
        child: Text('Contas financeiras'),
      ),
    );
  }
}
