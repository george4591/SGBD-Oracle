user defined exception

declare
    exception_name exception;
    ....
begin
    ....
    raise exception_name;
    ....
    exception
    when exception_name then
    statements ...
end;
/

-- STEP 1 (Raise an exception when the PL/SQL block it's executed until 5PM)
set serveroutput on
declare
    e_ex exception;
begin
    if to_number(to_char(sysdate, 'HH24')) <= 17 then
        raise e_ex;
    end if;
    exception
    when e_ex then
    dbms_output.put_line('It''s ' || to_number(to_char(sysdate, 'HH24')));
    dbms_output.put_line('Operation is not yet allowed!');
end;

-- STEP 2 (create an oracle code for the exception)
set serveroutput on
declare
    e_ex exception;
    pragma exception_init(e_ex, -20600); -- between 20999 and -20000
begin
    if to_number(to_char(sysdate, 'HH24')) <= 17 then
        raise_application_error(-20600,'error message');
    end if;
    exception
    when e_ex then
    dbms_output.put_line('It''s ' || to_number(to_char(sysdate, 'HH24')));
    dbms_output.put_line('Operation is not yet allowed!');
    dbms_output.put_line(sqlerrm); --used for display ORA code
end;

SUBPROGRAMS AND FUNCTIONS

Structure of a subprogram
 - header (name of the subprogram, parameters)
 - body (contains a set of statements)
 - end (an instruction that is meant to exist the subprogram and return the output)
 
Formal parameters:
  - IN (parameters that we are using for the input)
  - OUT (output parameters)
  - IN OUT (input output variables)
  
1) Display the 1st 3 products by a category given, and order by list price
create or replace procedure
    display_categ(categ number)
is
    cursor c is select product_name from product_information
    where category_id = categ and list_price is not null
    order by list_price;
begin
    for r in c loop
    exit when c%rowcount > 3;
    dbms_output.put_line(r.product_name);
    end loop;
end;
/
--the call of the subprogram
begin
    display_categ(15);
end;

-- IN (parameters that we are using for the input)
 2) Create a SP that modifies the salary of an employee whose id is given.
 Also the % of salary is given as a parameter.
 
 create or replace procedure
 modify_salary(v_employee_id IN number, percent number)
 is v_salary number;
 begin
    select salary into v_salary from employees where employee_id = v_employee_id;
    dbms_output.put_line('The before update salary: ' || v_salary);
    update employees
    set salary = salary * (1+ percent/100)
    where employee_id = v_employee_id;
    select salary into v_salary from employees where employee_id = v_employee_id;
    dbms_output.put_line('The after update salary: ' || v_salary);
 end;
 
 --the call of the subprg
 CALL modify_salary(176, 10);
 --or
 EXECUTE modify_salary(176, 10);
 --or 
 begin
    modify_salary(176, 10);
 end;
 
 -- OUT parameters subprg
 3) Create a subprg that returns the name, salary of an employee whose id is given.
 create or replace procedure
 proc_employee(p_employee_id IN number, p_name OUT varchar2, p_salary OUT number)
 is 
 begin
    select first_name, salary into p_name, p_salary from employees
    where employee_id = p_employee_id;
 end;
 
 -- the call of the subprg
 declare
    v_name varchar2(50);
    v_salary number;
 begin
    proc_employee(150, v_name, v_salary);
    dbms_output.put_line('The employee '|| v_name || ' has the salary ' ||v_salary);
 end;
 
 -- Create a subprog that calculates the avg salary and returns it.
 create or replace procedure salary_average(average out number) is
 begin
    select avg(salary) into average from employees;
 end;
 
declare
    average_salary number;
begin
  salary_average(average_salary);
  dbms_output.put_line('The average salary is: ' || average_salary);
end;
    
 
 
