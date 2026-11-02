/// Configurações globais de ambiente do MeuSaldo.
///
/// Injetadas em tempo de compilação via `--dart-define-from-file=env.json`
/// ou `--dart-define`.
abstract final class AppConfig {
  /// URL do projeto Supabase.
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Chave pública de cliente (publishable key / anon key) do Supabase.
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Indica se as credenciais do Supabase foram configuradas no ambiente.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
