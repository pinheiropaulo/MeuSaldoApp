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

## Backend remoto — adotado

### `supabase_flutter`

- Uso: autenticação, banco PostgreSQL remoto (RLS) e sincronização de dados do usuário.
- Camada: `apps/meusaldo`; jamais no `meusaldo_core`.
- Situação: instalado e integrado com repositórios remotos para autenticação, contas, categorias, transações e cartões de crédito.
- Dados financeiros: valores persistidos em centavos inteiros (`BIGINT`); regras de cálculo continuam no Core.

## Persistência local & Testes

### `shared_preferences`

- Uso: preferências simples, como tema, cor de destaque e primeira abertura.
- Camada: `apps/meusaldo`.
- Não usar para dados financeiros, tokens ou segredos.

### Repositórios em Memória (`InMemory*Repository`)

- Uso: dublês de teste (test fakes) para execução instantânea da suíte de testes de UI e widget sem dependência de rede externa ou credenciais remotas.
- Camada: `apps/meusaldo/lib/features/*/data/`.

### `drift`, `drift_flutter`, `drift_dev` e `build_runner` (Descontinuados e Removidos)

- Situação: removidos do projeto. O MeuSaldo opera com o Supabase como fonte única da verdade para dados em nuvem, eliminando a sobrecarga de um banco SQLite secundário redundante.

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

### `flutter_launcher_icons`

- Uso: gera os ícones Android e Web a partir da logo oficial em `assets/images/logo_meusaldo.png`.
- Camada: ferramenta de desenvolvimento do app (`dev_dependency`); não integra o Core nem é usada em tempo de execução.
- Configuração: `apps/meusaldo/flutter_launcher_icons.yaml`.
- Execução: `dart run flutter_launcher_icons` dentro de `apps/meusaldo` após alterar a imagem-fonte.

## Decisões atuais de não adoção

- Sem `get_it`: Riverpod cobre a injeção de dependências inicialmente.
- Sem Hive: se Drift for adotado, não manter dois bancos locais sem necessidade.
- Sem bibliotecas de dinheiro: `Money` próprio, baseado em centavos inteiros, é suficiente para o domínio inicial.
- Sem backend, notificações ou geolocalização física antes das respectivas features.
