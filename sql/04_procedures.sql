CREATE OR REPLACE PROCEDURE sp_expire_old_listings()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT lid
        FROM listing
        WHERE end_date IS NOT NULL
          AND end_date < CURRENT_DATE
          AND status NOT IN ('Sold', 'Expired')
    LOOP
        UPDATE listing
        SET status = 'Expired'
        WHERE lid = rec.lid;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_create_shipment_for_order(
    p_order_id INT,
    p_carrier VARCHAR,
    p_tracking_number VARCHAR,
    p_ship_from_country VARCHAR,
    p_ship_from_city VARCHAR,
    p_ship_from_street VARCHAR,
    p_ship_from_postal VARCHAR,
    p_ship_to_country VARCHAR,
    p_ship_to_city VARCHAR,
    p_ship_to_street VARCHAR,
    p_ship_to_postal VARCHAR,
    p_status VARCHAR DEFAULT 'Preparing'
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM customer_order
        WHERE oid = p_order_id
    ) THEN
        RAISE EXCEPTION 'Order % does not exist.', p_order_id;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM shipment
        WHERE order_id = p_order_id
    ) THEN
        RAISE EXCEPTION 'Order % already has a shipment.', p_order_id;
    END IF;

    INSERT INTO shipment (
        order_id,
        carrier,
        tracking_number,
        shipment_status,
        ship_from_country,
        ship_from_city,
        ship_from_street,
        ship_from_postalcode,
        ship_to_country,
        ship_to_city,
        ship_to_street,
        ship_to_postalcode
    )
    VALUES (
        p_order_id,
        p_carrier,
        p_tracking_number,
        p_status,
        p_ship_from_country,
        p_ship_from_city,
        p_ship_from_street,
        p_ship_from_postal,
        p_ship_to_country,
        p_ship_to_city,
        p_ship_to_street,
        p_ship_to_postal
    );
END;
$$;


CREATE OR REPLACE PROCEDURE sp_add_artist_social_link(
    p_uid INT,
    p_social_link VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM artist
        WHERE uid = p_uid
    ) THEN
        RAISE EXCEPTION 'Artist % does not exist.', p_uid;
    END IF;

    IF trim(p_social_link) = '' THEN
        RAISE EXCEPTION 'Social link cannot be empty.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM artist_social_link
        WHERE uid = p_uid
          AND social_link = p_social_link
    ) THEN
        RAISE EXCEPTION 'This social link already exists for artist %.', p_uid;
    END IF;

    INSERT INTO artist_social_link(uid, social_link)
    VALUES (p_uid, p_social_link);
END;
$$;
