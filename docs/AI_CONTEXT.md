# Contexto para agentes de IA

## Produto

MeuSaldo é um aplicativo Android de finanças pessoais para brasileiros. A interface deve transmitir controle calmo e leitura rápida de saldo, receitas, despesas, faturas e compromissos.

Idioma da interface: `pt-BR`. Moeda: `R$`, com vírgula decimal. Datas: padrão brasileiro.

## Estado atual

- O monorepo contém o app Flutter em `apps/meusaldo` e o pacote Dart puro `packages/meusaldo_core`.
- A dependência local `meusaldo_core` já está ligada ao `pubspec.yaml` do app.
- Ambos ainda usam os templates criados pelas ferramentas. Não presuma que login, armazenamento, backend ou regras financeiras já existam.
- O primeiro alvo é Android. Não introduza código específico de iOS, web ou desktop sem pedido explícito.

## Antes de alterar algo

1. Leia `docs/ARCHITECTURE.md` e o documento específico da tarefa.
2. Inspecione os arquivos existentes e preserve mudanças não relacionadas.
3. Defina a menor entrega verificável; não implemente módulos futuros por antecipação.
4. Ao concluir, execute os comandos de análise/teste aplicáveis e informe o resultado.

## Regras não negociáveis

- Regras financeiras ficam no `meusaldo_core`, em Dart puro e testável.
- Widgets, estado de tela, `BuildContext`, plugins e chamadas Android não entram no Core.
- Nunca use `double` para dinheiro. Valores monetários devem usar centavos inteiros ou um value object `Money`.
- Transferências devem preservar o total consolidado: débito e crédito são uma única operação de domínio.
- Não misture cores de marca com semântica: receita, despesa, alerta e transferência mantêm suas cores funcionais.
- Não adicione pacotes, persistência, backend, autenticação ou gerenciamento de estado sem justificar a necessidade na mudança.
- Consulte `docs/dependencias.md` antes de propor ou adicionar uma dependência.

## Ordem de implementação

1. Core: `Money`, resultados/erros, conta financeira, lançamento, transferência e testes.
2. App: tema Dark Burgundy, navegação e componentes compartilhados.
3. Fluxo MVP: autenticação → início → contas → lançamentos → criar/editar/excluir lançamento.
4. Cartões e faturas; depois recorrências, agenda, orçamento, relatórios e configurações.

## Referências

- `docs/ARCHITECTURE.md`: limites das camadas e invariantes.
- `docs/DESIGN_SYSTEM.md`: tokens e comportamento visual.
- `docs/dependencias.md`: dependências aprovadas, planejadas e decisões de não adoção.
- `docs/DEVELOPMENT.md`: comandos de desenvolvimento e critérios de entrega.
