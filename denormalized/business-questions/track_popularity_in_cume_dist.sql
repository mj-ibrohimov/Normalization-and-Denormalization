-- Track popularity in cumulative distribution(CUME_DIST) grouped for each playlist

select
	trc.track_popularity,
	trc.playlist_id,
	ROUND((cume_dist() over (partition by trc.playlist_id
order by
	trc.track_popularity))::numeric,
	3) as cume_dist
from
	denormalized_model.fact_tracks trc;