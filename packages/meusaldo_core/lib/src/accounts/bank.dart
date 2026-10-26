/// Representa uma instituição financeira / banco pré-cadastrado no Brasil.
class Bank {
  /// Nome oficial ou fantasia do banco (ex: "Nubank", "Itaú Unibanco").
  final String name;

  /// Segmento ou tipo institucional (ex: "Digital", "Tradicional / Privado", "Tradicional / Público").
  final String type;

  /// Foco principal da instituição financeira (ex: "Varejo, investimentos e corporate banking").
  final String focus;

  const Bank({
    required this.name,
    required this.type,
    required this.focus,
  });

  /// Converte a partir de mapa chave-valor (compatível com os campos em português "nome", "tipo", "foco").
  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      name: json['nome'] as String? ?? json['name'] as String? ?? '',
      type: json['tipo'] as String? ?? json['type'] as String? ?? '',
      focus: json['foco'] as String? ?? json['focus'] as String? ?? '',
    );
  }

  /// Converte para mapa serializável.
  Map<String, dynamic> toJson() => {
        'nome': name,
        'tipo': type,
        'foco': focus,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bank &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          focus == other.focus;

  @override
  int get hashCode => Object.hash(runtimeType, name, type, focus);

  @override
  String toString() => 'Bank(name: $name, type: $type)';

  /// Lista oficial com os principais bancos brasileiros pré-registrados.
  static const List<Bank> defaultBrazilianBanks = [
    Bank(
      name: 'Itaú Unibanco',
      type: 'Tradicional / Privado',
      focus: 'Varejo, investimentos e corporate banking',
    ),
    Bank(
      name: 'Banco do Brasil',
      type: 'Tradicional / Público',
      focus: 'Varejo, agronegócio e setor público',
    ),
    Bank(
      name: 'Caixa Econômica Federal',
      type: 'Tradicional / Público',
      focus: 'Habitação, programas sociais e FGTS',
    ),
    Bank(
      name: 'Bradesco',
      type: 'Tradicional / Privado',
      focus: 'Varejo, seguros e ampla rede de agências',
    ),
    Bank(
      name: 'Santander Brasil',
      type: 'Tradicional / Privado',
      focus: 'Varejo e financiamentos',
    ),
    Bank(
      name: 'BTG Pactual',
      type: 'Tradicional / Privado',
      focus: 'Investimentos e corporate banking',
    ),
    Bank(
      name: 'Nubank',
      type: 'Digital',
      focus: 'Cartões de crédito, conta digital e investimentos',
    ),
    Bank(
      name: 'Banco Inter',
      type: 'Digital',
      focus: 'Super app completo, investimentos e conta global',
    ),
    Bank(
      name: 'C6 Bank',
      type: 'Digital',
      focus: 'Cartões premium, conta internacional e investimentos',
    ),
    Bank(
      name: 'PagBank',
      type: 'Digital',
      focus: 'Meios de pagamento, serviços PJ e maquininhas',
    ),
    Bank(
      name: 'PicPay',
      type: 'Digital',
      focus: 'Carteira digital, pagamentos diários e marketplace',
    ),
    Bank(
      name: 'Neon',
      type: 'Digital',
      focus: 'Conta digital simplificada e foco em microempreendedores',
    ),
  ];
}
