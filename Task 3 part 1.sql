use NXT

INSERT INTO Department (DNUM, Dname, Locations)
VALUES (4, 'cs', 'banha'), (5, 'front', 'qal');

INSERT INTO Employee (SSN, Fname, Lname, Gender, WorkingHours, Dnum, SUPER_ID)
VALUES 
(101, 'Ali', 'Hassan', 'M', 40, 1, NULL),
(102, 'Sara', 'Youssef', 'F', 35, 2, 101);

INSERT INTO Dependances (Dependances_Name, Dependances_Gender, Dependances_BirthDate, ESSN)
VALUES 
('Omar', 'M', '2010-05-12', 101),
('Laila', 'F', '2012-08-23', 102);
go

INSERT INTO Project (Project_NO, Project_Name, Project_Locations, Dnum)
VALUES 
(201, 'ERP System', 'Cairo', 1),
(202, 'Recruitment Drive', 'Alexandria', 2);

INSERT INTO EMPProject (Project_NO, Salary, ESSN)
VALUES 
(201, 5000, 101),
(202, 4500, 102);

INSERT INTO HiringDate (Hiring_Date, Dnum)
VALUES 
('2020-01-15', 1),
('2021-03-10', 2);

select ssn,fname,gender from Employee
order by SSN;

delete from Employee where Fname='ali'

TRUNCATE table empproject

select * from empproject

 

 ALTER TABLE EMPProject
ADD CONSTRAINT FK_EMPProject_Employee
FOREIGN KEY (ESSN)
REFERENCES Employee(SSN)
ON DELETE CASCADE
ON UPDATE CASCADE;


delete from Employee where SSN=101;

UPDATE Employee
SET SUPER_ID = NULL
WHERE SUPER_ID = 101;  -- Replace 101 with the SSN of the supervisor you're deleting

UPDATE Dependances
SET ESSN = NULL
WHERE ESSN = 101;


DELETE FROM Employee
WHERE SSN = 101;
select * from Employee

alter table Employee
ADD Email VARCHAR(255) 
alter table Employee 
 alter COLUMN  Email  


 UPDATE Employee
SET Email = 'user' + CAST(SSN AS VARCHAR) + '@example.com'
WHERE Email IS NULL;

 ALTER TABLE Employee
ALTER COLUMN Email VARCHAR(255) not null ;

CREATE UNIQUE INDEX UQ_Employee_Email
ON Employee(Email);




   





