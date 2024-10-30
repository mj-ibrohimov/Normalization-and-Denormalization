-- Displaying top 3 the most popular tracks for each playlist
-- Using DENSE_RANK to avoid any unnecessary skips
select
	*
from
	((
	select
		track_id,
		pls.playlist_url,
		trc.track_popularity,
		dense_rank() over (partition by trc.playlist_id
	order by
		track_popularity desc ) as Row_Id
	from
		denormalized_model.fact_tracks trc
	join denormalized_model.dim_playlists pls on
		trc.playlist_id = pls.playlist_id)) as tp
where
	Row_Id <= 3;