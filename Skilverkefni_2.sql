/* 1:
	Smíðið trigger fyrir insert into Restrictors skipunina. 
	Triggernum er ætlað að koma í veg fyrir að einhver áfangi sé undanfari eða samfari síns sjálfs. 
	með öðrum orðum séu courseNumber og restrictorID með sama innihald þá stoppar triggerinn þetta með
	því að kasta villu og birta villuboð.
	Dæmi um insert sem triggerinn á að stoppa: insert into Restrictors values('GSF2B3U','GSF2B3U',1);
*/
delimiter $$
drop trigger if exists no_dupe$$
create trigger no_dupe
before insert on Restrictors
for each row
begin
	declare msg varchar(255);
    
    if(new.courseNumber == new restrictorID) then
		set msg = concat('Courses cannot restrict them selves', cast(new.courseNumber as char));
        signal sqlstate '45000' set message_text = msg;
	end if;
end$$
delimiter ;



-- 2:
-- Skrifið samskonar trigger fyrir update Restrictors skipunina.
delimiter $$
drop trigger if exists no_dupe$$
create trigger no_dupe
before update on Restrictors
for each row
begin
	declare msg varchar(255);
    
    if(new.courseNumber == new restrictorID) then
		set msg = concat('Courses cannot restrict them selves', cast(new.courseNumber as char));
        signal sqlstate '45000' set message_text = msg;
	end;
end$$
delimiter ;




/*
	3:
	Skrifið stored procedure sem leggur saman allar einingar sem nemandinn hefur lokið.
    Birta skal fullt nafn nemanda, heiti námsbrautar og fjölda lokinna eininga(
	Aðeins skal velja staðinn áfanga. passed = true
*/

delimiter $$
drop procedure if exists CourseList $$

create procedure CountThings(SID int)
begin
	select concat(firstName, " ", lastName) as name
    from students 
    where studentID = SID
    
    union all
    
    select trackID as track
    from registration
    where studentID = SID
    
    union all
    
    select count(courseNumber) as "Number of Courses"
    from registration
    where studentID = SID;
    
end $$
delimiter ;






/*
	4:
	Skrifið 3 stored procedure-a:
    AddStudent()
    AddMandatoryCourses()
    Hugmyndin er að þegar AddStudent hefur insertað í Students töfluna þá kallar hann á AddMandatoryCourses() sem skráir alla
    skylduáfanga á nemandann.
    Að endingu skrifið þið stored procedure-inn StudentRegistration() sem nota skal við sjálfstæða skráningu áfanga nemandans.
*/

delimiter $$
drop procedure if exists CourseList $$

create procedure AddStudent(fName varchar(55), lName varchar(55), DateOB date, startSem int, TID int)
begin
	insert into Students(firstName,lastName,dob,startSemester)values(fName, lName, DateOB, startSem);
    
    SID = select *from students ORDER BY id DESC LIMIT 1;
    
    AddMandatoryCourses(SID, TID)
end $$
delimiter ;


delimiter $$
drop procedure if exists CourseList $$

create procedure AddMandatoryCourses(SID int, TID int)
begin

	@counter = 0;

	while (select count(trackID) 
    from trackcourses 
    where mandatory && trackID == TID) >= counter
	begin
		insert into Registration
		(studentID,trackID,courseNumber,registrationDate,passed,semesterID)
		values
        (SID, 
		TID, 
			(select courseNumber
			from trackID
            order by courseNumber limit counter, 1),
		GETDATE(),
        false,
			(select semester
			from trackID
            order by courseNumber limit counter, 1)
        );
		

end $$
delimiter ;


delimiter $$
drop procedure if exists CourseList $$

create procedure StudentRegistration(SID int, TID int, courseNum char(10), semID int)
begin
		insert into Registration
		(studentID,trackID,courseNumber,registrationDate,passed,semesterID)
		values
        (SID,
		TID,
		courseNum,
		GETDATE(),
        false,
		semID);
end $$
delimiter ;
