
DROP PROCEDURE IF EXISTS pr_import_from_csv_to_table("table" text, path text, delimetr text);

CREATE or replace PROCEDURE pr_import_from_csv_to_table(IN "table" text, IN path text, IN delimetr text)
AS
$$
BEGIN
    EXECUTE format('COPY %s FROM %L WITH CSV DELIMITER %L HEADER;', $1, $2, $3);
END;
$$ LANGUAGE plpgsql;
