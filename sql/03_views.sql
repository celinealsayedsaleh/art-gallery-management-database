CREATE VIEW vw_active_listing_overview AS
SELECT
    l.lid,
    l.list_price,
    l.currency,
    l.status,
    l.start_date,
    l.end_date,
    (CURRENT_DATE - l.start_date) AS days_active,
    a.aid AS artwork_id,
    a.title AS artwork_title,
    a.medium,
    a.year_created,
    g.gid AS gallery_id,
    g.name AS gallery_name,
    ar.uid AS artist_uid,
    COALESCE(ar.artist_name, u.first_name || ' ' || u.last_name) AS artist_display_name,
    (
        SELECT MAX(o.offer_amount)
        FROM offer o
        WHERE o.listing_id = l.lid
    ) AS highest_offer_amount
FROM listing l
JOIN artwork a
    ON l.artwork_id = a.aid
JOIN gallery g
    ON l.gallery_id = g.gid
JOIN artist ar
    ON a.artist_uid = ar.uid
JOIN "user" u
    ON ar.uid = u.uid
WHERE l.status = 'Active';


CREATE VIEW artist_profile AS
SELECT
    u.uid,
    u.first_name,
    u.last_name,
    u.email,
    a.artist_name,
    a.nationality,
    a.bdate,
    a.verification_status
FROM "user" u
JOIN artist a
    ON u.uid = a.uid;


CREATE VIEW artist_follow_stats AS
SELECT
    a.uid,
    a.artist_name,
    COUNT(f.user_followed_by) AS follower_count
FROM artist a
LEFT JOIN follows f
    ON a.uid = f.user_followed_by
GROUP BY a.uid, a.artist_name;
