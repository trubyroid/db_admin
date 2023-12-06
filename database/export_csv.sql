DROP PROCEDURE IF EXISTS pr_export_to_csv_from_table("table" text, path text, delimetr text);

CREATE or replace PROCEDURE pr_export_to_csv_from_table(IN "table" text, IN path text, IN delimetr text)
AS
$$
BEGIN
    EXECUTE format('COPY %s TO %L DELIMITER ''%s'' CSV HEADER;', $1, $2, $3);

END;
$$ LANGUAGE plpgsql;
