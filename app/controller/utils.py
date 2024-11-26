import re

from loguru import logger

from controller.page_class import Page, PageData


def not_select(que: str):
    return all(map(lambda x: not que.startswith(x), ["SELECT", "WITH"]))


def get_changed_table(page_data: PageData, query: str) -> str:
    """Функция для поиска имени таблицы в не SELECT запросе"""
    pattern = r"(?:INTO|FROM|UPDATE|TABLE)\s+([\w]+)\s*"

    match = re.search(pattern, query, re.IGNORECASE)

    if re.search(pattern, query, re.IGNORECASE):
        table_name = match.group(1)
        return f"SELECT * FROM {table_name};"
    else:
        logger.info("Invalid query was requested.")
        page_data.set_error("ERROR: invalid query.")
        return ""


def query_check(page_data: PageData, query: str) -> bool:
    """Первичная проверка пользовательского запроса"""

    if not query.endswith(";") or query.startswith("SELECT") and "FROM" not in query:
        logger.info("Invalid query was requested.")
        page_data.set_error("ERROR: invalid query.")
        return False

    if query.count(";") > 1:
        logger.info("Invalid query was requested.")
        page_data.set_error("ERROR: you can enter only one query.")
        return False

    # if any(map(lambda x: x in query, ["DROP", "TRUNCATE"])):
    #     logger.warning(
    #         "Somebody tried to delete or truncate the table by custom query."
    #     )
    #     page_data.set_error("ERROR: you cannot delete or clear the table.")
    #     return False

    return True
