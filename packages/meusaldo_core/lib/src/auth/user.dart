/// Representa o usuário autenticado no MeuSaldo.
class User {
  /// Identificador único do usuário.
  final String id;

  /// Nome de exibição do usuário (ex: "Paulo Pinheiro").
  final String name;

  /// E-mail de login e notificações.
  final String email;

  /// URL ou caminho da foto de perfil (opcional).
  final String? photoUrl;

  /// Celular ou WhatsApp (opcional).
  final String? phone;

  /// Data de criação da conta.
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    required this.createdAt,
  });

  /// Cria uma nova instância de [User] validando campos obrigatórios.
  factory User.create({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
    String? phone,
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
      photoUrl: photoUrl,
      phone: phone,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Retorna uma cópia atualizada do usuário.
  User copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
  }) {
    return User.create(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          photoUrl == other.photoUrl &&
          phone == other.phone;

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, email, photoUrl, phone);

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
