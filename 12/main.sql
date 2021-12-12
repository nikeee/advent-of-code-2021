-- Run:
--     sqlite3 :memory: < main.sql
-- Runtime version:
--     sqlite3 --version
--     3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837balt1

create table edge (
    source text not null,
    dest text not null,
    primary key (source, dest)
);

.separator "-"
.import input.txt edge
.separator "\t"
.headers off

-- make relation bi-directional by adding the reverse direction
insert into edge (source, dest) select dest, source from edge;

pragma case_sensitive_like = 1;

with recursive
    nodes(x, path) as (
    select 'start', 'start'
    union
        select e.dest, path || ',' || e.dest
        from edge e
        join nodes n ON e.source = n.x
        -- if a cave is large, it can ocurr multiple times
        -- if not, it must only occurr once
        where
            source <> 'end' and dest <> 'start'
            and
            (upper(dest) = dest or not (path like '%' || dest || '%'))
)
select 'Number of paths according to rules; Part 1: ' || count(*) as solution
from nodes
where x = 'end';

create temp table small_cave as
select distinct source as id
    from edge
    where
        source = lower(source)
        and source <> 'start'
        and source <> 'end';

with recursive
    nodes(x, path) as (
    select 'start', 'start'
    union
        select e.dest, path || ',' || e.dest
        from edge e
        join nodes n ON e.source = n.x
        where
            source <> 'end' and dest <> 'start'
            and
            (
                upper(dest) = dest
                or
                not (path like '%' || dest || '%')
                -- this basically checks if there is already a small cave that occurrs twice
                -- if not, this cave can be used twice
                or not exists (
                    select id
                    from small_cave
                    where
                        -- hack to count the ocurrences of a string in pure SQL
                        -- ref: https://stackoverflow.com/a/54406626
                        ((length(path) - length(replace(path, id, ''))) / length(id)) >= 2
                )
            )
)
select 'Number of paths with modified rules; Part 2: ' || count(*) as solution
from nodes
where x = 'end';
