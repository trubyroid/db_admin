create table Peers
(
    Nickname varchar UNIQUE primary key,
    Birthday date not null
);

create table Tasks
(
    Title      varchar primary key UNIQUE DEFAULT NULL,
    ParentTask varchar                    DEFAULT NULL,
    foreign key (ParentTask) references Tasks (Title),
    MaxXP      integer not null CHECK (MaxXP > 0)
);

CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');

create table Checks
(
    ID     serial primary key,
    Peer   varchar,
    foreign key (Peer) references Peers (Nickname),
    Task   varchar,
    foreign key (Task) references Tasks (Title),
    "Date" date
);

create table P2P
(
    ID           serial primary key,
    "Check"      bigint,
    foreign key ("Check") references Checks (ID),
    CheckingPeer varchar,
    foreign key (CheckingPeer) references Peers (Nickname),
    State        check_status,
    "Time"       TIME without time zone
);

create table Verter
(
    ID      serial primary key,
    "Check" bigint,
    foreign key ("Check") references Checks (ID),
    State   check_status,
    "Time"  TIME without time zone
);

create table TransferredPoints
(
    ID           serial primary key,
    CheckingPeer varchar,
    foreign key (CheckingPeer) references Peers (Nickname),
    CheckedPeer  varchar CHECK ( CheckedPeer != CheckingPeer ),
    foreign key (CheckedPeer) references Peers (Nickname),
    PointsAmount integer
);

create table Friends
(
    ID    serial primary key,
    Peer1 varchar not null,
    foreign key (Peer1) references Peers (Nickname),
    Peer2 varchar not null,
    foreign key (Peer2) references Peers (Nickname)
);

create table Recommendations
(
    ID              serial primary key,
    Peer            varchar,
    foreign key (Peer) references Peers (Nickname),
    RecommendedPeer varchar,
    foreign key (RecommendedPeer) references Peers (Nickname)
);

create table XP
(
    ID       serial primary key,
    "Check"  bigint,
    foreign key ("Check") references Checks (ID),
    XPAmount integer,
    CHECK (XPAmount >= 0)
);

CREATE TYPE time_status AS ENUM ('1', '2');

create table TimeTracking
(
    ID     serial primary key,
    Peer   varchar,
    foreign key (Peer) references Peers (Nickname),
    "Date" date,
    "Time" TIME without time zone,
    State  int check (State in (1, 2))
);

create table Custom_Table
();
INSERT INTO Peers (Nickname, Birthday)
VALUES ('Diluc', '1986-04-30'),
       ('Bennett', '2000-02-29'),
       ('Dori', '1999-12-21'),
       ('Keqing', '1995-10-20'),
       ('Zhongli', '1940-12-31'),
       ('Qiqi', '1996-03-03'),
       ('Raiden', '1960-06-26'),
       ('Klee', '2015-07-27');


INSERT INTO Tasks (Title, ParentTask, MaxXP)
VALUES ('C2_SimpleBashUtils', NULL, 250),
       ('C3_s21_string+', 'C2_SimpleBashUtils', 500),
       ('C5_s21_decimal', 'C3_s21_string+', 350),
       ('C6_s21_matrix', 'C5_s21_decimal', 200),
       ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
       ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
       ('CPP1_s21_matrix+', 'C8_3DViewer_v1.0', 300),
       ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
       ('D01_Linux', 'C2_SimpleBashUtils', 300),
       ('DO2_Linux_Network', 'D01_Linux', 250),
       ('DO3_Linux_Monitoring', 'DO2_Linux_Network', 350),
       ('DO5_SimpleDocker', 'DO3_Linux_Monitoring', 300),
       ('DO6_CI/CD', 'DO5_SimpleDocker', 300);



INSERT INTO Checks (ID, Peer, Task, "Date")
VALUES (0, 'Diluc', 'C2_SimpleBashUtils', '2022-08-30'),
       (1, 'Bennett', 'C2_SimpleBashUtils', '2022-09-01'),
       (2, 'Dori', 'C2_SimpleBashUtils', '2022-9-03'),
       (3, 'Keqing', 'C2_SimpleBashUtils', '2022-09-04'),
       (4, 'Zhongli', 'C2_SimpleBashUtils', '2022-09-05'),
       (5, 'Diluc', 'C3_s21_string+', '2022-09-15'),
       (6, 'Bennett', 'C3_s21_string+', '2022-09-15'),
       (7, 'Klee', 'C2_SimpleBashUtils', '2022-09-15'),
       (8, 'Diluc', 'C5_s21_decimal', '2022-09-25'),
       (9, 'Diluc', 'C6_s21_matrix', '2022-09-26'),
       (10, 'Diluc', 'C7_SmartCalc_v1.0', '2022-10-01'),
       (11, 'Diluc', 'C8_3DViewer_v1.0', '2022-10-10'),
       (12, 'Keqing', 'C2_SimpleBashUtils', '2022-10-20');



INSERT INTO P2P ("Check", CheckingPeer, State, "Time")
VALUES (0, 'Bennett', 'Start', '13:00'),
       (0, 'Bennett', 'Success', '13:30'),
       (1, 'Dori', 'Start', '15:00'),
       (1, 'Dori', 'Success', '15:30'),
       (2, 'Keqing', 'Start', '19:00'),
       (2, 'Keqing', 'Success', '19:30'),
       (3, 'Diluc', 'Start', '11:00'),
       (3, 'Diluc', 'Failure', '11:30'),
       (4, 'Klee', 'Start', '10:00'),
       (4, 'Klee', 'Success', '11:00'),
       (5, 'Raiden', 'Start', '20:25'),
       (5, 'Raiden', 'Success', '21:00'),
       (6, 'Diluc', 'Start', '10:10'),
       (6, 'Diluc', 'Success', '10:40'),
       (7, 'Zhongli', 'Start', '12:15'),
       (7, 'Zhongli', 'Success', '12:30'),
       (8, 'Raiden', 'Start', '2:00'),
       (8, 'Raiden', 'Success', '2:30'),
       (9, 'Bennett', 'Start', '15:00'),
       (9, 'Bennett', 'Success', '15:30'),
       (10, 'Keqing', 'Start', '16:00'),
       (10, 'Keqing', 'Success', '16:50'),
       (11, 'Klee', 'Start', '10:00'),
       (11, 'Klee', 'Success', '11:00'),
       (12, 'Raiden', 'Start', '14:00'),
       (12, 'Raiden', 'Success', '14:30');


INSERT INTO Verter ("Check", State, "Time")
VALUES (0, 'Start', '12:31'),
       (0, 'Success', '12:35'),

       (1, 'Start', '15:31'),
       (1, 'Success', '15:35'),

       (2, 'Start', '19:31'),
       (2, 'Failure', '19:33'),

       (4, 'Start', '11:32'),
       (4, 'Success', '11:40'),

       (5, 'Start', '21:02'),
       (5, 'Success', '21:10'),

       (6, 'Start', '10:41'),
       (6, 'Success', '10:45'),

       (7, 'Start', '12:31'),
       (7, 'Success', '12:33'),

       (8, 'Start', '18:31'),
       (8, 'Success', '18:33'),

       (9, 'Start', '15:31'),
       (9, 'Success', '15:33'),

       (12, 'Start', '14:30'),
       (12, 'Failure', '14:33');


INSERT INTO TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
VALUES ('Bennett', 'Diluc', 1),
       ('Diluc', 'Bennett', 1),
       ('Dori', 'Bennett', 1),
       ('Keqing', 'Dori', 1),
       ('Diluc', 'Keqing', 1),
       ('Klee', 'Zhongli', 1),
       ('Raiden', 'Diluc', 1),
       ('Diluc', 'Klee', 1),
       ('Klee', 'Diluc', 1),
       ('Zhongli', 'Klee', 1),
       ('Bennett', 'Dori', 1),
       ('Dori', 'Keqing', 1),
       ('Diluc', 'Raiden', 1),
       ('Keqing', 'Raiden', 1);


INSERT INTO Friends (Peer1, Peer2)
VALUES ('Diluc', 'Bennett'),
       ('Diluc', 'Zhongli'),
       ('Raiden', 'Zhongli'),
       ('Qiqi', 'Bennett'),
       ('Klee', 'Qiqi');

INSERT INTO Recommendations (Peer, RecommendedPeer)
VALUES ('Diluc', 'Bennett'),
       ('Bennett', 'Diluc'),
       ('Bennett', 'Dori'),
       ('Dori', 'Keqing'),
       ('Keqing', 'Diluc'),
       ('Zhongli', 'Klee'),
       ('Diluc', 'Raiden'),
       ('Klee', 'Diluc'),
       ('Diluc', 'Klee'),
       ('Klee', 'Zhongli'),
       ('Dori', 'Bennett'),
       ('Keqing', 'Dori'),
       ('Raiden', 'Diluc');

INSERT INTO XP ("Check", XPAmount)
VALUES (0, 250),
       (1, 250),
       (4, 250),
       (5, 500),
       (6, 500),
       (7, 250),
       (8, 350),
       (9, 200),
       (10, 500),
       (11, 750);



INSERT INTO TimeTracking (Peer, "Date", "Time", State)
VALUES ('Dori', '2022-10-09', '18:32', 1),
       ('Dori', '2022-10-09', '19:32', 2),
       ('Dori', '2022-10-09', '20:32', 1),
       ('Dori', '2022-10-09', '22:32', 2),
       ('Keqing', '2022-10-09', '10:32', 1),
       ('Keqing', '2022-10-09', '12:32', 2),
       ('Keqing', '2022-10-09', '13:02', 1),
       ('Keqing', '2022-10-09', '21:32', 2),
       ('Zhongli', '2022-05-09', '10:32', 1),
       ('Zhongli', '2022-05-09', '12:32', 2),
       ('Qiqi', '2022-06-09', '11:02', 1),
       ('Qiqi', '2022-06-09', '21:32', 2),
       ('Diluc', '2022-09-21', '15:00', 1),
       ('Diluc', '2022-09-21', '22:00', 2),
       ('Bennett', '2022-09-21', '08:00', 1),
       ('Bennett', '2022-09-21', '20:00', 2),
       ('Keqing', '2022-09-21', '12:00', 1),
       ('Keqing', '2022-09-21', '19:00', 2);



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
$$ LANGUAGE plpgsql;DROP PROCEDURE IF EXISTS pr_export_to_csv_from_table("table" text, path text, delimetr text);

CREATE or replace PROCEDURE pr_export_to_csv_from_table(IN "table" text, IN path text, IN delimetr text)
AS
$$
BEGIN
    EXECUTE format('COPY %s TO %L DELIMITER ''%s'' CSV HEADER;', $1, $2, $3);

END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE IF EXISTS pr_import_from_csv_to_table("table" text, path text, delimetr text);

CREATE or replace PROCEDURE pr_import_from_csv_to_table(IN "table" text, IN path text, IN delimetr text)
AS
$$
BEGIN
    EXECUTE format('COPY %s FROM %L WITH CSV DELIMITER %L HEADER;', $1, $2, $3);
END;
$$ LANGUAGE plpgsql;


COMMENT ON FUNCTION fnc_check_date IS 'A function that identifies peers who have not left campus all day';
COMMENT ON FUNCTION fnc_count_parent_tasks IS 'The function displays the number of tasks preceding it, that is, how many tasks need to be completed, based on the entry conditions, in order to gain access to the current one';
COMMENT ON FUNCTION fnc_early_entry IS 'The function determines for each month the percentage of early entries: how many times people born in this month came to campus for the entire time, how many times people born in this month came to campus before 12:00 for all time, the percentage of early entries to campus relative to the total number of entrances.';
COMMENT ON FUNCTION fnc_successful_checks IS 'Returns a table of successful checks with the amount of experience gained';
COMMENT ON FUNCTION fnc_successful_checks_birthday IS 'The function determines the percentage of peers that have ever successfully passed verification on their birthday. Also determines the percentage of peers who failed a check at least once on their birthday';
COMMENT ON FUNCTION fnc_successful_checks_blocks IS 'The function determines the percentage of peers who: started only block 1, started only block 2, started both or did not start either';
COMMENT ON FUNCTION fnc_successful_checks_last_task IS 'The function finds all peers that have completed the entire specified block of tasks and the completion date of the last task';
COMMENT ON FUNCTION fnc_successful_tasks_1_2 IS 'The function determines all peers who passed the given tasks 1 and 2, but did not pass task 3';
COMMENT ON FUNCTION fnc_the_longest_interval IS 'The function identifies the peer who spent the most time on campus today.';
COMMENT ON FUNCTION fnc_transferred_points IS 'The function returns the TransferredPoints table, in a more human-readable form: nickname peer1, nickname peer2, number of transferred peer points.';
COMMENT ON FUNCTION fnc_recommendation_peer IS 'The function determines which peer each student should go to for checking';
COMMENT ON PROCEDURE pr_check_duration IS 'The procedure determines the duration of the last P2P check. Duration means the difference between the time specified in the record with the status "start" and the time specified in the record with the status "success" or "failure".';
COMMENT ON PROCEDURE pr_count_friends IS 'The procedure determines the N peers with the largest number of friends';
COMMENT ON PROCEDURE pr_count_out_of_campus IS 'The procedure determines peers that have left campus more than M times in the last N days';
COMMENT ON PROCEDURE pr_count_table IS 'The stored procedure lists the names and parameters of all scalar SQL user functions in the current database. Does not display functions without parameters';
COMMENT ON PROCEDURE pr_delete_dml_triggers IS 'Stored procedure that destroys all SQL DML triggers in the current database';
COMMENT ON PROCEDURE pr_last_current_online IS 'The procedure determines the peer who came last today';
COMMENT ON PROCEDURE pr_lucky_day IS 'The procedure finds "successful" days for inspections. A day is considered "successful" if it contains at least N consecutive successful checks. Consecutive successful checks mean successful checks without any unsuccessful checks between them. Moreover, the amount of experience for each of these checks is not less than 80% of the maximum.';
COMMENT ON PROCEDURE pr_max_done_task IS 'The procedure determines the peer with the largest number of completed jobs.';
COMMENT ON PROCEDURE pr_max_peer_xp IS 'The procedure determines the peer with the most XP';
COMMENT ON PROCEDURE pr_max_task_check IS 'The procedure determines the most frequently checked task for each day';
COMMENT ON PROCEDURE pr_p2p_check IS 'The procedure adds P2P verification. If the status is set to "start", will add a record to the Checks table (today date will be used)';
COMMENT ON PROCEDURE pr_peer_xp_sum IS 'The procedure determines the amount of XP received in total by each peer';
COMMENT ON PROCEDURE pr_points_change IS 'The procedure calculates the change in the number of peer points of each peer according to the TransferredPoints table';
COMMENT ON PROCEDURE pr_remove_table IS 'The stored procedure destroys all those tables in the current database whose names begin with TableName';
COMMENT ON PROCEDURE pr_show_info IS 'A stored procedure that displays the names and descriptions of the type of objects (only stored procedures and scalar functions), in the SQL text of which the string specified by the procedure parameter occurs';
COMMENT ON PROCEDURE pr_success_percent IS 'The procedure finds the percentage of successful and unsuccessful checks for the entire time';
COMMENT ON PROCEDURE pr_time_spent IS 'The procedure determines peers that arrived before a given time at least N times over the entire time';
COMMENT ON PROCEDURE pr_transferred_points IS 'The procedure calculates the change in the number of peer points of each peer according to the table returned by the fnc_transferred_points function';
COMMENT ON PROCEDURE pr_verter_check IS 'The procedure adds Verter checks';