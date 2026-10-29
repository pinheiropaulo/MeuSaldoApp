# Contexto para agentes de IA

## Produto

MeuSaldo é um aplicativo Android de finanças pessoais para brasileiros. A interface deve transmitir controle calmo e leitura rápida de saldo, receitas, despesas, faturas e compromissos.

Idioma da interface: `pt-BR`. Moeda: `R$`, com vírgula decimal. Datas: padrão brasileiro.

## Estado atual

- O monorepo contém o app Flutter em `apps/meusaldo` e o pacote Dart puro `packages/meusaldo_core`; a dependência local já está ligada ao app.
- Core: `Money`, entidades financeiras, contratos de repositório, cálculos de saldo e transferências já existem e possuem testes.
- App: tema Dark Burgundy, navegação, componentes compartilhados e as features de Início, Contas e Lançamentos estão implementados inicialmente com repositórios em memória.
- Drift já possui tabelas, conversores, mapeadores e `AppDatabase`. Ainda não é a fonte conectada aos providers de produção.
- Supabase foi escolhido como futura fonte remota de dados. Não adicionar SDK, autenticação ou tabelas sem uma entrega explicitamente autorizada.
- O primeiro alvo é Android. Web/PWA e iOS são itens futuros, não devem ser introduzidos por antecipação.

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
- Movimentações `completed` alteram o saldo atual; `pending` entram somente no saldo previsto.
- Movimentações podem ser corrigidas ou excluídas mesmo depois de confirmadas; a persistência deve reverter o efeito anterior e aplicar o novo efeito de forma atômica.
- Não misture cores de marca com semântica: receita, despesa, alerta e transferência mantêm suas cores funcionais.
- Não adicione pacotes, persistência, backend, autenticação ou gerenciamento de estado sem justificar a necessidade na mudança.
- Consulte `docs/dependencias.md` antes de propor ou adicionar uma dependência.

## Ordem de implementação

1. Consolidar documentação e regras de saldo atual/previsto.
2. Completar os casos de uso e testes de edição, exclusão e confirmação no Core.
3. Modelar e integrar Supabase, começando por contas, categorias e lançamentos.
4. Definir o Drift como cache/offline ou removê-lo do caminho de produção antes de duplicar repositórios.
5. Cartões e faturas; depois recorrências, agenda, orçamento, relatórios e configurações.

## Referências

- `docs/ARCHITECTURE.md`: limites das camadas e invariantes.
- `docs/DESIGN_SYSTEM.md`: tokens e comportamento visual.
- `docs/dependencias.md`: dependências aprovadas, planejadas e decisões de não adoção.
- `docs/DEVELOPMENT.md`: comandos de desenvolvimento e critérios de entrega.
