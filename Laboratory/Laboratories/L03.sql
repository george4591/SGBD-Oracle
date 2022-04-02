select department_name from departments d join employees e
on d.department_id = e.department_id;

select department_name from departments d join employees e
on d.department_id = e.department_id
group by department_name;

select department_name, department_id from departments d 
where d.department_id in (select department_id from employees);

select distinct d.department_name, d.department_id
from departments d join employees e
on d.department_id = e.department_id
order by department_id;

Cursors:
explict: 
1. for loop, loop, inline cursor
2. cursors with parameters, cursors with for update (today)

--1) Display the department name for those that have emploiyees. 
--Under each department diplay the employees names.

-- STEP 1 (write sql code)
select department_name from departments d
join employees e on d.department_id = e.department_id;

--STEP 2
select department_name from departments d
join employees e on d.department_id = e.department_id
group by department_name;

-- without join (with a subquery)

select department_name from departments d where department_id in
(select department_id from employees);

--STEP 3
select distinct d.department_name, d.department_id from departments d
join employees e on d.department_id = e.department_id
order by department_id;

select first_name, last_name from employees where department_id = 10;
select first_name, last_name from employees where department_id = 20;
select first_name, last_name from employees where department_id = 30;
-- STEP 4 (PL/SQL)
Administration
    Jennifer Whalen
Nb employees: 1
Marketing
    Michael	Hartstein
    Pat	Fay
Nb employees: 2
Purchasing
    Den	Raphaely
    Alexander Khoo
    Shelli Baida
    Sigal Tobias
    Guy	Himuro
    Karen Colmenares
Nb employees: 6
Total nb of employees: 9

set serveroutput on
declare
    cursor d is select distinct d.department_name, d.department_id from departments d
    join employees e on d.department_id = e.department_id
    order by department_id;
    
    cursor e(p_id number) is select first_name, last_name from employees 
    where department_id = p_id;
begin
    for r1 in d loop
        dbms_output.put_line(r1.department_name);
    end loop;
end;
/

--STEP 5 (display employees foreach department)
set serveroutput on
declare
    cursor d is select distinct d.department_name, d.department_id from departments d
    join employees e on d.department_id = e.department_id
    order by department_id;
    
    cursor e(p_id number) is select first_name, last_name from employees 
    where department_id = p_id;
begin
    for r1 in d loop
        dbms_output.put_line(r1.department_name);
        for r2 in e(r1.department_id) loop
            dbms_output.put_line('       ' || r2.first_name || ' ' || r2.last_name );
        end loop;
    end loop;
end;
/

-- Display the number of employees foreach department and in the end the total (no of emp)
set serveroutput on
declare
    cursor d is select distinct d.department_name, d.department_id from departments d
    join employees e on d.department_id = e.department_id
    order by department_id;
    
    cursor e(p_id number) is select first_name, last_name from employees 
    where department_id = p_id;
    
    emp number := 0;
    total number := 0;
    
begin
    for r1 in d loop
        dbms_output.put_line(r1.department_name);
        --emp : =0;
        for r2 in e(r1.department_id) loop
            dbms_output.put_line('       ' || r2.first_name || ' ' || r2.last_name );
            emp := emp+1;
        end loop;
        dbms_output.put_line('Nb of employees: ' || emp);
        dbms_output.put_line('');
        total := total + emp;
    end loop;
    dbms_output.put_line('Total: ' || total);
end;
/

--STEP 6 (with count)
set serveroutput on
declare
    cursor d is select distinct d.department_name,d.department_id,count(*) nb from departments d
                join employees e on d.department_id = e.department_id
                group by d.department_id,d.department_name
                order by department_id;
    cursor e(p_id number) is select first_name, last_name from employees where department_id=p_id;
    emp number := 0;
    total number := 0;
begin
    for r1 in d loop
        dbms_output.put_line(r1.department_name);
        for r2 in e(r1.department_id) loop  
            dbms_output.put_line( '         '||r2.first_name||' '|| r2.last_name);
            emp:=emp+1;        
        end loop;
        dbms_output.put_line('No of employees: '||r1.nb);
        total:=total+r1.nb;    
    end loop;    
        dbms_output.put_line('Total: ' ||total);
end;


-- STEP 7 (with inline cursor)
set serveroutput on
declare
    cursor d is select distinct d.department_name,d.department_id,count(*) nb from departments d
                join employees e on d.department_id = e.department_id
                group by d.department_id,d.department_name
                order by department_id;
    
    total number := 0;
begin
    for r1 in d loop
        dbms_output.put_line(r1.department_name);
        for r2 in (select first_name, last_name 
                    from employees 
                    where department_id = r1.department_id)
        loop  
            dbms_output.put_line( '         '||r2.first_name||' '|| r2.last_name);
        end loop;
        dbms_output.put_line('No of employees: '||r1.nb);
        total:=total+r1.nb;    
    end loop;    
        dbms_output.put_line('Total: ' ||total);
end;
/

-- FOR UPDATE

-- 1) without for update
--Raise the salary with 5%.
set serveroutput on
declare
    cursor c is select employee_id, salary 
    from employees where department_id=50;
    
    sal_before number;
    sal_after number;
begin
    select sum(salary) into sal_before from employees where department_id = 50;
    
    for r in c loop
        update employees set salary = salary * 1.05
        where employee_id = r.employee_id;
    end loop;
    
    select sum(salary) into sal_after from employees where department_id = 50;
    dbms_output.put_line(sal_before || '->' || sal_after);
    rollback; 
end;
/

-- for update (waiting all the jobs and then doing changes on the table that i need 
--or do the job now, and after run all the other jobs, for not having inconsistencies
--)

--STEP 2 (with for update)
set serveroutput on
declare
    cursor c is select employee_id, salary 
    from employees where department_id=50 for update;
    
    sal_before number;
    sal_after number;
begin
    select sum(salary) into sal_before from employees where department_id = 50 ;
    
    for r in c loop -- rows from the cursor will be locked for update
        update employees set salary = salary * 1.05
        where employee_id = r.employee_id;
    end loop; --  rows will be released from the cursor
    
    select sum(salary) into sal_after from employees where department_id = 50;
    dbms_output.put_line(sal_before || '->' || sal_after);
    rollback; 
end;
/

nowait
wait (number) ex: wait 5

set serveroutput on
declare
    cursor c is select employee_id, salary 
    from employees where department_id=50 for update nowait; -- don't wait for other jobs
    -- rows will be locked automatically imediatelly
    
    sal_before number;
    sal_after number;
begin
    select sum(salary) into sal_before from employees where department_id = 50 ;
    
    for r in c loop -- rows from the cursor will be locked for update
        update employees set salary = salary * 1.05
        where employee_id = r.employee_id;
    end loop; --  rows will be released from the cursor
    
    select sum(salary) into sal_after from employees where department_id = 50;
    dbms_output.put_line(sal_before || '->' || sal_after);
    rollback; 
end;
/

set serveroutput on
declare
    cursor c is select employee_id, salary 
    from employees where department_id=50 for update wait 5;
    
    sal_before number;
    sal_after number;
begin
    select sum(salary) into sal_before from employees where department_id = 50 ;
    
    for r in c loop -- rows from the cursor will be locked for update
        update employees set salary = salary * 1.05
        where employee_id = r.employee_id;
    end loop; --  rows will be released from the cursor
    
    select sum(salary) into sal_after from employees where department_id = 50;
    dbms_output.put_line(sal_before || '->' || sal_after);
    rollback; 
end;
/
