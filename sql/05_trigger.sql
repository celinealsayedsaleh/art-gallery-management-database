-- When an offer is accepted, all other pending offers on the same listing
-- are automatically rejected.

CREATE OR REPLACE FUNCTION fn_handle_accepted_offer()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.offer_status = 'Accepted'
       AND (OLD.offer_status IS DISTINCT FROM NEW.offer_status) THEN

        UPDATE offer
        SET offer_status = 'Rejected'
        WHERE listing_id = NEW.listing_id
          AND oid <> NEW.oid
          AND offer_status = 'Pending';

    END IF;

    RETURN NEW;
END;
$$;


CREATE TRIGGER trg_handle_accepted_offer
AFTER UPDATE ON offer
FOR EACH ROW
EXECUTE FUNCTION fn_handle_accepted_offer();
