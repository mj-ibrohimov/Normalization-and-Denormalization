CREATE TABLE IF NOT EXISTS public.playlists
(
    "playlist_id"  VARCHAR(255) PRIMARY KEY,
    "year_"        INTEGER      NULL,
    "playlist_url" VARCHAR(255) NULL
);
CREATE TABLE IF NOT EXISTS public.tracks
(
    "track_id"         VARCHAR(255) PRIMARY KEY,
    "track_name"       VARCHAR(255)     NULL,
    "track_popularity" INTEGER          NULL,
    "key_"             INTEGER          NULL,
    "duration_ms"      INTEGER          NULL,
    "time_signature"   INTEGER          NULL,
    "danceability"     DOUBLE PRECISION NULL,
    "energy"           DOUBLE PRECISION NULL,
    "loudness"         DOUBLE PRECISION NULL,
    "mode_"            INTEGER          NULL,
    "speechiness"      DOUBLE PRECISION NULL,
    "liveness"         DOUBLE PRECISION NULL,
    "valence"          DOUBLE PRECISION NULL,
    "tempo"            DOUBLE PRECISION NULL,
    "instrumentalness" DOUBLE PRECISION NULL,
    "acousticness"     DOUBLE PRECISION NULL
);
CREATE TABLE IF NOT EXISTS public.artists
(
    "artist_id"   VARCHAR(255) PRIMARY KEY,
    "artist_name" VARCHAR(255) NULL,
    "artist_popularity" INTEGER
);
CREATE TABLE IF NOT EXISTS public.playlist_tracks
(
    "playlist_id" VARCHAR(255) NULL REFERENCES public.playlists (playlist_id),
    "track_id"    VARCHAR(255) NULL REFERENCES public.tracks (track_id),
    PRIMARY KEY ("playlist_id", "track_id")
);
CREATE TABLE IF NOT EXISTS public.genres
(
    "genre_id"   VARCHAR(255) PRIMARY KEY,
    "genre_name" VARCHAR(255) NULL
);
CREATE TABLE IF NOT EXISTS public.albums
(
    "album_id"   VARCHAR(255) PRIMARY KEY,
    "album_name" VARCHAR(255) NULL
);
CREATE TABLE IF NOT EXISTS  public.artist_genres
(
    "artist_id" VARCHAR(255) NOT NULL REFERENCES public.artists (artist_id),
    "genre_id"  VARCHAR(255) NOT NULL REFERENCES public.genres (genre_id),
    PRIMARY KEY ("artist_id", "genre_id")
);

CREATE TABLE IF NOT EXISTS public.album_tracks
(
    "album_id" VARCHAR(255) NULL REFERENCES public.albums (album_id),
    "track_id" VARCHAR(255) NULL REFERENCES public.tracks (track_id),
    PRIMARY KEY ("album_id", "track_id")
);
CREATE TABLE IF NOT EXISTS public.track_artists
(
    "track_id"  VARCHAR(255) NOT NULL REFERENCES public.tracks (track_id),
    "artist_id" VARCHAR(255) NOT NULL REFERENCES public.artists (artist_id),
    PRIMARY KEY ("track_id", "artist_id")
);
