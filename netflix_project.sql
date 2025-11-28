-- Netflix Project
CREATE TABLE netflix
(
show_id	VARCHAR(7),
type VARCHAR(15),	
title VARCHAR(200),
director VARCHAR(250),	
casts VARCHAR(1000),	
country	VARCHAR(300),
date_added VARCHAR(50),	
release_year INT,	
rating VARCHAR(30),
duration VARCHAR(30),	
listed_in VARCHAR(300),
description VARCHAR(500)
);

SELECT *  FROM netflix
WHERE show_id='s8807';

SELECT COUNT(*) as total_data
FROM netflix;

SELECT *  FROM netflix;

-- TOTAL NO OF MOVIES AND SERIES ARE THERE IN DATASET
SELECT type,COUNT(type) as movie_series_ccnt
FROM netflix
GROUP BY type;

-- TOTAL NO NULL VALUES IN DIRECTOR COLUMN
SELECT COUNT(*) 
FROM netflix
WHERE director IS NULL OR TRIM(director) = '';

-- Business Problems & Its Solutions
'''
1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10. List all movies that are documentaries
11.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!#

12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
'''

-- 1. Count the number of Movies vs TV Shows

SELECT type,COUNT(type) AS total_no
FROM netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows
SELECT *  FROM netflix;

SELECT type,rating,common_rating
FROM(
	SELECT type,
	rating,
	COUNT(rating) as common_rating,
	RANK()OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) as rankings 
	FROM netflix
	GROUP by type,rating) as t1
WHERE rankings=1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE type='Movie' and release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT* FROM netflix;

SELECT unnest(string_to_array(country, ',')) AS new_country,COUNT(*) as total_content
FROM netflix
GROUP BY new_country
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT * from netflix;
SELECT MAX(minutes)
FROM(SELECT
    CASE
        WHEN duration LIKE '% min' THEN CAST(REPLACE(duration, ' min', '') AS INT)
        ELSE NULL
    END AS minutes
FROM netflix) as t1;
-- for better understanding
WITH cte_max_duration AS(SELECT
						show_id,
						title,
						type,
						CASE 
						WHEN duration LIKE '% min' THEN CAST(REPLACE(duration,' min', '')AS INT)
						ELSE NULL
						END  AS mins
						FROM netflix)
SELECT show_id,title,type,mins
FROM cte_max_duration
WHERE mins=(SELECT MAX(mins)
			FROM cte_max_duration);

-- 6 Find content added in the last 5 years
SELECT * FROM netflix;

SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD YYYY')>= CURRENT_DATE- INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type='TV Show'
AND 
SPLIT_PART(duration,' ',1)::NUMERIC >5;

--9. Count the number of content items in each genre
SELECT* FROM netflix;
-- MOST 5 watched genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,COUNT(show_id) as total_count
FROM netflix
GROUP BY genre
ORDER BY total_count DESC
LIMIT 5;
-- top 5 Least Watched genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,COUNT(show_id) as total_count
FROM netflix
GROUP BY genre
ORDER BY total_count ASC
LIMIT 5;

--10. List all movies that are documentaries

SELECT * FROM netflix

SELECT *
FROM netflix
WHERE type='Movie' 
AND listed_in LIKE '%Documentaries%';

--11. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;

-- 12 Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE casts ILIKE '%salman khan%'
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--13. Find the top 10 actors who have appeared in the highest number of movies produced in India.
WITH hight_actor_appered AS(SELECT 
show_id,
type,
UNNEST(STRING_TO_ARRAY(casts,',')) as cast1
FROM netflix
WHERE type='Movie' AND Country ILIKE'%India%'
)
SELECT cast1,COUNT(cast1) as total
FROM hight_actor_appered
GROUP BY cast1
ORDER BY total DESC;

--14.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!#

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
		COUNT(*) AS yearly_content,
		ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*)
						   FROM netflix
						   WHERE country='India'),2)::NUMERIC*100 as AVG_Country_Content_released
FROM netflix
WHERE country='India'
GROUP BY year;

'''15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
'''

SELECT *,
CASE
	WHEN
		description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad'
		ELSE 'Good'
		END Content_category
FROM netflix;

-- TOTAL COUNT OF GOOD AND BAD CONTENT

SELECT * FROM netflix;
WITH count_ct AS(SELECT *,
CASE
	WHEN
		description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad'
		ELSE 'Good'
		END Content_category
FROM netflix)
SELECT Content_category,COUNT(*) as total_cnt
FROM count_ct
GROUP BY Content_category;
