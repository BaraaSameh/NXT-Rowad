CREATE TABLE Employee(
SSN int primary key not null,
Fname NVARCHAR(255) not null,
Lname NVARCHAR(255) not null,
Gender CHAR(1) not null,
WorkingHours int,
Dnum int,
SUPER_ID int,
FOREIGN KEY (Dnum) REFERENCES Department(DNUM),
 FOREIGN KEY (SUPER_ID) REFERENCES Employee(SSN)
)


CREATE TABLE Department(
DNUM int primary key not null,
Dname NVARCHAR(255),
Locations NVARCHAR(255),
)


CREATE TABLE HiringDate(
Hiring_Date Date not null,
Dnum int,
FOREIGN KEY (Dnum) REFERENCES Department(DNUM)
)

CREATE TABLE Project(
Project_NO int primary key not null,
Project_Name NVARCHAR(255) not null,
Project_Locations NVARCHAR(255) not null,
Dnum int,
FOREIGN KEY (Dnum) REFERENCES Department(DNUM)
)

CREATE TABLE Dependances(
Dependances_Name NVARCHAR (255) primary key not null,
Dependances_Gender CHAR (1) not null,
Dependances_BirthDate Date not null,
ESSN int,
FOREIGN KEY (ESSN) REFERENCES Employee(SSN)
)

CREATE TABLE EMPProject(
Project_NO int primary key not null,
Salary NVARCHAR (255) not null,
ESSN int ,
FOREIGN KEY (ESSN) REFERENCES Employee(SSN)
)

INSERT INTO Department (Dnum, Dname, Locations)
VALUES 
(1, 'Engineering', 'Cairo'),
(2, 'HR', 'Alexandria'),
(3, 'Finance', 'Giza');


INSERT INTO Employee (SSN, FName, LName, Gender, Dnum, SUPER_ID, WorkingHours)
VALUES 
(1001, 'Baraa', 'Sameh', 'M', 1, NULL, 40),
(1002, 'Sara', 'Hassan', 'F', 1, 1001, 38),
(1003, 'Kareem', 'Omar', 'M', 2, 1001, 35),
(1004, 'Nour', 'Ahmed', 'F', 3, 1003, 37),
(1005, 'Hani', 'Tarek', 'M', 2, 1003, 42);

use NXT
select Fname From Employee
where Dnum='1'
order by SSN

update Employee
set Dnum= '3'
where SSN= '1001'

INSERT INTO Dependances (Dependances_Name, ESSN, Dependances_Gender, Dependances_BirthDate)
VALUES ('Laila Ali', 1002, 'F', '2012-05-14'),
 ('ahmed ali',1002,'M','2012-04-21');

 select * from Dependances

 delete from Dependances
 where Dependances_Name='Laila Ali';

 SELECT Fname,Lname from Employee
 where DNUM='3';

 INSERT INTO Project (Project_no, Project_name, Project_Locations, Dnum)
VALUES 
(2001, 'AI Health Monitor', 'Cairo', 1),
(2002, 'Payroll Automation', 'Alexandria', 2),
(2003, 'Financial Forecasting', 'Giza', 3);

select Project.Project_Name from Project
where Dnum='3'





