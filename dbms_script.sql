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

if OLD.faculty_approval <> NEW.faculty_approval 
then

ins_id1 := tg_argv[0];	
student_id1:= concat(E'\'',NEW.student_id,E'\'');	
offering_id1:= concat(E'\'',NEW.offering_id,E'\'');	
	
quer1 := concat('select s.YEAR	
from Students as s where s.student_id=',student_id1,'	
limit 1;');	
	
	
execute quer1 into year1;	
	
quer2 := concat('select s.dept	
from Students as s where s.student_id=',student_id1,'	
limit 1;');	
	
	
execute quer2 into dept1;	
	
quer1:= concat(E'\'',year1,E'\'');	
quer2:= concat(E'\'',dept1,E'\'');	
	
quer3 := concat('select a.ins_id	
from batch_adv a	
where a.dept =',quer2,' and a.year = ',quer1,'	
limit 1;');	
	
execute quer3 into adv_id1;	
tempvar1:= concat(E'\'',NEW.ticket_id,E'\'');	
quer2:= concat(E'\'Adv Apprv Pending\'');	
quer3:= concat(E'\'Pending\'');	
tempvar5:= concat(E'\'',NEW.request,E'\'');	
quer1:= concat('insert into adv_tickets_',adv_id1,' values(',tempvar1,',',student_id1,',',offering_id1,',',quer2,',',quer3,',',tempvar5,' );');	
execute quer1;	
	
quer1:= concat('UPDATE student_tickets_',NEW.student_id,' SET status = ',quer2,'WHERE ticket_id = ',tempvar1,';');	
execute quer1;	
NEW.status= 'Adv Apprv Pending';

end if;
RETURN NEW;	
END;	
	
$update_faculty_ticket$	
LANGUAGE plpgsql
security definer
;

CREATE OR REPLACE FUNCTION create_table()	
RETURNS TRIGGER as $create_table$
	DECLARE
	target_ins_id varchar(30);
	name varchar(30);
	quer varchar(1000);
	tquer varchar(1000);
	quer1 varchar(1000);
	BEGIN
	target_ins_id:= NEW.ins_id;
	quer1 := E'\'Pending \' ';
	quer:= concat('create table faculty_tickets_',target_ins_id,'(Ticket_ID VARCHAR(20) NOT NULL PRIMARY KEY,
	Student_ID VARCHAR(30) NOT NULL,
	Offering_ID VARCHAR(30) NOT NULL,
	Status VARCHAR(100) default ', quer1,',
	Faculty_approval VARCHAR(10) DEFAULT ',E'\'-\'',',
	Request VARCHAR(1000) NOT NULL
	);');
	execute quer;
	tquer := concat('CREATE TRIGGER update_fticket_trigger_', target_ins_id,'
	BEFORE UPDATE
	ON faculty_tickets_',target_ins_id,' 
	FOR EACH ROW
	EXECUTE PROCEDURE update_faculty_ticket(',target_ins_id,');');
	execute tquer;
	
	-- GRANT ACCESS TO ins
	quer1:=concat('create user ',target_ins_id,' WITH PASSWORD ',E'\'iitropar\';
	grant pg_read_server_files to ', target_ins_id,';');

	execute quer1;
	
	quer1:= concat('grant all on faculty_tickets_',target_ins_id,',course_offering to ',target_ins_id,';');
	execute quer1;
	quer1:= concat('grant select on faculty,students,batch_adv,dean_acad,course,Program_courses,slots,prerequisites
				   to ',target_ins_id,';');
	execute quer1;
	
	RETURN NEW;
	END;
$create_table$	
LANGUAGE plpgsql
security definer
;	

	
CREATE TRIGGER create_faculty_ticket_table	
BEFORE INSERT	
ON faculty	
FOR EACH ROW	
EXECUTE PROCEDURE create_table()	
;	

	
CREATE OR REPLACE FUNCTION create_dtable()	
RETURNS TRIGGER as $create_dtable$ 
	DECLARE
	target_ins_id varchar(30);
	quer varchar(1000);
	quer1 varchar(1000);
	BEGIN
	target_ins_id:= NEW.ins_id;
	quer1 := E'\'Pending \' ';
	quer:= concat('create table dean_tickets_',target_ins_id,'(Ticket_ID VARCHAR(20) NOT NULL PRIMARY KEY,
	Student_ID VARCHAR(30) NOT NULL,
	Offering_ID VARCHAR(30) NOT NULL,
	Status VARCHAR(100) default ', quer1,',
	Dean_approval VARCHAR(10) DEFAULT ',E'\'-\'',',
	Request VARCHAR(1000) NOT NULL
	);');
	execute quer;
	
	quer := concat('CREATE TRIGGER update_dean_trigger_', target_ins_id,'
	BEFORE UPDATE
	ON dean_tickets_',target_ins_id,'
	FOR EACH ROW
	EXECUTE PROCEDURE update_dean_ticket(',target_ins_id,');');
	execute quer;
	
	-- GRANT ACCESS TO dean
	quer1:=concat('create user dean_',target_ins_id,' WITH PASSWORD ',E'\'iitropar\';');
	execute quer1;
	
	quer1:= concat('ALTER USER dean_',target_ins_id,' WITH SUPERUSER;');
	execute quer1;
	
	/*
	quer1:= concat('grant all on dean_tickets_',target_ins_id,',course_offering to ',E'\'',target_ins_id,E'\'',';');
	execute quer1;
	quer1:= concat('grant all on faculty,students,batch_adv,dean_acad,course,Program_courses,slots,prerequisites
				   to ',E'\'',target_ins_id,E'\'',';');
	execute quer1;
	*/
	
	RETURN NEW;
	END;
$create_dtable$	
LANGUAGE plpgsql
security definer
;	


CREATE OR REPLACE FUNCTION update_dean_ticket()	
RETURNS TRIGGER as $update_dean_ticket$	
DECLARE	
student_id1 varchar(40);	
ins_id1 varchar(40);	
adv_id1 varchar(40);
dean_id1 varchar(40);
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
c_credit float(3);
year2 integer; 
sem integer;
	
BEGIN	
dean_id1 := tg_argv[0];	
student_id1:= concat(E'\'',NEW.student_id,E'\'');	
offering_id1:= concat(E'\'',NEW.offering_id,E'\'');	
	
quer1 := concat('select o.ins_id
from course_offering as o where o.offering_id=',offering_id1,'	
limit 1;');		
execute quer1 into ins_id1;

quer1 := concat('select s.year
from students as s where s.student_id=',student_id1,'	
limit 1;');	
execute quer1 into year1;	

quer1 := concat('select s.dept
from students as s where s.student_id=',student_id1,'	
limit 1;');	
execute quer1 into dept1;	

quer1:= concat(E'\'',year1,E'\'');	
quer2:= concat(E'\'',dept1,E'\'');	
	
quer3 := concat('select d.ins_id	
from batch_adv d
where d.year =',quer1,' and d.dept=',quer2,' limit 1;');	

execute quer3 into adv_id1;

tempvar1:= concat(E'\'',NEW.ticket_id,E'\'');

quer3:= concat(E'\'Dean Rejected\'');	

tempvar5:= concat(E'\'',NEW.request,E'\'');




if New.dean_approval='YES'
then

quer1:= concat('insert into offering_enrollment_',New.offering_id,' values(',student_id1,');');	
execute quer1;

quer1:= concat('select c.credit 
from course_offering as o, course as c
where o.offering_id = ',concat(E'\'', New.offering_id,E'\''),'
	and o.course_id = c.course_id limit 1;');
execute quer1 into c_credit;

quer1:= concat('select o.year 
			from course_offering as o
			where o.offering_id = ', concat(E'\'',new.offering_id,E'\''),';');
execute quer1 into year1;

quer1:= concat('select o.semester 
			from course_offering as o
			where o.offering_id = ', concat(E'\'',new.offering_id,E'\''),';');
execute quer1 into sem;


quer3:= concat(E'\'Dean Approved\'');

quer1 := concat('update student_registration_', new.student_id, ' set cred_limit = cred_limit - ', c_credit, ' where year = ', year1,' and semester = ', sem,';');
execute quer1;

quer1:= concat('UPDATE student_tickets_',NEW.student_id,' SET status = ',quer3,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;	

quer1:= concat('UPDATE faculty_tickets_',ins_id1,' set status = ',quer3,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;	

quer1:= concat('UPDATE adv_tickets_',adv_id1,' set status = ',quer3,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;

quer1:= concat('insert into student_courses_',new.student_id,' values(',offering_id1,');');
execute quer1;

/*
quer1:= concat('delete from student_tickets_',new.student_id,' where ticket_id = (select ticket_id 
				from student_tickets_',new.student_id,' order by ticket_id desc limit 1);
				delete from faculty_tickets_', ins_id1,' where ticket_id = (select ticket_id 
				from faculty_tickets_',ins_id1,' order by ticket_id desc limit 1);');
execute quer1;
*/


end if;



NEW.status = quer3;
quer1:= concat('UPDATE student_tickets_',NEW.student_id,' SET status = ',quer3,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;	

quer1:= concat('UPDATE faculty_tickets_',ins_id1,' set status = ',quer3,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;	

quer1:= concat('UPDATE adv_tickets_',adv_id1,' set status = ',quer3,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;




RETURN NEW;	
END;	
	
$update_dean_ticket$	
LANGUAGE plpgsql	
security definer
;	


CREATE TRIGGER create_dean_ticket_table	
BEFORE INSERT	
ON dean_acad	
FOR EACH ROW	
EXECUTE PROCEDURE create_dtable()	
;	
	
CREATE OR REPLACE FUNCTION update_adv_ticket()	
RETURNS TRIGGER as $update_adv_ticket$
DECLARE	
student_id1 varchar(40);	
ins_id1 varchar(40);	
adv_id1 varchar(40);	
dean_id1 varchar(40);
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
if OLD.adv_approval<>NEW.adv_approval
then

adv_id1 := tg_argv[0];	
student_id1:= concat(E'\'',NEW.student_id,E'\'');	
offering_id1:= concat(E'\'',NEW.offering_id,E'\'');	
	
quer1 := concat('select o.ins_id
from course_offering as o where o.offering_id=',offering_id1,'	
limit 1;');		
execute quer1 into ins_id1;

quer1 := concat('select o.semester
from course_offering as o where o.offering_id=',offering_id1,'	
limit 1;');	
execute quer1 into semester1;	

quer1 := concat('select o.year
from course_offering as o where o.offering_id=',offering_id1,'	
limit 1;');	
execute quer1 into year1;	


quer1:= concat(E'\'',year1,E'\'');	
quer2:= concat(E'\'',semester1,E'\'');	
	
quer3 := concat('select d.ins_id	
from dean_acad	as d
where d.year =',quer1,' limit 1;');	

execute quer3 into dean_id1;

tempvar1:= concat(E'\'',NEW.ticket_id,E'\'');	
quer2:= concat(E'\'Dean Apprv Pending\'');	
quer3:= concat(E'\'Pending\'');	
tempvar5:= concat(E'\'',NEW.request,E'\'');	
quer1:= concat('insert into dean_tickets_',dean_id1,' values(',tempvar1,',',student_id1,',',offering_id1,',',quer2,',',quer3,',',tempvar5,' );');	
execute quer1;	
	
quer1:= concat('UPDATE student_tickets_',NEW.student_id,' SET status = ',quer2,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;	

quer1:= concat('UPDATE faculty_tickets_',ins_id1,' set status = ',quer2,' WHERE ticket_id = ',tempvar1,';');	
execute quer1;	

NEW.status:='Dean Apprv Pending';

end if;

RETURN NEW;	
END;	
	
$update_adv_ticket$	
LANGUAGE plpgsql
security definer
;
	
CREATE OR REPLACE FUNCTION create_advtable()	
RETURNS TRIGGER as $create_advtable$	
	DECLARE
	target_ins_id varchar(30);
	quer varchar(1000);
	quer1 varchar(1000);
	BEGIN
	target_ins_id:= NEW.ins_id;
	quer1 := E'\'Pending \' ';
	quer:= concat('create table adv_tickets_',target_ins_id,'(Ticket_ID VARCHAR(30) NOT NULL PRIMARY KEY,
	Student_ID VARCHAR(30) NOT NULL,
	Offering_ID VARCHAR(30) NOT NULL,
	Status VARCHAR(100) default ', quer1,',
	adv_approval VARCHAR(10) DEFAULT ',E'\'-\'',',
	Request VARCHAR(1000) NOT NULL
	);');
	execute quer;
	
	-- GRANT ACCESS TO ADV
	quer1:=concat('create user adv_',target_ins_id,' WITH PASSWORD ',E'\'iitropar\';');
	execute quer1;
	
	quer1:= concat('grant all on adv_tickets_',target_ins_id,' to adv_',target_ins_id,';');
	execute quer1;
	quer1:= concat('grant select on faculty,students,batch_adv,dean_acad,course,course_offering,Program_courses,slots,prerequisites
				   to adv_',target_ins_id,';');
	execute quer1;
	
	
	quer := concat('CREATE TRIGGER update_adv_trigger_', target_ins_id,'
	BEFORE UPDATE
	ON adv_tickets_',target_ins_id,'
	FOR EACH ROW
	EXECUTE PROCEDURE update_adv_ticket(',target_ins_id,');');
	execute quer;
	
	RETURN NEW;
	END;
$create_advtable$	
LANGUAGE plpgsql	
security definer
;	
	
	
CREATE TRIGGER create_adv_ticket_table	
BEFORE INSERT	
ON batch_adv	
FOR EACH ROW	
EXECUTE PROCEDURE create_advtable()	
;	
	
CREATE OR REPLACE FUNCTION create_offtable()	
RETURNS TRIGGER as $create_offtable$	
	DECLARE
	target_off_id varchar(30);
	
	quer varchar(1000);
	quer1 varchar(1000);
	tquer varchar(1000);
	dean_id1 varchar(40);
	
	BEGIN
	target_off_id:= NEW.offering_id;
	quer:= concat('create table Offering_enrollment_',target_off_id,'(
	Student_ID VARCHAR(30) NOT NULL,
	Grade INTEGER default -1
	);');
	execute quer;

	/* GRANT ACCESS TO FACULTY and dean */
	quer:= concat('select d.ins_id from dean_acad d,course_offering o where o.year=d.year and o.offering_id = ',E'\'',NEW.offering_id,E'\'','
				  limit 1;');
	execute quer into dean_id1;
	
	quer:= concat('grant all on offering_enrollment_',target_off_id,' to ',NEW.ins_id,';');
	execute quer;
	/*
	quer:= concat('grant all on offering_enrollment_',target_off_id,' to ',E'\'',dean_id1,E'\'',';');
	execute quer;
	*/
	
	tquer := concat('CREATE TRIGGER update_student_data_', target_off_id,'
	BEFORE INSERT
	ON offering_enrollment_',target_off_id,'
	FOR EACH ROW
	EXECUTE PROCEDURE update_cg_creds(',E'\'',target_off_id,E'\'',');');
	execute tquer;


	RETURN NEW;
	END;
$create_offtable$	
LANGUAGE plpgsql	
security definer
;	
	
CREATE TRIGGER create_offering_enrollment_table	
BEFORE INSERT	
ON course_offering	
FOR EACH ROW	
EXECUTE PROCEDURE create_offtable()	
;	


CREATE OR REPLACE FUNCTION check_eligibility()	
RETURNS TRIGGER as $check_eligibility$	
DECLARE	
student_id varchar(30);
student_id1 varchar(30);
offering_id varchar(50);	
offering_id1 varchar(50);	
quer1 varchar(1000);	
quer2 varchar(1000);	
quer3 varchar(1000);	
quer4 varchar(1000);	
quer5 varchar(1000);	
quer6 varchar(1000);	
tquer varchar(1000);	
req varchar(1000);	
Cred_acq float(3);	
max_cred float(3);	
course_cred float(3);	
flag boolean;	
ct INTEGER;	
min_cg float(3);	
s_cg float(3);	
inst_id varchar(40);	
tid varchar(40);	
c_start_time time;
c_end_time time;
clashes integer;
day1 varchar(10);
c_credit float(3);
year1 integer;
sem integer;

BEGIN	
	
student_id := tg_argv[0];
student_id1:= concat(E'\'',student_id,E'\'');	
offering_id := NEW.offering_id;	
offering_id1:= concat(E'\'',offering_id,E'\'');	
--credit limit	
flag := false;	
req:='';


quer1:= concat('select count(*) from student_tickets_20191103 t where t.offering_id =',offering_id1, 'and status=', E'\'Dean Approved\'',' ;' );
execute quer1 into ct;
if ct>0
then
return new;
end if;


quer1 := concat('select sr.Cred_limit	
from Student_registration_', student_id,' as sr, course_offering as ofr	
where ofr.offering_id =', offering_id1,' and ofr.semester = sr.semester and ofr.year = sr.year	
limit 1;');	
	
quer2 := concat('select sr.current_credits	
from Student_registration_', student_id,' as sr, course_offering as ofr	
where ofr.offering_id =', offering_id1,' and ofr.semester = sr.semester and ofr.year = sr.year	
limit 1;');	
	
quer3 := concat('select c.credit	
from course_offering as ofr, course as c	
where ofr.offering_id =', offering_id1,' and c.course_id = ofr.course_id	
limit 1;');	
	
execute quer1 into max_cred;	
execute quer2 into cred_acq;	
execute quer3 into course_cred;	
	
if cred_acq + course_cred > max_cred	
then	
flag := true;	

quer1:=req;
req:= concat(quer1, 'Credit Limit Exceeds');	
end if;	
	
quer1 := concat('select count(*)	
from (select distinct p.pre_course_id	
from prerequisites as p, course_offering as ofr	
where ofr.offering_id =', offering_id1,' and p.applied_course_id = ofr.course_id	
except	
select distinct ofr1.course_id	
from course_offering as ofr1, student_grades_', student_id,' as sc1	
where sc1.offering_id = ofr1.offering_id and sc1.grade > 5) as foo limit 1');	
execute quer1 into ct;	
	
if ct>0	
then	
flag := true;	
quer1:= req;
req := concat(quer1,', Prerequisite Courses not Complete ');	
end if;	

select ofr.cg_crit into min_cg	
from course_offering as ofr	
where ofr.offering_id = NEW.offering_id;	
quer3 := concat('select c.cgpa	
from Student_registration_', student_id,' as c, course_offering as ofr	
where ofr.offering_id =', offering_id1,' and c.semester = ofr.semester and c.year = ofr.year	
limit 1;')	
;
