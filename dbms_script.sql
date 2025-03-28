create table Students	
(	
	Student_ID VARCHAR(30) NOT NULL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Year INTEGER NOT NULL,
	Dept VARCHAR(6) NOT NULL
)	
;	

--Create Faculty Table	
create table Faculty	
(	
	INS_ID VARCHAR(30) NOT NULL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Dept VARCHAR(6) NOT NULL
)	
;	
--Create Course Table	
create table Course	
(	
	Course_ID VARCHAR(10) NOT NULL PRIMARY KEY,
	Title VARCHAR(1000) NOT NULL,
	Dept VARCHAR(6) NOT NULL,
	L INTEGER,
	T INTEGER,
	P INTEGER,
	S INTEGER,
	Credit FLOAT(2)
)	
;	
create table Batch_Adv	
(	
	INS_ID VARCHAR(30) NOT NULL,
	Dept VARCHAR(6) NOT NULL,
	YEAR INTEGER,
	FOREIGN KEY(INS_ID) REFERENCES Faculty(INS_ID) ON DELETE CASCADE
)	
;	
	
create table Dean_Acad	
(	
	INS_ID VARCHAR(30) NOT NULL,
	Dept VARCHAR(6) NOT NULL,
	YEAR INTEGER,
	FOREIGN KEY(INS_ID) REFERENCES Faculty(INS_ID) ON DELETE CASCADE
	
)	
;	
	create table Slots	
(	
	Slot_ID VARCHAR(10) NOT NULL PRIMARY KEY,
	Start_time time,
	End_time time,
	day varchar(10)
)	
;	
	
create table Course_Offering	
(	
	Offering_ID VARCHAR(100) NOT NULL PRIMARY KEY,
	Course_ID VARCHAR(10) NOT NULL,
	INS_ID VARCHAR(30) NOT NULL,
	Slot_ID VARCHAR(10) NOT NULL,
	Semester INTEGER NOT NULL,
	YEAR INTEGER NOT NULL,
	Status VARCHAR(50) default 'Running',
	CG_crit float(3) default 0,
	FOREIGN KEY(INS_ID) REFERENCES Faculty(INS_ID) ON DELETE CASCADE,
	FOREIGN KEY(Course_ID) REFERENCES Course(Course_ID) ON DELETE CASCADE,
	FOREIGN KEY(Slot_ID) REFERENCES Slots(Slot_ID) ON DELETE CASCADE
)	
;	

create table Program_Courses	
(	
	Course_ID VARCHAR(10) NOT NULL,
	Dept VARCHAR(10) NOT NULL,
	Year INTEGER NOT NULL,
	Course_Type VARCHAR(100),
	FOREIGN KEY(COURSE_ID) REFERENCES COURSE(COURSE_ID) ON DELETE CASCADE
)	
;	
	
create table Prerequisites	
(	
	Applied_Course_ID VARCHAR(10) NOT NULL,
	Pre_Course_ID VARCHAR(10) NOT NULL,
	FOREIGN KEY(Applied_COURSE_ID) REFERENCES COURSE(COURSE_ID) ON DELETE CASCADE,
	FOREIGN KEY(PRE_COURSE_ID) REFERENCES COURSE(COURSE_ID) ON DELETE CASCADE
	
)	
;	

CREATE OR REPLACE FUNCTION update_faculty_ticket()	
RETURNS TRIGGER as $update_faculty_ticket$	
DECLARE	
student_id1 varchar(40);	
ins_id1 varchar(40);	
adv_id1 varchar(40);	
offering_id1 varchar (40);	
quer1 varchar(1000);	
quer2 varchar(1000);	
quer3 varchar(1000);	
dept1 VARCHAR(10);	
YEAR1 INTEGER;	
SEMESTER1 INTEGER;	
tempvar1 varchar(100);	
tempvar2 varchar(100);	
tempvar3 varchar(100);	
tempvar4 varchar(100);	
tempvar5 varchar(100);	
	
BEGIN	
