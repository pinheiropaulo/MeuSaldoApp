# Dependências

Este documento é o catálogo de dependências do MeuSaldo. Antes de adicionar um pacote, confirme se ele aparece aqui, em qual fase será usado e qual problema resolve. Não adicione dependências por conveniência ou por preferência pessoal.

## Política

- Adicione um pacote somente na fase em que a funcionalidade correspondente for implementada.
- Registre a justificativa, a camada de uso e a alternativa avaliada antes de alterar um `pubspec.yaml`.
- O `meusaldo_core` permanece Dart puro: não recebe Flutter, plugins, armazenamento, HTTP ou bibliotecas de UI.
- Prefira APIs do SDK Dart/Flutter quando forem suficientes.
- Após adicionar um pacote, rode análise e testes do projeto afetado.

## Fundação adotada

### `go_router`

- Uso: rotas, redirecionamentos de autenticação, navegação entre features e barra inferior.
- Camada: `apps/meusaldo`.
- Situação: instalado e em uso na navegação declarativa do app.

### `flutter_riverpod`

- Uso: estado das features, injeção de dependências e dados assíncronos.
- Camada: `apps/meusaldo`; o Core não depende dele.
- Situação: instalado e em uso nos providers e estado das features.

### `intl`

- Uso: formatos de moeda, números, datas e meses.
- Camada: `apps/meusaldo` e, quando necessário, adaptadores de apresentação; regras monetárias continuam no Core usando centavos inteiros.
- Situação: instalado e em uso para formatos de apresentação.

### `flutter_localizations`

- Uso: delegados de localização do Flutter e locale da aplicação.
- Camada: `apps/meusaldo`.
- Situação: instalado; o MVP suporta somente `pt_BR`.

### `google_fonts`

- Uso: Roboto e JetBrains Mono previstos no design system.
- Camada: `apps/meusaldo`.
- Situação: instalado e usado no tema. Antes de publicar, avaliar fontes empacotadas como assets para evitar dependência de rede em tempo de execução.

## Localização inicial

O MVP é exclusivamente em português brasileiro (`pt_BR`). Não existe seletor de idioma no escopo inicial.

Localização significa idioma e formatos regionais, não geolocalização física. Ela será usada para:

- moeda no formato `R$ 1.234,56`;
- datas, meses e dias da semana em português;
- textos com plural, como `1 lançamento` e `2 lançamentos`;
- utilização do locale do Android, mantendo `pt_BR` como locale suportado.

`intl` formata dados para exibição. Ele não substitui o value object `Money`: valores financeiros continuam armazenados e calculados em centavos inteiros.

## Persistência local — adotada, com papel pendente

### `drift`, `drift_flutter`, `drift_dev` e `build_runner`

- Uso: banco SQLite tipado, migrations, consultas relacionais e geração de código.
- Camada: implementações de repositório em `apps/meusaldo`.
- Situação: instalados. O projeto possui `AppDatabase`, tabelas, conversores e mapeadores.
- Decisão pendente: definir se Drift será cache/offline após a adoção do Supabase. Não criar uma segunda fonte de verdade sem sincronização definida.

### `shared_preferences`

- Uso: preferências simples, como tema, cor de destaque e primeira abertura.
- Camada: `apps/meusaldo`.
- Não usar para dados financeiros, tokens ou segredos.

## Backend remoto — planejado

### `supabase_flutter`

- Uso: autenticação, banco PostgreSQL remoto e sincronização de dados do usuário.
- Camada: `apps/meusaldo`; jamais no `meusaldo_core`.
- Entrada: somente após a modelagem das tabelas, RLS e estratégia de falhas/offline estarem documentadas e autorizadas.
- Dados financeiros: valores persistidos em centavos inteiros; regras de cálculo continuam no Core.

## Segurança e alertas — futuros

### `flutter_secure_storage`

- Uso: token de sessão ou informações sensíveis de autenticação.
- Entrada: somente quando autenticação real for implementada.

### `flutter_local_notifications` e `timezone`

- Uso: lembretes de vencimentos, faturas e lançamentos recorrentes.
- Entrada: na feature de agenda/contas a vencer, com a UX de permissão Android definida.

## Comunicação remota — futura

### `dio`

- Uso: cliente HTTP, interceptadores e integração com API.
- Entrada: somente após existir uma decisão de backend e contrato de API.

### `freezed`, `json_serializable` e `build_runner`

- Uso: DTOs e serialização quando o volume de contratos de API justificar geração de código.
- Entrada: junto à integração de backend, não antes.

## Testes

- `test`: já usado pelo `meusaldo_core` para regras de domínio.
- `mocktail`: pode entrar para testes de adaptadores e repositórios do app.
- `integration_test`: SDK Flutter; será usado nos primeiros fluxos Android completos.

## Código gerado

- Arquivos `*.g.dart` do Drift são gerados por `build_runner`. Eles não devem ser editados manualmente.
- Mantenha-os versionados quando forem necessários para compilar o projeto; exclua-os apenas da análise estática se os lints do projeto gerarem ruído.
- Não confunda a exclusão do analyzer com `.gitignore`: excluir da análise não remove o arquivo do Git nem impede a compilação.

## Decisões atuais de não adoção

- Sem `get_it`: Riverpod cobre a injeção de dependências inicialmente.
- Sem Hive: se Drift for adotado, não manter dois bancos locais sem necessidade.
- Sem bibliotecas de dinheiro: `Money` próprio, baseado em centavos inteiros, é suficiente para o domínio inicial.
- Sem backend, notificações ou geolocalização física antes das respectivas features.
