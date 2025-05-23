use master
go

if not exists (select * from sys.databases where name = 'candidates')
  create database candidates
go

use candidates
go


-- #region drop existing
/*
select 'drop table dbo.' + table_name from information_schema.tables where table_name not like '[_]rnd[_]%' and table_name != 'numbers'

drop table dbo.admin_settings
drop table dbo.numbers
drop table dbo.exchange_rates
drop table dbo.employees_departments
drop table dbo.departments
drop table dbo.payments
drop table dbo.invoices
drop table dbo.amort_plan
drop table dbo.contracts
drop table dbo.currencies
drop table dbo.customers
drop table dbo.employees
drop table dbo.countries
*/
-- #endregion



--#region admin_settings

if not exists (select * from information_schema.tables where table_name = 'admin_settings' and table_schema = 'dbo')
  create table dbo.admin_settings
  (
    id int identity(1,1) not null
      constraint PK_admin_settings
        primary key,
    code varchar(100) not null,
    description varchar(1000) null,
    val_string nvarchar(max) null,
    val_int int null,
    val_decimal decimal(20,4) null,
    val_datetime datetime null,
    val_bit bit null,
    ts datetime not null
      constraint DF_admin_settings_ts
        default (getdate())
  )
go

--#endregion admin_settings



-- #region table employees

if not exists (select * from information_schema.tables where table_name='employees' and table_schema = 'dbo')
  create table dbo.employees
  (
    employee_id int identity(1,1) not null
      constraint PK_employees
        primary key,
    name varchar(500) null,
    username varchar(100) null,
    email varchar(500) null,
    active_from datetime null,
    active_to datetime null,
    ts datetime not null
      constraint DF_employees_ts
        default (getdate())
  )
go

-- #endregion


--#region departments

if not exists (select * from information_schema.tables where table_name = 'departments' and table_schema = 'dbo')
  create table dbo.departments
  (
    department_id int identity(1,1) not null
      constraint PK_departmetns
        primary key,
    name varchar(500),
    description varchar(1000),
    ts datetime not null
      constraint DF_departments_ts
        default (getdate())
  )
go

--#endregion departments



--#region employees_departments

if not exists (select * from information_schema.tables where table_name = 'employees_departments' and table_schema = 'dbo')
  create table dbo.employees_departments
  (
    id int identity(1,1) not null
      constraint PK_employees_departments
        primary key,
    employee_id int not null
      constraint FK_employees_departments_employees_employees
        foreign key references dbo.employees,
    department_id int not null
      constraint FK_employees_departments_departments
        foreign key references dbo.departments,
    active_from datetime not null,
    active_to datetime null,
    ts datetime not null
      constraint DF_employees_departments_ts
        default (getdate())
  )
go

--#endregion employees_departments



-- #region table countries

if not exists (select * from information_schema.tables where table_name = 'countries' and table_schema = 'dbo')
  create table dbo.countries
  (
    country_code varchar(2) not null
      constraint PK_countries
        primary key,
    country_name varchar(100) not null,
    eu_member bit not null
      constraint DF_countries_eu_member
        default (0),
    ts datetime not null
      constraint DF_countries_ts
        default (getdate())
  )
go

-- #endregion countries



-- #region table customers

if not exists (select * from information_schema.tables where table_name='customers' and table_schema = 'dbo')
  create table dbo.customers
  (
    customer_id int identity(1,1) not null
      constraint PK_customers
        primary key,
    short_name varchar(100) not null,
    full_name varchar(1000) null,
    registration_number varchar(20) null,
    tax_number varchar(20) null,
    street varchar(70) not null,
    postal_code varchar(10) null,
    country_code varchar(2) null
      constraint FK_customers_countries_country_code
        foreign key references dbo.countries,
    email varchar(200) null,
    customer_type varchar(100) null,
    assigned_employee_id int null
      constraint FK_customers_assigned_employee_id
        foreign key references dbo.employees,
    inactive bit not null
      constraint DF_customers_inactive
        default (0),
    ts datetime not null
      constraint DF_customers_ts
        default (getdate())
  )
go

-- #endregion



-- #region currencies

if not exists (select * from information_schema.tables where table_name = 'currencies' and table_schema = 'dbo')
  create table dbo.currencies
  (
    currency_code varchar(3)
      constraint PK_currencies
        primary key,
    name varchar(100) not null,
    international_code varchar(10) null,
    country_code varchar(2) null
      constraint FK_currencies_country_code
        foreign key references dbo.countries,
    inactive bit not null
      constraint DF_currencies_inactive
        default (0),
    ts datetime not null
      constraint DF_currencies_ts
        default (getdate())
  )
go

-- #endregion


--#region exchange_rates

if not exists (select * from information_schema.tables where table_name = 'exchange_rates' and table_schema = 'dbo')
  create table dbo.exchange_rates
  (
    currency_from varchar(3) not null
      constraint FK_exchange_rates_currency_from
        foreign key references dbo.currencies,
    currency_to varchar(3) not null
      constraint FK_exchange_rates_currency_to
        foreign key references dbo.currencies,
    exchange_rate decimal(18,4) not null,
    exchange_rate_date date not null,
    constraint PK_exchange_rates
      primary key (currency_from, currency_to, exchange_rate_date),
    ts datetime not null
      constraint DF_exchange_rates_ts
        default (getdate())
  )
go

--#endregion exchange_rates



-- #region contracts

if not exists (select * from information_schema.tables where table_name='contracts' and table_schema = 'dbo')
  create table dbo.contracts
  (
    contract_id int identity(1,1) not null
      constraint PK_contracts_contract_id
        primary key,
    contract_number varchar(50) not null
      constraint UQ_contracts_contract_number
        unique,
    customer_id int not null
      constraint FK_contracts_customers_customer_id
        foreign key references dbo.customers,
    description varchar(100) not null,
    contract_value decimal(18,2) not null,
    tax_value decimal(18,2) not null
      constraint DF_contract_tax_value
        default(0),
    interest_rate decimal(20,10) not null,
    currency_code varchar(3) not null
      constraint FK_contracts_currency_currency_code
        foreign key references dbo.currencies,
    tax_rate decimal(4,2) not null,
    activity_status varchar(20) null
      constraint DF_contracts_activity_status
        default ('inactive'),
    entered_date date not null
      constraint DF_contracts_entered_date
        default (getdate()),
    activation_date date null,
    duration int not null, 
    employee_id int not null
      constraint FK_employees_employee_id
        foreign key references dbo.employees,
    ts datetime not null
      constraint DF_contracts_ts
        default (getdate())
  )
go

-- #endregion



-- #region table invoices

if not exists (select * from information_schema.tables where table_name='invoices' and table_schema = 'dbo')
  create table dbo.invoices
  (
    invoice_id int identity(1,1)
      constraint PK_invoice
        primary key,
    customer_id int not null
      constraint FK_invoices_customers_customer_id
        foreign key references dbo.customers,
    invoice_issue_date date not null,
    due_date date not null,
    currency_code varchar(3) not null
      constraint FK_invoices_currencies_currency_code
        foreign key references dbo.currencies,
    net_amount decimal(18,2) not null,
    tax_amount decimal(18,2) not null,
    total_amount decimal(18,2) not null,
    tax_rate decimal(4,2) not null,
    document_id varchar(50) null,
    contract_id int null
      constraint FK_invoice_contracts_contract_id
        foreign key references dbo.contracts,
    ts datetime not null
      constraint DF_invoices_ts
        default (getdate()),
    --
    constraint CK_invoices_total_amount
      check (total_amount = net_amount + tax_amount)
  )
go

-- #endregion



-- #region table amort_plan

if not exists (select * from information_schema.tables where table_name='amort_plan' and table_schema = 'dbo')
  create table dbo.amort_plan
  (
    document_id varchar(50) not null
      constraint PK_amort_plan primary key,
    contract_id int not null
      constraint FK_amort_plan_contract_contract_id
        foreign key references dbo.contracts(contract_id),
    claim_type varchar(50) not null,
    currency_code varchar(3) not null
      constraint FK_amortisation_plan_currencies_currency_code
        foreign key references dbo.currencies,
    claim_date date not null,
    claim_due_date date not null,
    claim_period int not null,
    net_amount decimal(18,2) not null,
    interest_amount decimal(18,2) not null,
    tax_amount decimal(18,2) not null,
    other_amount decimal(18,2) not null,
    total_amount decimal(18,2) not null,
    paid_amount decimal(18,2) not null,
    due_amount decimal(18,2) not null,
    ts datetime not null
      constraint DF_amort_plan_ts
        default (getdate()),
    --
    constraint CK_amortisation_plan_total_amount
      check (total_amount = net_amount + interest_amount + tax_amount + other_amount),
    constraint CK_amortisation_plan_paid_amount
      check (paid_amount <= total_amount),
    constraint CK_amorisation_plan_due_amount
      check (due_amount = total_amount - paid_amount)
  )
go

-- #endregion



--#region payments

if not exists (select * from information_schema.tables where table_name = 'payments' and table_schema = 'dbo')
  create table dbo.payments
  (
    payment_id int identity(1,1)
      constraint PK_payments primary key,
    payment_date date not null,
    payment_amount decimal(18,2) not null,
    currency_code varchar(3) not null
      constraint FK_payments_currency_code
        foreign key references dbo.currencies,
    document_id varchar(50) null,
    invoice_id int null
      constraint FK_payments_invoice_id
        foreign key references dbo.invoices,
    customer_id int null
      constraint FK_payments_customer_id
        foreign key references dbo.customers,
    ts datetime not null
      constraint DF_payments_ts
        default (getdate())
  )
go

--#endregion payments



--#region other tables

if not exists (select * from information_schema.tables where table_name = 'numbers' and table_schema = 'dbo')
  select top 100000
    identity(int,1,1) as num
  into dbo.numbers
  from sys.objects a, sys.objects b, sys.objects c
go


if not exists (select * from information_schema.tables where table_name = '_rnd_names' and table_schema = 'dbo')
  create table dbo._rnd_names
  (
    name varchar(100)
      constraint PK__rnd_names
        primary key
  )
go


if not exists (select * from information_schema.tables where table_name = '_rnd_surnames' and table_schema = 'dbo')
  create table dbo._rnd_surnames
  (
    surname varchar(100)
      constraint PK__rndsurnames
        primary key
  )
go


if not exists (select * from information_schema.tables where table_name = '_rnd_companies' and table_schema = 'dbo')
  create table dbo._rnd_companies
  (
    company varchar(100)
      constraint PK__rnd_companies
        primary key
  )
go


if not exists (select * from information_schema.tables where table_name = '_rnd_streets' and table_schema = 'dbo')
  create table dbo._rnd_streets
  (
    street varchar(100)
      constraint PK__rnd_streets
        primary key
  )
go

--drop table numbers
--select * from numbers

--#endregion other tables




