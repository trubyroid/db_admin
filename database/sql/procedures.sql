-- 1)Написать процедуру добавления P2P проверки
-- Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время.
-- Если задан статус "начало", добавить запись в таблицу Checks (в качестве даты использовать сегодняшнюю).
-- Добавить запись в таблицу P2P.
-- Если задан статус "начало", в качестве проверки указать только что добавленную запись, иначе указать проверку с незавершенным P2P этапом.

DROP PROCEDURE IF EXISTS pr_p2p_check(checked varchar, checking varchar, taskName varchar, state check_status,
                                      P2Ptime time);

CREATE or replace PROCEDURE pr_p2p_check(checked varchar,
                                         checking varchar,
                                         taskName varchar,
                                         state check_status,
                                         P2Ptime time)
AS
$$
DECLARE
    id_check integer := 0;
BEGIN
    IF state = 'Start'
    THEN
        id_check = (SELECT max(id) FROM checks) + 1;
        INSERT INTO checks (id, peer, task, "Date")
        VALUES (id_check, checked, taskName, (SELECT CURRENT_DATE));
    ELSE
        id_check = (SELECT Checks.id
                    FROM p2p
                             INNER JOIN checks
                                        ON checks.id = p2p."Check"
                    WHERE checkingpeer = checking
                      AND peer = checked
                      AND task = taskName
                    ORDER BY checks.id DESC
                    LIMIT 1);
    END IF;

    INSERT INTO p2p ("Check", checkingpeer, state, "Time")
    VALUES (id_check, checking, state, P2Ptime);
END
$$ LANGUAGE plpgsql;

-- 2) Написать процедуру добавления проверки Verter'ом
-- Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время.
-- Добавить запись в таблицу Verter (в качестве проверки указать проверку соответствующего задания с самым поздним (по времени) успешным P2P этапом)

CREATE or replace PROCEDURE pr_verter_check(nickname varchar, taskName varchar, verterState check_status,
                                            checkTime time)
AS
$$
DECLARE
    id_check integer := (SELECT checks.id
                         FROM p2p
                                  INNER JOIN checks
                                             ON checks.id = p2p."Check" AND p2p.state = 'Success'
                                                 AND checks.task = taskName
                                                 AND checks.peer = nickname
                         ORDER BY p2p."Time"
                         LIMIT 1);
BEGIN
    INSERT INTO verter ("Check", state, "Time")
    VALUES (id_check, verterState, checkTime);
END
$$ LANGUAGE plpgsql;

-- 4) Найти процент успешных и неуспешных проверок за всё время
-- Формат вывода: процент успешных, процент неуспешных

DROP PROCEDURE IF EXISTS pr_success_percent(IN ref refcursor);

CREATE OR REPLACE PROCEDURE pr_success_percent(IN ref refcursor)
AS
$$
BEGIN
    OPEN ref FOR
        WITH tmp AS (SELECT id,
                            "Check",
                            state,
                            "Time"
                     FROM p2p
                     WHERE NOT (state = 'Start')
                     UNION ALL
                     SELECT id,
                            "Check",
                            state,
                            "Time"
                     FROM verter
                     WHERE NOT (state = 'Start'))

        SELECT (cast
            (cast((SELECT count(*)
                   FROM p2p
                   WHERE NOT (state = 'Start')) - count(*) AS numeric) / (SELECT count(*)
                                                                          FROM p2p
                                                                          WHERE NOT (state = 'Start')) *
             100 AS int))                                                                   AS SuccessfulChecks,
               cast
                   (cast(count(*) AS numeric) / (SELECT count(*)
                                                 FROM p2p
                                                 WHERE NOT (state = 'Start')) * 100 AS int) AS UnsuccessfulChecks
        FROM tmp
        WHERE (state = 'Failure');
END;
$$ LANGUAGE plpgsql;

--- 5) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

DROP PROCEDURE IF EXISTS pr_points_change(IN ref refcursor);

CREATE OR REPLACE PROCEDURE pr_points_change(IN ref refcursor)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT checkingpeer      AS Peer,
               SUM(pointsamount) AS PointsChange
        FROM (SELECT checkingpeer,
                     SUM(pointsamount) AS pointsamount
              FROM TransferredPoints
              GROUP BY checkingpeer
              UNION ALL
              SELECT checkedpeer,
                     SUM(-pointsamount) AS pointsamount
              FROM TransferredPoints
              GROUP BY checkedpeer) AS change
        GROUP BY checkingpeer
        ORDER BY PointsChange DESC;
END;
$$ LANGUAGE plpgsql;

-- 6) Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

DROP procedure IF EXISTS pr_transferred_points(IN ref refcursor);

CREATE OR REPLACE PROCEDURE pr_transferred_points(IN ref refcursor)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT "Peer1"           as Peer,
               sum(pointsamount) AS PointsChange
        FROM (SELECT "Peer1",
                     SUM("PointsAmount") AS pointsamount
              FROM fnc_transferred_points()
              GROUP BY "Peer1"
              UNION ALL
              SELECT "Peer2",
                     SUM(-"PointsAmount") AS pointsamount
              FROM fnc_transferred_points()
              GROUP BY "Peer2") AS change
        GROUP BY Peer
        ORDER BY pointschange DESC;
END;
$$ LANGUAGE plpgsql;

-- 7) Определить самое часто проверяемое задание за каждый день
-- При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все.
-- Формат вывода: день, название задания

DROP PROCEDURE IF EXISTS pr_max_task_check(IN ref refcursor);

CREATE OR REPLACE PROCEDURE pr_max_task_check(IN ref refcursor)
AS
$$
BEGIN
    OPEN ref FOR
        WITH t1 AS (SELECT "Date"      AS d,
                           checks.task,
                           COUNT(task) AS tc
                    FROM checks
                    GROUP BY checks.task, d)
        SELECT t2.d AS day, t2.task
        FROM (SELECT t1.task,
                     t1.d,
                     rank() OVER (PARTITION BY t1.d ORDER BY tc DESC) AS rank
              FROM t1) AS t2
        WHERE rank = 1
        ORDER BY day;
END
$$ LANGUAGE plpgsql;

-- 8) Определить длительность последней P2P проверки
-- Под длительностью подразумевается разница между временем, указанным в записи со статусом "начало", и временем, указанным в записи со статусом "успех" или "неуспех".
-- Формат вывода: длительность проверки

DROP PROCEDURE IF EXISTS pr_check_duration(IN ref refcursor);

CREATE OR REPLACE PROCEDURE pr_check_duration(IN ref refcursor)
AS
$$
DECLARE
    id_check_start int  := (SELECT "Check"
                            FROM p2p
                            WHERE state != 'Start'
                              AND "Check" = (SELECT max("Check") FROM p2p)
                            LIMIT 1);
    id_check_end   int  := (SELECT "Check"
                            FROM p2p
                            WHERE state = 'Start'
                              AND "Check" = (SELECT max("Check") FROM p2p)
                            LIMIT 1);
    starts_check   time := (SELECT "Time"
                            FROM p2p
                            WHERE state != 'Start'
                              AND "Check" = (SELECT max("Check") FROM p2p)
                            LIMIT 1);
    end_check      time := (SELECT "Time"
                            FROM p2p
                            WHERE state = 'Start'
                              AND "Check" = (SELECT max("Check") FROM p2p)
                            LIMIT 1);
BEGIN
    IF id_check_end = id_check_start
    THEN
        OPEN ref FOR
            SELECT starts_check - end_check AS "Duration";
    ELSE
        RAISE NOTICE ' P2P check is not completed ';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 12) Определить N пиров с наибольшим числом друзей
-- Параметры процедуры: количество пиров N.
-- Результат вывести отсортированным по кол-ву друзей.
-- Формат вывода: ник пира, количество друзей

DROP PROCEDURE IF EXISTS pr_count_friends;

CREATE OR REPLACE PROCEDURE pr_count_friends(IN ref refcursor, IN limits int)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT peer1        AS peer,
               count(peer2) AS "FriendsCount"
        FROM friends
        GROUP BY peer
        ORDER BY "FriendsCount" DESC
        LIMIT limits;
END;
$$ LANGUAGE plpgsql;


-- 14) Определить кол-во XP, полученное в сумме каждым пиром
-- Если одна задача выполнена несколько раз, полученное за нее кол-во XP равно максимальному за эту задачу.
-- Результат вывести отсортированным по кол-ву XP.
-- Формат вывода: ник пира, количество XP

DROP PROCEDURE IF EXISTS pr_peer_xp_sum(ref refcursor);

CREATE OR REPLACE PROCEDURE pr_peer_xp_sum(IN ref refcursor)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT peer,
               SUM(xpamount) AS "XP"
        FROM (SELECT peer, task, MAX(xpamount) AS xpamount
              FROM xp
                       INNER JOIN checks c on c.id = xp."Check"
              GROUP BY peer, task) AS "XP"
        GROUP BY peer
        ORDER BY "XP" DESC;
END
$$ LANGUAGE plpgsql;

-- 17) Найти "удачные" для проверок дни. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
-- Параметры процедуры: количество идущих подряд успешных проверок N.
-- Временем проверки считать время начала P2P этапа.
-- Под идущими подряд успешными проверками подразумеваются успешные проверки, между которыми нет неуспешных.
-- При этом кол-во опыта за каждую из этих проверок должно быть не меньше 80% от максимального.
-- Формат вывода: список дней

DROP PROCEDURE IF EXISTS pr_lucky_day(ref refcursor, N int);

CREATE OR REPLACE PROCEDURE pr_lucky_day(IN ref refcursor, N int)
AS
$$
BEGIN
    OPEN ref FOR
        WITH t1 AS (SELECT c.id,
                           "Date",
                           peer,
                           v."Check"  AS id_check,
                           t.maxxp    AS max_xp,
                           x.xpamount AS peer_get_xp,
                           v.state
                    FROM checks c
                             INNER JOIN p2p on c.id = p2p."Check" AND (p2p.state = 'Success')
                             INNER JOIN verter v on c.id = v."Check" AND (v.state = 'Success')
                             INNER JOIN tasks t on t.title = c.task
                             INNER JOIN xp x on c.id = x."Check"
                    ORDER BY "Date")
        SELECT "Date"
        FROM t1
        WHERE t1.peer_get_xp > t1.max_xp * 0.8
        GROUP BY "Date"
        HAVING count("Date") >= N;
END
$$ LANGUAGE plpgsql;


-- 18) Определить пира с наибольшим числом выполненных заданий
-- Формат вывода: ник пира, число выполненных заданий

DROP PROCEDURE IF EXISTS pr_max_done_task(ref refcursor);

CREATE OR REPLACE PROCEDURE pr_max_done_task(IN ref refcursor) AS
$$
BEGIN
    OPEN ref FOR
        SELECT peer, count(xpamount) xp
        from xp
                 JOIN checks c on c.id = xp."Check"
        GROUP BY peer
        ORDER BY xp DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;


-- 19) Определить пира с наибольшим количеством XP
-- Формат вывода: ник пира, количество XP

DROP PROCEDURE IF EXISTS pr_max_peer_xp(ref refcursor);

CREATE OR REPLACE PROCEDURE pr_max_peer_xp(IN ref refcursor) AS
$$
BEGIN
    OPEN ref FOR
        SELECT nickname      AS "Peer",
               sum(xpamount) AS "XP"
        FROM peers
                 INNER JOIN checks c on peers.nickname = c.peer
                 INNER JOIN xp x on c.id = x."Check"
        GROUP BY nickname
        ORDER BY "XP" DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;


-- 21) Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
-- Параметры процедуры: время, количество раз N.
-- Формат вывода: список пиров

DROP PROCEDURE IF EXISTS pr_time_spent(IN ref refcursor, checkTime time, N int);

CREATE OR REPLACE PROCEDURE pr_time_spent(IN ref refcursor, checkTime time, N int)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT peer
        FROM timetracking t
        WHERE state = 1
          AND t."Time" < checkTime
        GROUP BY peer
        HAVING count(peer) > N;
END;
$$ LANGUAGE plpgsql;

-- 22) Определить пиров, выходивших за последние N дней из кампуса больше M раз
-- Параметры процедуры: количество дней N, количество раз M.
-- Формат вывода: список пиров

DROP PROCEDURE IF EXISTS pr_count_out_of_campus(IN ref refcursor, N int, M int);

CREATE OR REPLACE PROCEDURE pr_count_out_of_campus(IN ref refcursor, N int, M int)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT peer
        FROM (SELECT peer,
                     "Date",
                     count(*) AS counts
              FROM timetracking
              WHERE state = 2
                AND "Date" > (current_date - N)
              GROUP BY peer, "Date"
              ORDER BY "Date") AS res
        GROUP BY peer
        HAVING SUM(counts) > M;
END
$$ LANGUAGE plpgsql;

-- 23) Определить пира, который пришел сегодня последним
-- Формат вывода: ник пира

DROP PROCEDURE IF EXISTS pr_last_current_online(IN ref refcursor);

CREATE OR REPLACE PROCEDURE pr_last_current_online(IN ref refcursor)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT peer
        FROM timetracking
        WHERE "Date" = current_date
          AND state = 1
        ORDER BY "Time" DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;


-- 1) Создать хранимую процедуру, которая, не уничтожая базу данных,
-- уничтожает все те таблицы текущей базы данных, имена которых начинаются с фразы 'TableName'.


DROP PROCEDURE IF EXISTS pr_remove_table(TableName text);

CREATE OR REPLACE PROCEDURE pr_remove_table(IN TableName text)
AS
$$
BEGIN
    FOR TableName IN
        SELECT quote_ident(table_name)
        FROM information_schema.tables
        WHERE table_name LIKE TableName || '%'
          AND table_schema LIKE 'public'
        LOOP
            EXECUTE 'DROP TABLE ' || TableName;
        END LOOP;
END
$$ LANGUAGE plpgsql;

-- 2) Создать хранимую процедуру с выходным параметром, которая выводит список имен и параметров всех скалярных SQL функций
-- пользователя в текущей базе данных. Имена функций без параметров не выводить. Имена и список параметров должны выводиться в одну строку.
-- Выходной параметр возвращает количество найденных функций.

DROP PROCEDURE IF EXISTS pr_count_table(OUT n int);

CREATE OR REPLACE PROCEDURE pr_count_table(OUT n int)
AS
$$
BEGIN
    n = (SELECT count(*)
         FROM (SELECT routines.routine_name, parameters.data_type
               FROM information_schema.routines
                        LEFT JOIN information_schema.parameters ON routines.specific_name = parameters.specific_name
               WHERE routines.specific_schema = 'public'
                 AND parameters.data_type IS NOT NULL
               ORDER BY routines.routine_name, parameters.ordinal_position) as foo);
END
$$ LANGUAGE plpgsql;

-- 3) Создать хранимую процедуру с выходным параметром, которая уничтожает все SQL DML триггеры в текущей базе данных.
-- Выходной параметр возвращает количество уничтоженных триггеров.

DROP PROCEDURE IF EXISTS pr_delete_dml_triggers (IN ref refcursor, OUT result int);

CREATE OR REPLACE PROCEDURE pr_delete_dml_triggers(IN ref refcursor, OUT result int)
AS
$$
BEGIN
    FOR ref IN
        SELECT trigger_name || ' ON ' || event_object_table
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
        LOOP
            EXECUTE 'DROP TRIGGER ' || ref;
            result := result + 1;
        END LOOP;
END
$$ LANGUAGE plpgsql;


--4) Создать хранимую процедуру с входным параметром, которая выводит имена и описания типа объектов (только
-- хранимых процедур и скалярных функций), в тексте которых на языке SQL встречается строка, задаваемая параметром процедуры.

DROP PROCEDURE IF EXISTS pr_show_info (IN ref refcursor, IN name text);

CREATE OR REPLACE PROCEDURE pr_show_info(IN ref refcursor, IN name text)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT routine_name,
               routine_type,
               routine_definition
        FROM information_schema.routines
        WHERE specific_schema = 'public'
          AND routine_definition LIKE '%' || name || '%';
END
$$ LANGUAGE plpgsql;