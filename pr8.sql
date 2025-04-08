/* SELECT ... INTO ...
Write a procedure which prints out the number of employees and average salary of the employees 
whose hiredate was the day which is the parameter of the procedure (e.g. 'Monday'). 
*/
select count(*), avg(sal)
from emp
where to_char(hiredate, 'Day', 'nls_date_language=english') 
            like 'Thursday%';

CREATE OR REPLACE PROCEDURE day_avg(d varchar2) IS
    v_count integer;
    v_avg number;
begin
    select count(*), round(avg(sal), 2)
    into v_count, v_avg
    from emp
    where to_char(hiredate, 'Day', 'nls_date_language=english') 
                like d || '%';
    dbms_output.put_line('Number of emps: ' || v_count
                                        || ', Average sal: ' || v_avg);
end;

set serveroutput on
execute day_avg('Thursday');

/*Cursor
Write a procedure which takes the employees working on the parameter department
in alphabetical order, and prints out the jobs of the employees in a concatenated string.
*/
CREATE OR REPLACE PROCEDURE print_jobs(d_name varchar2) IS
    cursor emp_curs is
        select job
        from nikovits.emp natural join nikovits.dept
        where dname = d_name
        order by ename;
    emp_rec emp_curs%rowtype;
    jobs varchar(100) := '';
begin
    open emp_curs;
    loop
        fetch emp_curs into emp_rec;
        if emp_curs%notfound then
            jobs := substr(jobs, 1, length(jobs) - 1);
            exit;
        end if;
        jobs := jobs || emp_rec.job || '-';
    end loop;
    dbms_output.put_line(jobs);
end;

call print_jobs('ACCOUNTING');

/* Insert, Delete, Update
Write a procedure which increases the salary of the employees who has salary category p (p is parameter).
The increment should be the minimal salary of the employee's own department.
After executing the update statement, the procedure should print out the average salary of the employees.
*/
create table practice9
as select * from nikovits.emp;

CREATE OR REPLACE PROCEDURE upd_cat(p integer) IS
    cursor emp_curs is
        select *
        from practice9 join nikovits.sal_cat
        on sal between lowest_sal and highest_sal
        where category = p
        for update of sal;
    v_avg number;
    v_minsal integer;
begin
    for emp_rec in emp_curs loop
        select min(sal) into v_minsal from practice9
            where deptno = emp_rec.deptno;
        update practice9 p
        set sal = sal + v_minsal
        where current of emp_curs;
    end loop;
    select round(avg(sal), 2) into v_avg
    from practice9;
    dbms_output.put_line(v_avg);
end; 

select *
        from practice9 join nikovits.sal_cat
        on sal between lowest_sal and highest_sal
        where category = 4;

set serveroutput on
execute upd_cat(2);

commit;

/* Associative Array
Write a procedure which takes the first n (n is the parameter) prime numbers and puts them into 
an associative array. The procedure should print out the last prime and the total sum of the prime numbers.
*/
CREATE OR REPLACE PROCEDURE primes(n integer) IS
    type prime_table_type is table of integer
    index by binary_integer;
    v_prime_table prime_table_type;
    v_sum integer := 0;
    i integer := 2;
begin
    loop
        if prim(i) = 1 then
            v_prime_table(v_prime_table.count + 1) := i;
            v_sum := v_sum + i;
        end if;
        if v_prime_table.count = n then
            exit;
        end if;
        i := i + 1;
    end loop;
    dbms_output.put_line(v_prime_table(v_prime_table.last) || ' ' || v_sum);
end;

execute primes(100);

/* Cursor and associative array
Write a plsql procedure which takes the employees in alphabetical order
and puts every second employee's name (1st, 3rd, 5th etc.) and salary into an associative array.
The program should print out the last but one (the one before the last) values from the array.
*/
CREATE OR REPLACE PROCEDURE curs_array IS
    cursor emp_cursor is
        select ename, sal from emp order by ename;
    emp_cursor_rec emp_cursor%rowtype;
    type emp_cursor_array is table of emp_cursor%rowtype
    index by binary_integer;
    v_emp_cursor_array emp_cursor_array;
begin
    for emp_cursor_rec in emp_cursor loop
        if mod(emp_cursor%rowcount, 2) = 1 then
            v_emp_cursor_array(v_emp_cursor_array.count + 1) 
                        := emp_cursor_rec;
        end if;
    end loop;
    dbms_output.put_line(v_emp_cursor_array(v_emp_cursor_array.count-1).ename
                            || ' ' || v_emp_cursor_array(v_emp_cursor_array.count-1).sal);
end;

set serveroutput on
execute curs_array();
