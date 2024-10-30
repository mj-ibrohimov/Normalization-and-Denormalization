-- Selecting average track danceability for each genre
-- With this query, we can collect all danceable genres and give personalized recommendations
select
	distinct genre_name,
	AVG(danceability) over (partition by g.genre_id) as avg_danceability
from
	denormalized_model.fact_tracks t
join denormalized_model.dim_artists art on
	art.artist_id = t.artist_id
join denormalized_model.dim_genres g on
	g.genre_id = art.genre_id
order by
	avg_danceability desc
limit 10;