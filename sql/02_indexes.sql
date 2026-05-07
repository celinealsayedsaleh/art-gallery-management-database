CREATE INDEX idx_user_phone_uid ON user_phone(uid);
CREATE INDEX idx_gallery_contactinfo_gid ON gallery_contactinfo(gid);
CREATE INDEX idx_artist_social_link_uid ON artist_social_link(uid);

CREATE INDEX idx_follows_user_follows ON follows(user_follows);
CREATE INDEX idx_follows_user_followed_by ON follows(user_followed_by);
CREATE INDEX idx_represented_by_gid ON represented_by(gid);
CREATE INDEX idx_represented_by_uid ON represented_by(uid);
CREATE INDEX idx_has_tid ON has(tid);
CREATE INDEX idx_has_aid ON has(aid);

CREATE INDEX idx_artwork_artist_uid ON artwork(artist_uid);
CREATE INDEX idx_artwork_category_id ON artwork(category_id);
CREATE INDEX idx_artwork_insurance_plan_id ON artwork(insurance_plan_id);
CREATE INDEX idx_edition_artwork_id ON edition(artwork_id);
CREATE INDEX idx_listing_gallery_id ON listing(gallery_id);
CREATE INDEX idx_listing_artwork_id ON listing(artwork_id);
CREATE INDEX idx_offer_listing_id ON offer(listing_id);
CREATE INDEX idx_offer_collector_uid ON offer(collector_uid);
CREATE INDEX idx_order_collector_uid ON customer_order(collector_uid);
CREATE INDEX idx_order_offer_id ON customer_order(offer_id);
CREATE INDEX idx_order_insurance_plan_id ON customer_order(insurance_plan_id);
CREATE INDEX idx_shipment_order_id ON shipment(order_id);
CREATE INDEX idx_exhibition_curator_uid ON exhibition(curator_uid);
CREATE INDEX idx_exhibition_gallery_id ON exhibition(gallery_id);

CREATE INDEX idx_artwork_title ON artwork(title);
CREATE INDEX idx_artwork_year_created ON artwork(year_created);
CREATE INDEX idx_listing_status_start_date ON listing(status, start_date);
CREATE INDEX idx_offer_status_created_at ON offer(offer_status, created_at);
CREATE INDEX idx_order_status_created_at ON customer_order(status, created_at);
CREATE INDEX idx_exhibition_dates ON exhibition(opening_date, closing_date);
CREATE INDEX idx_insurance_status_end ON insurance_plan(policy_status, coverage_end);
