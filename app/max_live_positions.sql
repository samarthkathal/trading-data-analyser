do
$$
declare
    ele record;
begin
for ele in select unique_id, trader_id, open_time, close_time 
           from historical_positions
           order by open_time desc
           limit 3
    loop
    raise notice '% - % ', ele.movie_id, ele.movie_name;
    end loop;
end;
$$;