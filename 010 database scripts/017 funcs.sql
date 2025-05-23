--#region gv_rand

if exists (select * from sys.objects where name = 'v_rand' and objectproperty(object_id, 'IsView') = 1)
  drop view v_rand
go

/*
16.10.2024 VladimirG; created
*/

create view v_rand
as
  select checksum(newid()) as rnd
go

--#endregion v_rand



--#region fn_random_chars

if exists (select * from dbo.sysobjects where id = object_id(N'fn_random_chars') and xtype in (N'FN', N'IF', N'TF'))
  drop function fn_random_chars
go

/*
16.10.2024 VladimirG; created
*/

create function fn_random_chars(@len int, @lowercase bit, @uppercase bit, @numbers bit)
  returns varchar(1000)
as
begin
  return (
    isnull((select (
      select top (@len)
        '' + char(n.num)
      from dbo.numbers n
      cross join dbo.numbers n1
      where 1 = 1
        and (
          (@numbers = 1 and n.num between 48 and 57)
          or (@uppercase = 1 and n.num between 65 and 90)
          or (@lowercase = 1 and n.num between 97 and 122)
        )
        and n1.num < 10
      order by (select rnd from v_rand) for xml path('')
    )), '')
  )
end
go

--#endregion fn_random_chars



--#region fn_random_num

if exists (select * from dbo.sysobjects where id = object_id(N'fn_random_num') and xtype in (N'FN', N'IF', N'TF'))
  drop function fn_random_num
go

/*
Returns random number between 0 and 100000
16.10.2024 VladimirG; created
*/

create function fn_random_num(@limit int)
  returns int
as
begin
  return (select top 1 num - 1 from dbo.numbers where num - 1 <= @limit order by (select rnd from v_rand))
end
go


--#endregion fn_random_num
