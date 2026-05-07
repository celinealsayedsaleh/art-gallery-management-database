DROP VIEW IF EXISTS artist_profile;
DROP VIEW IF EXISTS vw_active_listing_overview;
DROP TRIGGER IF EXISTS trg_handle_accepted_offer ON offer;
DROP FUNCTION IF EXISTS fn_handle_accepted_offer();
DROP PROCEDURE IF EXISTS sp_expire_old_listings();
DROP PROCEDURE IF EXISTS sp_create_shipment_for_order(
    INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR
);
DROP PROCEDURE IF EXISTS sp_add_artist_social_link(INT, VARCHAR);

DROP TABLE IF EXISTS has CASCADE;
DROP TABLE IF EXISTS represented_by CASCADE;
DROP TABLE IF EXISTS follows CASCADE;
DROP TABLE IF EXISTS artist_social_link CASCADE;
DROP TABLE IF EXISTS gallery_contactinfo CASCADE;
DROP TABLE IF EXISTS user_phone CASCADE;
DROP TABLE IF EXISTS shipment CASCADE;
DROP TABLE IF EXISTS customer_order CASCADE;
DROP TABLE IF EXISTS offer CASCADE;
DROP TABLE IF EXISTS listing CASCADE;
DROP TABLE IF EXISTS edition CASCADE;
DROP TABLE IF EXISTS exhibition CASCADE;
DROP TABLE IF EXISTS artwork CASCADE;
DROP TABLE IF EXISTS insurance_plan CASCADE;
DROP TABLE IF EXISTS curator CASCADE;
DROP TABLE IF EXISTS collector CASCADE;
DROP TABLE IF EXISTS artist CASCADE;
DROP TABLE IF EXISTS style_tag CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS gallery CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

CREATE TABLE "user" (
    uid INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
    CONSTRAINT chk_user_email_format
        CHECK (position('@' in email) > 1)
);

CREATE TABLE gallery (
    gid INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    commission_rate NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    policies_url VARCHAR(500),
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20),
    CONSTRAINT chk_gallery_commission_rate
        CHECK (commission_rate >= 0 AND commission_rate <= 100)
);

CREATE TABLE category (
    cid INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE style_tag (
    tid INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE insurance_plan (
    pid INT GENERATED ALWAYS AS IDENTITY,
    coverage_amount NUMERIC(12,2) NOT NULL CHECK (coverage_amount >= 0),
    insurance_cost NUMERIC(12,2) NOT NULL CHECK (insurance_cost >= 0),
    policy_status VARCHAR(20) NOT NULL CHECK (
        policy_status IN ('Active', 'Expired', 'Pending', 'Cancelled')
    ),
    coverage_start DATE NOT NULL,
    coverage_end DATE NOT NULL,
    terms_conditions TEXT NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_insurance_plan PRIMARY KEY (pid),
    CONSTRAINT chk_insurance_dates CHECK (coverage_end >= coverage_start)
);

CREATE TABLE artist (
    uid INTEGER PRIMARY KEY,
    artist_name VARCHAR(150),
    nationality VARCHAR(100),
    bdate DATE NOT NULL,
    verification_status BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_artist_user
        FOREIGN KEY (uid)
        REFERENCES "user" (uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_artist_bdate
        CHECK (bdate <= CURRENT_DATE)
);

CREATE TABLE collector (
    uid INTEGER PRIMARY KEY,
    collector_type VARCHAR(20) NOT NULL,
    billing_country VARCHAR(100) NOT NULL,
    billing_city VARCHAR(100) NOT NULL,
    billing_street VARCHAR(255) NOT NULL,
    billing_postal_code VARCHAR(20),
    CONSTRAINT fk_collector_user
        FOREIGN KEY (uid)
        REFERENCES "user" (uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_collector_type
        CHECK (collector_type IN ('Individual', 'Business'))
);

CREATE TABLE curator (
    uid INTEGER PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    verified BOOLEAN NOT NULL DEFAULT FALSE,
    specialty VARCHAR(100),
    CONSTRAINT fk_curator_user
        FOREIGN KEY (uid)
        REFERENCES "user" (uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE user_phone (
    uid INTEGER NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    PRIMARY KEY (uid, phone_number),
    FOREIGN KEY (uid)
        REFERENCES "user"(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE gallery_contactinfo (
    gid INTEGER NOT NULL,
    contact_info VARCHAR(30) NOT NULL,
    PRIMARY KEY (gid, contact_info),
    FOREIGN KEY (gid)
        REFERENCES gallery(gid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE artist_social_link (
    uid INTEGER NOT NULL,
    social_link VARCHAR(255) NOT NULL,
    PRIMARY KEY (uid, social_link),
    FOREIGN KEY (uid)
        REFERENCES artist(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE artwork (
    aid INT GENERATED ALWAYS AS IDENTITY,
    artist_uid INT NOT NULL,
    category_id INT NOT NULL,
    insurance_plan_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    year_created INT NOT NULL CHECK (
        year_created BETWEEN 1000 AND EXTRACT(YEAR FROM CURRENT_DATE)
    ),
    medium VARCHAR(100) NOT NULL,
    height NUMERIC(8,2) NOT NULL CHECK (height > 0),
    width NUMERIC(8,2) NOT NULL CHECK (width > 0),
    depth NUMERIC(8,2) CHECK (depth IS NULL OR depth > 0),
    CONSTRAINT pk_artwork PRIMARY KEY (aid),
    CONSTRAINT fk_artwork_artist
        FOREIGN KEY (artist_uid)
        REFERENCES artist(uid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_artwork_category
        FOREIGN KEY (category_id)
        REFERENCES category(cid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_artwork_insurance
        FOREIGN KEY (insurance_plan_id)
        REFERENCES insurance_plan(pid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE edition (
    eid INT NOT NULL,
    artwork_id INT NOT NULL,
    edition_type VARCHAR(20) NOT NULL CHECK (
        edition_type IN ('Limited', 'Open', 'Exclusive', 'Artist Proof')
    ),
    size INT NOT NULL CHECK (size > 0),
    production_method VARCHAR(100) NOT NULL,
    base_pricing NUMERIC(12,2) NOT NULL CHECK (base_pricing >= 0),
    CONSTRAINT pk_edition PRIMARY KEY (eid, artwork_id),
    CONSTRAINT fk_edition_artwork
        FOREIGN KEY (artwork_id)
        REFERENCES artwork(aid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE listing (
    lid INT GENERATED ALWAYS AS IDENTITY,
    gallery_id INT NOT NULL,
    artwork_id INT NOT NULL,
    list_price NUMERIC(12,2) NOT NULL CHECK (list_price >= 0),
    currency VARCHAR(10) NOT NULL CHECK (
        currency IN ('USD', 'LBP', 'EUR', 'GBP')
    ),
    status VARCHAR(20) NOT NULL DEFAULT 'Draft' CHECK (
        status IN ('Draft', 'Active', 'Paused', 'Sold', 'Expired')
    ),
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT pk_listing PRIMARY KEY (lid),
    CONSTRAINT fk_listing_gallery
        FOREIGN KEY (gallery_id)
        REFERENCES gallery(gid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_listing_artwork
        FOREIGN KEY (artwork_id)
        REFERENCES artwork(aid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_listing_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE offer (
    oid INT GENERATED ALWAYS AS IDENTITY,
    listing_id INT NOT NULL,
    collector_uid INT NOT NULL,
    offer_amount NUMERIC(12,2) NOT NULL CHECK (offer_amount > 0),
    currency VARCHAR(10) NOT NULL CHECK (
        currency IN ('USD', 'LBP', 'EUR', 'GBP')
    ),
    offer_status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (
        offer_status IN ('Pending', 'Accepted', 'Rejected', 'Withdrawn')
    ),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_offer PRIMARY KEY (oid),
    CONSTRAINT fk_offer_listing
        FOREIGN KEY (listing_id)
        REFERENCES listing(lid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_offer_collector
        FOREIGN KEY (collector_uid)
        REFERENCES collector(uid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE customer_order (
    oid INT GENERATED ALWAYS AS IDENTITY,
    collector_uid INT NOT NULL,
    offer_id INT NOT NULL,
    insurance_plan_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Placed' CHECK (
        status IN ('Placed', 'Paid', 'Packed', 'Shipped', 'Delivered', 'Cancelled')
    ),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0),
    discount NUMERIC(12,2) DEFAULT 0 CHECK (discount >= 0),
    payment_method VARCHAR(30) NOT NULL CHECK (
        payment_method IN ('Cash on Delivery', 'Credit Card', 'Debit Card', 'Bank Transfer')
    ),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_customer_order PRIMARY KEY (oid),
    CONSTRAINT uq_customer_order_offer UNIQUE (offer_id),
    CONSTRAINT fk_order_collector
        FOREIGN KEY (collector_uid)
        REFERENCES collector(uid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_offer
        FOREIGN KEY (offer_id)
        REFERENCES offer(oid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_insurance
        FOREIGN KEY (insurance_plan_id)
        REFERENCES insurance_plan(pid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE shipment (
    sid INT GENERATED ALWAYS AS IDENTITY,
    order_id INT NOT NULL,
    carrier VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100) NOT NULL,
    shipment_status VARCHAR(20) NOT NULL DEFAULT 'Preparing' CHECK (
        shipment_status IN ('Preparing', 'Shipped', 'In Transit', 'Delivered', 'Returned')
    ),
    ship_from_country VARCHAR(50) NOT NULL,
    ship_from_city VARCHAR(50) NOT NULL,
    ship_from_street VARCHAR(120) NOT NULL,
    ship_from_postalcode VARCHAR(20),
    ship_to_country VARCHAR(50) NOT NULL,
    ship_to_city VARCHAR(50) NOT NULL,
    ship_to_street VARCHAR(120) NOT NULL,
    ship_to_postalcode VARCHAR(20),
    CONSTRAINT pk_shipment PRIMARY KEY (sid),
    CONSTRAINT uq_shipment_order UNIQUE (order_id),
    CONSTRAINT uq_shipment_tracking UNIQUE (tracking_number),
    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id)
        REFERENCES customer_order(oid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE exhibition (
    eid INT GENERATED ALWAYS AS IDENTITY,
    curator_uid INT NOT NULL,
    gallery_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    exhibition_type VARCHAR(20) NOT NULL CHECK (
        exhibition_type IN ('Virtual', 'Physical', 'Hybrid')
    ),
    location VARCHAR(150),
    opening_date DATE NOT NULL,
    closing_date DATE NOT NULL,
    CONSTRAINT pk_exhibition PRIMARY KEY (eid),
    CONSTRAINT fk_exhibition_curator
        FOREIGN KEY (curator_uid)
        REFERENCES curator(uid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_exhibition_gallery
        FOREIGN KEY (gallery_id)
        REFERENCES gallery(gid)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_exhibition_dates
        CHECK (closing_date >= opening_date),
    CONSTRAINT chk_exhibition_location
        CHECK (
            (exhibition_type = 'Virtual' AND location IS NULL)
            OR
            (exhibition_type IN ('Physical', 'Hybrid'))
        )
);

CREATE TABLE follows (
    user_follows INTEGER NOT NULL,
    user_followed_by INTEGER NOT NULL,
    PRIMARY KEY (user_follows, user_followed_by),
    CONSTRAINT fk_follows_user_follows
        FOREIGN KEY (user_follows)
        REFERENCES "user"(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_follows_user_followed_by
        FOREIGN KEY (user_followed_by)
        REFERENCES "user"(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_no_self_follow
        CHECK (user_follows <> user_followed_by)
);

CREATE TABLE represented_by (
    gid INTEGER NOT NULL,
    uid INTEGER NOT NULL,
    PRIMARY KEY (uid, gid),
    CONSTRAINT fk_represented_by_gallery
        FOREIGN KEY (gid)
        REFERENCES gallery(gid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_represented_by_artist
        FOREIGN KEY (uid)
        REFERENCES artist(uid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE has (
    tid INTEGER NOT NULL,
    aid INTEGER NOT NULL,
    PRIMARY KEY (aid, tid),
    CONSTRAINT fk_artwork_style_tag_style_tag
        FOREIGN KEY (tid)
        REFERENCES style_tag(tid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_artwork_style_tag_artwork
        FOREIGN KEY (aid)
        REFERENCES artwork(aid)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
