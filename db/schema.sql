CREATE TABLE `artists` (
	`id` INTEGER PRIMARY KEY,
	`artist` VARCHAR(255) NOT NULL
);
CREATE INDEX `artist` ON `artists` ( `artist` ) ;

CREATE TABLE `albums` (
	`id` INTEGER PRIMARY KEY,
	`artist_id` INT NOT NULL,
	`album` VARCHAR(255) NOT NULL
);
CREATE INDEX `artist_album` ON `albums` (`artist_id`, `album`) ;

CREATE TABLE `genres` (
	`id` INTEGER PRIMARY KEY,
	`genre` VARCHAR(255) NOT NULL
) ;
CREATE INDEX `genre` ON `genres` ( `genre` ) ;

CREATE TABLE `tracks` (
	`id` INTEGER PRIMARY KEY,
	`track_number` INT,
	`artist_id` INT NOT NULL,
	`album_id` INT NOT NULL,
	`title` VARCHAR NOT NULL,
	`genre_id` INT,
	`length` INT,
	`comment` VARCHAR
) ;
CREATE INDEX `track_artist` ON `tracks` (`artist_id`) ;
CREATE INDEX `track_album` ON `tracks` (`album_id`) ;
CREATE INDEX `track_genre` ON `tracks` (`genre_id`) ;
CREATE INDEX `track_title` ON `tracks` (`title`) ;
