-- в запросах номером зачётки является id студента
-- 1
SELECT student.name, hobby.name from student, hobby, student_hobby
WHERE student_hobby.student_id = student.id AND
 student_hobby.hobby_id = hobby.id

 --2
 SELECT student.name, hobby.name, MAX(student_hobby.date_finish - student_hobby.date_start) as duration
FROM student_hobby
JOIN student ON student.id = student_hobby.student_id
JOIN hobby ON hobby.id = student_hobby.hobby_id
GROUP BY student.id, hobby.id
HAVING MAX(student_hobby.date_finish - student_hobby.date_start) IS NOT NULL
ORDER BY duration desc
LIMIT 1

--3
SELECT student.id, student.surname, student.name, 
student.date_birth
FROM student_hobby
JOIN student on student.id = student_hobby.student_id
JOIN hobby on hobby.id = student_hobby.hobby_id
WHERE student.score > (SELECT AVG(score) from student)
AND (SELECT SUM(risk) from hobby) > 0.9

--4
SELECT student.id, student.date_birth, student.name, student.surname,
12 * extract(year from age(date_finish, date_start)) duration_months + extract(month from age(date_start)),
hobby.name
FROM student_hobby
JOIN student on student.id = student_hobby.student_id
JOIN hobby on hobby.id = student_hobby.hobby_id
WHERE student_hobby.date_finish IS NOT NULL
AND student_hobby.date_start IS NOT NULL

--5
SELECT student.name, student.surname, student.id, student.date_birth
FROM student
JOIN student_hobby ON student_hobby.student_id = student.id
WHERE student_hobby.date_finish IS NOT NULL
AND extract(years from age(student.date_birth))>18
GROUP BY student.id
HAVING COUNT(*) > 1
--6 
SELECT student.n_group, AVG(student.score) 
FROM student
JOIN student_hobby ON student_hobby.student_id = student.id
WHERE student_hobby.date_finish IS NOT NULL
GROUP BY student.n_group
HAVING count(*)>0

--7
SELECT hobby.name, risk, 12 * extract(year from age(date_finish, date_start)) + extract(month from age(date_start))duration_months,
student.id student_id
from student_hobby
JOIN hobby on hobby.id = student_hobby.hobby_id
JOIN student on student.id = student_hobby.student_id
GROUP BY student.id, hobby.name, hobby.risk, date_start, date_finish
HAVING age(date_finish, date_start)=MAX(age(date_finish, date_start))
ORDER BY duration_months DESC
LIMIT 1

--8 
SELECT hobby.name, student.id, student.score
FROM student_hobby
JOIN hobby on student_hobby.hobby_id = hobby.id
JOIN student on student.id = student_hobby.student_id
GROUP BY hobby.name, student.id
HAVING student.score = (SELECT MAX(score) from student)

--9 
SELECT hobby.name
FROM student_hobby
JOIN hobby on student_hobby.hobby_id = hobby.id
JOIN student on student.id = student_hobby.student_id
GROUP BY hobby.name, student.n_group, student.score
HAVING substr(CAST(n_group AS VARCHAR), 1, 1) = '2'
AND substr(CAST(student.score AS VARCHAR), 1, 1) = '3'

-- 10
SELECT z1.course
FROM
(SELECT count(hC) cnt, z2.course from
(SELECT student_id hC, substr(CAST(n_group AS VARCHAR), 1, 1)
course
FROM student_hobby
JOIN student on student_hobby.student_id = student.id
GROUP BY course, student_id
HAVING count(CASE WHEN student_hobby.date_finish IS NULL THEN 1 END)>1) z2
GROUP BY z2.course) 
z3
JOIN (SELECT count(student.id) allC, substr(CAST(n_group AS VARCHAR), 1, 1) course
from student
group by course) z1 on z1.course = z3.course
where 0.5*allc<cnt

-- 11
SELECT z1.course
FROM
(SELECT count(hC) cnt, z2.course from
(SELECT id hC, substr(CAST(n_group AS VARCHAR), 1, 1)
course
FROM student
WHERE score>=4) z2
GROUP BY z2.course) 
z3
JOIN (SELECT count(student.id) allC, substr(CAST(n_group AS VARCHAR), 1, 1) course
from student
group by course) z1 on z1.course = z3.course
where 0.6*allc<cnt

-- 12
SELECT count(DISTINCT hobby_id), course
FROM student_hobby
JOIN (SELECT student.id stid, substr(CAST(n_group AS VARCHAR), 1, 1) course
from student
group by student.id)sub1 on stid = student_id
WHERE date_finish IS NULL 
GROUP BY course

-- 13
SELECT student.id, student.surname, student.name, student.date_birth
from student_hobby
FULL JOIN student on student_hobby.student_id = student.id
WHERE student_hobby.student_id IS NULL

-- 14
CREATE OR REPLACE VIEW V1 AS
SELECT student.id, student.surname, student.name, student.date_birth
from student_hobby
JOIN student on student.id = hobby_id
WHERE date_finish IS NULL AND extract(years from (age(date_start))) >=5;
Select * from V1

--15 
SELECT count(student_id), hobby.name
FROM student_hobby
JOIN hobby on student_hobby.hobby_id = hobby.id
GROUP BY hobby.name

-- 16
SELECT hobby.id
FROM student_hobby
JOIN hobby on student_hobby.hobby_id = hobby.id
GROUP BY hobby.id
ORDER BY count(student_id) DESC
LIMIT 1

-- 17
SELECT student.name, student.surname, student.date_birth, student.n_group
from student_hobby
JOIN student on student.id = student_id
JOIN hobby on hobby.id = hobby_id
WHERE hobby.id = (SELECT hobby.id id_h
FROM student_hobby
JOIN hobby on student_hobby.hobby_id = hobby.id
GROUP BY hobby.id
ORDER BY count(student_id) DESC
LIMIT 1) 

-- 18
SELECT h.id, h.risk FROM hobby h
ORDER BY h.risk DESC LIMIT(3)

-- 19
SELECT DISTINCT student.n_group
from student_hobby
JOIN student on student_id = student.id
ORDER BY age(date_start, date_finish) DESC
LIMIT 10

-- 20
SELECT DISTINCT n_group
FROM (SELECT n_group
from student_hobby
JOIN student on student_id = student.id
ORDER BY age(date_start, date_finish) DESC
LIMIT 10) z1

-- 21
CREATE OR REPLACE VIEW V2 AS
SELECT id, n_group, name, surname, score
FROM student
ORDER BY score DESC;
SELECT * from V2

-- 22 - Выводит для каждого курса все самые популярные хобби
-- например, если на каком-то курсе несколько хобби одинаково максимально популярны
-- то они будут выведены все
--
CREATE OR REPLACE VIEW V3 AS
SELECT z3.course, nm from(
    SELECT MAX(cnt) mx, nm
from (SELECT hobby.name nm, count(hobby_id) cnt, substr(CAST(n_group AS VARCHAR), 1, 1) course
 from student_hobby
JOIN student on student.id = student_id
JOIN hobby on hobby_id = hobby.id
 GROUP BY course, hobby.name
) z1
GROUP BY nm) z2
JOIN
(SELECT MAX(cnt) mx, course
from (SELECT hobby.name nm, count(hobby_id) cnt, substr(CAST(n_group AS VARCHAR), 1, 1) course
 from student_hobby
JOIN student on student.id = student_id
JOIN hobby on hobby_id = hobby.id
 GROUP BY course, hobby.name
) z1
GROUP BY course ) z3 on z3.mx = z2.mx;
SELECT * from V3

-- 23
CREATE OR REPLACE VIEW V4 AS
with h1 AS(
    SELECT substr(CAST(n_group AS VARCHAR), 1, 1) as course,
    hobby_id
    from student_hobby
    JOIN student on student.id = student_id
    WHERE
    substr(CAST(n_group AS VARCHAR), 1, 1) = '2'
), h2 AS(
    SELECT count(hobby_id) cnt, hobby_id from h1
    GROUP BY hobby_id
), h3 AS(
    SELECT max(cnt) mx
    FROM h2
), h4 AS(
    SELECT hobby_id hid from h2,h3
    WHERE h2.cnt = h3.mx
), h5 AS(
    SELECT hobby.name nam, hobby.risk from h4
    INNER JOIN hobby ON hobby.id = hid 
), h6 AS(
    SELECT max(risk) mr from h5
)
SELECT nam 
from h5, h6
WHERE risk = h6.mr

-- 24
CREATE OR REPLACE VIEW V5 AS
with h1 AS(
    SELECT count(student.id) all_stud, 
    substr(CAST(n_group AS VARCHAR), 1, 1) course
    FROM student
    group by course
), h2 AS(
    SELECT count(student.id) high_grades_st,
    substr(CAST(n_group AS VARCHAR), 1, 1) course
    FROM student
    WHERE score>4
    GROUP BY course
)
SELECT * from h1 JOIN
h2 ON h2.course = h1.course;
SELECT * from V5

--25
CREATE OR REPLACE VIEW p_hobby AS
SELECT h.*
from hobby h
JOIN student_hobby sh ON h.id=sh.hobby_id 
JOIN student st ON st.id=sh.student_id
WHERE sh.date_finish IS NULL
GROUP BY h.id, h.name
ORDER BY count(st.name) DESC
LIMIT (1);
SELECT *FROM p_hobby;

--26
CREATE OR REPLACE VIEW UPDATABLE AS
SELECT st.id, st.surname, st.name, st.n_group 
-- содержит первичный ключ, на одной таблице, нет DISTINCT, group by, HAVING
-- и т.д.
FROM students st

--27
SELECT substr(st.name::varchar, 1,1) Alphabet, Max(st.score), avg(st.score), min(st.score)
FROM student st
WHERE st.score>3.6
GROUP BY Alphabet

--28
SELECT substr(st.n_group::varchar, 1,1) as course, st.surname, max(st.score), min(st.score), avg(st.score)
FROM student st
GROUP BY course, st.surname

--29
SELECT extract(year from date_birth) as year, count(h.name)
FROM student st
JOIN student_hobby sh ON st.id=sh.student_id
JOIN hobby h ON h.id=sh.hobby_id
GROUP by year

--30
SELECT substr(st.name::varchar, 1,1) as alphabet, Max(h.risk), min(h.risk)
FROM student st
JOIN student_hobby sh ON st.id=sh.student_id 
JOIN hobby h ON h.id=sh.hobby_id
GROUP BY alphabet

--31
SELECT extract (month from date_birth) mn, student.score
from student_hobby
JOIN student on student_id = student.id
JOIN hobby on hobby_id = hobby.id
WHERE hobby.name = 'Футбол'
GROUP BY mn, score

-- 32
SELECT ' Имя: ' || st.name || ' Фамилия: ' || st.surname || ' Группа:' || st.n_group as students
FROM student st
FULL JOIN student_hobby sh ON st.id = sh.student_id
WHERE sh.date_start is not null

--33
SELECT st.surname,
case when position('ов' IN st.surname) = 0 then 'Нет'
else position('ов' IN st.surname)::varchar end
from student st

--34
SELECT rpad(st.surname,10,'#') 
FROM student st

--35
SELECT trim('#' FROM n_surname) 
FROM (SELECT rpad(st.surname,10,'#') as n_surname
FROM student st) as all_surname

-- 36
SELECT '2018-05-01'::date -'2018-04-01'::date

--37
SELECT EXTRACT(DOW FROM now ())  today,
CASE WHEN (EXTRACT(DOW FROM now ())::integer) = 1 THEN (now()::date+5)
WHEN (EXTRACT(DOW FROM now ())::integer) = 2 THEN (now()::date+4)
WHEN (EXTRACT(DOW FROM now ())::integer) = 3 THEN (now()::date+3)
WHEN (EXTRACT(DOW FROM now ())::integer) = 4 THEN (now()::date+2)
WHEN (EXTRACT(DOW FROM now ())::integer) = 5 THEN (now()::date+1)
WHEN (EXTRACT(DOW FROM now ())::integer) = 6 THEN (now()::date)
WHEN (EXTRACT(DOW FROM now ())::integer) = 7 THEN (now()::date+6)
END 

--38
SELECT EXTRACT(CENTURY FROM now ()) as century, EXTRACT(WEEK FROM now ()) as week, EXTRACT(DOY FROM now ()) as day

--39
SELECT st.name || ' ' || st.surname || ' ' || h.name || ' ' || CASE WHEN sh.date_finish IS NULL THEN 'занимается'
WHEN sh.date_finish IS NOT NULL THEN 'закончил'	END
FROM student st
JOIN student_hobby sh on sh.student_id=st.id
JOIN hobby h on h.id=sh.hobby_id
WHERE sh.date_start IS NOT NULL

--40
SELECT n_group as groups, 
count(score) filter(WHERE round(score) = '2') as "2",
count(score) filter(WHERE round(score) = '3') as "3",
count(score)filter(WHERE round(score) = '4') as "4",
count(score) filter(WHERE round(score) = '5') as "5"
FROM student 
GROUP BY n_group
ORDER BY n_group ASC

