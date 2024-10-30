-- Create schema for denormalized model
CREATE SCHEMA IF NOT EXISTS denormalized_model;

-- Create fact table: fact_tracks
CREATE TABLE IF NOT EXISTS denormalized_model.fact_tracks
(
    track_id         VARCHAR(255) PRIMARY KEY,
    track_name       VARCHAR(255),
    track_popularity INTEGER,
    album_id         VARCHAR(255),
    artist_id        VARCHAR(255),
    playlist_id      VARCHAR(255),
    duration_ms      INTEGER,
    time_signature   INTEGER,
    danceability     DOUBLE PRECISION,
    energy           DOUBLE PRECISION,
    key_             INTEGER,
    loudness         DOUBLE PRECISION,
    mode_            INTEGER,
    speechiness      DOUBLE PRECISION,
    acousticness     DOUBLE PRECISION,
    instrumentalness DOUBLE PRECISION,
    liveness         DOUBLE PRECISION,
    valence          DOUBLE PRECISION,
    tempo            DOUBLE precision
);


-- Create dimension table: dim_artists
CREATE TABLE IF NOT EXISTS denormalized_model.dim_artists
(
    artist_id         VARCHAR(255) PRIMARY KEY,
    artist_name       VARCHAR(255),
    genre_id VARCHAR(255),
    artist_popularity INTEGER
    
);

-- Create dimension table: dim_playlists
CREATE TABLE IF NOT EXISTS denormalized_model.dim_playlists
(
    playlist_id  VARCHAR(255) PRIMARY KEY,
    playlist_url VARCHAR(255),
    year_        INTEGER
);

-- Create dimension table: dim_albums
CREATE TABLE IF NOT EXISTS denormalized_model.dim_albums
(
    album_id   VARCHAR(255) PRIMARY KEY,
    album_name VARCHAR(255)
);

-- Create dimension table: dim_genres
CREATE TABLE IF NOT EXISTS denormalized_model.dim_genres
(
    genre_id   VARCHAR(255) PRIMARY KEY,
    genre_name VARCHAR(255)
);



ALTER TABLE denormalized_model.fact_tracks
    DROP CONSTRAINT IF EXISTS track_album_fk;
ALTER TABLE denormalized_model.fact_tracks
    ADD CONSTRAINT track_album_fk FOREIGN KEY (album_id)
        REFERENCES denormalized_model.dim_albums (album_id);

ALTER TABLE denormalized_model.fact_tracks
    DROP CONSTRAINT IF EXISTS track_artist_fk;
ALTER TABLE denormalized_model.fact_tracks
    ADD CONSTRAINT track_artist_fk FOREIGN KEY (artist_id)
        REFERENCES denormalized_model.dim_artists (artist_id);

ALTER TABLE denormalized_model.fact_tracks
    DROP CONSTRAINT IF EXISTS track_playlist_fk;
ALTER TABLE denormalized_model.fact_tracks
    ADD CONSTRAINT track_playlist_fk FOREIGN KEY (playlist_id)
        REFERENCES denormalized_model.dim_playlists (playlist_id);

ALTER TABLE denormalized_model.dim_artists
	DROP CONSTRAINT IF EXISTS artist_genre_fk;
ALTER TABLE denormalized_model.dim_artists
	ADD CONSTRAINT artist_genre_fk FOREIGN KEY (genre_id)
		REFERENCES denormalized_model.dim_genres (genre_id);