#@title
drop user if exists pgoyal;
drop user if exists bsodhi,kalyan,dean_kalyan,adv_kalyan,adv_pgoyal,gunturi,dean_gunturi,st_20191103,st_20191081;
drop user if exists adv_kalse, adv_kumbh, kumbh, kalse, saifu, st_20191111, st_20201081, st_20201112;

insert into faculty values('pgoyal', 'Puneet', 'CSE');
insert into faculty values('bsodhi', 'Sodhi', 'CSE');
insert into faculty values('kalyan', 'TVK', 'CSE');
insert into faculty values('gunturi', 'VG', 'CSE');
insert into faculty values('saifu', 'SF', 'EE');
insert into faculty values('kalse', 'KSV', 'EE');
insert into faculty values('kumbh', 'BK', 'EE');

insert into dean_acad values('gunturi','CSE',2019);
insert into dean_acad values('kalyan','CSE',2020);

insert into batch_adv values('pgoyal', 'CSE', 2020);
insert into batch_adv values('kalyan', 'CSE', 2019);
insert into batch_adv values('kumbh', 'EE', 2020);
insert into batch_adv values('kalse', 'EE', 2019);

insert into course values('CS201', 'DSA', 'CSE', 3, 1, 2, 6, 4);
insert into course values('CS202', 'PPD', 'CSE', 2, 3, 4, 5, 4.2);
insert into course values('CS203', 'DLD', 'CSE', 2, 3, 6, 2, 3);
insert into course values('CS301', 'DBMS', 'CSE', 3, 1, 2, 6, 4);
insert into course values('CS302', 'DAA', 'CSE', 3, 1, 0, 5, 3);
insert into course values('CS303', 'OS', 'CSE', 2, 3, 3, 4, 4);
insert into course values('EE201', 'ELE', 'EE', 2, 3, 3, 4, 4);


insert into slots values('slot1','1:00','2:00','monday');
insert into slots values('slot2','10:00','12:00','tuesday');
insert into slots values('slot3','10:00','2:00','monday');


insert into program_courses values('CS201','CSE',2020,'Program_core');
insert into program_courses values('CS201','CSE',2019,'Program_core');
insert into program_courses values('EE201','CSE',2019,'Program_core');
insert into program_courses values('EE201','CSE',2020,'Program_core');
insert into program_courses values('CS202','CSE',2020,'Program_Elective');
insert into program_courses values('CS202','CSE',2019,'Program_Elective');
insert into program_courses values('CS203','CSE',2020,'Program_core');
insert into program_courses values('CS203','CSE',2019,'Program_core');
insert into program_courses values('CS301','CSE',2020,'Program_core');
insert into program_courses values('CS301','CSE',2019,'Program_core');
insert into program_courses values('CS302','CSE',2020,'Program_Elective');
insert into program_courses values('CS302','CSE',2019,'Program_Elective');
insert into program_courses values('CS303','CSE',2020,'Program_core');
insert into program_courses values('CS303','CSE',2019,'Program_core');


insert into program_courses values('CS201','EE',2020,'Program_core');
insert into program_courses values('CS201','EE',2019,'Program_core');
insert into program_courses values('EE201','EE',2019,'Program_core');
insert into program_courses values('EE201','EE',2020,'Program_core');
insert into program_courses values('CS202','EE',2020,'Program_Elective');
insert into program_courses values('CS202','EE',2019,'Program_Elective');
insert into program_courses values('CS203','EE',2020,'Program_core');
insert into program_courses values('CS203','EE',2019,'Program_core');
insert into program_courses values('CS301','EE',2020,'Program_core');
insert into program_courses values('CS301','EE',2019,'Program_core');
insert into program_courses values('CS302','EE',2020,'Program_Elective');
insert into program_courses values('CS302','EE',2019,'Program_Elective');
insert into program_courses values('CS303','EE',2020,'Program_Elective');
insert into program_courses values('CS303','EE',2019,'Program_Elective');

--Program courses for MEB Dept

insert into prerequisites values('CS301','CS201');
insert into prerequisites values('CS302','CS202');
insert into prerequisites values('CS303','CS203');


insert into course_offering values('2020_cs301', 'CS301', 'pgoyal', 'slot2', 1, 2020, 'Running', 7);	
insert into course_offering values('2019_cs301', 'CS301', 'pgoyal', 'slot1', 1, 2019);
insert into course_offering values('2020_cs302', 'CS302', 'kalyan', 'slot3', 1, 2020, 'Running', 8);
insert into course_offering values('2019_cs302', 'CS302', 'gunturi', 'slot3', 1, 2019, 'Running', 8);
insert into course_offering values('2021_cs303', 'CS303', 'kalyan', 'slot3', 1, 2021, 'Running', 7);
insert into course_offering values('2020_cs303', 'CS303', 'kalyan', 'slot3', 1, 2020, 'Running', 7);
insert into course_offering values('2020_cs303_2', 'CS303', 'kalyan', 'slot3', 2, 2020, 'Running', 7);
insert into course_offering values('2019_cs303', 'CS303', 'kalyan', 'slot3', 1, 2019, 'Running', 7);

insert into students values('20191103', 'Nitish', 2019, 'CSE');
insert into students values('20191081', 'Bharat', 2019, 'CSE');
insert into students values('20201081', 'Neymar Jr', 2020, 'CSE');
insert into students values('20191111', 'ABC', 2019, 'EE');
insert into students values('20201112', 'DEF', 2020, 'EE');

insert into student_registration_20191103 values(1, 2019);
insert into student_courses_20191103 values('2019_cs303');
update faculty_tickets_kalyan set faculty_approval = 'YES';
update adv_tickets_kalyan set adv_approval = 'YES';

insert into course_offering values('2019_cs202', 'CS202', 'kalyan', 'slot1', 1, 2019, 'Running');
insert into student_registration_20191111 values(1, 2019, 0, 42, 38, 45, 43, 9);
insert into student_courses_20191111 values('2019_cs202');
