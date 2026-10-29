# MeuSaldo

Aplicativo Android de controle financeiro pessoal, desenvolvido em Flutter. O produto ajuda a acompanhar contas, cartões, faturas, lançamentos, orçamentos e compromissos financeiros em português do Brasil.

> Status: MVP Android em evolução. O Core financeiro, tema, navegação, telas de Início, Contas e Lançamentos, além da base local com Drift, já estão implementados. A próxima decisão técnica é a integração segura com Supabase.

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

`meusaldo_core` não deve depender de Flutter, Android, banco de dados ou API. O app é responsável por UI, navegação e adaptadores de infraestrutura. O Supabase será a fonte remota de dados; Drift permanece uma infraestrutura local cuja função (cache/offline) será definida antes da sincronização.

## Pré-requisitos

- Flutter SDK compatível com o projeto
- Android SDK e um dispositivo/emulador Android configurado
- Dart SDK, incluído na instalação do Flutter

## Como verificar o app Android

```powershell
cd apps/meusaldo
flutter pub get
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
- [Organização do projeto](docs/organizacao-do-projeto.md)
- [Plano de ação](docs/PLANO_DE_ACAO.md)

Antes de modificar código, leia o contexto de IA e os documentos relevantes à mudança.
