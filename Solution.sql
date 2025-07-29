-- Netflix Project 
drop table if exists netflix ;

create table netflix 
(
	show_id	varchar(6),
	type varchar(150),
	title varchar(150),	
	director varchar(208),	
	"cast" varchar(1000),	
	country	varchar(200),
	date_added varchar(50),	
	release_year int ,	
	rating varchar(10),
	duration varchar(15),	
	listed_in varchar(150),	
	description varchar(300)
);


select * from netflix



SELECT count(*) as total_content from netflix;



--1. Count the number of Movies vs TV Shows
SELECT distinct type from netflix
group by type




--2. Find the most common rating for movies and TV shows
select
type,
rating 
from
(
SELECT type,
rating,
count(*),
rank() over(partition by type order by count(*) desc) as ranking -- 
from netflix 
group by 1,2) as t1
where ranking=1;



--3. List all movies released in a specific year (e.g., 2020)

select title, release_year from netflix
where release_year= '2020' and type ='Movie' ;



--4. Find the top 5 countries with the most content on Netflix
select
	unnest(string_to_array(country, ',')) as new_country,
	count(show_id) as total_content
from netflix
group by 1 
order by total_content desc
limit 5; 


--5. Identify the longest movie
select *
from netflix
where type = 'Movie' and duration = (select max(duration) from netflix);




--6. Find content added in the last 5 years
select title , date_added
from netflix
where TO_DATE(date_added, 'Month DD, YYYY') < CURRENT_DATE - INTERVAL '5 days';


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select *
from netflix
where director ILIKE '%Rajiv Chilaka%';



--8. List all TV shows with more than 5 seasons
select title
from netflix
where type = 'TV Show' and cast(split_part(duration,' ',1) as integer) > 5 ;


--9. Count the number of content items in each genre
select 
	unnest(string_to_array(listed_in,',')),
	count(show_id) as total_content	
from netflix
group by 1
order by 2 desc;



--10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!
select *
from netflix


select 
	extract(year from TO_DATE(date_added, 'Month DD, YYYY')) as year, 
	count(*) as yearly_content,
	round(
	count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric*100,2) as avg_content_per_year
from netflix 
where country = 'India'
group by 1;


--11. List all movies that are documentaries
select title 
from ( 
select 
	title,
	trim(unnest(string_to_array(listed_in,','))) as kind_of_mv
from netflix) as t 
where kind_of_mv = 'Documentaries'

-- OR another one possible query is:
select * from netflix
where listed_in ilike '%documentaries%'


--12. Find all content without a director
select *
from netflix
where director is null


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * 
from netflix
where 
"cast" ilike '%Salman Khan%' and release_year> extract(year from current_date) - 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	unnest(string_to_array("cast",',')) as unit_cast,
	count(*) as total_content
from netflix
where country= 'India'
group by unit_cast
order by total_content desc
limit 10


/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

with new_table
as
(
select *,
case 
	when 	
		description ilike '%kill%' or
		description ilike '%violence%' then 'bad content'
	else 'good content' 
end as category 
from netflix
)
select 
	category,
	count(*) as total_content
from new_table
group by category;



-- -- Extra tasks--


--a)  Understanding what content is available in different countries
select
	u_country,
	STRING_AGG(DISTINCT unit_list, ', ') AS all_categories,
	COUNT(DISTINCT TRIM(unit_list)) AS total_categories
from
(
select  trim(unnest(string_to_array(country,','))) as u_country, 
		trim(unnest(string_to_array(listed_in,','))) as unit_list
from netflix
WHERE country IS NOT NULL AND listed_in IS NOT NULL
)
group by u_country
order by total_categories desc


--  Does Netflix has more focus on TV Shows than movies in recent years.
select 
	 extract(year from TO_DATE(date_added, 'Month DD, YYYY')) as "year",
	 COUNT(CASE WHEN type = 'Movie' THEN 1 END) AS total_movies,
  	 COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS total_tv_shows,
	 count(*) as "sum"
from netflix
where date_added is not null
group by "year"
order by "year" desc