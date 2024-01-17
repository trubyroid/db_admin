from controller.page_class import Page, PageData, PageFunc
from model.utils import formatting_update_vals
from settings import db
from psycopg2 import sql
from loguru import logger


def get_result_table(page: Page):
    """Получает колонны и данные"""
    page.set_return_mode(True)
    get_columns_names(page)
    select_table(page)


def get_columns_names(page: Page) -> None:
    """Получает названия столбцов в таблице"""

    if page.table_name not in ("custom_table", "func_result"):
        select = "SELECT column_name \
                  FROM information_schema.columns \
                  WHERE table_name = {tbl} \
                    AND table_schema = 'public';"
    else:
        select = "SELECT attname \
                  FROM pg_attribute \
                  WHERE attrelid = {tbl} \
                    ::regclass AND attnum > 0"

    query = sql.SQL(select).format(tbl=sql.Placeholder())
    params = (page.table_name,)
    
    result = db.query_execute(page, query, params)
    page.set_columns_names(result)


def get_tables_names(pd: Page) -> None:
    """Получает названия всех таблиц"""
    query = sql.SQL("SELECT table_name \
                    FROM information_schema.tables \
                    WHERE table_schema='public' \
                        AND table_type='BASE TABLE' \
                        AND table_name NOT IN ('custom_table', 'func_result');")

    result = db.query_execute(pd, query)
    pd.set_tables_names(result)


def get_funcs(pd: PageFunc) -> None:
    """Получает данные о хранимых функциях"""
    query = sql.SQL("SELECT p.prokind, p.proname,"
                "p.proargnames,p.proargmodes,"
                "oidvectortypes(p.proargtypes) "
                "FROM pg_catalog.pg_namespace n "
                "JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid "
                "WHERE n.nspname = 'public';")

    pd.funcs_data = sorted(db.query_execute(pd, query), reverse=True)


def select_table(pd: Page) -> None:
    """Вывод всех записей таблицы"""
    query = sql.SQL("SELECT * FROM {tbl};").format(
        tbl=sql.Identifier(pd.table_name))

    logger.info(f"The table {pd.table_name} was requested.")
    pd.set_table_data(sorted(db.query_execute(pd, query)))


def insert_row(pd: Page, params: tuple) -> None:
    """Создание новой записи"""
    query = sql.SQL("INSERT INTO {table} VALUES ({vals})").format(
        table=sql.Identifier(pd.table_name),
        vals=sql.SQL(', ').join(sql.Placeholder() * len(params)))

    logger.info(f"New row in '{pd.table_name}' was created.")
    db.query_execute(pd, query, params)


def update_row(pd: PageData, keys: list, params: tuple) -> None:
    """Изменение записи"""
    kwargs = formatting_update_vals(keys)

    query = sql.SQL("UPDATE {tbl} "
                    "SET {kwrgs} "
                    "WHERE {pk} = {pv};").format(
        tbl=sql.Identifier(pd.table_name),
        kwrgs=sql.Composed(kwargs),
        pk=sql.Identifier(pd.pk),
        pv=sql.Placeholder()
    )

    logger.info(f"The row '{params[-1]}' in '{pd.table_name}' was updated.")
    db.query_execute(pd, query, params)


def delete_row(pd: PageData, params: tuple) -> None:
    """Удаление записи"""
    query = sql.SQL("DELETE FROM {tbl} WHERE {pk} = {pv};").format(
        tbl=sql.Identifier(pd.table_name),
        pk=sql.Identifier(pd.pk),
        pv=sql.Placeholder())

    logger.info(f"The row '{params[0]}' from table '{pd.table_name}' was deleted.")
    db.query_execute(pd, query, params)


def call_procedure(page: Page, params: tuple) -> None:
    """Вызов процедуры"""
    query = sql.SQL("CALL {proc}({args});").format(
        proc=sql.Identifier(page.proc_name),
        args=sql.SQL(', ').join([sql.Placeholder() for i in range(len(params))])
    )
    return db.query_execute(page, query, params)


def truncate_cascade(pd: PageData) -> None:
    """Очистка таблицы для импорта"""
    query = sql.SQL("TRUNCATE {tbl} CASCADE;").format(
        tbl=sql.Identifier(pd.table_name))

    db.query_execute(pd, query)


def drop_tmp_table(pd: Page) -> None:
    """Удаление пользовательской таблицы"""
    query = sql.SQL("DROP TABLE IF EXISTS {tbl};").format(
    tbl=sql.Identifier(pd.table_name)
    )

    db.query_execute(pd, query)


def use_function(pf: PageFunc, params: tuple):
    """Формирует запрос для создания пользовательской таблицы
    с результатом работы вызванной функции"""
    query = sql.SQL("CREATE TEMPORARY TABLE {tbl} AS "
                    "SELECT * FROM {func}({args});").format(
        tbl=sql.Identifier(pf.table_name),
        func=sql.Identifier(pf.func_name),
        args=sql.SQL(', ').join([sql.Placeholder() for i in range(len(params))])
    )

    logger.info(f"The function {pf.func_name} was called.")
    db.query_execute(pf, query, params)


def create_as_select(pd: Page, select_query: str, params: tuple = None):
    """Создает временную таблицу на основе пользовательского запроса"""
    create_new = "CREATE TEMPORARY TABLE {} AS"
    query = " ".join([create_new, select_query])

    query = sql.SQL(query).format(
        sql.Identifier(pd.table_name)
    )

    db.query_execute(pd, query, params)


def insert_updated_table(pd: Page, updated_table: str):
    """Перенос таблицы с обновленными данными во временную таблицу"""
    query = sql.SQL("CREATE TABLE {cstm_tbl} AS "
                    "SELECT * FROM {updtd_tbl};").format(
         cstm_tbl=sql.Identifier(pd.table_name),
         updtd_tbl=sql.Identifier(updated_table)
    )

    db.query_execute(pd, query)


def get_func_description(pf: PageFunc, func_name: str):
    """Получение описания функции"""
    query = sql.SQL("SELECT description "
                    "FROM pg_description "
                    "WHERE objoid = {fnc} :: regproc;").format(
        fnc=sql.Placeholder()
    )
    params = (func_name,)
    description = db.query_execute(pf, query, params)
    return pf.description_handler(description)


def call_ref_procedure(pf: PageFunc, params: tuple) -> None:
    """Вызов процедуры с результатом в курсоре"""
    query = sql.SQL("CALL {proc}({args}); FETCH ALL IN ref;").format(
        proc=sql.Identifier(pf.proc_name),
        args=sql.SQL(', ').join([sql.Placeholder() for i in range(len(params))])
    )

    logger.info(f"The procedure {pf.proc_name} was called.")
    pf.set_data(db.query_execute(pf, query, params))


def create_ref_table(pf: PageFunc):
    """Создание временной таблицы на основе данных из курсора"""
    query = sql.SQL("CREATE TEMPORARY TABLE {tbl}({clmns} varchar);").format(
        tbl=sql.Identifier(pf.table_name),
        clmns=sql.SQL(' varchar, ').join([sql.Identifier(col) for col in pf.ref_columns])
    )

    db.query_execute(pf, query, pf.ref_columns)


def insert_ref_values(pf: PageFunc):
    """Формирование запроса на внесение данных из курсора во временную таблицу"""
    if not pf.ref_data:
        return

    params = list(pf.ref_data[0])
    query = sql.SQL("INSERT INTO {table} VALUES ({args})").format(
        table=sql.Identifier(pf.table_name),
        args=sql.SQL(', ').join(sql.Placeholder() * len(params))
    )

    for row in pf.ref_data[1:]:
        val = sql.SQL("({args})").format(
            args=sql.SQL(', ').join(sql.Placeholder() * len(row))
        )
        query = sql.SQL(",").join((query, val))
        params.extend(row)

    query = sql.SQL("").join((query, sql.SQL(";")))

    db.query_execute(pf, query, params)
