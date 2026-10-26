import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  final preco = Money.fromReais(150, 50);
  final desconto = Money.fromReais(20);
  final total = preco - desconto;

  print('Preço original: $preco');
  print('Desconto: $desconto');
  print('Total a pagar: $total');

  const Result<Money, Failure> resultado = Result.success(
    Money.fromCents(5000),
  );
  resultado.when(
    onSuccess: (valor) => print('Sucesso: $valor'),
    onFailure: (erro) => print('Falha: ${erro.message}'),
  );
}
