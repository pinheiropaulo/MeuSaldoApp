# Organização do projeto

## Estrutura do monorepo

```text
MeuSaldoApp/
├── apps/
│   └── meusaldo/                    # Aplicativo Flutter para Android
│       └── lib/
│           ├── app/                 # Bootstrap, rotas, tema e configuração
│           ├── features/            # Funcionalidades do produto
│           └── shared/              # UI e infraestrutura reutilizáveis do app
├── packages/
│   └── meusaldo_core/               # Domínio financeiro em Dart puro
└── docs/                             # Documentação e decisões técnicas
```

## Responsabilidades

### `apps/meusaldo`

Contém apenas preocupações do aplicativo: Flutter, widgets, navegação, gerenciamento de estado, adaptadores de persistência/API e integrações Android.

### `packages/meusaldo_core`

Contém regras de negócio puras e testáveis: entidades, value objects, validações, casos de uso e contratos de repositório. Não pode importar Flutter, plugins, banco de dados, HTTP ou Android.

## Organização do aplicativo

```text
apps/meusaldo/lib/
├── app/
│   ├── app.dart
│   ├── routing/
│   └── theme/
├── features/
│   └── transactions/
│       ├── data/                    # Implementações e DTOs da feature
│       ├── presentation/
│       │   ├── screens/
│       │   ├── state/
│       │   └── widgets/
│       └── transactions.dart        # API pública opcional da feature
└── shared/
    ├── widgets/                     # Componentes visuais reutilizáveis
    └── infrastructure/              # Serviços usados por mais de uma feature
```

Use `features/` para funcionalidades do produto, como `auth`, `accounts`, `transactions`, `cards`, `categories`, `budgets` e `settings`. Um widget específico de uma feature deve ficar dentro dela; só mova algo para `shared/` quando for reutilizado por mais de uma feature.

## Organização do Core

```text
packages/meusaldo_core/lib/
├── meusaldo_core.dart               # Exportações públicas
└── src/
    ├── shared/                      # Money, Result, erros e tipos comuns
    ├── accounts/
    ├── transactions/
    ├── cards/
    ├── categories/
    ├── budgets/
    └── recurring/
```

Os testes do domínio ficam em `packages/meusaldo_core/test/`, acompanhando as áreas de `src/`.

## Regra contra telas monolíticas

O arquivo `*_screen.dart` é o orquestrador da página, não o local onde todos os elementos visuais são implementados. Ele deve conter somente `Scaffold`, estrutura de rolagem, callbacks de navegação e a sequência das seções da tela.

- Meta: até **150 linhas** por arquivo de tela. Ao se aproximar desse limite, extrair a maior seção visual antes de continuar.
- Seções visuais vão para arquivos próprios em `presentation/widgets/`, por exemplo `balance_summary_section.dart` ou `transaction_filter_sheet.dart`.
- Widgets pequenos e exclusivos podem permanecer junto à seção que os usa; não crie abstrações artificiais para componentes usados uma única vez.
- Estado, validação e chamadas de casos de uso não devem ser implementados dentro de widgets puramente visuais.

Exemplo de uma tela organizada:

```text
presentation/
├── screens/
│   └── home_screen.dart
├── state/
│   └── home_controller.dart
└── widgets/
    ├── balance_summary_section.dart
    ├── quick_actions_section.dart
    └── upcoming_bills_section.dart
```

## Convenções de nomes

- Arquivos e diretórios: `snake_case`.
- Telas: `*_screen.dart`.
- Componentes visuais: nomes orientados ao papel, como `account_balance_card.dart`.
- Controladores/notifiers: nomes da feature mais o papel, como `transactions_controller.dart`.
- Não use `utils.dart`, `helpers.dart` ou `common.dart` como destino genérico de código sem responsabilidade clara.

## Antes de criar ou mover arquivos

1. Identifique a feature e a camada responsável.
2. Verifique se a regra pertence ao Core ou ao app Flutter.
3. Reutilize componentes existentes quando o comportamento e o visual forem equivalentes.
4. Atualize os testes do Core se uma regra financeira for criada ou alterada.
