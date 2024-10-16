--#region employees not assigned to departments

declare
  @cnt int = 6,
  @id int

while @cnt > 0
begin
  set @id = (select top 1 id from dbo.employees_departments order by newid())

  delete from dbo.employees_departments
  where id = @id

  set @cnt = @cnt - 1
end

/*
select * from employees
select * from employees_departments
select * from employees where employee_id not in (select employee_id from employees_departments)
*/

--#endregion



