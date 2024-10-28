COMMENT ON FUNCTION fnc_check_date IS 'A function that identifies peers who have not left campus all day';
COMMENT ON FUNCTION fnc_count_parent_tasks IS 'The function displays the number of tasks preceding it, that is, how many tasks need to be completed, based on the entry conditions, in order to gain access to the current one';
COMMENT ON FUNCTION fnc_early_entry IS 'The function determines for each month the percentage of early entries: how many times people born in this month came to campus for the entire time, how many times people born in this month came to campus before 12:00 for all time, the percentage of early entries to campus relative to the total number of entrances.';
COMMENT ON FUNCTION fnc_interval IS 'The function determines peers who left campus yesterday for more than N minutes';
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
COMMENT ON FUNCTION to_minutes IS ''; -- Вспомогательная функция!
COMMENT ON FUNCTION fnc_transferred_points_after_p2p_start IS ''; -- Проблема! Возможно вспомогательная функция. Используется в триггерах
COMMENT ON FUNCTION fnc_xp IS ''; -- Проблема! Возможно вспомогательная функция. Используется в триггерах