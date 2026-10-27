# Dependências

Este documento é o catálogo de dependências do MeuSaldo. Antes de adicionar um pacote, confirme se ele aparece aqui, em qual fase será usado e qual problema resolve. Não adicione dependências por conveniência ou por preferência pessoal.

## Política

- Adicione um pacote somente na fase em que a funcionalidade correspondente for implementada.
- Registre a justificativa, a camada de uso e a alternativa avaliada antes de alterar um `pubspec.yaml`.
- O `meusaldo_core` permanece Dart puro: não recebe Flutter, plugins, armazenamento, HTTP ou bibliotecas de UI.
- Prefira APIs do SDK Dart/Flutter quando forem suficientes.
- Após adicionar um pacote, rode análise e testes do projeto afetado.

## Fundação aprovada — ainda não instalada

### `go_router`

- Uso: rotas, redirecionamentos de autenticação, navegação entre features e barra inferior.
- Camada: `apps/meusaldo`.
- Entrada: quando a estrutura de navegação e as primeiras telas Flutter forem criadas.

### `flutter_riverpod`

- Uso: estado das features, injeção de dependências e dados assíncronos.
- Camada: `apps/meusaldo`; o Core não depende dele.
- Entrada: junto às primeiras telas que consomem casos de uso do Core.

### `intl`

- Uso: formatos de moeda, números, datas e meses.
- Camada: `apps/meusaldo` e, quando necessário, adaptadores de apresentação; regras monetárias continuam no Core usando centavos inteiros.
- Entrada: na implementação do tema e dos primeiros dados exibidos.

### `flutter_localizations`

- Uso: delegados de localização do Flutter e locale da aplicação.
- Camada: `apps/meusaldo`.
- Entrada: junto com `intl`.

### `google_fonts`

- Uso: Roboto e JetBrains Mono previstos no design system.
- Camada: `apps/meusaldo`.
- Entrada: na implementação do tema. Antes de publicar, avaliar fontes empacotadas como assets para evitar dependência de rede em tempo de execução.

## Localização inicial

O MVP é exclusivamente em português brasileiro (`pt_BR`). Não existe seletor de idioma no escopo inicial.

Localização significa idioma e formatos regionais, não geolocalização física. Ela será usada para:

- moeda no formato `R$ 1.234,56`;
- datas, meses e dias da semana em português;
- textos com plural, como `1 lançamento` e `2 lançamentos`;
- utilização do locale do Android, mantendo `pt_BR` como locale suportado.

`intl` formata dados para exibição. Ele não substitui o value object `Money`: valores financeiros continuam armazenados e calculados em centavos inteiros.

## Persistência local — futura

### `drift`, `drift_flutter`, `drift_dev` e `build_runner`

- Uso: banco SQLite tipado, migrations, consultas relacionais e geração de código.
- Camada: implementações de repositório em `apps/meusaldo`.
- Entrada: depois de `Money`, contas, lançamentos e transferências estarem definidos e testados no Core.

### `shared_preferences`

- Uso: preferências simples, como tema, cor de destaque e primeira abertura.
- Camada: `apps/meusaldo`.
- Não usar para dados financeiros, tokens ou segredos.

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

## Decisões atuais de não adoção

- Sem `get_it`: Riverpod cobre a injeção de dependências inicialmente.
- Sem Hive: se Drift for adotado, não manter dois bancos locais sem necessidade.
- Sem bibliotecas de dinheiro: `Money` próprio, baseado em centavos inteiros, é suficiente para o domínio inicial.
- Sem backend, notificações ou geolocalização física antes das respectivas features.
