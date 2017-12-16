PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE albums(
card_uuid string,
album_name string,
listen_count integer
);
COMMIT;
