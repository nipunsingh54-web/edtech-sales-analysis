CREATE TABLE edtech_sales_data (
    record_id INT PRIMARY KEY,
    enrollment_id VARCHAR(50),
    student_id INT,
    gender VARCHAR(20),
    age INT,
    enrollment_date DATE,
    month VARCHAR(20),
    enrollment_status VARCHAR(50),
    lead_source VARCHAR(100),
    course_code VARCHAR(50),
    course VARCHAR(100),
    fees INT,
    city VARCHAR(100)
);


-- 1. View Complete Dataset
-- =========================
select * from edtech_sales_data


-- 2. Total Enrollments
-- =====================
select count(*) AS Total_enrollments from edtech_sales_data


-- 3. Total Revenue from Enrolled Students
-- Purpose: Calculate total revenue generated
-- ===========================================
select sum(fees) AS total_revenue from edtech_sales_data
where enrollment_status = 'Enrolled';


-- 4. Revenue & Students by Course
-- Purpose: Identify top-performing courses based on
--          total students and revenue generated
-- =============================================
select course,
count(*) as total_students,
sum(fees) as revenue
from edtech_sales_data
where enrollment_status = 'Enrolled'
group by course
order by revenue DESC;


-- 5. Top 5 Cities by Enrollments
-- Purpose: Identify cities with highest student demand
-- ====================================================
select city,
count(*) as enrollments
from edtech_sales_data
group by city
order by enrollments DESC
limit 5;


-- 6. Monthly Enrollment Trend
-- Purpose: Analyze enrollment growth month-over-month
-- ===================================================
select 
date_trunc('month', enrollment_date) AS month,
count(*) as total_enrollments
from edtech_sales_data
group by date_trunc('month', enrollment_date)
order by month;


-- 7. Gender-wise Student Distribution
-- Purpose: Understand demographic distribution
-- =============================================
select gender,
count(*) as total
from edtech_sales_data
group by gender;


-- 8. Revenue by City and Course
-- Purpose: Identify high-revenue course combinations
--          across different cities
-- ================================
select city,
course,
sum(fees) as revenue
from edtech_sales_data
where enrollment_status = 'Enrolled'
group by city, course
order by city, revenue DESC;


-- 9. Monthly Revenue Trend
-- Purpose: Track revenue performance over time
-- ============================================
select 
date_trunc('month', enrollment_date) as month,
sum(fees) as revenue
from edtech_sales_data
where enrollment_status = 'Enrolled'
group by date_trunc('month', enrollment_date)
order by revenue DESC;




