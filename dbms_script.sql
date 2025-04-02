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

execute quer3 into s_cg;	
	
if min_cg > s_cg	
then flag := true;
quer1:=req;
req := concat(quer1, ', CG Criteria Not Met');	
end if;	
	
quer1:= concat('select st.start_time
from slots as st, course_offering as o
where o.offering_id = ', offering_id1,' and o.slot_id = st.slot_id;');
execute quer1 into c_start_time;

quer1:= concat('select st.end_time
from slots as st, course_offering as o
where o.offering_id = ', offering_id1,' and o.slot_id = st.slot_id;');
execute quer1 into c_end_time;

quer1:= concat('select st.day
from slots as st, course_offering as o
where o.offering_id = ', offering_id1,' and o.slot_id = st.slot_id;');
execute quer1 into day1;


if flag <> true	
then --insert into offering table	
	quer1:= concat('select count(*)
	from course_offering as o, student_courses_',student_id,' as s, slots as st
	where o.offering_id = s.offering_id and o.slot_id = st.slot_id 
		and st.day=',E'\'',day1,E'\'',' and st.start_time < ',E'\'',c_end_time,E'\'',' and st.end_time >', E'\'',c_start_time,E'\'',' and o.status = ', E'\'','Running', E'\'',';');
	execute quer1 into clashes;
	if clashes = 0
	then 
		quer4 := concat('insert into offering_enrollment_',NEW.offering_id, ' values(', student_id1,');');
		execute quer4;
		
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

		quer1 := concat('update student_registration_', student_id, ' set cred_limit = cred_limit - ', c_credit, ' where year = ', year1,' and semester = ', sem,';');
		execute quer1;

	else 
	return old;

	end if;
	



else	
	select ins_id into inst_id	
	from course_offering as ofr	
	where ofr.offering_id = NEW.offering_id;	
	quer4 := concat('select count(*)	
	from student_tickets_', student_id,';');	
	execute quer4 into ct;	

	tid := concat(E'\'',student_id, '_', ct,E'\'');	
	quer4:=concat(E'\'',req,E'\'');	
	quer5:= concat('insert into student_tickets_', student_id,'	
	(ticket_id, offering_id, request) values(', tid,' ,', offering_id1, ', ', quer4,');');	

	quer6:= concat('insert into faculty_tickets_', inst_id,	
	'(ticket_id, student_id, offering_id, request) values(', tid,' ,', student_id, ', ', offering_id1, ', ', quer4,');');	
	execute quer5;	
	execute quer6;	

	RETURN OLD;

end if;	
RETURN NEW;	
END;	
	
$check_eligibility$	
LANGUAGE plpgsql
security definer
;

CREATE OR REPLACE FUNCTION update_cred_limit_registration()	
RETURNS TRIGGER as $update_cred_limit_registration$	
DECLARE	
student_id varchar(30);
student_id1 varchar(30);
offering_id varchar(50);	
offering_id1 varchar(50);	
quer1 varchar(1000);	
creditsum float(3);
numb integer;
BEGIN	

creditsum:= 0;
student_id := tg_argv[0];
student_id1:= concat(E'\'',student_id,E'\'');	

if NEW.cred_limit = 0
then
	quer1:= concat('select sum(sh.credits),count(*) 
					from (select s.current_credits from student_registration_',student_id,' s order by year desc,semester desc limit 2)
					as sh(credits) ;');
	execute quer1 into creditsum,numb;


	if numb = 0 or creditsum = 0
	then 
		NEW.cred_limit=18;
		
	else
		execute 
		concat('select s.program_core_credit, s.program_elective_credit, s.science_core_credit, s.open_elective_credit, s.cgpa   
		from student_registration_',student_id,' s order by year desc,semester desc limit 1;') 
		into new.program_core_credit, new.program_elective_credit, new.science_core_credit, new.open_elective_credit, new.cgpa;
		NEW.cred_limit=1.25*(creditsum/2);
		
	end if;



end if;	
RETURN NEW;	
END;
$update_cred_limit_registration$	
LANGUAGE plpgsql
security definer
;	


CREATE OR REPLACE FUNCTION create_st_tables()		
RETURNS TRIGGER as $create_st_tables$		
DECLARE		
target_off_id varchar(14);		
target_st_id varchar(14);		
quer1 varchar(1000);		
quer2 varchar(1000);		
quer3 varchar(1000);		
quer4 varchar(1000);		
quer5 varchar(1000);		
quer6 varchar(1000);		
tquer varchar(1000);		
adv_id varchar(100);		
		
BEGIN		
target_st_id:= NEW.student_id;

quer1:= concat('create table Student_registration_',target_st_id,'(		
Semester INTEGER,		
YEAR INTEGER,		
Current_credits FLOAT(3) DEFAULT 0,
Program_core_credit FLOAT(3) DEFAULT 0,
Program_elective_credit FLOAT(3) DEFAULT 0,
SCIENCE_core_credit FLOAT(3) DEFAULT 0,
Open_elective_credit FLOAT(3) DEFAULT 0,		
CGPA float(3) default 0,
Cred_limit FLOAT(3) default 0

);');		
execute quer1;		


tquer := concat('CREATE TRIGGER create_registration_', target_st_id,'		
BEFORE INSERT		
ON Student_Registration_',target_st_id,'		
FOR EACH ROW		
EXECUTE PROCEDURE update_cred_limit_registration(',target_st_id,');');		
execute tquer;		


quer1 := E'\'Pending\'';		
		
quer2:= concat('create table Student_Tickets_',target_st_id,'(		
Ticket_ID VARCHAR(30) NOT NULL PRIMARY KEY,		
Offering_ID VARCHAR(100) NOT NULL,		
status varchar(20) default ', quer1,',		
Request VARCHAR(1000),		
FOREIGN KEY(Offering_ID) REFERENCES Course_Offering(Offering_ID) ON DELETE CASCADE		
);');		
execute quer2;		
quer3:= concat('create table Student_Courses_',target_st_id,'(		
Offering_ID VARCHAR(100) NOT NULL,	
FOREIGN KEY(Offering_ID) REFERENCES Course_Offering(Offering_ID) ON DELETE CASCADE		
);');		
execute quer3;	

quer3:= concat('create table Student_Grades_',target_st_id,'(		
Offering_ID VARCHAR(100) NOT NULL,
Grade INTEGER default -1,
FOREIGN KEY(Offering_ID) REFERENCES Course_Offering(Offering_ID) ON DELETE CASCADE		
);');		
execute quer3;		

/*
CREATE NEW STUDENT HERE AND GIVE RIGHTS TO CORRESPONDING DEAN AND BATCH_ADV
ASSUMPTION:BOTH OF THEM NEED TO BE ADDED TO DATABASE BEFORE STUDENT 
*/
quer1:=concat('create user st_',target_st_id,' WITH PASSWORD ',E'\'iitropar\';');
execute quer1;
	
quer1:= concat('grant select,insert on student_courses_',target_st_id,' to st_',target_st_id,';');
execute quer1;

quer1:= concat('grant select,insert on student_tickets_',target_st_id,', student_registration_',target_st_id,', student_grades_',target_st_id,'
			   to st_',target_st_id,';');
execute quer1;

quer1:= concat('grant select on faculty,students,batch_adv,dean_acad,course,course_offering,Program_courses,slots,prerequisites
				   to st_',target_st_id,';');
execute quer1;


quer1:= concat('select d.ins_id from batch_adv d where d.year=',NEW.year,' and d.dept=',E'\'',NEW.DEPT,E'\'',' limit 1;');

execute quer1 into quer6;

quer1:= concat('grant select on student_tickets_',target_st_id,', student_registration_',target_st_id,', student_grades_',target_st_id,'
			   to adv_',quer6,';');
execute quer1;

tquer := concat('CREATE TRIGGER create_ticket_trigger_', target_st_id,'		
BEFORE INSERT		
ON Student_Courses_',target_st_id,'		
FOR EACH ROW		
EXECUTE PROCEDURE check_eligibility(',target_st_id,');');		
execute tquer;		


RETURN NEW;		
END;		
		
$create_st_tables$		
LANGUAGE plpgsql
security definer
;		
	
		
CREATE TRIGGER create_student_tables		
BEFORE INSERT		
ON Students		
FOR EACH ROW		
EXECUTE PROCEDURE create_st_tables()		
;		





create or replace function is_the_student_ready_to_graduate(student_id1 varchar (40))
returns varchar(10) as $$

declare
--student_id1 varchar(40);
quer1 varchar(1000);
quer2 varchar(1000);
var1 FLOAT(3);
var2 FLOAT(3);
var3 FLOAT(3);
var4 FLOAT(3);
var5 FLOAT(3);


begin
quer1:= concat('select program_core_credit from student_registration_',student_id1,' order by year desc,semester desc limit 1;'
);
execute quer1 into var1;

quer1:= concat('select program_elective_credit from student_registration_',student_id1,' order by year desc,semester desc limit 1;'
);
execute quer1 into var2;

quer1:= concat('select science_core_credit from student_registration_',student_id1,' order by year desc,semester desc limit 1;'
);
execute quer1 into var3;

quer1:= concat('select open_elective_credit from student_registration_',student_id1,' order by year desc,semester desc limit 1;'
);
execute quer1 into var4;

quer1:= concat('select cgpa from student_registration_',student_id1,' order by year desc,semester desc limit 1;'
);
execute quer1 into var5;

if var1>=40 and var2>=40 and var3>=40 and var4>=40 and var5>=5
then 
quer2:='YES';
else
quer2:= 'NO';
end if;

return quer2;
END;
$$	
LANGUAGE plpgsql
security invoker
;	
	



create or replace function update_grades(offering_id varchar (40), file varchar(1000))
returns varchar(10) as $$

declare
--student_id1 varchar(40);
quer1 varchar(1000);
quer2 varchar(1000);


begin
quer1:= concat('delete from offering_enrollment_',offering_id,';');
execute quer1;

quer2:= E'\',\'';
quer1:= concat('COPY offering_enrollment_', offering_id,'(student_id, grade)
FROM ',concat(E'\'',file,E'\''),'
DELIMITER ', quer2,'
CSV HEADER;'
);
execute quer1;

execute concat('update course_offering set status = ', E'\'Completed\'',' where offering_id = ', E'\'',offering_id, E'\'',';');


return 'Imported';
END;
$$	
LANGUAGE plpgsql
security invoker
;	


CREATE OR REPLACE FUNCTION gradesheet(student_id1 varchar(30))
returns table(course varchar,grade integer,semester integer,year integer)
language plpgsql
security invoker
as $$

declare
quer1 varchar(1000);

begin
quer1:= concat('select c.course_id,sg.grade,o.semester,o.year from student_grades_',student_id1,' sg,
course_offering o, course c
where c.course_id=o.course_id and o.offering_id=sg.offering_id
;');
return query execute(quer1);

end
$$
;

create or replace function get_cg(st_id varchar (40))
returns float(3) as $$

declare
quer1 varchar(1000);
quer2 varchar(1000);
cg float(3);
tc integer;

begin
quer1:= concat('select (sum((c.credit) * (s.grade))::float) /sum(c.credit)    
			   from student_grades_',st_id,' as s, course_offering as o, course as c
			   where o.offering_id = s.offering_id and c.course_id = o.course_id;');
execute quer1 into cg;

return cg;
END;
$$	
LANGUAGE plpgsql	
;	


CREATE OR REPLACE FUNCTION update_cg_creds()		
RETURNS TRIGGER as $update_cg_creds$		
DECLARE		
off_id varchar(14);		
target_st_id varchar(14);		
quer1 varchar(1000);		
quer2 varchar(1000);		
c_type varchar(100);
c_credit float(3);
cg float(3);
sem integer;
year1 integer;
		
BEGIN		

if new.grade = -1
then 
return new;
end if;

off_id := tg_argv[0];
quer1:= concat('select p.course_type 
from students as s, course_offering as o, program_courses as p
where ',concat(E'\'',New.student_id,E'\''),' = s.student_id and 
		o.offering_id = ',concat(E'\'',off_id,E'\''),'
	  and o.course_id = p.course_id and p.dept = s.dept 
	  and s.year = p.year limit 1;');
	 
execute quer1 into c_type;  

quer1:= concat('select c.credit 
from course_offering as o, course as c
where o.offering_id = ',concat(E'\'',off_id,E'\''),'
	  and o.course_id = c.course_id limit 1;');
execute quer1 into c_credit;

quer1:= concat('select o.year 
			  from course_offering as o
			   where o.offering_id = ', concat(E'\'',off_id,E'\''),';');
execute quer1 into year1;

quer1:= concat('select o.semester 
			  from course_offering as o
			   where o.offering_id = ', concat(E'\'',off_id,E'\''),';');
execute quer1 into sem;



quer1 := concat('insert into student_grades_', New.student_id, ' values(', concat(E'\'',off_id,E'\''),',', New.grade,');');
execute quer1;

quer1:=concat('select * from get_cg(', E'\'',New.student_id, E'\'',');');
execute quer1 into cg;

--Cg updated in Registration
quer1 := concat('update student_registration_', New.student_id, ' set cgpa = ',cg,' where year = ', year1,' and semester = ', sem,';');
execute quer1;

--Credits updated in Registration
raise notice '(%d)', c_type;

if new.grade > 5
then
quer1 := concat('update student_registration_', New.student_id, ' set ', c_type,'_credit =',c_type,'_credit +',c_credit, ' where year = ', year1,' and semester = ', sem,';');
execute quer1;

quer1 := concat('update student_registration_', New.student_id, ' set current_credits = current_credits + ',c_credit, ' where year = ', year1,' and semester = ', sem,';');
execute quer1;
end if;

RETURN NEW;		
END;		
		
$update_cg_creds$		
LANGUAGE plpgsql
security definer
;
