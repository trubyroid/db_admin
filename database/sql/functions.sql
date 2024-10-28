-- 1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
-- Ник пира 1, ник пира 2, количество переданных пир поинтов.
-- Количество отрицательное, если пир 2 получил от пира 1 больше поинтов.


DROP FUNCTION IF EXISTS fnc_transferred_points();

CREATE OR REPLACE FUNCTION fnc_transferred_points()
    RETURNS TABLE
            (
                "Peer1"        varchar,
                "Peer2"        varchar,
                "PointsAmount" integer
            )
AS
$$
WITH tmp AS (SELECT tp.checkingPeer,
                    tp.checkedPeer,
                    tp.pointsamount
             FROM TransferredPoints tp
                      INNER JOIN TransferredPoints ON tp.checkingPeer = tp.checkedPeer
                 AND tp.checkedPeer = tp.checkingPeer)
    (SELECT checkingPeer,
            checkedPeer,
            sum(result.pointsamount)
     FROM (SELECT tp.checkingPeer, tp.checkedPeer, tp.pointsamount
           FROM TransferredPoints tp
           UNION
           SELECT t.checkedPeer, t.checkingPeer, -t.pointsamount
           FROM tmp t) AS result
     GROUP BY 1, 2)
EXCEPT
SELECT tmp.checkingPeer,
       tmp.checkedPeer,
       tmp.pointsamount
FROM tmp;
$$ LANGUAGE sql;


-- 2) Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного задания, кол-во полученного XP
-- В таблицу включать только задания, успешно прошедшие проверку (определять по таблице Checks).
-- Одна задача может быть успешно выполнена несколько раз. В таком случае в таблицу включать все успешные проверки.

DROP FUNCTION IF EXISTS fnc_successful_checks;

CREATE or replace FUNCTION fnc_successful_checks()
    RETURNS TABLE
            (
                peer     varchar,
                task     varchar,
                xpamount integer
            )
AS
$tab$
BEGIN
    RETURN QUERY
        WITH one AS (SELECT checks.id
                     FROM checks
                              INNER JOIN p2p ON checks.id = p2p."Check"
                              LEFT JOIN Verter ON checks.id = Verter."Check"
                     WHERE p2p.state = 'Success' AND checks.task > 'C6_s21_matrix'
                        OR p2p.state = 'Success' AND Verter.state = 'Success'

                     GROUP BY checks.id)

        SELECT checks.peer,
               checks.task,
               xp.xpamount
        FROM one
                 INNER JOIN checks ON one.id = checks.id
                 INNER JOIN XP ON one.id = XP."Check"
        GROUP BY checks.peer, checks.task, xp.xpamount;
END
$tab$ LANGUAGE plpgsql;

-- 3) Написать функцию, определяющую пиров, которые не выходили из кампуса в течение всего дня
-- Параметры функции: день, например 12.05.2022.
-- Функция возвращает только список пиров.


DROP FUNCTION IF EXISTS fnc_check_date(peer_date date);

CREATE OR REPLACE FUNCTION fnc_check_date(peer_date date)
    RETURNS TABLE
            (
                peer varchar
            )
AS
$$
SELECT peer
FROM timetracking
WHERE "Date" = peer_date
  AND state = '1'
GROUP BY peer
HAVING SUM(state) = 1
$$ LANGUAGE sql;

-- 9) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
-- Параметры процедуры: название блока, например "CPP".
-- Результат вывести отсортированным по дате завершения.
-- Формат вывода: ник пира, дата завершения блока (т.е. последнего выполненного задания из этого блока)

DROP FUNCTION IF EXISTS fnc_successful_checks_last_task;

CREATE or replace FUNCTION fnc_successful_checks_last_task(mytask varchar)
    RETURNS TABLE
            (
                Peer varchar,
                Day  date
            )
AS
$tab$
BEGIN
    return query
        WITH tasks_current_block AS (SELECT *
                                     FROM tasks
                                     WHERE tasks.title SIMILAR TO concat(mytask, '[0-9]_%')),
             last_task AS (SELECT MAX(title) AS title
                           FROM tasks_current_block),
             date_of_successful_check AS (SELECT checks.peer,
                                                 checks.task,
                                                 checks."Date"
                                          FROM checks
                                                   INNER JOIN p2p ON checks.id = p2p."Check"
                                          WHERE p2p.state = 'Success'
                                          GROUP BY checks.id)

        SELECT dosc.peer   AS Peer,
               dosc."Date" AS Day
        FROM date_of_successful_check dosc
                 INNER JOIN last_task ON dosc.task = last_task.title;
END
$tab$ LANGUAGE plpgsql;

-- 10) Определить, к какому пиру стоит идти на проверку каждому обучающемуся
-- Определять нужно исходя из рекомендаций друзей пира, т.е. нужно найти пира, проверяться у которого рекомендует наибольшее число друзей.
-- Формат вывода: ник пира, ник найденного проверяющего

DROP FUNCTION IF EXISTS fnc_recommendation_peer(IN Peer varchar, OUT recommendedpeer varchar);

CREATE OR REPLACE FUNCTION fnc_recommendation_peer(IN checking_peer varchar)
    RETURNS TABLE
            (
                Peer            varchar,
                RecommendedPeer varchar
            )
AS
$$
BEGIN
    RETURN QUERY
        WITH find_friends AS (SELECT friends.peer2
                              FROM friends
                              WHERE friends.peer1 NOT LIKE checking_peer),
             recommended_peers AS (SELECT recommendations.recommendedpeer AS rp
                                   FROM recommendations
                                            INNER JOIN find_friends ON recommendations.peer = find_friends.peer2
                                   WHERE recommendations.recommendedpeer NOT LIKE checking_peer),
             recommended_peer AS (SELECT recommended_peers.rp,
                                         COUNT(*)
                                  FROM recommended_peers
                                  GROUP BY recommended_peers.rp
                                  ORDER BY 2 DESC
                                  LIMIT 1)
        SELECT (SELECT peers.nickname
                FROM peers
                WHERE peers.nickname = checking_peer),
               (SELECT rp AS RecommendedPeer FROM recommended_peer);
END;
$$
    LANGUAGE plpgsql;

-- 11) Определить процент пиров, которые:
--
-- Приступили только к блоку 1
-- Приступили только к блоку 2
-- Приступили к обоим
-- Не приступили ни к одному
--
-- Пир считается приступившим к блоку, если он проходил хоть одну проверку любого задания из этого блока (по таблице Checks)
-- Параметры процедуры: название блока 1, например SQL, название блока 2, например A.
-- Формат вывода: процент приступивших только к первом

DROP function IF EXISTS fnc_successful_checks_blocks(block1 varchar, block2 varchar);

CREATE FUNCTION fnc_successful_checks_blocks(block1 varchar, block2 varchar)
    RETURNS TABLE
            (
                StartedBlock1      BIGINT,
                StartedBlock2      BIGINT,
                StartedBothBlocks  BIGINT,
                DidntStartAnyBlock BIGINT
            )
AS
$$
DECLARE
    count_peers int := (SELECT COUNT(peers.nickname)
                        FROM peers);
BEGIN
    RETURN QUERY
        WITH startedblock1 AS (SELECT DISTINCT peer
                               FROM Checks
                               WHERE Checks.task SIMILAR TO concat(block1, '[0-9]_%')),
             startedblock2 AS (SELECT DISTINCT peer
                               FROM Checks
                               WHERE Checks.task SIMILAR TO concat(block2, '[0-9]_%')),
             startedboth AS (SELECT DISTINCT startedblock1.peer
                             FROM startedblock1
                                      INNER JOIN startedblock2 ON startedblock1.peer = startedblock2.peer),
             startedoneof AS (SELECT DISTINCT peer
                              FROM ((SELECT * FROM startedblock1) UNION (SELECT * FROM startedblock2)) AS foo),

             count_startedblock1 AS (SELECT count(*) AS count_startedblock1
                                     FROM startedblock1),
             count_startedblock2 AS (SELECT count(*) AS count_startedblock2
                                     FROM startedblock2),
             count_startedboth AS (SELECT count(*) AS count_startedboth
                                   FROM startedboth),
             count_startedoneof AS (SELECT count(*) AS count_startedoneof
                                    FROM startedoneof)


        SELECT ((SELECT count_startedblock1::bigint FROM count_startedblock1) * 100 / count_peers)             AS StartedBlock1,
               ((SELECT count_startedblock2::bigint FROM count_startedblock2) * 100 /
                count_peers)                                                                                   AS StartedBlock2,
               ((SELECT count_startedboth::bigint FROM count_startedboth) * 100 /
                count_peers)                                                                                   AS StartedBothBlocks,
               ((SELECT count_peers - count_startedoneof::bigint FROM count_startedoneof) * 100 /
                count_peers)                                                                                   AS DidntStartAnyBlock;

END
$$
    LANGUAGE plpgsql;


-- 13) Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
-- Также определите процент пиров, которые хоть раз проваливали проверку в свой день рождения.
-- Формат вывода: процент успехов в день рождения, процент неуспехов в день рождения


DROP FUNCTION IF EXISTS fnc_successful_checks_birthday();

CREATE FUNCTION fnc_successful_checks_birthday()
    RETURNS TABLE
            (
                SuccessfulChecks   bigint,
                UnsuccessfulChecks bigint
            )
AS
$$
DECLARE
    checks_count integer := (SELECT MAX(id)
                             FROM checks);
    suck_checks  bigint  := (SELECT COUNT(*)
                             FROM Peers
                                      INNER JOIN Checks ON Peers.birthday = Checks."Date"
                             WHERE Peers.Nickname = Checks.Peer);
BEGIN
    RETURN QUERY
        SELECT (SELECT suck_checks / checks_count * 100)                  AS SuccessfulChecks,
               (SELECT (checks_count - suck_checks) / checks_count * 100) AS UnsuccessfulChecks;
END
$$
    LANGUAGE plpgsql;

-- 15) Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
-- Параметры процедуры: названия заданий 1, 2 и 3.
-- Формат вывода: список пиров

DROP FUNCTION IF EXISTS fnc_successful_tasks_1_2(task1 varchar, task2 varchar, task3 varchar);

CREATE FUNCTION fnc_successful_tasks_1_2(task1 varchar, task2 varchar, task3 varchar)
    RETURNS TABLE
            (
                Peer varchar
            )
AS
$$
WITH suck_task1 AS (SELECT peer
                    FROM fnc_successful_checks() AS successful_checks
                    WHERE successful_checks.task LIKE task1),
     suck_task2 AS (SELECT peer
                    FROM fnc_successful_checks() AS successful_checks
                    WHERE successful_checks.task LIKE task2),
     suck_task3 AS (SELECT Peer
                    FROM fnc_successful_checks() AS successful_checks
                    WHERE successful_checks.task NOT LIKE task3)
SELECT *
FROM ((SELECT * FROM suck_task1) INTERSECT (SELECT * FROM suck_task2) INTERSECT (SELECT * FROM suck_task3)) AS foo;
$$
    LANGUAGE sql;

-- 16) Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
-- То есть сколько задач нужно выполнить, исходя из условий входа, чтобы получить доступ к текущей.
-- Формат вывода: название задачи, количество предшествующих

DROP FUNCTION IF EXISTS fnc_count_parent_tasks();

CREATE OR REPLACE FUNCTION fnc_count_parent_tasks()
    RETURNS TABLE
            (
                Task      varchar,
                PrevCount integer
            )
AS
$$
WITH RECURSIVE r AS (SELECT CASE
                                WHEN (tasks.parenttask IS NULL) THEN 0
                                ELSE 1
                                END          AS counter,
                            tasks.title,
                            tasks.parenttask AS current_tasks,
                            tasks.parenttask
                     FROM tasks

                     UNION ALL

                     SELECT (CASE
                                 WHEN child.parenttask IS NOT NULL THEN counter + 1
                                 ELSE counter
                         END)                AS counter,
                            child.title      AS title,
                            child.parenttask AS current_tasks,
                            parrent.title    AS parrenttask
                     FROM tasks AS child
                              CROSS JOIN r AS parrent
                     WHERE parrent.title LIKE child.parenttask)
SELECT title        AS Task,
       MAX(counter) AS PrevCount
FROM r
GROUP BY title
ORDER BY 1;
$$
    LANGUAGE sql;

-- 20) Определить пира, который провел сегодня в кампусе больше всего времени
-- Формат вывода: ник пира

DROP FUNCTION IF EXISTS fnc_the_longest_interval();

CREATE FUNCTION fnc_the_longest_interval()
    RETURNS TABLE
            (
                peer varchar
            )
AS
$$
WITH go_in AS (SELECT *
               FROM timetracking
               WHERE timetracking.state = 1),
     go_out AS (SELECT *
                FROM timetracking
                WHERE timetracking.state = 2),
     intervals AS (SELECT go_in.peer,
                          MAX(go_out."Time" - go_in."Time") AS interval_in_school
                   FROM go_in
                            INNER JOIN go_out ON go_in."Date" = go_out."Date"
                   WHERE go_in."Date" = current_date
                   GROUP BY go_in.peer
                   ORDER BY interval_in_school DESC)
SELECT peer
FROM intervals
LIMIT 1;
$$
    LANGUAGE sql;


-- 24) Определить пиров, которые выходили вчера из кампуса больше чем на N минут
-- Параметры процедуры: количество минут N.
-- Формат вывода: список пиров

DROP FUNCTION to_minutes(t time);

CREATE OR REPLACE FUNCTION to_minutes(t time without time zone)
    RETURNS integer AS
$BODY$
DECLARE
    hs INTEGER := (SELECT(EXTRACT(HOUR FROM t::time) * 60 * 60));
    ms INTEGER := (SELECT (EXTRACT(MINUTES FROM t::time)));
BEGIN
    SELECT (hs + ms) INTO ms;
    RETURN ms;
END;
$BODY$
    LANGUAGE 'plpgsql';

DROP FUNCTION fnc_interval;

CREATE or replace FUNCTION fnc_interval(N int)
    RETURNS TABLE
            (
                peer          varchar,
                time_interval time
            )
AS
$tab$
BEGIN
    RETURN QUERY
        WITH go_in AS (SELECT *
                       FROM timetracking
                       WHERE timetracking.state = 1),
             go_out AS (SELECT *
                        FROM timetracking
                        WHERE timetracking.state = 2)

        SELECT go_in.peer,
               ((go_out."Time" - go_in."Time")::time without time zone)
        FROM go_in
                 INNER JOIN go_out ON go_in.peer = go_out.peer
        WHERE go_in."Date" = go_out."Date"
          AND (SELECT to_minutes((go_out."Time" - go_in."Time")::time without time zone) > N);
END
$tab$ LANGUAGE plpgsql;


-- 25) Определить для каждого месяца процент ранних входов
-- Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, приходили в кампус за всё время (будем называть это общим числом входов).
-- Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, приходили в кампус раньше 12:00 за всё время (будем называть это числом ранних входов).
-- Для каждого месяца посчитать процент ранних входов в кампус относительно общего числа входов.
-- Формат вывода: месяц, процент ранних входов


DROP FUNCTION IF EXISTS fnc_early_entry();

CREATE FUNCTION fnc_early_entry()
    RETURNS TABLE
            (
                Month        int,
                EarlyEntries BIGINT
            )
AS
$$
BEGIN
    RETURN QUERY
        WITH peers_birthdays AS (SELECT nickname, date_part('month', birthday) :: text AS date_month
                                 FROM peers),
             months AS (SELECT date_part('month', months) :: text AS "dateMonth"
                        FROM generate_series(
                                     '2023-01-01' :: DATE,
                                     '2023-12-31' :: DATE,
                                     '1 month'
                                 ) AS months),
             entries_in_birth_month AS (SELECT date_month,
                                               peers_birthdays.nickname,
                                               timetracking."Date",
                                               timetracking."Time"
                                        FROM peers_birthdays
                                                 INNER JOIN months ON months."dateMonth" = peers_birthdays.date_month
                                                 INNER JOIN timetracking ON timetracking.peer = peers_birthdays.nickname
                                        WHERE date_part('month', timetracking."Date") :: text =
                                              peers_birthdays.date_month),
             early_entries AS (SELECT *
                               FROM entries_in_birth_month
                               WHERE entries_in_birth_month."Time" < '12:00:00'),

             count_early_entries AS (SELECT months."dateMonth"::int,
                                            COUNT(early_entries.nickname) AS count_ea
                                     FROM months
                                              LEFT JOIN early_entries ON months."dateMonth" = early_entries.date_month
                                     GROUP BY months."dateMonth"),

             count_all_entries as (SELECT months."dateMonth"::int,
                                          COUNT(entries_in_birth_month.nickname) AS count_all
                                   FROM months
                                            LEFT JOIN entries_in_birth_month
                                                      ON months."dateMonth" = entries_in_birth_month.date_month
                                   GROUP BY months."dateMonth")

        SELECT count_all_entries."dateMonth" AS Month,
               count_early_entries.count_ea  AS EarlyEntries
        FROM count_all_entries
                 INNER JOIN count_early_entries ON count_all_entries."dateMonth" = count_early_entries."dateMonth"
        ORDER BY 1;
END
$$ LANGUAGE plpgsql;
