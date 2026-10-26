# Guia de desenvolvimento

## Comandos

### App Android

```powershell
cd apps/meusaldo
flutter pub get
flutter analyze
flutter test
flutter run
```

### Core

```powershell
cd packages/meusaldo_core
dart pub get
dart analyze
dart test
```

## Fluxo de mudança

1. Comece pelo Core quando a alteração mudar regra financeira.
2. Escreva ou atualize testes do Core antes de conectar a interface.
3. Implemente o adaptador e a tela no app Flutter.
4. Rode análise e testes no pacote afetado.
5. Não altere arquivos gerados, `.dart_tool/`, `build/` ou arquivos de IDE.

## Dependências

Antes de adicionar uma dependência, leia `docs/dependencias.md`, confirme que a funcionalidade não pode ser atendida com Dart/Flutter já existente e documente a justificativa no pull request ou no resumo da alteração. Após a inclusão, rode `flutter pub get` ou `dart pub get`, seguido de análise e testes no projeto afetado.
