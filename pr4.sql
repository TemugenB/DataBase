-- 1. Give the maximal salary.
SELECT max(sal) FROM emp;

-- 2. Give the sum of all salaries.
SELECT sum(sal) FROM emp;

-- 3. Give the summarized salary and average salary in department 20.
SELECT sum(sal), avg(sal) FROM emp WHERE deptno=20;

-- 4. Count how many different jobs exist in the emp table.
SELECT count(DISTINCT job) FROM emp;

-- 5. Count how many employees have a salary greater than 2000.
SELECT count(*) FROM emp WHERE sal > 2000;

-- 6. Give the average salary for each department. (deptno, avg_sal)
SELECT deptno, round(avg(sal)) FROM emp GROUP BY deptno;

-- 7. Give the location and average salary for each department. (deptno, loc, avg_sal)
SELECT d.deptno, loc, round(avg(sal)) 
FROM emp e, dept d
WHERE d.deptno=e.deptno 
GROUP BY d.deptno, loc;

-- Alternative syntax using NATURAL JOIN
SELECT deptno, loc, round(avg(sal)) 
FROM emp NATURAL JOIN dept 
GROUP BY deptno, loc;

-- 8. Count the number of employees per department. (deptno, num_emp)
SELECT deptno, count(empno) FROM emp GROUP BY deptno;

-- 9. Give departments where the average salary is greater than 2000. (deptno, avg_sal)
SELECT deptno, avg(sal) FROM emp GROUP BY deptno HAVING avg(sal) > 2000;

-- 10. Give departments with at least 4 employees and their average salary. (deptno, avg_sal)
SELECT deptno, avg(sal) FROM emp GROUP BY deptno HAVING count(empno) >= 4;

-- 11. Give departments with at least 4 employees, showing average salary and location.
SELECT d.deptno, loc, avg(sal) FROM emp e, dept d
WHERE d.deptno=e.deptno 
GROUP BY d.deptno, loc HAVING count(empno) >= 4;

-- 12. List the name and location of departments where average salary is greater than 2000. (dname, loc)
SELECT dname, loc FROM emp d, dept o
WHERE d.deptno=o.deptno 
GROUP BY dname, loc HAVING avg(sal) >= 2000;

-- 13. List salary categories that have exactly 3 employees in them.
SELECT category FROM emp, sal_cat
WHERE sal BETWEEN lowest_sal AND highest_sal
GROUP BY category HAVING count(*) = 3;

-- Alternative syntax using JOIN ON
SELECT category FROM emp JOIN sal_cat ON (sal BETWEEN lowest_sal AND highest_sal)
GROUP BY category HAVING count(*) = 3;

-- 14. List salary categories where all employees in that category are from the same department.
SELECT category FROM emp, sal_cat
WHERE sal BETWEEN lowest_sal AND highest_sal
GROUP BY category HAVING count(distinct deptno) = 1;

-- 15. Count how many employees have even vs odd empno values. (parity, num_of_emps)
SELECT decode(mod(empno, 2), 0, 'even', 1, 'odd') parity, count(empno) num_of_emps 
FROM emp GROUP BY mod(empno, 2);

-- 16. For each job, show number of employees, average salary, and a string made of '#' symbols 
--     where each '#' represents 200 units of average salary.
SELECT job, count(empno), round(avg(sal)),
      rpad('#', round(avg(sal)/200), '#') 
FROM emp GROUP BY job;
