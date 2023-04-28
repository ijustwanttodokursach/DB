--1
SELECT name, surname from student WHERE score>=4 AND score<=4.5
SELECT name, surname from student WHERE score between 4 and 4.5
-- 2
SELECT  surname, name from student WHERE CAST(n_group AS varchar)LIKE '2%'
--3
SELECT n_group, name, surname FROM student ORDER BY n_group DESC, name ASC
--4
SELECT name, surname, score FROM student WHERE score>=4 ORDER BY score DESC
--5
SELECT name, risk from hobby WHERE id = 1 OR id = 2
--6
SELECT student_id, hobby_id FROM student_hobby WHERE date_start>='2005-05-05' AND date_start<='2015-11-11' AND date_finish IS NULL
--7
SELECT name, surname FROM student WHERE score>=4.5 ORDER BY score DESC
--8
SELECT score, name FROM student WHERE score=(SELECT MAX (score) from student)  GROUP BY name, score 
SELECT name, surname FROM student ORDER BY score DESC LIMIT 5
--9
SELECT name, CASE WHEN risk>=0.8 THEN 'очень высокий'
WHEN risk>=0.6 AND risk<0.8 THEN 'высокий'
WHEN risk>=0.4 AND risk<0.6 THEN 'средний'
WHEN risk>=0.2 AND risk<0.4 THEN 'низкий'
WHEN risk<0.2 THEN 'очени низкий'
 END FROM hobby 
--10
 SELECT name, risk FROM hobby ORDER BY risk DESC LIMIT 3