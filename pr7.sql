/* Write a function which decides if the parameter number is prime or not. 
   In case of yes (no) the function returns 1 (0).
*/
create or replace function prim(n integer) return number is
    i number := 0;
begin
    if n < 2 then
        return 0;
    end if;
    for i in 2..n/2 loop
        if mod(n,i) = 0 then
            return 0;
        end if;
    end loop;
    return 1;
end;

select prim(2), prim(3), prim(5), prim(6), prim(7) from dual;

/* Write a procedure which prints out the n-th Fibonacchi number. 
   fib1 = 0, fib2 = 1, fib3 = 1, fib4 = 2 ... etc.
*/

create or replace procedure fib(n integer) is
    v1 integer := 0;
    v2 integer := 1;
    v_next integer := 0;
begin
    if n = 1 then
        v_next := v1;
    elsif n = 2 then
        v_next := v2;
    end if;
    for i in 3..n loop
        v_next := v1 + v2;
        v1 := v2;
        v2 := v_next;
    end loop;
    dbms_output.put_line(TO_CHAR(v_next));
end;

call fib(1);

/* Write a function which returns the greatest common divisor of two integers */

CREATE OR REPLACE FUNCTION gcd(p1 integer, p2 integer) RETURN number IS
    i int;
begin
    for i in reverse 1..p1 loop
        if MOD(p1, i) = 0 and mod(p2, i) = 0 then
            return i;
        end if;
    end loop;
end;

select gcd(80, 100) from dual;

/* Write a function which returns the number of times the first string parameter contains 
   the second string parameter. 
*/
CREATE OR REPLACE FUNCTION num_times(p1 VARCHAR2, p2 VARCHAR2)
RETURN integer IS
    i int;
    res int := 0;
BEGIN
    FOR i IN 1..(length(p1) - length(p2) + 1) LOOP
         IF substr(p1, i, length(p2)) = p2 THEN
            res := res + 1;
        END IF;
    END LOOP;
    RETURN res;
END;

select substr('something', 5, 5) from dual;

select num_times('ab c ab ab de ab fg a', 'ab') from dual;

/* Write a function which returns the sum of the numbers in its string parameter.
   The numbers are separated with a '+'.
*/
CREATE OR REPLACE FUNCTION sum_of(p_char VARCHAR2) RETURN number IS
    res int := 0;
    i int;
    subs varchar(10);
begin
    for i in 1..length(p_char) loop
        if substr(p_char, i, 1) != '+' then
            -- || alt gr + w
            subs := subs || substr(p_char, i, 1);
        else
            res := res + TO_NUMBER(subs);
            subs := '';
        end if;
    end loop;
    res := res + TO_NUMBER(subs);
    return res;
end;

select sum_of('1+2+3') from dual;
