/// Representa o usuário autenticado no MeuSaldo.
class User {
  /// Identificador único do usuário.
  final String id;

  /// Nome de exibição do usuário (ex: "Paulo Pinheiro").
  final String name;

  /// E-mail de login e notificações.
  final String email;

  /// Data de criação da conta.
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  /// Cria uma nova instância de [User] validando campos obrigatórios.
  factory User.create({
    required String id,
    required String name,
    required String email,
    DateTime? createdAt,
  }) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O ID do usuário não pode ser vazio.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'O nome do usuário não pode ser vazio.');
    }

    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw ArgumentError.value(email, 'email', 'Informe um endereço de e-mail válido.');
    }

    return User(
      id: trimmedId,
      name: trimmedName,
      email: trimmedEmail,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => Object.hash(runtimeType, id, name, email);

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
