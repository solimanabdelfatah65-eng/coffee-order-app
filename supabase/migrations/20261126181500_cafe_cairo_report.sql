begin;

do $cairo_report$
declare
  function_definition text;
  old_day_predicate constant text := $old_day$o.created_at >= date_trunc('day', now())$old_day$;
  new_day_predicate constant text := $new_day$o.created_at >= coalesce(
    nullif(v_payload->>'start_at', '')::timestamptz,
    date_trunc('day', now() at time zone 'Africa/Cairo') at time zone 'Africa/Cairo'
  )
  and o.created_at < coalesce(
    nullif(v_payload->>'end_at', '')::timestamptz,
    (date_trunc('day', now() at time zone 'Africa/Cairo') + interval '1 day') at time zone 'Africa/Cairo'
  )$new_day$;
  old_hour_expression constant text := $old_hour$extract(hour from o.created_at)$old_hour$;
  new_hour_expression constant text := $new_hour$extract(hour from o.created_at at time zone 'Africa/Cairo')$new_hour$;
begin
  select pg_get_functiondef('public.cafe_api(text,text,jsonb)'::regprocedure)
    into function_definition;

  if position(old_day_predicate in function_definition) > 0 then
    function_definition := replace(function_definition, old_day_predicate, new_day_predicate);
  elsif position(new_day_predicate in function_definition) = 0 then
    raise exception 'The expected cafe_api daily report predicate was not found';
  end if;

  if position(old_hour_expression in function_definition) > 0 then
    function_definition := replace(function_definition, old_hour_expression, new_hour_expression);
  elsif position(new_hour_expression in function_definition) = 0 then
    raise exception 'The expected cafe_api hourly report expression was not found';
  end if;

  execute function_definition;
end;
$cairo_report$;

commit;
