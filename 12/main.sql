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
        where (upper(dest) = dest or not (path like '%' || dest || '%'))
        and not path like '%,end' -- a valid path always ands in 'end'
)
select 'Number of paths according to rules; Part 1: ' || count(*) as solution
from nodes
where x = 'end';
