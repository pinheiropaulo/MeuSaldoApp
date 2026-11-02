-- ==============================================================================
-- MeuSaldo — Schema PostgreSQL para Supabase
-- ==============================================================================
-- Diretrizes Arquiteturais:
-- 1. Valores monetários estritamente em centavos inteiros (BIGINT).
-- 2. Row Level Security (RLS) habilitado em 100% das tabelas.
-- 3. Cada usuário acessa apenas os seus próprios dados (auth.uid() = user_id).
-- 4. Gatilhos automáticos para perfis e categorias padrão no primeiro cadastro.
-- ==============================================================================

-- Extensão UUID (padrão no Supabase)
create extension if not exists "uuid-ossp";

-- ==============================================================================
-- 1. TABELA: profiles (Perfis de Usuário vinculados ao Supabase Auth)
-- ==============================================================================
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    full_name text not null,
    email text not null,
    avatar_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Usuários podem ver seu próprio perfil"
    on public.profiles for select
    using (auth.uid() = id);

create policy "Usuários podem atualizar seu próprio perfil"
    on public.profiles for update
    using (auth.uid() = id);

create policy "Usuários podem inserir seu próprio perfil"
    on public.profiles for insert
    with check (auth.uid() = id);

-- ==============================================================================
-- 2. TABELA: accounts (Contas Financeiras / Bancárias / Carteira)
-- ==============================================================================
create table if not exists public.accounts (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    type text not null check (type in ('checking', 'savings', 'cash', 'digitalWallet', 'investment')),
    initial_balance_cents bigint not null default 0,
    current_balance_cents bigint not null default 0,
    is_active boolean not null default true,
    color_hex text not null default '#6D1834',
    bank_code text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.accounts enable row level security;

create policy "Usuários gerenciam suas próprias contas"
    on public.accounts for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create index if not exists idx_accounts_user on public.accounts(user_id);

-- ==============================================================================
-- 3. TABELA: categories (Categorias de Receita e Despesa)
-- ==============================================================================
create table if not exists public.categories (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    icon_name text not null default 'category',
    color_hex text not null default '#6D1834',
    type text not null check (type in ('expense', 'income', 'both')),
    monthly_budget_cents bigint, -- Teto orçamentário mensal opcional em centavos
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.categories enable row level security;

create policy "Usuários gerenciam suas próprias categorias"
    on public.categories for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create index if not exists idx_categories_user on public.categories(user_id);

-- ==============================================================================
-- 4. TABELA: credit_cards (Cartões de Crédito)
-- ==============================================================================
create table if not exists public.credit_cards (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    limit_cents bigint not null check (limit_cents > 0),
    closing_day integer not null check (closing_day between 1 and 31),
    due_day integer not null check (due_day between 1 and 31),
    color_hex text not null default '#6D1834',
    brand text not null default 'mastercard',
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.credit_cards enable row level security;

create policy "Usuários gerenciam seus próprios cartões"
    on public.credit_cards for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create index if not exists idx_credit_cards_user on public.credit_cards(user_id);

-- ==============================================================================
-- 5. TABELA: invoices (Faturas de Cartão de Crédito)
-- ==============================================================================
create table if not exists public.invoices (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    card_id uuid not null references public.credit_cards(id) on delete cascade,
    month integer not null check (month between 1 and 12),
    year integer not null check (year between 2000 and 2100),
    closing_date date not null,
    due_date date not null,
    total_cents bigint not null default 0,
    is_closed boolean not null default false,
    is_paid boolean not null default false,
    paid_date date,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique(card_id, month, year)
);

alter table public.invoices enable row level security;

create policy "Usuários gerenciam suas próprias faturas"
    on public.invoices for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create index if not exists idx_invoices_card on public.invoices(card_id, year, month);
create index if not exists idx_invoices_user on public.invoices(user_id);

-- ==============================================================================
-- 6. TABELA: transactions (Lançamentos Financeiros)
-- ==============================================================================
create table if not exists public.transactions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    description text not null,
    amount_cents bigint not null check (amount_cents > 0),
    date timestamptz not null,
    type text not null check (type in ('expense', 'income', 'transfer')),
    status text not null default 'completed' check (status in ('completed', 'pending')),
    source_account_id uuid references public.accounts(id) on delete set null,
    destination_account_id uuid references public.accounts(id) on delete set null,
    category_id uuid references public.categories(id) on delete set null,
    card_id uuid references public.credit_cards(id) on delete set null,
    installment_number integer,
    total_installments integer,
    notes text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.transactions enable row level security;

create policy "Usuários gerenciam seus próprios lançamentos"
    on public.transactions for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create index if not exists idx_transactions_user_date on public.transactions(user_id, date desc);
create index if not exists idx_transactions_category on public.transactions(category_id);
create index if not exists idx_transactions_source_acc on public.transactions(source_account_id);
create index if not exists idx_transactions_dest_acc on public.transactions(destination_account_id);
create index if not exists idx_transactions_card on public.transactions(card_id);

-- ==============================================================================
-- 7. TABELA: recurring_transactions (Lançamentos Recorrentes / Fixos)
-- ==============================================================================
create table if not exists public.recurring_transactions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    description text not null,
    amount_cents bigint not null check (amount_cents > 0),
    type text not null check (type in ('expense', 'income')),
    frequency text not null default 'monthly' check (frequency in ('daily', 'weekly', 'monthly', 'yearly')),
    due_day integer not null check (due_day between 1 and 31),
    source_account_id uuid references public.accounts(id) on delete set null,
    category_id uuid references public.categories(id) on delete set null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.recurring_transactions enable row level security;

create policy "Usuários gerenciam suas próprias recorrências"
    on public.recurring_transactions for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create index if not exists idx_recurring_user on public.recurring_transactions(user_id);

-- ==============================================================================
-- 8. GATILHOS AUTOMÁTICOS (Triggers): Atualização de updated_at
-- ==============================================================================
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create or replace trigger on_profiles_updated
    before update on public.profiles
    for each row execute function public.handle_updated_at();

create or replace trigger on_accounts_updated
    before update on public.accounts
    for each row execute function public.handle_updated_at();

create or replace trigger on_categories_updated
    before update on public.categories
    for each row execute function public.handle_updated_at();

create or replace trigger on_credit_cards_updated
    before update on public.credit_cards
    for each row execute function public.handle_updated_at();

create or replace trigger on_invoices_updated
    before update on public.invoices
    for each row execute function public.handle_updated_at();

create or replace trigger on_transactions_updated
    before update on public.transactions
    for each row execute function public.handle_updated_at();

create or replace trigger on_recurring_updated
    before update on public.recurring_transactions
    for each row execute function public.handle_updated_at();

-- ==============================================================================
-- 9. GATILHO DE BOAS-VINDAS: Criação de perfil e categorias padrão no cadastro
-- ==============================================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
    -- 1. Cria o perfil público do usuário
    insert into public.profiles (id, full_name, email, avatar_url)
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
        new.email,
        new.raw_user_meta_data->>'avatar_url'
    );

    -- 2. Cria as categorias padrão de Despesas
    insert into public.categories (user_id, name, icon_name, color_hex, type) values
        (new.id, 'Alimentação', 'restaurant', '#F04444', 'expense'),
        (new.id, 'Mercado', 'shopping_cart', '#F2C94C', 'expense'),
        (new.id, 'Moradia', 'home', '#4C8DFF', 'expense'),
        (new.id, 'Transporte', 'directions_car', '#9B51E0', 'expense'),
        (new.id, 'Lazer', 'sports_esports', '#FF7A00', 'expense'),
        (new.id, 'Saúde', 'favorite', '#EB5757', 'expense'),
        (new.id, 'Educação', 'school', '#2D9CDB', 'expense'),
        (new.id, 'Outros', 'category', '#6D1834', 'expense');

    -- 3. Cria as categorias padrão de Receitas
    insert into public.categories (user_id, name, icon_name, color_hex, type) values
        (new.id, 'Salário', 'payments', '#22A06B', 'income'),
        (new.id, 'Rendimentos', 'trending_up', '#27AE60', 'income'),
        (new.id, 'Freelance', 'work', '#219653', 'income'),
        (new.id, 'Outras Receitas', 'account_balance_wallet', '#6FCF97', 'income');

    return new;
end;
$$ language plpgsql security definer;

-- Trigger disparado no Supabase Auth após confirmação de usuário
create or replace trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();
