Create or replace function public.random_string(length integer) returns text as
$$
declare
    chars  text[]  := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
    result text    := '';
    i      integer := 0;
begin
    if length < 0 then
        raise exception 'Given length cannot be less than 0';
    end if;
    for i in 1..length
        loop
            result := result || chars[1 + random() * (array_length(chars, 1) - 1)];
        end loop;
    return result;
end;
$$ language plpgsql;

-- inserting albums data
WITH raw_albums_data AS (select distinct e.album as album_name from public.playlists_data e)
insert
into public.albums
select public.random_string(22), album_name
from raw_albums_data
where not exists
          (select * from public.albums t where t.album_name = raw_albums_data.album_name);

-- inserting artists data
WITH raw_artists_data AS (select distinct e.artist_id, e.artist_name,e.artist_popularity from public.playlists_data e)
insert
into public.artists
select raw_artists_data.artist_id, raw_artists_data.artist_name, raw_artists_data.artist_popularity
from raw_artists_data
where not exists(select * from public.artists t where t.artist_id = raw_artists_data.artist_id);

-- inserting genres data
WITH raw_genres_data
--     extracting genres
         AS (select distinct trim(replace(unnest(string_to_array(
            REGEXP_REPLACE(playlists_data.artist_genres, '[\[\]]', '', 'g'),
            ',')), '''', '')) genre
             from public.playlists_data)
insert
into public.genres
select public.random_string(22), raw_genres_data.genre
from raw_genres_data
where not exists(select * from public.genres t where t.genre_name = raw_genres_data.genre);


-- inserting tracks

WITH raw_tracks_data AS (select distinct e.track_id,
                                         e.track_name,
                                         e.track_popularity,
                                         e.key_,
                                         e.duration_ms,
                                         e.time_signature,
                                         e.danceability,
                                         e.energy,
                                         e.loudness,
                                         e.mode_,
                                         e.speechiness,
                                         e.valence,
                                         e.tempo,
                                         e.liveness,
                                         e.instrumentalness,
                                         e.acousticness
                         from public.playlists_data e)
insert
into public.tracks
select e.track_id,
       e.track_name,
       e.track_popularity,
       e.key_,
       e.duration_ms,
       e.time_signature,
       e.danceability,
       e.energy,
       e.loudness,
       e.mode_,
       e.speechiness,
       e.liveness,
       e.valence,
       e.tempo,
       e.instrumentalness,
       e.acousticness
from raw_tracks_data e
where not exists (select * from public.tracks t where t.track_id = e.track_id);


-- inserting artist_genres
DO
$$
    DECLARE
        genre_name_ varchar;
        artist_id_  varchar;
        genre_      record;
    BEGIN
        for genre_name_,artist_id_ in select trim(replace(unnest(string_to_array(
                REGEXP_REPLACE(e.artist_genres, '[\[\]]', '', 'g'),
                ',')), '''', '')), e.artist_id from public.playlists_data e
            loop
                --             getting genre info
                select * into genre_ from public.genres where genre_name = genre_name_;
                --             checking if the relation already exists
                if genre_ is not null and
                   not exists ((select *
                                from public.artist_genres t
                                where artist_id_ = t.artist_id
                                  and genre_.genre_id = t.genre_id)) then

                    insert into public.artist_genres values (artist_id_, genre_.genre_id);
                end if;

            end loop;
    END
$$;

-- inserting album_tracks
DO
$$
    DECLARE
        track_id_   varchar;
        album_name_ varchar;
        album_      record;
    BEGIN
        for track_id_,album_name_ in
            select e.track_id, e.album from public.playlists_data e
            loop
                -- getting album by name
                select * into album_ from public.albums e where e.album_name = album_name_;

                if album_ is not null
                    and not exists(select *
                                   from public.album_tracks t
                                   where t.track_id = track_id_
                                     and t.album_id = album_.album_id) then
                    insert into public.album_tracks values (album_.album_id, track_id_);
                end if;
            end loop;
    END
$$;

-- inserting playlists

WITH raw_playlist_data AS (select distinct e.playlist_url,
                                           cast(e.year_ as integer)
                           from public.playlists_data e)
insert
into public.playlists
select public.random_string(22), raw_playlist_data.year_, raw_playlist_data.playlist_url
from raw_playlist_data
where not exists(select *
                 from public.playlists e
                 where e.playlist_url = raw_playlist_data.playlist_url
                   and e.year_ = raw_playlist_data.year_);


-- inserting playlist_tracks
WITH raw_playlist_trakcs AS (select e.playlist_url, e.track_id from public.playlists_data e)
insert
into public.playlist_tracks
select pl.playlist_id, raw_playlist_trakcs.track_id
from raw_playlist_trakcs
         JOIN public.playlists pl on pl.playlist_url = raw_playlist_trakcs.playlist_url
where not exists(select *
                 from public.playlist_tracks t
                 where t.playlist_id = pl.playlist_id
                   and t.track_id = raw_playlist_trakcs.track_id);


-- inserting track_artists

WITH raw_track_artists AS (
-- cleaning duplicates
    select e.track_id, e.artist_id
    from public.playlists_data e
    where (select count(*)
           from public.playlists_data t
           where e.artist_id = t.artist_id
             and e.track_id = t.track_id) = 1)
insert
into public.track_artists
select raw_track_artists.track_id, raw_track_artists.artist_id
from raw_track_artists
where not exists(select *
                 from public.track_artists t
                 where t.track_id = raw_track_artists.track_id
                   and t.artist_id = raw_track_artists.artist_id);