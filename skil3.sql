use ProgresSTracker_V6;
/*
1:
	Skrifið STored procedure: STudentLiSTJSon() sem notar cursor til að breyta vensluðum gögnum í JSon STring.
	JSon-formuð gögnin eru liSTi af objeCTum.
	OBS: STudentLiSTJSon skilar texta sem þið hafið formað.

	NiðurSTöðurnar ættu að líta einhvern vegin svona út:

	[
		  {"firST_name": "Guðrún", "laST_name": "Ólafsdóttir", "date_of_birth": "1999-03-31"},
		  {"firST_name": "Andri Freyr", "laST_name": "Kjartansson", "date_of_birth": "2000-11-01"},
		  {"firST_name": "Tinna Líf", "laST_name": "Björnsson", "date_of_birth": "1998-08-14"},
		  {"firST_name": "Magni Þór", "laST_name": "SIgurðsson", "date_of_birth": "2000-05-27"},
		  {"firST_name": "Rheza Már", "laST_name": "Hamid-Davíðs", "date_of_birth": "2001-09-17"},
		  {"firST_name": "Hadría Gná", "laST_name": "Schmidt", "date_of_birth": "1999-07-29"},
		  {"firST_name": "Jasmín Rós", "laST_name": "STefánsdóttir", "date_of_birth": "1996-02-29"}
	]
*/
delimiter $$
drop procedure if exiSTs STudentJSon $$
create procedure STudentJSon()
begin
declare FN varchar(255);
declare LN varchar(255);
declare dob date;
declare done int default false;
    declare JSONtxt longtext;
   
    declare C1 cursor 
		for seleCT firSTName, laSTName, dob from STudents;
           
declare continue handler for not found set done = true;
set JSONtxt = '[';
open C1;
   
C1: loop
fetch C1 into FN,LN,dob;
        if done then leave C1;
end if;
        set JSONtxt = concat(JSONtxt, '{"firST_name": ','"', FN,'", ',
										'"laST_name": ','"', LN, '", ',
                                        '"date_of_birth": ','"', dob, '"},');
end loop;

	set JSONtxt = trim(trailing ',' from JSONtxt);
set JSONtxt = concat(JSONtxt,']');

close C1;
seleCT JSONtxt;
end $$
delimiter ;
call STudentJSon();

/*
	2:
	Skrifið nú SIngleSTudentJSon()þannig að nemandinn innihaldi nú liSTa af þeim áföngum sem hann hefur tekið.
	Śé nemandinn enn við nám þá koma þeir áfangar líka með.
	ATH: setjið nemandann sem objeCT.
	Líkleg niðurSTaða:

	{
		"STudent_id": "1",
		"firST_name": "Guðrún",
		"laST_name": "Ólafsdóttir",
		"date_of_birth": "1999-03-31",
		"courses" :[
		  {"course_number": "STÆ103","course_credits": "5","STatus": "pass"},
		  {"course_number": "EÐL103","course_credits": "5","STatus": "pass"},
		  {"course_number": "STÆ203","course_credits": "5","STatus": "pass"},
		  {"course_number": "EÐL203","course_credits": "5","STatus": "pass"},
		  {"course_number": "STÆ303","course_credits": "5","STatus": "pass"},
		  {"course_number": "GSF2A3U","course_credits": "5","STatus": "pass"},
		  {"course_number": "FOR3G3U","course_credits": "5","STatus": "pass"},
		  {"course_number": "GSF2B3U","course_credits": "5","STatus": "pass"},
		  {"course_number": "GSF3B3U","course_credits": "5","STatus": "fail"},
		  {"course_number": "FOR3D3U","course_credits": "5","STatus": "fail"}
		]
	}
*/
delimiter $$
drop procedure if exiSTs SIngleSTudentJSon $$
create procedure SIngleSTudentJSon()
begin
declare CN varchar(255);
declare ST varchar(255);
declare pass bool;
declare done int default false;
    declare JSONtxt longtext;
   
    declare C1
cursor for
seleCT Courses.courseNumber, Courses.courseCredits, RegiSTration.passed
from Courses
join RegiSTration on Courses.courseNumber = RegiSTration.courseNumber;

declare continue handler for not found set done = true;
set JSONtxt = '[';

seleCT concat('"STudentID": ','"', STudents.STudentID,'", ',
			  '"firSTName": ','"', STudents.firSTName,'", ',
			  '"laSTName": ','"', STudents.laSTName,'", ',
              '"date_of_birth": ','"', STudents.dob,'"},') into JSONtxt
from STudents
where STudents.STudentID = 1;

open C1;

C1: loop
fetch C1 into CN,ST,pass;
        if done then leave C1;
end if;
        -- Nota concat fallið til að setja saman JSon STrenginn
        set JSONtxt = concat(JSONtxt, '{"courseNumber": ','"', CN,'", ',
										'"courseCredits": ','"', ST,'", ',
                                        '"STatus": ','"', pass, '"},');
end loop;

	set JSONtxt = trim(trailing ',' from JSONtxt);
set JSONtxt = concat(JSONtxt,']');

close C1;
seleCT JSONtxt;

end $$
delimiter ;
call SIngleSTudentJSon();
/*
	3:
	Skrifið STored procedure: SemeSTerInfoJSon() sem birtir uplýSIngar um ákveðið semeSTer.
	SemeSTrið inniheldur liSTa af nemendum sem eru /hafa verið á þessu semeSTri.
	Og að sjálfsögðu eru gögnin á JSon formi!

	Gæti litið út einhvern veginn svona(hérna var semeSTerID 8 notað á original gögnin:
	[
		{"STudent_id": "1", "firST_name": "Guðrún", "laST_name": "Ólafsdóttir", "courses_taken": "2"},
		{"STudent_id": "2", "firST_name": "Andri Freyr", "laST_name": "Kjartansson", "courses_taken": "1"},
		{"STudent_id": "5", "firST_name": "Rheza Már", "laST_name": "Hamid-Davíðs", "courses_taken": "2"},
		{"STudent_id": "6", "firST_name": "Hadríra Gná", "laST_name": "Schmidt", "courses_taken": "2"}
	]
*/
delimiter $$
drop procedure if exiSTs SemeSTerInfoJSon $$
create procedure SemeSTerInfoJSon()
begin
declare SI int;
declare FN varchar(255);
declare LN varchar(255);
declare CT int;

declare done int default false;
    
    declare JSONtxt longtext;
   
    declare C1
cursor for
seleCT STudents.STudentID, STudents.firSTName, STudents.laSTName, count(courseNumber) as number_of_courses
from STudents
inner join RegiSTration on STudents.STudentID = RegiSTration.STudentID
and RegiSTration.semeSTerID = SI
group by STudents.STudentID;

declare continue handler for not found set done = true;
set JSONtxt = '[';

open C1;

C1: loop
fetch C1 into SI,FN,LN,CT;
        if done then leave C1;
end if;
        set JSONtxt = concat(JSONtxt, '{"STudent_id": ','"', SI,'", ',
										'"firST_name": ','"', FN,'", ',
                                        '"laST_name": ','"', LN,'", ',
                                        '"course_taken": ','"', CT, '"},');
end loop;

	set JSONtxt = trim(trailing ',' from JSONtxt);
set JSONtxt = concat(JSONtxt,']');

close C1;
seleCT JSONtxt;

end $$
delimiter ;
call SemeSTerInfoJSon();

