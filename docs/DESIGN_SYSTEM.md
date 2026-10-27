# Design system — Dark Burgundy

## Intenção

Interface mobile sóbria e acolhedora para uso frequente. Priorize legibilidade financeira, hierarquia e alvos de toque confortáveis; evite gamificação, gradientes e sombras fortes.

## Tokens principais

| Uso | Token |
| --- | --- |
| Fundo | `#171417` |
| Superfície | `#242025` |
| Superfície elevada | `#2E2830` |
| Borda sutil | `#3D353F` |
| Texto primário | `#F4EEF1` |
| Texto secundário | `#B5A7AD` |
| Marca/CTA | `#6D1834` |
| Destaque de marca | `#FFB1C1` |
| Receita | `#22A06B` |
| Despesa/atraso | `#F04444` |
| Alerta | `#F2C94C` |
| Saldo/transferência | `#4C8DFF` |

## Tipografia e números

- Roboto para textos da interface.
- JetBrains Mono para valores financeiros, com números tabulares.
- Prefixo `R$` com menor ênfase visual; negativos usam o sinal antes da moeda: `- R$ 150,00`.

## Componentes

- Controles interativos: altura mínima de 48px e raio de 8px.
- Cards: raio de 12px e borda de 1px.
- Modais e hero cards: raio de 16px.
- Use borda e diferença de superfície para elevação; não use sombra como principal mecanismo.
- Ações destrutivas exigem confirmação explícita.

## Tema futuro

O usuário poderá escolher cor de destaque. Essa escolha altera apenas tokens de marca, CTA e estado ativo. As cores financeiras semânticas permanecem fixas.
