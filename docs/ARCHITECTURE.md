# Arquitetura

## Visão geral

O monorepo separa o domínio financeiro do aplicativo Flutter.

```text
apps/meusaldo                 Flutter, Android, navegação, UI e infraestrutura
packages/meusaldo_core        Entidades, value objects, casos de uso e contratos
```

## `meusaldo_core`

O Core deve ser uma biblioteca Dart independente de Flutter. Ele pode conter:

- entidades: `FinancialAccount`, `Transaction`, `Category`, `CreditCard`, `Invoice`;
- value objects: `Money`, identificadores e períodos;
- enums e regras de validação;
- casos de uso e interfaces de repositório;
- testes unitários de regras financeiras.

Ele não pode importar `package:flutter`, plugins, `BuildContext`, widgets, banco de dados, HTTP ou código Android.

## App Flutter

O app é organizado por funcionalidade. Cada feature pode ter apresentação, adaptadores de dados e integração com o Core.

```text
lib/
  app/                         # inicialização, rotas e tema
  features/
    accounts/
    transactions/
    cards/
  shared/                      # widgets e adaptadores reutilizáveis do app
```

Implementações de repositório vivem no app, não no Core. O Core declara contratos; o app decide se os dados vêm de memória, banco local ou API.

## Invariantes financeiros iniciais

- `Money` usa centavos inteiros; operações não podem introduzir erro de arredondamento.
- Receita aumenta saldo disponível; despesa reduz saldo disponível.
- Uma transferência registra origem e destino de forma atômica e não muda o saldo consolidado.
- Uma categoria deve ser compatível com o tipo de lançamento.
- Editar ou excluir um lançamento deve recalcular os agregados afetados.
- Lançamentos de cartão alteram a fatura correspondente; o pagamento altera a situação da fatura, não cria uma receita.

## Testes

Toda nova regra no Core precisa de teste unitário. O app testa widgets, navegação e adaptadores separadamente. Não esconda regra de negócio em widget tests.
