
-- BREAKDOWN BETWEEN THE MALE AND FEMALE EMPLOYEES WORKING IN THE COMPANY EACH YEAR, STARTING FROM 1990.

-- This query extracts the year from the t_dept_emp table. Then it extracts the gender from the t_employees table.
-- It then counts the number of employees in the t_employees table. This table is used as it contains distinct emp_no.

SELECT
	YEAR(d.from_date) AS calendar_year,
    e.gender,
    COUNT(e.emp_no) AS no_of_employees
FROM 
	t_employees e
JOIN 
	t_dept_emp d ON e.emp_no = d.emp_no
GROUP BY calendar_year, e.gender
HAVING calendar_year >= 1990;

-- COMPARING THE NUMBER OF MALE MANAGERS TO THE NUMBER OF FEMALE MANAGERS FROM DIFFERENT DEPARTMENTS FOR EACH YEAR, STARTING FROM 1990.

SELECT
	d.dept_name,
    ee.gender,
	dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
		WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
	END AS active
FROM
	(SELECT
		YEAR(hire_date) AS calendar_year
	FROM
		t_employees
	GROUP BY calendar_year) e
CROSS JOIN 
	t_dept_manager dm
JOIN 
	t_departments d ON d.dept_no = dm.dept_no
JOIN 
	t_employees ee ON ee.emp_no = dm.emp_no
ORDER BY dm.emp_no, calendar_year;


-- COMPARING THE AVERAGE SALARY OF FEMALE VERSUS MALE EMPLOYEES IN THE ENTIRE COMPANY UNTIL YEAR 2002.

SELECT
	e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS avg_salary,
    YEAR(s.from_date) AS calendar_year 
FROM 
    t_employees e
JOIN 
	t_salaries s ON s.emp_no = e.emp_no
JOIN
	t_dept_emp de ON s.emp_no = de.emp_no
JOIN 
	t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;


-- CREATE AN SQL STORED PROCEDURE THAT WILL OBTAIN THE AVERAGE MALE AND FEMALE SALARY PER DEPARTMENT WITHIN A CERTAIN SALARY RANGE. 
-- LET THIS RANGE BE DEFINED BY TWO VALUES THE USER CAN INSERT WHEN CALLING THE PROCEDURE.

DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$

CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
	SELECT
		e.gender,
        d.dept_name,
        AVG(s.salary) AS avg_salary
	FROM
		t_salaries s
	JOIN
		t_employees e ON s.emp_no = e.emp_no
	JOIN
		t_dept_emp de ON e.emp_no = de.emp_no
	JOIN 
		t_departments d ON d.dept_no = de.dept_no
	WHERE salary BETWEEN p_min_salary AND p_max_salary
    GROUP BY d.dept_no, e.gender;
END$$

DELIMITER ;

CALL filter_salary(50000, 90000);








