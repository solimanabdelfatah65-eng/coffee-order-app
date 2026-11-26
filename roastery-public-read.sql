grant select on public.roastery_products, public.roastery_options to anon, authenticated;

alter table public.roastery_products enable row level security;
alter table public.roastery_options enable row level security;

drop policy if exists "Public can read active roastery products" on public.roastery_products;
create policy "Public can read active roastery products"
  on public.roastery_products for select
  to anon, authenticated
  using (active = true);

drop policy if exists "Public can read active roastery options" on public.roastery_options;
create policy "Public can read active roastery options"
  on public.roastery_options for select
  to anon, authenticated
  using (active = true);
