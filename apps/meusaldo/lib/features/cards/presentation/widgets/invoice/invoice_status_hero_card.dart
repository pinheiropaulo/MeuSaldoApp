import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card hero dinâmico exibindo o status da fatura (aberta, fechada ou paga),
/// valores consolidados e progresso do limite de crédito.
class InvoiceStatusHeroCard extends StatelessWidget {
  final Invoice invoice;
  final CreditCard card;
  final VoidCallback onPayPressed;
  final VoidCallback onViewInstallmentsPressed;

  const InvoiceStatusHeroCard({
    super.key,
    required this.invoice,
    required this.card,
    required this.onPayPressed,
    required this.onViewInstallmentsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM yyyy", "pt_BR");
    final dueFormat = DateFormat("dd 'de' MMMM", "pt_BR");

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Status Badge + Data de Fechamento/Pagamento
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(),
              Text(
                invoice.isPaid
                    ? 'Pago em ${invoice.paidDate != null ? dateFormat.format(invoice.paidDate!) : dateFormat.format(invoice.dueDate)}'
                    : 'Fecha em ${dateFormat.format(invoice.closingDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bloco do Valor
          if (invoice.isPaid) ...[
            _buildPaidAmountSection(),
          ] else ...[
            _buildOpenAmountSection(dueFormat),
          ],

          const SizedBox(height: 14),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 12),

          // Barra de Consumo do Limite
          _buildLimitProgressBar(),

          const SizedBox(height: 16),

          // Ações do Hero: Registrar Pagamento / Ver Parceladas
          Row(
            children: [
              if (!invoice.isPaid)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      key: const Key('invoice_hero_pay_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.primaryHighlight,
                      ),
                      label: const Text(
                        'Registrar Pagamento',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: onPayPressed,
                    ),
                  ),
                ),
              if (!invoice.isPaid) const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    key: const Key('invoice_hero_installments_button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surfaceElevated,
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.view_timeline_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    label: const Text(
                      'Ver Parceladas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: onViewInstallmentsPressed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (invoice.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.income.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.income.withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: AppColors.income),
            SizedBox(width: 5),
            Text(
              'Fatura Paga',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.income,
              ),
            ),
          ],
        ),
      );
    }

    final isClosed = invoice.status == InvoiceStatus.closed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.alert.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.alert,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isClosed ? 'Fatura Fechada' : 'Fatura Aberta',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.alert,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenAmountSection(DateFormat dueFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total de gastos desta fatura',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'R\$ ',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              invoice.totalAmount.format(includeSymbol: false),
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.event, size: 14, color: AppColors.alert),
            const SizedBox(width: 4),
            Text(
              'Vencimento em ${dueFormat.format(invoice.dueDate)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.alert,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaidAmountSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.income.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total liquidado',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                'R\$ ${invoice.paidAmount.format()}',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.income,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Fatura integralmente quitada sem pendências ativas.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitProgressBar() {
    final usedProgress = (card.usedPercentage / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Limite total utilizado',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              '${card.usedPercentage}% utilizado',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: usedProgress,
            minHeight: 6,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.transfer,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comprometido: R\$ ${card.usedLimit.format()}',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Disponível: R\$ ${card.availableLimit.format()}',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.income,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
