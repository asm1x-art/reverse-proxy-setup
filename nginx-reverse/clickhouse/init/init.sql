CREATE DATABASE IF NOT EXISTS logs_db;

CREATE TABLE IF NOT EXISTS logs_db.request_logs
(
    request_id String,
    user       String,
    ip         String,
    host       String,
    uri        String,
    method     String,
    args       String,
    body       String,
    time       DateTime
)
ENGINE = MergeTree()
ORDER BY (time)
SETTINGS storage_policy = 'with_archive'
TTL time + INTERVAL 14 DAY TO VOLUME 'archive';