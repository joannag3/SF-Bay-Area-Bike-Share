select * from station sn;
select * from trip t;
select * from status ss;
select * from weather w; 


-----------------------------------------------
--                STATION
-----------------------------------------------

-- ilosc obslugiwanych stacji
select count(distinct (name) ) from station;

-- nazwy poszczegolnych stacji
select distinct name from station;

-- ilosc obslugiwanych miast
select count (distinct (city) ) from station s ;

-- nazwy poszczegolnych miast
select distinct city from station ;

-- ranking i ilosc doków dostêpnych w poszczególnych miastach
select 
city, 
sum(dock_count),
dense_rank  () over (order by sum(dock_count) desc ) as ranking 
from station sn
group by city;


-- ranking stacji wg ilosc doków
select city, name, dock_count, 
dense_rank  () over (order by dock_count desc) as ranking 
from station s
group by s.city, s.dock_count, s.name  
order by ranking, city;

-----------------------------------------------
--                TRIP
-----------------------------------------------

-- ilosc wypozyczen
select count(id) from trip t ;

-- iloœæ wypo¿yczeñ rowerów w danym roku i miesiacu i w sumie wszystkich
select 
distinct rok,
miesiac,
sum(ilosc) as suma
from
(
select count(id) as ilosc,
to_char(start_date, 'YYYY') as  rok,
to_char(start_date, 'MM') as  miesiac
from trip t
group by rollup  (start_date)
order by miesiac
) as q
group by  (q.rok, q.miesiac)
order by rok, miesiac;

-- czas przejazdu w minutach
select 
sum(duration/60) as laczny_czas,
min(duration/60) as minimalny_czas,
avg(duration/60) as sredni_czas,
max(duration/60) as maksymalny_czas
from trip t;

-- czas przejazdu w minutach w ci¹gu tej samej doby
select 
sum(duration/60) as laczny_czas,
min(duration/60) as minimalny_czas,
round (avg(duration/60), 2) as sredni_czas,
max(duration/60) as maksymalny_czas
from trip t
where start_date = end_date ;

-- ilosc wypozyczen przekraczajacych dobe (ponad 86400 sekund)
select 
count(f.id) as wiecej
from
(
select id, duration, start_station_name, end_station_name from trip t
group by  id, duration, start_station_name, end_station_name  
having duration > (60 * 60 * 1)
order by duration desc
) as f;

-- ilosc wypozyczen, gdy stacja poczatkowa i koncowa sa te same
select 
start_station_name,
count(id) as ilosc 
from trip t 
where start_station_name = end_station_name 
group by rollup (start_station_name)
order by ilosc desc;

-- ilosc wypozyczen, gdy stacja poczatkowa i koncowa nie s¹ takie same
select 
distinct start_station_name,
count(id) as ilosc 
from trip t 
where start_station_name != end_station_name 
group by rollup (start_station_name)
order by ilosc desc;

-- typy i ilosci klientów
(
select 
'iloœæ abonanentów: ' as typ,
count(id) as ilosc from trip 
where subscription_type = 'Subscriber'
)
union
(
select 
'iloœæ jednorazowych klientów' as informacja,
count(id) from trip 
where subscription_type = 'Customer'
);

-- iloœci i typy klientów v.2
select subscription_type, count(id) from trip t 
group by subscription_type;

-- czas przejazdow z podzia³em na typ wypozyczaj¹cego (w minutach)
select 
subscription_type, 
avg(duration/60) as sredni_czas,
sum (duration/60) as suma_czas
from trip t 
group by subscription_type;


-- najpopularniejszy rower i poczatkowa / koncowa stacja
select 
'najpopularniejszy' as info,
subscription_type,
mode () within group (order by bike_id) as id_rower,
mode () within group (order by start_station_name) as id_poczatkowa_stacja,
mode () within group (order by end_station_name) as id_koncowa_stacja,
mode () within group(order by zip_code) as kod_pocztowy -- Kalifornia
from trip t 
group by subscription_type ;

-- wskazanie naczêœciej u¿ywanej stacji i sumy czasu przejazdów ze stacj¹ pocz¹tkow¹
select
start_station_name, 
sum(duration)  as czas
from trip t 
where start_station_id = '70'
group by start_station_name;

-- top w Kaliforni
select 
'najpopularniejszy w Kaliforni' as info,
subscription_type,
mode () within group (order by bike_id) as id_rower,
mode () within group (order by start_station_name) as id_poczatkowa_stacja,
mode () within group (order by end_station_name) as id_koncowa_stacja
from trip t 
where zip_code = '94107'
group by subscription_type;

-- najpopularniejsze stacje wg sortowania 
select * from
(select 
start_station_name as poczatkowa_stacja, 
count(1) as ilosc_poczatkowa
from trip t
group by start_station_name
order by ilosc_poczatkowa desc) as s,
(select 
end_station_name as koncowa_stacja, 
count(id) as ilosc_koncowa
from trip t
group by end_station_name
order by ilosc_koncowa desc
limit 10) as e;

-- najrzadziej u¿ywane stacje  
select distinct s.poczatkowa_stacja,
s.ilosc_poczatkowa,
e.koncowa_stacja,
e.ilosc_koncowa
from
(select 
start_station_name as poczatkowa_stacja, 
count(id) as ilosc_poczatkowa
from trip t
group by start_station_name
order by ilosc_poczatkowa asc
limit 10) as s,
(select 
end_station_name as koncowa_stacja, 
count(id) as ilosc_koncowa
from trip t
group by end_station_name
order by ilosc_koncowa asc
limit 10) as e;

-- iloœæ kodów pocztowych
select count(zip_code)  from trip t 

-- ranking wypozyczen wg stacji i typu klienta
select 
sub.start_station_name,
suma_cus,
suma_sub,
(suma_cus + suma_sub) as suma_total,
case when suma_sub < suma_cus then 'customer'
else 'subscriber' end as ranking
from
(
select start_station_name, subscription_type, sum(duration) as suma_sub from trip t 
where subscription_type = 'Subscriber'
group by subscription_type, start_station_name 
order by start_station_name, suma_sub desc
) as sub
join 
(
select start_station_name, subscription_type, sum(duration) as suma_cus from trip t 
where subscription_type = 'Customer'
group by subscription_type, start_station_name 
order by start_station_name, suma_cus desc
) as cus
on sub.start_station_name = cus.start_station_name;

-- ranking wypozyczen wg stacji koñcowej i typu klienta
select 
sub.end_station_name,
suma_cus,
suma_sub,
(suma_cus + suma_sub) as suma_total,
case when suma_sub < suma_cus then 'customer'
else 'subscriber' end as ranking
from
(
select end_station_name, subscription_type, sum(duration) as suma_sub from trip t 
where subscription_type = 'Subscriber'
group by subscription_type, end_station_name 
order by end_station_name, suma_sub desc
) as sub
join 
(
select end_station_name, subscription_type, sum(duration) as suma_cus from trip t 
where subscription_type = 'Customer'
group by subscription_type, end_station_name 
order by end_station_name, suma_cus desc
) as cus
on sub.end_station_name = cus.end_station_name;

-- ranking wg miasta i typu klienta
select 
sub.city,
suma_cus,
suma_sub,
(suma_cus + suma_sub) as suma_total,
case when suma_sub < suma_cus then 'customer'
else 'subscriber' end as ranking
from
(
select city, subscription_type, sum(duration) as suma_sub from trip t 
join station s on t.start_station_name = s.name
where subscription_type = 'Subscriber'
group by subscription_type, city 
order by city, suma_sub desc
) as sub
join 
(
select city, subscription_type, sum(duration) as suma_cus from trip t 
join station s on t.start_station_name = s.name 
where subscription_type = 'Customer'
group by subscription_type, city 
order by city, suma_cus desc
) as cus
on sub.city = cus.city;


-----------------------------------------------
--                WEATHER
-----------------------------------------------

--temperature - temperatura
--dew point - punkt rosy ??
--humidity - wilgotnoœæ
--sea level pressure inches - ciœnienie w calach
--visibility miles - widocznoœæ w milach
--wind speed - prêdkoœæ wiatru
--gust speed - prêdkoœæ podmuchu
--precipitation_inches - opady w calach
--cloud_cover - zachmurzenie
--events - wydarzenia
--wind_dir_degrees - kierunek wiatru w stopniach

-- œrednie danych maj¹cych wp³yw na jazdê na rowerze
select * from 
(
select 
'1. temperatura' as kategoria,
avg(max_temperature_f) as srednia_max,
avg(mean_temperature_f) as srednia_mean,
avg(min_temperature_f) as srednia_min
from weather w 
union
select 
'2. wilgotnoœæ' as kategoria,
avg(max_humidity) as srednia_max,
avg(mean_humidity) as srednia_mean,
avg(min_humidity) as srednia_min
from weather w 
union
select 
'3. widodcznoœæ w kilometrach' as kategoria,
avg((max_visibility_miles)*1.61) as srednia_max,
avg((mean_visibility_miles)*1.61) as srednia_mean,
avg((min_visibility_miles)*1.61) as srednia_min
from weather w
) as z
order by kategoria;

-- œrednie danych maj¹cych wp³yw na jazdê na rowerze
select 
avg((max_wind_speed_mph)*1.61) as srednia_max_pred_wiatru_km,
avg((mean_wind_speed_mph) * 1.61) as srednia_mean_pred_wiatru_km,
avg((max_gust_speed_mph) * 1.61) as srednia_max_podmuchu_wiatru_km,
avg(cloud_cover) as srednia_zachmurzenie
from weather w ;

-- rodzaje zdarzen i iloœci wyst¹pieñ
select distinct (events), count(events) as ilosc from weather w 
group by events 
order by ilosc desc;
