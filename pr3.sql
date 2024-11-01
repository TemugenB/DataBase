--List the employees whose salary is divisible by 15.
SELECT ename
FROM emp 
WHERE mod(sal, 15)=0;

--List the employees, whose hiredate is greater than 1982.01.01. 
SELECT ename
FROM emp 
WHERE hiredate > to_date('1982.01.01', 'yyyy.mm.dd');

--List the employees where the second character of his name is 'A'. 
SELECT ename
FROM emp 
WHERE substr(ename,2,1) = 'A';

--List the employees whose name contains two 'L'-s.
SELECT ename
FROM emp 
WHERE instr(ename,'L',1,2) > 0;

--List the emloyees whose name has a 'T' in the last but one position (position before the last).
SELECT ename
FROM emp 
WHERE substr(ename,-2,1) = 'T';

--List the square root of the salaries rounded to 2 decimals and the integer part of it.
SELECT round(sqrt(sal),2), trunc(round(sqrt(sal),2))
FROM emp;

--In which month was the hiredate of ADAMS? (give the name of the month)
SELECT to_char(hiredate, 'month')
FROM emp WHERE ename = 'ADAMS';

--Give the number of days since ADAMS's hiredate. 
SELECT trunc(sysdate - hiredate) 
FROM emp WHERE ename = 'ADAMS';

--List the employees whose hiredate was Tuesday. 
alter session set nls_date_language='english';

SELECT ename,
FROM emp WHERE to_char(hiredate, 'day') LIKE '%tuesday%';

--Give the manager-employee name pairs where the length of the two names are equal.
SELECT e1.ename, e2.ename mgr_name
FROM emp e1, emp e2
WHERE e1.mgr = e2.empno AND length(e1.ename) = length(e2.ename);

--List the employees whose salary is in category 1. 
SELECT emp.ename FROM emp, sal_cat
WHERE emp.sal BETWEEN lowest_sal AND highest_sal AND category=1;

--List the employees whose salary category is an even number.
SELECT emp.ename FROM emp, sal_cat
WHERE emp.sal BETWEEN lowest_sal AND highest_sal AND mod(category, 2) = 0;

--Give the number of days between the hiredate of KING and the hiredate of JONES.
SELECT e1.hiredate - e2.hiredate
FROM emp e1, emp e2
WHERE e1.ename = 'KING' AND e2.ename= 'JONES';

--Give the name of the day (e.g. Monday) which was the last day of the month in which KING's hiredate was.
SELECT to_char(last_day(hiredate), 'day')
FROM emp WHERE ename = 'KING';

--Give the name of the day (e.g. Monday) which was the first day of the month in which KING's hiredate was. (trunc function)
SELECT to_char(trunc(hiredate, 'month'), 'day')
FROM emp WHERE ename = 'KING';


--Give the names of employees whose department name contains a letter 'C' and whose salary category is >= 4.
SELECT ename, dname FROM emp
JOIN dept ON emp.deptno = dept.deptno
JOIN sal_cat ON sal BETWEEN lowest_sal AND highest_sal 
WHERE dname LIKE '%C%' AND category >=4;

--List the name and salary of the employees, and a charater string where one '#' denotes 1000 (rounded). (So if the salary is 1800 then print -> '##', because 1800 rounded to thousands is 2.) 
SELECT ename, sal, rpad('#', round(sal, -3)/1000, '#')
FROM emp;