-- 1
SELECT n_group, COUNT(name) as num_students
FROM student
GROUP BY n_group;

-- 2
SELECT n_group, max(score) as ms FROM student
GROUP BY n_group

--3
SELECT count(surname), surname as sn 
FROM student 
GROUP BY surname

-- 4
SELECT count (extract(year from date_birth)), extract(year from date_birth)  FROM student
GROUP BY extract(year from date_birth)

-- 5
SELECT count(substr(CAST(n_group AS VARCHAR), 1, 1)), n_group from student
GROUP BY n_group

--6
SELECT count(n_group), n_group FROM student GROUP BY n_group
HAVING substr(CAST(n_group AS VARCHAR), 1, 1) = '4'

--7
SELECT 
  n_group, 
  AVG(score) AS avg_mark
FROM student
GROUP BY n_group
HAVING AVG(score) <= 3.5
ORDER BY avg_mark ASC;

--8 
SELECT n_group, count(name) as students, max(score) as max, avg(score) as average,
 min(score) as min from student
GROUP BY n_group

--9
SELECT name, score, n_group
FROM student
WHERE n_group =3011 AND score =
  (SELECT MAX(score) 
   FROM student
   WHERE n_group = 3011)
--10
SELECT n_group, name, score
FROM student
WHERE (score) in (SELECT 
max(score) from student GROUP BY n_group)