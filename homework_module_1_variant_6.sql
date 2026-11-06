/*
ФИО: Киселев Виталий Дмитриевич

Домашнее задание к первому модулю
Вариант 6
Описание предметной области
Описание расписания пригородных электропоездов одного направления. Включает в себя: станции, график движения электропоездов, стоимости билетов. Станции описываются: названием, тарифной зоной, порядковым номером на направлении. График движения электропоездов описывается: указанием станции начала маршрута, указанием станции, завершающей маршрут, списком станций, на которых поезд не останавливается, временем прибытия на каждую станцию, на которой поезд останавливается, списком дней недели, по которым данный маршрут работает. Стоимости билетов описываются: количеством пересекаемых зон и, непосредственно, самой стоимостью.
Поезда двигаются в одном направлении, но по мере удаления от начальной станции ветка может разделяться на несколько подветок. 
*/

BEGIN;

CREATE SCHEMA railway_v6;
SET LOCAL search_path = railway_v6;

CREATE TABLE stations (
    station_no         integer PRIMARY KEY,
    station_name       varchar(200) NOT NULL CHECK (btrim(station_name) <> ''),
    tariff_zone        smallint NOT NULL CHECK (tariff_zone >= 0),
    parent_station_no  integer REFERENCES stations (station_no),
    CHECK (
        (station_no = 1 AND parent_station_no IS NULL)
        OR
        (station_no > 1 AND parent_station_no IS NOT NULL
                        AND parent_station_no < station_no)
    )
);

CREATE TABLE routes (
    route_id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_station_no  integer NOT NULL REFERENCES stations (station_no),
    end_station_no    integer NOT NULL REFERENCES stations (station_no),
    CHECK (start_station_no < end_station_no)
);

CREATE TABLE route_stations (
    route_id            integer NOT NULL REFERENCES routes (route_id) ON DELETE CASCADE,
    station_no          integer NOT NULL REFERENCES stations (station_no),
    arrival_time        time(0),
    arrival_day_offset  smallint NOT NULL DEFAULT 0 CHECK (arrival_day_offset >= 0),
    PRIMARY KEY (route_id, station_no),
    UNIQUE (route_id, arrival_day_offset, arrival_time),
    CHECK (arrival_time IS NULL OR arrival_time < TIME '24:00:00'),
    CHECK (arrival_time IS NOT NULL OR arrival_day_offset = 0)
);

CREATE TABLE route_days (
    route_id  integer NOT NULL REFERENCES routes (route_id) ON DELETE CASCADE,
    weekday   smallint NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    PRIMARY KEY (route_id, weekday)
);

CREATE TABLE zone_fares (
    crossed_zone_count  smallint PRIMARY KEY CHECK (crossed_zone_count >= 0),
    price               numeric(12,2) NOT NULL CHECK (price >= 0 AND price <> 'NaN'::numeric)
);

COMMIT;
