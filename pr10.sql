/* DATALOG-like
Take the relation FLIGHT and give a recursive query for the following:
Give all the possible routes from Orig city to Dest city with the total cost of the route.
  FLIGHT(airline VARCHAR2(10), orig VARCHAR2(15), dest VARCHAR2(15), cost NUMBER);
Help:
Use a temporal relation Reaches(x,y,c,r) which gives the pair of cities (x,y) for which
it is possible to get from city x to city y by taking one or more flights, and c is the total
cost of that flight, r is the route (concatenated string).
First specify the Datalog rules for Reaches(orig,dest,cost,route) then rewrite it into an SQL recursive query,
then write a procedure where p_orig and p_dest are parameters.
*/
WITH  reaches(orig, dest) AS 
 (
  SELECT orig, dest FROM nikovits.flight
   UNION ALL
  SELECT flight.orig, reaches.dest FROM nikovits.flight, reaches
  WHERE flight.dest = reaches.orig AND flight.orig <> reaches.dest
  )
  CYCLE orig SET is_cycle TO 'Y' DEFAULT 'N' 
SELECT  distinct orig, dest FROM reaches order by orig, dest;

CREATE OR REPLACE PROCEDURE route_costs(p_orig VARCHAR, p_dest VARCHAR) IS
CURSOR c is WITH  reaches(orig, dest, cost, route) AS 
 (
  SELECT orig, dest, cost, orig||'-'||dest FROM nikovits.flight
   UNION ALL
    SELECT reaches.orig, flight.dest, reaches.cost+flight.cost cost, reaches.route||'-'||flight.dest 
    FROM nikovits.flight, reaches
    WHERE reaches.dest = flight.orig AND reaches.orig <> flight.dest                                            -- here comes the recursive part 
  )
  CYCLE orig, dest SET cycle_yes TO 'Y' DEFAULT 'N' 
SELECT  distinct orig, dest, cost, route FROM reaches 
WHERE orig=p_orig AND dest=p_dest;
begin
    for rec in c loop
        dbms_output.put_line(rec.route||': '||rec.cost);
    end loop;
end;

set serveroutput on
execute route_costs('San Francisco','New York');

/* CONNECT BY
Write a procedure which prints out (based on table NIKOVITS.PARENTOF) the names 
of people who has a richer descendant than him/her. 
(That is, at least one descendant has more money than the person.)
*/
CREATE OR REPLACE PROCEDURE rich_descendant IS
cnt INTEGER;
BEGIN
 FOR rec IN (SELECT name, money FROM nikovits.parentof) loop   -- loop over all the people having their name and money
  SELECT COUNT(*) into cnt
  FROM nikovits.parentof
  WHERE LEVEL > 1 and rec.money < money
  START WITH name = rec.name
  CONNECT BY prior name = parent;
  if cnt > 0 then
    dbms_output.put_line(rec.name);
  end if;
 END loop;
END;

 
set serveroutput on
execute rich_descendant(); 

/*
Write a procedure which prints out (based on table NIKOVITS.PARENTOF) the name,
money and average money of the descendants for whom it is true, that the average money
of the descendants is greater than the person's money.
The program should print out 3 pieces of data for every row: Name, Money, Avg_Money_of_Descendants 
*/
CREATE OR REPLACE PROCEDURE rich_avg_descendant IS
avrg FLOAT;
BEGIN
 FOR rec IN (SELECT name, money FROM nikovits.parentof) loop   -- loop over all the people having their name and money
  SELECT avg(money) into avrg
  FROM nikovits.parentof
  WHERE LEVEL > 1
  START WITH name = rec.name
  CONNECT BY prior name = parent;
  if avrg > rec.money then
    dbms_output.put_line(rec.name || ' - ' || rec.money || ' - ' || avrg);
  end if;
 END loop;
END;

set serveroutput on
execute rich_avg_descendant();

/*
Write a procedure which prints out (based on table NIKOVITS.FLIGHT) the nodes (cities)
of the directed cycles, which start and end with the parameter city.
Example output: Dallas-Chicago-Denver-Dallas
*/
CREATE OR REPLACE PROCEDURE find_cycle(p_node VARCHAR2) IS
  cursor c is SELECT SYS_CONNECT_BY_PATH(orig, '-') || '-' || dest route
  FROM nikovits.flight
  WHERE dest = CONNECT_BY_ROOT orig
  START WITH orig = p_node
  CONNECT BY NOCYCLE prior dest = orig;
BEGIN
  for rec in c loop
    dbms_output.put_line(rec.route);
  end loop;
END;

select * from nikovits.flight

SELECT  LPAD(' ', 2*(LEVEL-1)) || name, parent, city, CONNECT_BY_ROOT city
FROM nikovits.parentof
WHERE city = CONNECT_BY_ROOT city
START WITH  name='ADAM'
CONNECT BY  PRIOR name = parent;

set serveroutput on
execute find_cycle('Denver');


  SELECT SYS_CONNECT_BY_PATH(orig, '-') || '-' || dest
  FROM nikovits.flight
  WHERE dest = CONNECT_BY_ROOT orig
  START WITH orig = 'Dallas'
  CONNECT BY NOCYCLE prior dest = orig;
  
  
  SELECT CONNECT_BY_ROOT orig AS first, dest AS final_dest, LEVEL, 
       SYS_CONNECT_BY_PATH(orig, '->')||'->'||dest "route",        -- we concatenate the final dest at the end
       CONNECT_BY_ISCYCLE, CONNECT_BY_ISLEAF
FROM nikovits.flight                                                       
START WITH orig='Dallas'
CONNECT BY NOCYCLE PRIOR dest = orig
ORDER BY LEVEL;

/*
Write a procedure which prints out (based on table NIKOVITS.PARENTOF) the name and city
of people who have at least two ancestors with the same city as the person's city.
*/
CREATE OR REPLACE PROCEDURE ancestor2 IS
c integer;
BEGIN
 FOR rec1 IN (SELECT name, city FROM nikovits.parentof) loop   -- loop over all the people having their name and money
  for rec2 in (select string_match(route, rec1.city) c from
  (SELECT name, parent, SYS_CONNECT_BY_PATH(city, '-') route
  FROM nikovits.parentof
  START WITH name = rec1.name
  CONNECT BY prior parent = name)) loop
    if rec2.c > 2 then
      dbms_output.put_line(rec1.name || ' - ' || rec1.city);
      exit;
    end if;
  end loop;
 END loop;
END;



set serveroutput on
execute ancestor2();

select name, parent, string_match(route, city), city, route
from
(SELECT name, parent, SYS_CONNECT_BY_PATH(city, '-') route
  FROM nikovits.parentof
  --WHERE LEVEL > 1
  START WITH name = 'PETER'
  CONNECT BY prior parent = name),
  (select city from nikovits.parentof where name = 'PETER')
  
  select * from nikovits.parentof
