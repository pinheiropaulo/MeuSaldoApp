# MeuSaldo

Aplicativo Android de controle financeiro pessoal, desenvolvido em Flutter. O produto ajuda a acompanhar contas, cartões, faturas, lançamentos, orçamentos e compromissos financeiros em português do Brasil.

> Status: fundação do monorepo criada. O app e o Core ainda contêm os templates iniciais; as regras financeiras e as telas Flutter serão implementadas gradualmente.

## Arquitetura

O projeto separa interface e regras de negócio:

```text
MeuSaldoApp/
├── apps/
│   └── meusaldo/             # App Flutter focado inicialmente em Android
├── packages/
│   └── meusaldo_core/        # Domínio financeiro em Dart puro
└── docs/                     # Arquitetura, design e guias de desenvolvimento
```

`meusaldo_core` não deve depender de Flutter, Android, banco de dados ou API. O app é responsável por UI, navegação e adaptadores de infraestrutura.

## Pré-requisitos

- Flutter SDK compatível com o projeto
- Android SDK e um dispositivo/emulador Android configurado
- Dart SDK, incluído na instalação do Flutter

## Como executar o app Android

```powershell
cd apps/meusaldo
flutter pub get
flutter run
```

Para verificar qualidade:

```powershell
flutter analyze
flutter test
```

## Como testar o Core

```powershell
cd packages/meusaldo_core
dart pub get
dart analyze
dart test
```

## Documentação

- [Contexto para agentes de IA](docs/AI_CONTEXT.md)
- [Arquitetura](docs/ARCHITECTURE.md)
- [Dependências e localização](docs/dependencias.md)
- [Design system](docs/DESIGN_SYSTEM.md)
- [Guia de desenvolvimento](docs/DEVELOPMENT.md)

Antes de modificar código, leia o contexto de IA e os documentos relevantes à mudança.
