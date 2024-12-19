-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

---- EDA

select count(*) from spotify
select count(DISTINCT artist ) from spotify
select count(DISTINCT album ) from spotify
select DISTINCT album_type FROM spotify

select MAX(duration_min) from spotify
select MIN(duration_min) from spotify

SELECT * from spotify
where duration_min = 0

DELETE FROM spotify
WHERE duration_min = 0;
SELECT * from spotify
where duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_Played_on FROM spotify;

/*
-- ---------------------------------
-- Data Analysis -Easy Category
-- ---------------------------------
1.Retrieve the names of all tracks that have more than 1 billion streams.
2.List all albums along with their respective artists.
3.Get the total number of comments for tracks where licensed = TRUE.
4.Find all tracks that belong to the album type single.
5.Count the total number of tracks by each artist.
*/

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
WHERE stream > 1000000000
-- Q.2 List all albums along with their respective artists.

SELECT
DISTINCT album, artist
FROM spotify
order by 1

SELECT
DISTINCT album
FROM spotify
order by 1

-- Q.3 Get the total number of comments for tracks where licensed = TRUE.

SELECT 
SUM(comments) as total_comments
FROM spotify
WHERE licensed = 'true'

-- Q.4 Find all tracks that belong to the album type single.

SELECT * FROM spotify
WHERE album_type = 'single'

-- Q.5 Count the total number of tracks by each artist.

SElECT 
     artist,
	 count(*) as total_no_songs 
from spotify
group by artist
order by 2

/*
-- ------------------------------
   --Medium Level
-- ------------------------------
6.Calculate the average danceability of tracks in each album.
7.Find the top 5 tracks with the highest energy values.
8.List all tracks along with their views and likes where official_video = TRUE.
9.For each album, calculate the total views of all associated tracks.
10.Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q.6 Calculate the average danceability of tracks in each album.
SELECT
    album,
	avg(danceability) as avg_danceability
FROM spotify
group by 1	
order by 2 desc

-- Q.7 Find the top 5 tracks with the highest energy values.
SELECT 
    track,
	max(energy)
FROM spotify 
group by 1
order by 2 desc
LIMIT 5

-- Q.8 List all tracks along with their views and likes where official_video = TRUE.
SELECT 
    track,
	SUM(views) as total_views,
	Sum(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
group by 1
order by 2 desc
LIMIT 5

-- Q.9 For each album, calculate the total views of all associated tracks.
SELECT 
    album,
	track,
	SUM(views) as total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC\

-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT 
    track,
	-- most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY 1
) as t1
WHERE 
     streamed_on_spotify > streamed_on_youtube
     AND
	 streamed_on_youtube <> 0

/*	 
-- ---------------------------------------
-- Advanced Problem
-- ---------------------------------------
11.Find the top 3 most-viewed tracks for each artist using window functions.
12.Write a query to find tracks where the liveness score is above the average.
13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- Q.11 Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist
AS
(SELECT 
    artist,
	track,
	SUM(views) as total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views)DESC) as rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <= 3


-- Q.12 Write a query to find tracks where the liveness score is above the average.
SELECT 
    track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
-- SELECT AVG(liveness) FROM spotify -- 0.19


-- Q.13
--Use a WITH clause to calculate the difference between
--the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
   album,
   MAX(energy) as highest_energy,
   MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1
)
SELECT
    album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC


-- Query Optimization

EXPLAIN ANALYZE -- et 7.97 ms pt 0.112ms
SELECT 
   artist,
   track,
   views
FROM spotify
WHERE artist = 'Gorillaz'
     AND
	 most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25	 






