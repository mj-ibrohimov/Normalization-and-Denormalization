DO
$$
    DECLARE
        den_data record;
    BEGIN

        for den_data in
            select distinct
                on (t.track_id) t.*,
                                alb.album_id,
                                alb.album_name,
                                art.artist_id,
                                art.artist_name,
                                art.artist_popularity,
                                pls.playlist_id,
                                pls.playlist_url,
                                pls.year_,
                                gnr.genre_id,
                                gnr.genre_name
            from public.tracks t
                     JOIN public.album_tracks at
                          on at.track_id = t.track_id
                     JOIN public.albums alb on alb.album_id = at.album_id
                     JOIN public.track_artists ta on ta.track_id = t.track_id
                     JOIN public.artists art on art.artist_id = ta.artist_id
                     JOIN public.playlist_tracks pt on pt.track_id = t.track_id
                     JOIN public.playlists pls on pls.playlist_id = pt.playlist_id
                     JOIN public.artist_genres ag on ag.artist_id = art.artist_id
                     JOIN public.genres gnr on gnr.genre_id = ag.genre_id
            where not exists (select * from denormalized_model.fact_tracks e where e.track_id = t.track_id )
            loop

                -- inserting into denormalized_model.dim_albums table
                if not exists (select * from denormalized_model.dim_albums e where e.album_id = den_data.album_id) then
                    insert
                    into denormalized_model.dim_albums(album_id, album_name)
                    values (den_data.album_id, den_data.album_name);
                end if;
 
               -- inserting into denormalized_model.dim_genres table
                if
                    not exists(select * from denormalized_model.dim_genres e where e.genre_id = den_data.genre_id) then
                    insert into denormalized_model.dim_genres(genre_id, genre_name)
                    values (den_data.genre_id, den_data.genre_name);
                end if;

                -- inserting into denormalized_model.dim_artists table
                if
                    not exists(select * from denormalized_model.dim_artists e where e.artist_id = den_data.artist_id) then
                    insert into denormalized_model.dim_artists(artist_id, artist_name,genre_id,artist_popularity)
                    values (den_data.artist_id, den_data.artist_name,den_data.genre_id, den_data.artist_popularity);
                end if;

                -- inserting into denormalized_model.dim_playlists table
                if
                    not exists(select *
                               from denormalized_model.dim_playlists e
                               where e.playlist_id = den_data.playlist_id) then
                    insert into denormalized_model.dim_playlists(playlist_id, playlist_url, year_)
                    values (den_data.playlist_id, den_data.playlist_url, den_data.year_);
                end if;

                -- inserting into denormalized_model.dim_tracks table
                insert into denormalized_model.fact_tracks(track_id, track_name, track_popularity, album_id, artist_id,
                                                      playlist_id, duration_ms, time_signature, danceability,
                                                      energy, key_, loudness, mode_, speechiness, acousticness,
                                                      instrumentalness, liveness, valence, tempo)

                values (den_data.track_id, den_data.track_name, den_data.track_popularity,
                        den_data.album_id,
                        den_data.artist_id,
                        den_data.playlist_id,
                        den_data.duration_ms, den_data.time_signature, den_data.danceability,
                        den_data.energy,
                        den_data.key_, den_data.loudness, den_data.mode_, den_data.speechiness, den_data.acousticness,
                        den_data.instrumentalness, den_data.liveness, den_data.valence, den_data.tempo);
            end loop;

    END
$$;