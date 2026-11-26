create table if not exists public.products (
  id text primary key,
  name text not null,
  origin text not null default '',
  description text not null default '',
  price numeric(10, 2) not null check (price > 0),
  image text not null,
  roast text not null default 'وسط',
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id text primary key,
  customer text not null,
  phone text not null,
  address text not null default '',
  fulfillment text not null check (fulfillment in ('توصيل للمنزل', 'استلام من المطحنة')),
  items jsonb not null check (jsonb_typeof(items) = 'array'),
  total numeric(10, 2) not null check (total >= 0),
  status text not null default 'قيد الطحن والتجهيز'
    check (status in ('قيد الطحن والتجهيز', 'جاهز للاستلام', 'تم التسليم')),
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Anyone can view products" on public.products;
create policy "Anyone can view products"
  on public.products for select
  using (true);

drop policy if exists "Authenticated users can manage products" on public.products;
create policy "Authenticated users can manage products"
  on public.products for all
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Customers can create orders" on public.orders;
create policy "Customers can create orders"
  on public.orders for insert
  to anon, authenticated
  with check (true);

drop policy if exists "Authenticated users can manage orders" on public.orders;
create policy "Authenticated users can manage orders"
  on public.orders for all
  to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
