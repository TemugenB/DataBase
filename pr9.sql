/* Update with cursor
Write a procedure which updates the salaries on a department (parameter: department number).
The update should increase the salary with n*10000, where n is the number of vowels (A,E,I,O,U)
in the name of the employee. (For ALLEN it is 2, for KING it is 1.)
The procedure should print out the name and new salary of the modified employees.
*/

CREATE OR REPLACE PROCEDURE curs_upd(p_deptno INTEGER) IS
    cursor upd_emp_cursor is
        select ename, sal from emp where deptno = p_deptno for update;
    nr_vowels int;
begin
    for rec in upd_emp_cursor loop
        nr_vowels := 0;
        for i in 1..length(rec.ename) loop
            if substr(rec.ename, i, 1) in ('A', 'E', 'I', 'O', 'U') then
                nr_vowels := nr_vowels + 1;
            end if;
        end loop;
        update emp set sal = sal + nr_vowels * 10000 
            where current of upd_emp_cursor;
    end loop;
    for rec in upd_emp_cursor loop
        dbms_output.put_line(rec.ename || ' - ' || rec.sal);
    end loop;
    rollback;
end;

set serveroutput on
execute curs_upd(10);


/* (exception)
Write a function which gets a date parameter in one of the following formats: 
'yyyy.mm.dd' or 'dd.mm.yyyy'. The function should return the name of the 
day, e.g. 'Tuesday'. If the parameter doesn't match any format, the function
should return 'wrong format'.
*/
CREATE OR REPLACE FUNCTION day_name(d varchar2) RETURN varchar2 IS
...
SELECT day_name('2017.05.01'), day_name('02.05.2017'), day_name('abc') FROM dual;

Hint: Try to convert the string to date and handle the exception if the conversion fails.

CREATE OR REPLACE FUNCTION day_name(d varchar2) RETURN varchar2 IS
    full_year_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(full_year_exception, -01841);
begin
    declare
        date_format_exception EXCEPTION;
        PRAGMA EXCEPTION_INIT(date_format_exception, -01830);
    begin
        return to_char(to_date(d, 'yyyy.mm.dd'), 'Day', 'nls_date_language=english');
    exception
        when date_format_exception then
            return to_char(to_date(d, 'dd.mm.yyyy'), 'Day', 'nls_date_language=english');
    end;
exception
    when full_year_exception then
        return 'wrong format';
    when others then
        return 'whatever exception';
end;

SELECT day_name('2024.04.24'), day_name('24.04.2024'), day_name('abc') 
FROM dual;


/* (exception, SQLCODE)
Write a procedure which gets a number parameter and prints out the reciprocal,
the sqare root and the factorial of the parameter in different lines. 
If any of these outputs is not defined or causes an overflow, the procedure should 
print out 'not defined' or the error code (SQLCODE) for this part.
(The factorial is defined only for nonnegative integers.)
*/
CREATE OR REPLACE PROCEDURE numbers(n number) IS
...
set serveroutput on
execute numbers(0);
execute numbers(-2);
execute numbers(40);

CREATE OR REPLACE PROCEDURE numbers(n number) IS
begin
    begin
        dbms_output.put_line('Recprocal: ' || to_number(1/n));
    EXCEPTION
        when ZERO_DIVIDE then
            dbms_output.put_line(SQLCODE || ': Error at calculating reciprocal:' 
                                    || ' tried to divide by zero ');
        when others then
            dbms_output.put_line(SQLCODE || ': Error at calculating reciprocal: ' 
                                    || SQLERRM);
    end;
    begin
        dbms_output.put_line('Square root: ' || sqrt(n));
    exception
        when VALUE_ERROR then
            dbms_output.put_line(SQLCODE || ': Error at calculating square root:' 
                                    || ' value error ');
        when others then
            dbms_output.put_line(SQLCODE || ': Error at calculating square root: ' 
                                    || SQLERRM);
    end;
    declare
        NEGATIVE_VALUE_EXCEPTION EXCEPTION;
    begin
        if n<0 then
            raise NEGATIVE_VALUE_EXCEPTION;
        else
            dbms_output.put_line('Factorial: ' || factor(n));
        end if;
    exception
        when NEGATIVE_VALUE_EXCEPTION then
            dbms_output.put_line(SQLCODE || ': Error at calculating factorial:' 
                                    || ' negative value error ');
        when others then
            dbms_output.put_line(SQLCODE || ': Error at calculating factorial: ' 
                                    || SQLERRM);
    end;
end;

set serveroutput on
execute numbers(0);
execute numbers(-2);
execute numbers(40);


/* (exception)
Write a function which returns the sum of the numbers in its string parameter.
The numbers are separated with a '+'. If any expression between the '+' characters
is not a number, the function should consider this expression as 0.
*/
CREATE OR REPLACE FUNCTION sum_of2(p_char VARCHAR2) RETURN number IS
Test:
SELECT sum_of2('1+21 + bubu + + 2 ++') FROM dual;

Hint: try to convert the expressions to number, and handle the exception

CREATE OR REPLACE FUNCTION sum_of2(p_char VARCHAR2) RETURN number IS
    v_sum int := 0;
    v_substring varchar(10);
begin
    for i in 1..length(p_char) loop
        if substr(p_char, i, 1) != '+' then
            v_substring := v_substring || substr(p_char, i, 1);
        else
            begin
                if TO_NUMBER(v_substring) is null then
                    raise VALUE_ERROR;
                else
                    v_sum := v_sum + TO_NUMBER(v_substring);
                end if;
            exception
                when others then
                    v_sum := v_sum;
            end;
            v_substring := '';
        end if;
    end loop;
    begin
        if TO_NUMBER(v_substring) is null then
            raise VALUE_ERROR;
        else
            v_sum := v_sum + TO_NUMBER(v_substring);
        end if;
    exception
        when others then
            v_sum := v_sum;
    end;
    return v_sum;
end;

SELECT sum_of2('1+21 + bubu + y1 + 2 + -1 ++') FROM dual;
