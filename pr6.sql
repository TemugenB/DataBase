create table emp_tmp as (select * from emp)

create table dept_tmp as (select * from dept)

-- 1
delete from emp_tmp where comm is null

-- 2
delete from emp_tmp where 1982 > EXTRACT(year from hiredate)

-- 3
delete from emp_tmp
where deptno in (select deptno from dept where loc = 'DALLAS') ;

-- 4
DELETE FROM EMP_TMP WHERE SAL < (SELECT AVG(SAL) FROM EMP_TMP);

-- 5
DELETE FROM EMP_TMP e1 WHERE SAL < 
(SELECT AVG(SAL) FROM EMP_TMP e2 WHERE e1.deptno = e2.deptno);

-- 6
delete from emp_tmp where sal = (select max(sal) from emp_tmp)

-- 8
select * from nikovits.sal_cat;

DELETE FROM DEPT_TMP WHERE DEPTNO IN
(SELECT DEPTNO FROM EMP_TMP JOIN SAL_CAT ON SAL BETWEEN LOWEST_SAL AND HIGHEST_SAL 
WHERE CATEGORY=2 GROUP BY DEPTNO HAVING COUNT(*)>=2)

-- 9
insert into emp_tmp (empno, ename, deptno, hiredate, sal)
values (1, 'Williams', 10, SYSDATE, (select round(avg(sal)) from emp_tmp where deptno = 10 ));

-- 10
UPDATE EMP_TMP SET SAL=SAL*1.2 WHERE DEPTNO=20;

-- 11
update emp_tmp set sal = sal+500 where comm is null or sal < (select avg(sal) from emp_tmp);

-- 12
UPDATE EMP_TMP SET COMM=(NVL(COMM, 0) + (SELECT MAX(COMM) FROM EMP_TMP));

-- 13
update emp_tmp set ename = 'Poor' where sal = (select min(sal) from emp_tmp); 

-- 14
update emp_tmp set COMM=(NVL(COMM, 0) + 3000) where empno in
(select mgr from emp_tmp group by mgr having count(*)>=2);

-- 15
update emp_tmp set sal=(sal + (select min(sal) from emp_tmp)) where empno in
(select mgr from emp_tmp);

-- 16

update emp_tmp e1 set e1.sal=(e1.sal + 
(select avg(sal) from emp_tmp e2 where e1.deptno=e2.deptno)) 
where e1.empno in
(select empno from emp_tmp
minus
select mgr from emp_tmp);

ROLLBACK
