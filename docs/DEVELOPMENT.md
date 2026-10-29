# Guia de desenvolvimento

## Comandos

### App Android

```powershell
cd apps/meusaldo
flutter pub get
flutter analyze
flutter test
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

## Drift e `build_runner`

Após alterar uma tabela, conversor ou anotação do Drift, gere novamente os arquivos:

```powershell
cd apps/meusaldo
dart run build_runner build --delete-conflicting-outputs
```

- Nunca edite arquivos `*.g.dart` manualmente.
- `*.g.dart` é código necessário à compilação e deve permanecer versionado quando o projeto depender dele.
- Para ignorar avisos de lint apenas nesses arquivos, adicione `lib/**/*.g.dart` em `analyzer.exclude` de `apps/meusaldo/analysis_options.yaml`. Isso não substitui o versionamento e não impede que o código seja gerado.

## Dependências

Antes de adicionar uma dependência, leia `docs/dependencias.md`, confirme que a funcionalidade não pode ser atendida com Dart/Flutter já existente e documente a justificativa no pull request ou no resumo da alteração. Após a inclusão, rode `flutter pub get` ou `dart pub get`, seguido de análise e testes no projeto afetado.
