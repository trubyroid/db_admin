-- Триггеры.

-- 3) Написать триггер: после добавления записи со статутом "начало" в таблицу P2P, изменить соответствующую запись в таблице TransferredPoints

DROP FUNCTION fnc_transferred_points_after_p2p_start() CASCADE;

CREATE OR REPLACE FUNCTION fnc_transferred_points_after_p2p_start()
    RETURNS TRIGGER AS
$tab$
BEGIN
    IF NEW.state = 'Start' THEN
        WITH peers2 AS (SELECT DISTINCT NEW.checkingpeer,
                                        checks.peer as checkedpeer
                        FROM p2p
                                 INNER JOIN checks ON checks.id = NEW."Check"
                        GROUP BY p2p.checkingpeer, checkedpeer)

        UPDATE transferredpoints
        SET pointsamount = transferredpoints.pointsamount + 1,
            id           = transferredpoints.id
        FROM peers2
        WHERE transferredpoints.checkingpeer = peers2.checkingpeer
          AND transferredpoints.checkedpeer = peers2.checkedpeer;
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$tab$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transferred_points
    AFTER INSERT
    ON p2p
    FOR EACH ROW
EXECUTE PROCEDURE fnc_transferred_points_after_p2p_start();


-- 4) Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
-- Запись считается корректной, если:
-- Количество XP не превышает максимальное доступное для проверяемой задачи
-- Поле Check ссылается на успешную проверку
-- Если запись не прошла проверку, не добавлять её в таблицу.

DROP FUNCTION IF EXISTS fnc_xp() CASCADE;;

CREATE OR REPLACE FUNCTION fnc_xp()
    RETURNS TRIGGER AS
$trg_xp$
DECLARE
    status varchar(20);
    max_xp integer;
BEGIN
    SELECT tasks.maxxp
    INTO max_xp
    FROM checks
             INNER JOIN tasks ON tasks.title = checks.task;
    SELECT p2p.state
    INTO status
    FROM checks
             INNER JOIN p2p ON checks.id = p2p."Check";

    IF new.xpamount > max_xp THEN
        RAISE EXCEPTION 'xp amount is more than max xp for this task';
    ELSEIF status = 'Failure' THEN
        RAISE EXCEPTION 'check is failure';
    ELSE
        RETURN NEW;
    END IF;
END;
$trg_xp$ LANGUAGE plpgsql;


CREATE TRIGGER trg_xp
    BEFORE INSERT
    ON xp
    FOR EACH ROW
EXECUTE PROCEDURE fnc_xp();


--DROP FUNCTION IF EXISTS fnc_xp();