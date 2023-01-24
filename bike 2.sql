select * from station sn;
select * from trip t;
select * from status ss;
select * from weather w; 


-- dodane kolumny 'true'/'false' jesli wakacje

select t.*,
(case when to_char(start_date, 'MM') = '07' then 'true'
when to_char(start_date, 'MM') = '08' then 'true'
WHEN (start_date IS NULL OR start_station_name = '') THEN 'NULL'
else 'false'
end) as wakacje
from trip t 
order by start_date;

-- trasy top 10 i iloœci

select 
distinct (start_station_name),
end_station_name,
count(1) as ilosc
from trip t 
group by  start_station_name, end_station_name 
order by ilosc desc 
limit 10

select * from trip t 
where start_station_name = end_station_name 

-- the best trasy i iloœci dla customer w sekundach
(
select 
'1. The best z ca³oœci' as info,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc
from trip t 
where subscription_type = 'Customer'
and start_station_name != end_station_name
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by info, ilosc desc
limit 1
)
union 
-- the best dla customer do 30 min
(
select 
'2. The best trasa do 30 min' as info,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc
from trip t 
where subscription_type = 'Customer'
and start_station_name != end_station_name
and duration < (60*60/2)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by ilosc desc
limit 1
)
union
-- the best dla customer do 60 min
(
select 
'3. The best trasa do 60 min' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Customer'
and start_station_name != end_station_name
and duration between (60 * 60 / 2) and (60 * 60)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by ilosc desc
limit 1
)
union
-- the best dla customer do 5 h
(
select 
'4. The best trasa do 5 h' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Customer'
and start_station_name != end_station_name
and duration between (60 * 60) and (60 * 60 * 5)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by ilosc desc
limit 1
)
union
-- the best dla customer do 12 h
(
select 
'5. The best trasa do 12 h' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Customer'
and start_station_name != end_station_name
and duration between (60 * 60) and (60 * 60 * 12)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by ilosc desc
limit 1
)
union
-- the best dla customer do 24 h
(
select 
'6. The best trasa do 24 h' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Customer'
and start_station_name != end_station_name
and duration between (60 * 60) and (60 * 60 * 12)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by ilosc desc
limit 1
);

-- the best trasy dla subscriber
(
select 
'1. The best z ca³oœci' as info,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc
from trip t 
where subscription_type = 'Subscriber'
and start_station_name != end_station_name
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by  ilosc desc
limit 1
)
union 
-- the best dla customer do 30 min
(
select 
'2. The best trasa do 30 min' as info,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc
from trip t 
where subscription_type = 'Subscriber'
and start_station_name != end_station_name
and duration < (60*60/2)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by  ilosc desc
limit 1
)
union
-- the best dla customer do 60 min
(
select 
'2. The best trasa do 60 min' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Subscriber'
and start_station_name != end_station_name
and duration between (60 * 60 / 2) and (60 * 60)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by ilosc desc 
limit 1
)
union
-- the best dla customer do 3 h
(
select 
'3. The best trasa do 5 h' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Subscriber'
and start_station_name != end_station_name
and duration between (60 * 60) and (60 * 60 * 5)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by  ilosc desc 
limit 1
)
union
-- the best dla customer do 12 h
(
select 
'4. The best trasa do 12 h' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Subscriber'
and start_station_name != end_station_name
and duration between (60 * 60) and (60 * 60 * 12)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by  ilosc desc 
limit 1
)
union
-- the best dla customer do 24 h
(
select 
'5. The best trasa do 24 h' as informacja,
start_station_name,
end_station_name,
duration as czas,
count(id) as ilosc 
from trip t 
where subscription_type = 'Subscriber'
and start_station_name != end_station_name
and duration between (60 * 60) and (60 * 60 * 12)
group by (start_station_name, end_station_name,subscription_type, start_station_id, end_station_id, duration)
order by  ilosc desc 
limit 1
)

-- trasy worst 10  i iloœci dla Subscriber
select 
distinct start_station_name,
end_station_name,
count(1) as ilosc_sub
from trip t 
where subscription_type ilike '%sub%'
and start_station_name != end_station_name
group by (start_station_name, end_station_name,subscription_type)
order by ilosc_sub desc
limit 10;

-- przedstawienie ilosciowe

select 
sum(duration) as suma_czasu,
count(id) as l_wypozyczen,
count(distinct start_station_id) as l_stacji_pocz,
count(distinct end_station_id) as l_stacji_kon,
count(distinct bike_id) as l_rowerow,
count(distinct subscription_type) l_typow,
count(distinct zip_code) as l_kodow_poczt
from trip;

